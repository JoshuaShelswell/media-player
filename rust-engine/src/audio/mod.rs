// rust-engine/src/audio/mod.rs

pub mod buffer;
pub mod decoder;
pub mod device;
pub mod diagnostics;
pub mod position;
pub mod resampler;
pub mod state;

// Re-export key types for convenience
pub use buffer::AudioRingBuffer;
pub use position::PlaybackPosition;
pub use state::{PlayerState, PlaybackStatus};

// You may also choose to re-export decoder functions if needed:
pub use decoder::{initialize_ffmpeg, get_supported_extensions, is_supported_audio_format, play_audio_file};
