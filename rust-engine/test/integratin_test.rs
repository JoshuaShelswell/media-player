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

    fn test_play_audio_file() {
        let test_file = CString::new("test_data/sample.mp3").unwrap();
        let result = play_audio_file_ffi(test_file.as_ptr());
        // Assuming 0 is success.
        assert_eq!(result, 0);
    }

    #[test]
    fn test_control_bluetooth() {
        let command = CString::new("play").unwrap();
        control_bluetooth(command.as_ptr());
    }
}
