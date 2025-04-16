// rust-engine/src/audio/state.rs

use std::time::Duration;

#[derive(Default)]
pub enum PlaybackStatus {
    #[default]
    Stopped,
    Playing,
    Paused,
}

#[derive(Default)]
pub struct PlayerState {
    pub duration: Option<Duration>,
    pub track_completed: bool,
    pub status: PlaybackStatus,
    pub network_buffering: bool,
    pub buffer_progress: f32,
}

// (Add additional fields and methods as needed.)
