


#include "flutter_webrtc_base.h"
#include "flutter_webrtc_native.h"

namespace flutter_webrtc_plugin {

using namespace flutter;

class callback {
    private:
    std::unique_ptr<flutter::MethodResult<EncodableValue>> result;

    public:
    callback(std::unique_ptr<flutter::MethodResult<EncodableValue>> result) : result(std::move(result));
    OnSuccessOffer(std::string type, std::string sdp) {
        flutter::EncodableMap params;
        params[flutter::EncodableValue("sdp")] = sdp;
        params[flutter::EncodableValue("type")] = type;
        result->Success(flutter::EncodableValue(params));
    }

}

}