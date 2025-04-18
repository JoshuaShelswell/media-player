// rust-engine/src/lib.rs

mod audio;

use std::ffi::CStr;
use std::os::raw::c_char;

// Re-export core APIs (but *not* `play_audio_file`—we’ll expose that by name below).
pub use audio::buffer::AudioRingBuffer;
pub use audio::decoder::{initialize_ffmpeg, get_supported_extensions, is_supported_audio_format};
pub use audio::position::PlaybackPosition;
pub use audio::state::{PlayerState, PlaybackStatus};

/// FFI entrypoint for playing a track.
/// Exported as `play_audio_file` so your Flutter code can `DynamicLibrary.lookup("play_audio_file")`.
#[no_mangle]
pub extern "C" fn play_audio_file(file_path: *const c_char) -> i32 {
    let path = unsafe {
        if file_path.is_null() {
            return -1; // null pointer
        }
        match CStr::from_ptr(file_path).to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return -2, // invalid UTF-8
        }
    };

    use std::sync::{Arc, Mutex, atomic::AtomicBool};
    use audio::decoder::play_audio_file as decoder_play;

    let pause_flag = Arc::new(AtomicBool::new(false));
    let stop_flag  = Arc::new(AtomicBool::new(false));
    let state      = Arc::new(Mutex::new(PlayerState::default()));
    let position   = Arc::new(Mutex::new(PlaybackPosition::new(44_100)));
    let volume     = Arc::new(Mutex::new(1.0_f32));

    match decoder_play(&path, pause_flag, stop_flag, state, position, volume) {
        Ok(_) => 0,
        Err(_) => -3,
    }
}

/// FFI stub for stopping playback (Flutter expects `stop_audio`).
/// You can wire this up to your `stop_flag`/`state` if you hold them somewhere globally.
#[no_mangle]
pub extern "C" fn stop_audio() -> i32 {
    // TODO: signal your decoder's stop_flag here
    0
}
