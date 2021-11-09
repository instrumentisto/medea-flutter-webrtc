use std::time::{SystemTime, UNIX_EPOCH};

use libwebrtc_sys::system_time_millis;

#[test]
fn it_works() {
    let millis_from_rust = SystemTime::now
        .duration_since(UNIX_EPOCH)
        .expect("Time went backwards");

    assert!((millis_from_rust - millis_from_cpp).abs() < 1000);
}
