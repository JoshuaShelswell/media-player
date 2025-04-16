// media-player-project/rust-engine/tests/integration_test.rs
#[cfg(test)]
mod tests {
    use std::ffi::CString;
    use rust_engine::{play_audio, control_bluetooth};

    #[test]
    fn test_play_audio() {
        let track = CString::new("example_track.mp3").unwrap();
        play_audio(track.as_ptr());
    }

    #[test]
    fn test_control_bluetooth() {
        let command = CString::new("play").unwrap();
        control_bluetooth(command.as_ptr());
    }
}
