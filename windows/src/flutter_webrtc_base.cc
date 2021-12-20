#include "flutter_webrtc_base.h"

namespace flutter_webrtc_plugin {

FlutterWebRTCBase::FlutterWebRTCBase(BinaryMessenger* messenger,
                                     TextureRegistrar* textures)
    : messenger_(messenger), textures_(textures) {}

FlutterWebRTCBase::~FlutterWebRTCBase() {}

// std::string FlutterWebRTCBase::GenerateUUID() {
//   return uuidxx::uuid::Generate().ToString(false);
// }

// RTCPeerConnection* FlutterWebRTCBase::PeerConnectionForId(
//     const std::string& id) {
//   auto it = peerconnections_.find(id);

//   if (it != peerconnections_.end())
//     return (*it).second.get();

//   return nullptr;
// }

// void FlutterWebRTCBase::RemovePeerConnectionForId(const std::string& id) {
//   auto it = peerconnections_.find(id);
//   if (it != peerconnections_.end())
//     peerconnections_.erase(it);
// }

// RTCMediaTrack* FlutterWebRTCBase ::MediaTrackForId(const std::string& id) {
//   auto it = local_tracks_.find(id);

//   if (it != local_tracks_.end())
//     return (*it).second.get();

//   return nullptr;
// }

// void FlutterWebRTCBase::RemoveMediaTrackForId(const std::string& id) {
//   auto it = local_tracks_.find(id);
//   if (it != local_tracks_.end())
//     local_tracks_.erase(it);
// }

// FlutterPeerConnectionObserver*
// FlutterWebRTCBase::PeerConnectionObserversForId(
//     const std::string& id) {
//   auto it = peerconnection_observers_.find(id);

//   if (it != peerconnection_observers_.end())
//     return (*it).second.get();

//   return nullptr;
// }

// void FlutterWebRTCBase::RemovePeerConnectionObserversForId(
//     const std::string& id) {
//   auto it = peerconnection_observers_.find(id);
//   if (it != peerconnection_observers_.end())
//     peerconnection_observers_.erase(it);
// }

// scoped_refptr<RTCMediaStream> FlutterWebRTCBase::MediaStreamForId(
//     const std::string& id) {
//   auto it = local_streams_.find(id);
//   if (it != local_streams_.end()) {
//     return (*it).second;
//   }

//   for (auto kv : peerconnection_observers_) {
//     auto pco = kv.second.get();
//     auto stream = pco->MediaStreamForId(id);
//     if (stream != nullptr)
//       return stream;
//   }

//   return nullptr;
// }

// void FlutterWebRTCBase::RemoveStreamForId(const std::string& id) {
//   auto it = local_streams_.find(id);
//   if (it != local_streams_.end())
//     local_streams_.erase(it);
// }

// bool FlutterWebRTCBase::ParseConstraints(const EncodableMap& constraints,
//                                          RTCConfiguration* configuration) {
//   memset(&configuration->ice_servers, 0, sizeof(configuration->ice_servers));
//   return false;
// }

// bool FlutterWebRTCBase::CreateIceServers(const EncodableList&
// iceServersArray,
//                                          IceServer* ice_servers) {
//   size_t size = iceServersArray.size();
//   for (size_t i = 0; i < size; i++) {
//     IceServer& ice_server = ice_servers[i];
//     EncodableMap iceServerMap = GetValue<EncodableMap>(iceServersArray[i]);
//     bool hasUsernameAndCredential =
//         iceServerMap.find(EncodableValue("username")) != iceServerMap.end()
//         && iceServerMap.find(EncodableValue("credential")) !=
//         iceServerMap.end();
//     auto it = iceServerMap.find(EncodableValue("url"));
//     if (it != iceServerMap.end() && TypeIs<std::string>(it->second)) {
//       if (hasUsernameAndCredential) {
//         std::string username = GetValue<std::string>(
//             iceServerMap.find(EncodableValue("username"))->second);
//         std::string credential = GetValue<std::string>(
//             iceServerMap.find(EncodableValue("credential"))->second);
//         std::string uri = GetValue<std::string>(it->second);
//         ice_server.username = username;
//         ice_server.password = credential;
//         ice_server.uri = uri;
//       } else {
//         std::string uri = GetValue<std::string>(it->second);
//         ice_server.uri = uri;
//       }
//     }
//     it = iceServerMap.find(EncodableValue("urls"));
//     if (it != iceServerMap.end()) {
//       if (TypeIs<std::string>(it->second)) {
//         if (hasUsernameAndCredential) {
//           std::string username = GetValue<std::string>(
//               iceServerMap.find(EncodableValue("username"))->second);
//           std::string credential = GetValue<std::string>(
//               iceServerMap.find(EncodableValue("credential"))->second);
//           std::string uri = GetValue<std::string>(it->second);
//           ice_server.username = username;
//           ice_server.password = credential;
//           ice_server.uri = uri;
//         } else {
//           std::string uri = GetValue<std::string>(it->second);
//           ice_server.uri = uri;
//         }
//       }
//       if (TypeIs<EncodableList>(it->second)) {
//         const EncodableList urls = GetValue<EncodableList>(it->second);
//         for (auto url : urls) {
//           const EncodableMap map = GetValue<EncodableMap>(url);
//           std::string value;
//           auto it2 = map.find(EncodableValue("url"));
//           if (it2 != map.end()) {
//             value = GetValue<std::string>(it2->second);
//             if (hasUsernameAndCredential) {
//               std::string username = GetValue<std::string>(
//                   iceServerMap.find(EncodableValue("username"))->second);
//               std::string credential = GetValue<std::string>(
//                   iceServerMap.find(EncodableValue("credential"))->second);
//               ice_server.username = username;
//               ice_server.password = credential;
//               ice_server.uri = value;
//             } else {
//               ice_server.uri = value;
//             }
//           }
//         }
//       }
//     }
//   }
//   return size > 0;
// }

// bool FlutterWebRTCBase::ParseRTCConfiguration(const EncodableMap& map,
//                                               RTCConfiguration& conf) {
//   auto it = map.find(EncodableValue("iceServers"));
//   if (it != map.end()) {
//     const EncodableList iceServersArray =
//     GetValue<EncodableList>(it->second); CreateIceServers(iceServersArray,
//     conf.ice_servers);
//   }
//   // iceTransportPolicy (public API)
//   it = map.find(EncodableValue("iceTransportPolicy"));
//   if (it != map.end() && TypeIs<std::string>(it->second)) {
//     std::string v = GetValue<std::string>(it->second);
//     if (v == "all")  // public
//       conf.type = IceTransportsType::kAll;
//     else if (v == "relay")
//       conf.type = IceTransportsType::kRelay;
//     else if (v == "nohost")
//       conf.type = IceTransportsType::kNoHost;
//     else if (v == "none")
//       conf.type = IceTransportsType::kNone;
//   }

//   // bundlePolicy (public api)
//   it = map.find(EncodableValue("bundlePolicy"));
//   if (it != map.end() && TypeIs<std::string>(it->second)) {
//     std::string v = GetValue<std::string>(it->second);
//     if (v == "balanced")  // public
//       conf.bundle_policy = kBundlePolicyBalanced;
//     else if (v == "max-compat")  // public
//       conf.bundle_policy = kBundlePolicyMaxCompat;
//     else if (v == "max-bundle")  // public
//       conf.bundle_policy = kBundlePolicyMaxBundle;
//   }

//   // rtcpMuxPolicy (public api)
//   it = map.find(EncodableValue("rtcpMuxPolicy"));
//   if (it != map.end() && TypeIs<std::string>(it->second)) {
//     std::string v = GetValue<std::string>(it->second);
//     if (v == "negotiate")  // public
//       conf.rtcp_mux_policy = RtcpMuxPolicy::kRtcpMuxPolicyNegotiate;
//     else if (v == "require")  // public
//       conf.rtcp_mux_policy = RtcpMuxPolicy::kRtcpMuxPolicyRequire;
//   }

//   // FIXME: peerIdentity of type DOMString (public API)
//   // FIXME: certificates of type sequence<RTCCertificate> (public API)
//   // iceCandidatePoolSize of type unsigned short, defaulting to 0
//   it = map.find(EncodableValue("iceCandidatePoolSize"));
//   if (it != map.end()) {
//     conf.ice_candidate_pool_size = GetValue<int>(it->second);
//   }

//   // sdpSemantics (public api)
//   it = map.find(EncodableValue("sdpSemantics"));
//   if (it != map.end() && TypeIs<std::string>(it->second)) {
//     std::string v = GetValue<std::string>(it->second);
//     if (v == "plan-b")  // public
//       conf.sdp_semantics = SdpSemantics::kPlanB;
//     else if (v == "unified-plan")  // public
//       conf.sdp_semantics = SdpSemantics::kUnifiedPlan;
//   }
//   return true;
// }

// scoped_refptr<RTCMediaTrack> FlutterWebRTCBase::MediaTracksForId(
//     const std::string& id) {
//   auto it = local_tracks_.find(id);
//   if (it != local_tracks_.end()) {
//     return (*it).second;
//   }

//   return nullptr;
// }

// void FlutterWebRTCBase::RemoveTracksForId(const std::string& id) {
//   auto it = local_tracks_.find(id);
//   if (it != local_tracks_.end())
//     local_tracks_.erase(it);
// }

}  // namespace flutter_webrtc_plugin
