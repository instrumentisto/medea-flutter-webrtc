mod bridge;

use bridge::rtc;

#[must_use]
pub fn system_time_millis() -> i64 {
    rtc::SystemTimeMillis()
}
