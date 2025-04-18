// rust-engine/src/lib.rs

mod audio;
pub use audio::buffer::AudioRingBuffer;
pub use audio::decoder::{initialize_ffmpeg, get_supported_extensions, is_supported_audio_format};
pub use audio::position::PlaybackPosition;
pub use audio::state::{PlayerState, PlaybackStatus};

use std::{
    ffi::CStr,
    os::raw::c_char,
    sync::{
        Arc,
        atomic::{AtomicBool, Ordering},
        Once,
        Mutex,
    },
};
use audio::decoder::play_audio_file as decoder_play;

// ————————————————————————————————————————————————————————————
// GLOBALS FOR FLAGS & POSITION
// ————————————————————————————————————————————————————————————
static INIT: Once = Once::new();
static mut PAUSE_FLAG: Option<Arc<AtomicBool>>              = None;
static mut STOP_FLAG:  Option<Arc<AtomicBool>>              = None;
static mut POSITION:   Option<Arc<Mutex<PlaybackPosition>>> = None;

fn init_globals() {
    INIT.call_once(|| unsafe {
        PAUSE_FLAG = Some(Arc::new(AtomicBool::new(false)));
        STOP_FLAG  = Some(Arc::new(AtomicBool::new(false)));
        // seed POSITION with a dummy; real one set on each play
        POSITION   = Some(Arc::new(Mutex::new(PlaybackPosition::new(44_100))));
    });
}

#[no_mangle]
pub extern "C" fn play_audio_file(file_path: *const c_char) -> i32 {
    init_globals();

    // convert path
    let path = unsafe {
        if file_path.is_null() { return -1; }
        match CStr::from_ptr(file_path).to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return -2,
        }
    };

    // clone and reset flags
    let pause = unsafe { PAUSE_FLAG.as_ref().unwrap().clone() };
    let stop  = unsafe { STOP_FLAG.as_ref().unwrap().clone() };
    pause.store(false, Ordering::SeqCst);
    stop.store(false, Ordering::SeqCst);

    // create a fresh Position and stash globally
    let pos = Arc::new(Mutex::new(PlaybackPosition::new(44_100)));
    unsafe { POSITION = Some(pos.clone()) };

    // local state & volume
    let state  = Arc::new(Mutex::new(PlayerState::default()));
    let volume = Arc::new(Mutex::new(1.0_f32));

    // hand off to decoder; this blocks until end or stop_flag
    match decoder_play(&path, pause, stop, state, pos, volume) {
        Ok(_)  => 0,
        Err(_) => -3,
    }
}

#[no_mangle]
pub extern "C" fn pause_audio_file() {
    init_globals();
    unsafe {
        if let Some(f) = &PAUSE_FLAG {
            f.store(true, Ordering::SeqCst);
        }
    }
}

#[no_mangle]
pub extern "C" fn resume_audio_file() {
    init_globals();
    unsafe {
        if let Some(f) = &PAUSE_FLAG {
            f.store(false, Ordering::SeqCst);
        }
    }
}

#[no_mangle]
pub extern "C" fn stop_audio() -> i32 {
    init_globals();
    unsafe {
        if let Some(f) = &STOP_FLAG {
            f.store(true, Ordering::SeqCst);
        }
    }
    0
}

#[no_mangle]
pub extern "C" fn get_position_seconds() -> f32 {
    init_globals();
    unsafe {
        POSITION
            .as_ref()
            .map(|p| p.lock().unwrap().position().as_secs_f32())
            .unwrap_or(0.0)
    }
}

#[no_mangle]
pub extern "C" fn get_duration_seconds() -> f32 {
    init_globals();
    unsafe {
        POSITION
            .as_ref()
            .map(|p| p.lock().unwrap().duration().as_secs_f32())
            .unwrap_or(0.0)
    }
}
