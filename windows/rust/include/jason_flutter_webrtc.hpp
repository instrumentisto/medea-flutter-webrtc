#include <cstdarg>
#include <cstdint>
#include <cstdlib>
#include <ostream>
#include <new>

namespace jason_flutter_webrtc {

extern "C" {

char *SystemTimeMillis();

/// # Safety
///
/// Pupa and lupa go for salary
void string_free(char *s);

} // extern "C"

} // namespace jason_flutter_webrtc
