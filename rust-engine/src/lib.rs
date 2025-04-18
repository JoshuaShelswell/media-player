// rust-engine/src/lib.rs


mod audio;
pub use audio::buffer::AudioRingBuffer;
pub use audio::decoder::{initialize_ffmpeg, get_supported_extensions, is_supported_audio_format};
pub use audio::position::PlaybackPosition;
pub use audio::state::{PlayerState, PlaybackStatus};

use std::ffi::CStr;
use std::os::raw::c_char;
use std::sync::{Arc, atomic::{AtomicBool, Ordering}, Once, Mutex};

use audio::decoder::play_audio_file as decoder_play;

// ————————————————————————————————————————————————————————————
// GLOBAL FLAGS (shared across FFI calls and your decoder’s loop)
// ————————————————————————————————————————————————————————————
static INIT: Once = Once::new();
static mut PAUSE_FLAG: Option<Arc<AtomicBool>> = None;
static mut STOP_FLAG:  Option<Arc<AtomicBool>> = None;

fn init_flags() {
    INIT.call_once(|| {
        unsafe {
            PAUSE_FLAG = Some(Arc::new(AtomicBool::new(false)));
            STOP_FLAG  = Some(Arc::new(AtomicBool::new(false)));
        }
    });
}

#[no_mangle]
pub extern "C" fn play_audio_file(file_path: *const c_char) -> i32 {
    // ensure our globals exist
    init_flags();

    // validate & convert C string
    let path = unsafe {
        if file_path.is_null() { return -1; }
        match CStr::from_ptr(file_path).to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return -2,
        }
    };

    // grab clones of our shared flags
    let pause = unsafe { PAUSE_FLAG.as_ref().unwrap().clone() };
    let stop  = unsafe { STOP_FLAG.as_ref().unwrap().clone() };

    // reset them for a fresh play
    pause.store(false, Ordering::SeqCst);
    stop.store(false, Ordering::SeqCst);

    // local state/position/volume (same as your old stub)
    let state    = Arc::new(Mutex::new(PlayerState::default()));
    let position = Arc::new(Mutex::new(PlaybackPosition::new(44_100)));
    let volume   = Arc::new(Mutex::new(1.0_f32));

    // hand off to your decoder loop (this will block until end or stop_flag)
    match decoder_play(&path, pause, stop, state, position, volume) {
        Ok(_)  => 0,
        Err(_) => -3,
    }
}

#[no_mangle]
pub extern "C" fn pause_audio_file() {
    init_flags();
    // flip the decoder’s pause flag on
    unsafe {
        if let Some(f) = &PAUSE_FLAG {
            f.store(true, Ordering::SeqCst);
        }
    }
}

#[no_mangle]
pub extern "C" fn resume_audio_file() {
    init_flags();
    // flip the decoder’s pause flag off
    unsafe {
        if let Some(f) = &PAUSE_FLAG {
            f.store(false, Ordering::SeqCst);
        }
    }
}

#[no_mangle]
pub extern "C" fn stop_audio() -> i32 {
    init_flags();
    // signal the decoder’s stop flag
    unsafe {
        if let Some(f) = &STOP_FLAG {
            f.store(true, Ordering::SeqCst);
        }
    }
    0
}