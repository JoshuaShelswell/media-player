// media-player/core/src/network/server.rs

use tokio::net::{TcpListener, TcpStream};
use tokio::sync::mpsc;
use tokio_tungstenite::{accept_async, WebSocketStream};
use futures::StreamExt;
use serde::{Deserialize, Serialize};
use tokio::time::{sleep, Duration};

// Additional imports to resolve missing symbols:
use tungstenite::accept; // for the synchronous branch later
use tungstenite::Message;

#[derive(Serialize, Deserialize)]
pub enum Command {
    Play(String),
    Pause,
    Next,
    Previous,
    SetVolume(f32),
    Seek(f32),
    LoadPlaylist(u32),
    GetLibraryContents,
}

#[derive(Serialize, Deserialize)]
pub enum Event {
    TrackChanged { title: String, artist: String, duration: f64, position: f64 },
    PlaybackStateChanged { is_playing: bool },
    VolumeChanged(f32),
    PlaylistsUpdated(Vec<PlaylistInfo>),
}

#[derive(Serialize, Deserialize)]
pub struct PlaylistInfo {
    pub id: u32,
    pub name: String,
    pub track_count: usize,
}

pub struct RemoteServer {
    pub command_tx: mpsc::Sender<Command>,
    pub event_rx: mpsc::Receiver<Event>,
}

impl RemoteServer {
    pub fn new() -> Self {
        let (command_tx, _command_rx) = mpsc::channel(100);
        let (_event_tx, event_rx) = mpsc::channel(100);
        Self { command_tx, event_rx }
    }

    pub async fn start(&mut self, port: u16) -> Result<(), Box<dyn std::error::Error>> {
        let addr = format!("0.0.0.0:{}", port);
        let listener = TcpListener::bind(&addr).await?;
        println!("WebSocket server listening on {}", addr);

        while let Ok((stream, _)) = listener.accept().await {
            let tx = self.command_tx.clone();
            tokio::spawn(async move {
                if let Err(e) = RemoteServer::handle_connection(stream, tx).await {
                    eprintln!("Connection error: {}", e);
                }
            });
        }
        Ok(())
    }

    async fn handle_connection(stream: TcpStream, command_tx: mpsc::Sender<Command>)
        -> Result<(), Box<dyn std::error::Error>>
    {
        let ws_stream = accept_async(stream).await?;
        println!("New WebSocket connection established");
        RemoteServer::process_socket(ws_stream, command_tx).await;
        Ok(())
    }

    async fn process_socket(
        ws_stream: WebSocketStream<TcpStream>,
        command_tx: mpsc::Sender<Command>
    ) {
        let (_ws_sender, mut ws_receiver) = ws_stream.split();

        let mut recv_task = tokio::spawn(async move {
            while let Some(Ok(msg)) = ws_receiver.next().await {
                if let Ok(text) = msg.into_text() {
                    if let Ok(cmd) = serde_json::from_str::<Command>(&text) {
                        let _ = command_tx.send(cmd).await;
                    }
                }
            }
        });

        let mut event_task = tokio::spawn(async move {
            sleep(Duration::from_secs(3600)).await;
        });

        tokio::select! {
            _ = &mut recv_task => { event_task.abort(); },
            _ = &mut event_task => { recv_task.abort(); },
        }
    }
}

// Update the synchronous branch to use a Tokio runtime and async APIs.
// This function is used by FFI (via player_init) to start a basic WebSocket server.
pub fn websocket_server_thread(port: u16) {
    let rt = tokio::runtime::Runtime::new().unwrap();
    rt.block_on(async {
        let listener = TcpListener::bind(("0.0.0.0", port))
            .await
            .expect("Failed to bind WebSocket port");
        println!("(Synchronous branch) WebSocket server listening on 0.0.0.0:{}", port);
        while let Ok((stream, _)) = listener.accept().await {
            tokio::spawn(async move {
                if let Ok(ws_stream) = accept_async(stream).await {
                    println!("New WebSocket client connected (synchronous branch)");
                    sleep(Duration::from_secs(3600)).await;
                }
            });
        }
    });
}
