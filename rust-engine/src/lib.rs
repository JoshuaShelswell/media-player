// media-player-project/rust-engine/src/lib.rs
mod audio;
mod bluetooth;

use std::os::raw::c_char;
use std::ffi::CStr;

/// FFI function to play audio using ffmpeg and cpal.
/// Expects a pointer to a null-terminated UTF-8 string (track path or name).
#[no_mangle]
pub extern "C" fn play_audio(track_ptr: *const c_char) {
    unsafe {
        let c_str = CStr::from_ptr(track_ptr);
        let track = c_str.to_str().expect("Invalid UTF-8 string");
        println!("Rust Engine: Playing track '{}'", track);
        audio::player::play(track);
    }
}

/// FFI function to handle Bluetooth commands.
/// Expects a pointer to a null-terminated UTF-8 string with the command.
#[no_mangle]
pub extern "C" fn control_bluetooth(command_ptr: *const c_char) {
    unsafe {
        let c_str = CStr::from_ptr(command_ptr);
        let command = c_str.to_str().expect("Invalid UTF-8 string");
        println!("Rust Engine: Received Bluetooth command '{}'", command);
        bluetooth::controller::handle_command(command);
    }
}
