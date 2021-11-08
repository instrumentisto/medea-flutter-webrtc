use std::thread::sleep_ms;

use libwebrtc_sys::system_time_millis;

#[test]
fn it_works() {
    let a: i32 = system_time_millis().parse().unwrap();
    sleep_ms(2000);
    let b: i32 = system_time_millis().parse().unwrap();

    assert!((a - b) < 3000);
}
