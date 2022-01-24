enum IceTransportType {
  all,
  relay,
  nohost,
  none,
}

class IceServer {
  IceServer(List<String> urls, String? username, String? password) {
    this.urls = urls;
    this.username = username;
    this.password = password;
  }

  late List<String> urls;
  String? username;
  String? password;

  dynamic toMap() {
    return {
      'urls': urls,
      'username': username,
      'password': password,
    };
  }
}
