use libwebrtc_sys::system_time_millis;

#[test]
fn it_works() {
    let a = system_time_millis();
    let b = system_time_millis();

    assert!((a - b).abs() < 100);
}
