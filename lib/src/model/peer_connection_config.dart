/// ICE transport which should be used by some `PeerConnection`.
enum IceTransportType {
  /// Offer all types of ICE candidates.
  all,

  /// Only advertize relay-type candidates, like TURN servers, to avoid leaking the IP address of the client.
  relay,

  /// Gather all ICE candidate types except for host candidates.
  nohost,

  /// No ICE candidate offered.
  none,
}

/// ICE server which should be used by some `PeerConnection`.
class IceServer {
  /// Creates new ICE server with a provided parameters.
  IceServer(List<String> urls, String? username, String? password) {
    this.urls = urls;
    this.username = username;
    this.password = password;
  }

  /// List of URLs of this [IceServer].
  late List<String> urls;

  /// Username for auth on this [IceServer].
  String? username;

  /// Password for auth on this [IceServer].
  String? password;

  /// Converts this model to the [Map] expected by Flutter.
  dynamic toMap() {
    return {
      'urls': urls,
      'username': username,
      'password': password,
    };
  }
}
