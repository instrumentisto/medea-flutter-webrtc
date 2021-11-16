#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

namespace jason_flutter_webrtc {

extern "C" {

char *SystemTimeMillis();

DeviceInfo VideoInfoTest();

/// # Safety
///
/// No safety
void string_free(char *s);

} // extern "C"

} // namespace jason_flutter_webrtc
