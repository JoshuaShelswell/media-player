use std::env;
use std::ffi::CString;
use media_player_core::{player_init, player_open_file};

fn main() {
    // Initialize the backend (FFmpeg, player, etc.)
    if !unsafe { player_init() } {
        eprintln!("Failed to initialize media player backend.");
        return;
    }

    // Check if a file path was provided as a command-line argument.
    let args: Vec<String> = env::args().collect();
    if args.len() > 1 {
        let c_path = CString::new(args[1].clone()).unwrap();
        unsafe {
            if player_open_file(c_path.as_ptr()) {
                println!("Playing {}...", args[1]);
            } else {
                eprintln!("Failed to open file: {}", args[1]);
            }
        }
    }

    println!("Media player running. Press Ctrl+C to exit.");

    // Keep the process alive.
    std::thread::park();
}
