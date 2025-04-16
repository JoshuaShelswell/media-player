// rust-engine/src/lib.rs

mod audio;

use std::ffi::{CStr, CString};
use std::os::raw::c_char;

// Re-export items from the audio module if desired.
pub use audio::buffer::AudioRingBuffer;
pub use audio::decoder::{initialize_ffmpeg, get_supported_extensions, is_supported_audio_format, play_audio_file};
pub use audio::position::PlaybackPosition;
pub use audio::state::{PlayerState, PlaybackStatus};

#[no_mangle]
pub extern "C" fn play_audio_file_ffi(file_path: *const c_char) -> i32 {
    // Convert the incoming C string into a Rust string.
    let path = unsafe {
        if file_path.is_null() {
            return -1; // Error code for null pointer.
        }
        match CStr::from_ptr(file_path).to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return -2, // Conversion error.
        }
    };

    // Create or initialize necessary flags, state, and other parameters.
    // For real use, you likely want to manage these over multiple calls.
    use std::sync::{Arc, Mutex, atomic::AtomicBool};
    use audio::decoder::play_audio_file;

    // We create dummy flags and state here.
    let pause_flag = Arc::new(AtomicBool::new(false));
    let stop_flag = Arc::new(AtomicBool::new(false));
    let state = Arc::new(Mutex::new(PlayerState::default()));
    let playback_position = Arc::new(Mutex::new(PlaybackPosition::new(44100)));
    let volume = Arc::new(Mutex::new(1.0_f32));

    // Call the play function from the decoder module.
    // This function should already be implemented in your old code.
    match play_audio_file(
        &path,
        pause_flag,
        stop_flag,
        state,
        playback_position,
        volume,
    ) {
        Ok(_) => 0,  // Success
        Err(_) => -3, // Failure launching playback
    }
}
