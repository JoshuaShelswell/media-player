// rust-engine/src/audio/mod.rs

//! Top‑level module definitions for the `audio` crate.

pub mod buffer;
pub mod decoder;
pub mod device;
pub mod diagnostics;
pub mod position;
pub mod state;

// We only re‑export what our `lib.rs` actually uses.
// All other public items (e.g. AudioRingBuffer, PlayerState, etc.)
// are re‑exported from the root `lib.rs`.

// No `pub use buffer::AudioRingBuffer;` here
// No `pub use position::PlaybackPosition;` here
// No `pub use state::{PlayerState, PlaybackStatus};` here
// No `pub use decoder::{initialize_ffmpeg, ... , play_audio_file};` here
