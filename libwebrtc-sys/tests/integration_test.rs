use std::{thread::sleep, time::Duration};

use libwebrtc_sys::system_time_millis;

#[test]
fn it_works() {
    let a: i32 = system_time_millis().parse().unwrap();
    sleep(Duration::from_secs(1));
    let b: i32 = system_time_millis().parse().unwrap();

    assert!((a - b).abs() < 1500);
}
