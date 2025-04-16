// media-player/core/src/lib.rs

mod audio;
mod playlist;
mod library;
mod player;
mod network;
mod ffi;

// Publicly re-export the FFI functions for Flutter integration.
pub use ffi::*;
