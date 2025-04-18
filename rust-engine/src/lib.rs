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
// GLOBALS FOR FLAGS, POSITION & VOLUME
// ————————————————————————————————————————————————————————————
static INIT:   Once                              = Once::new();
static mut PAUSE_FLAG: Option<Arc<AtomicBool>>     = None;
static mut STOP_FLAG:  Option<Arc<AtomicBool>>     = None;
static mut POSITION:   Option<Arc<Mutex<PlaybackPosition>>> = None;
static mut VOLUME:     Option<Arc<Mutex<f32>>>     = None;

fn init_globals() {
    INIT.call_once(|| unsafe {
        PAUSE_FLAG = Some(Arc::new(AtomicBool::new(false)));
        STOP_FLAG  = Some(Arc::new(AtomicBool::new(false)));
        // Seed POSITION & VOLUME; real ones set on play().
        POSITION   = Some(Arc::new(Mutex::new(PlaybackPosition::new(44_100))));
        VOLUME     = Some(Arc::new(Mutex::new(1.0)));
    });
}

#[no_mangle]
pub extern "C" fn play_audio_file(file_path: *const c_char) -> i32 {
    init_globals();

    // Convert C string to Rust String
    let path = unsafe {
        if file_path.is_null() { return -1; }
        match CStr::from_ptr(file_path).to_str() {
            Ok(s) => s.to_owned(),
            Err(_) => return -2,
        }
    };

    // Clone & reset flags
    let pause = unsafe { PAUSE_FLAG.as_ref().unwrap().clone() };
    let stop  = unsafe { STOP_FLAG.as_ref().unwrap().clone() };
    pause.store(false, Ordering::SeqCst);
    stop.store(false,  Ordering::SeqCst);

    // Fresh POSITION & VOLUME for this session
    let pos = Arc::new(Mutex::new(PlaybackPosition::new(44_100)));
    unsafe { POSITION = Some(pos.clone()) };
    let vol = Arc::new(Mutex::new(1.0_f32));
    unsafe { VOLUME = Some(vol.clone()) };

    // Local player state
    let state = Arc::new(Mutex::new(PlayerState::default()));

    // Hand off to decoder; blocks until end or stop_flag
    match decoder_play(&path, pause, stop, state, pos, vol) {
        Ok(_)  => 0,
        Err(_) => -3,
    }
}

#[no_mangle]
pub extern "C" fn pause_audio_file() {
    init_globals();
    unsafe { PAUSE_FLAG.as_ref().unwrap().store(true, Ordering::SeqCst); }
}

#[no_mangle]
pub extern "C" fn resume_audio_file() {
    init_globals();
    unsafe { PAUSE_FLAG.as_ref().unwrap().store(false, Ordering::SeqCst); }
}

#[no_mangle]
pub extern "C" fn stop_audio() -> i32 {
    init_globals();
    unsafe { STOP_FLAG.as_ref().unwrap().store(true, Ordering::SeqCst); }
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

// ————————————————————————————————————————————————————————————
// VOLUME CONTROL
// ————————————————————————————————————————————————————————————

/// Set playback volume (0.0–1.0).
#[no_mangle]
pub extern "C" fn set_volume(level: f32) {
    init_globals();
    unsafe {
        if let Some(vol_arc) = &VOLUME {
            if let Ok(mut vol_lock) = vol_arc.lock() {
                *vol_lock = level.clamp(0.0, 1.0);
                eprintln!("⚙️ volume set to {}", *vol_lock);
            }
        }
    }
}

// ————————————————————————————————————————————————————————————
// SEEK CONTROL
// ————————————————————————————————————————————————————————————

/// Seek playback to absolute [seconds].
#[no_mangle]
pub extern "C" fn seek_audio(target_sec: f32) {
    init_globals();
    unsafe {
        if let (Some(pos_arc), Some(dur_s)) = (
            &POSITION,
            POSITION.as_ref().map(|p| p.lock().unwrap().duration().as_secs_f32()),
        ) {
            let duration = dur_s.max(0.0001);
            let fraction = (target_sec / duration).clamp(0.0, 1.0);
            if let Ok(mut pos_lock) = pos_arc.lock() {
                pos_lock.request_seek(fraction);
                eprintln!("⏩ seek requested to {:.4} ({:.2}%)", fraction, fraction*100.0);
            }
        }
    }
}
