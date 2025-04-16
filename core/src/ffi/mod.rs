// media-player/core/src/ffi/mod.rs

use std::ffi::CStr;
use std::os::raw::{c_char, c_void};
use std::thread;
use std::sync::Mutex;

use crate::player::Player;
use crate::network::server::RemoteServer;

// For this minimal prototype we use global singleton pointers.
// In production, use safer dependency injection patterns.
static mut PLAYER_INSTANCE: Option<Mutex<Player>> = None;
static mut REMOTE_SERVER_INSTANCE: Option<Mutex<RemoteServer>> = None;

#[no_mangle]
pub extern "C" fn player_init() -> bool {
    // Initialize FFmpeg (if needed, add extra FFmpeg init code here)
    // Start the WebSocket server on port 3000 in a background thread
    thread::spawn(move || {
        crate::network::server::websocket_server_thread(3000);
    });
    true
}

#[no_mangle]
pub extern "C" fn player_open_file(path: *const c_char) -> bool {
    if path.is_null() {
        return false;
    }
    let c_str = unsafe { CStr::from_ptr(path) };
    if let Ok(path_str) = c_str.to_str() {
        // For now, we use a dummy implementation.
        // In production, call your FFmpeg/CPAL integration here.
        println!("Opening file: {}", path_str);
        unsafe {
            // Initialize the player instance if not already set.
            if PLAYER_INSTANCE.is_none() {
                PLAYER_INSTANCE = Some(Mutex::new(Player::new()));
            }
        }
        true
    } else {
        false
    }
}

#[no_mangle]
pub extern "C" fn player_play() {
    let player = unsafe { PLAYER_INSTANCE.as_ref() }.unwrap().lock().unwrap();
    // Dummy implementation: simply log.
    println!("Playing (via FFI)...");
}

#[no_mangle]
pub extern "C" fn player_pause() {
    let player = unsafe { PLAYER_INSTANCE.as_ref() }.unwrap().lock().unwrap();
    println!("Pausing (via FFI)...");
}

#[no_mangle]
pub extern "C" fn player_stop() {
    println!("Stopping (via FFI)...");
}

#[no_mangle]
pub extern "C" fn player_get_position() -> f64 {
    // Return dummy value
    0.0
}

#[no_mangle]
pub extern "C" fn player_get_duration() -> f64 {
    // Return dummy value
    0.0
}

#[no_mangle]
pub extern "C" fn player_get_state() -> u8 {
    // 0 = stopped, 1 = playing, 2 = paused.
    0
}

#[no_mangle]
pub extern "C" fn player_get_track_title() -> *const c_char {
    static mut TITLE_CSTRING: Option<std::ffi::CString> = None;
    let title = "Demo Track";
    let cstr = std::ffi::CString::new(title).unwrap();
    unsafe {
        TITLE_CSTRING = Some(cstr);
        TITLE_CSTRING.as_ref().unwrap().as_ptr()
    }
}

#[no_mangle]
pub extern "C" fn player_get_local_ip() -> *const c_char {
    static mut LOCAL_IP: Option<std::ffi::CString> = None;
    let ip = "192.168.1.100"; // Replace with dynamic IP detection as needed.
    let cstr = std::ffi::CString::new(ip).unwrap();
    unsafe {
        LOCAL_IP = Some(cstr);
        LOCAL_IP.as_ref().unwrap().as_ptr()
    }
}

#[no_mangle]
pub extern "C" fn start_remote_server(port: i32) -> bool {
    let server = RemoteServer::new();
    let boxed_server = Box::new(server);
    let ptr = Box::into_raw(boxed_server);
    unsafe {
        REMOTE_SERVER_INSTANCE = Some(Mutex::new(*Box::from_raw(ptr)));
    }
    thread::spawn(move || {
        let runtime = tokio::runtime::Runtime::new().unwrap();
        runtime.block_on(async {
            unsafe {
                if let Some(ref server_mutex) = REMOTE_SERVER_INSTANCE {
                    let mut server = server_mutex.lock().unwrap();
                    let _ = server.start(port as u16).await;
                }
            }
        });
    });
    true
}
