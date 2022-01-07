import 'dart:convert';
import 'dart:core';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

class CreateSample extends StatefulWidget {
  static String tag = 'peer_connection_sample';

  @override
  _CreateSampleState createState() => _CreateSampleState();
}

class _CreateSampleState extends State<CreateSample> {
  String text = '42';

  @override
  void initState() {
    super.initState();
  }

  var configuration = <String, dynamic>{
    'iceServers': [
      {'url': 'stun:stun.l.google.com:19302'},
    ]
  };

  final loopbackConstraints = <String, dynamic>{
    'mandatory': {},
    'optional': [
      {'DtlsSrtpKeyAgreement': true},
    ],
  };

  final Map<String, dynamic> defaultSdpConstraints = {
    'mandatory': {
      'OfferToReceiveAudio': true,
      'OfferToReceiveVideo': true,
    },
    'optional': [false, false],
  };

  final Map<String, dynamic> argg = <String, dynamic>{
          'type': 'offer',
          'sdp': 
          '''v=0 <br />
              <br />
              o=- 721127235359436047 2 IN IP4 127.0.0.1<br />
              <br />
              s=-<br />
              t=0 0<br />
              <br />
              a=group:BUNDLE audio video<br />
              <br />
              a=extmap-allow-mixed<br />
              <br />
              a=msid-semantic: WMS<br />
              <br />
              m=audio 9 UDP/TLS/RTP/SAVPF 111 63 103 104 9 102 0 8 106 105 13 110 112 113 126<br />
              <br />
              c=IN IP4 0.0.0.0<br />
              <br />
              a=rtcp:9 IN IP4 0.0.0.0<br />
              <br />
              a=ice-ufrag:XLOk<br />
              <br />
              a=ice-pwd:A4TWcimH+JafJN0DZtpEUXjl<br />
              <br />
              a=ice-options:trickle<br />
              <br />
              a=fingerprint:sha-256 AE:24:3C:97:4D:0A:DD:35:EA:12:9D:0A:87:C8:2D:E3:FE:BF:5E:97:A1:80:FE:A2:9C:7E:75:BC:C8:51:AF:98<br />
              <br />
              a=setup:actpass<br />
              <br />
              a=mid:audio<br />
              <br />
              a=extmap:1 urn:ietf:params:rtp-hdrext:ssrc-audio-level<br />
              <br />
              a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time<br />
              <br />
              a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01<br />
              <br />
              a=recvonly<br />
              <br />
              a=rtcp-mux<br />
              <br />
              a=rtpmap:111 opus/48000/2<br />
              <br />
              a=rtcp-fb:111 transport-cc<br />
              <br />
              a=fmtp:111 minptime=10;useinbandfec=1<br />
              <br />
              a=rtpmap:63 red/48000/2<br />
              <br />
              a=fmtp:63 111/111<br />
              <br />
              a=rtpmap:103 ISAC/16000<br />
              <br />
              a=rtpmap:104 ISAC/32000<br />
              <br />
              a=rtpmap:9 G722/8000<br />
              <br />
              a=rtpmap:102 ILBC/8000<br />
              <br />
              a=rtpmap:0 PCMU/8000<br />
              <br />
              a=rtpmap:8 PCMA/8000<br />
              <br />
              a=rtpmap:106 CN/32000<br />
              <br />
              a=rtpmap:105 CN/16000<br />
              <br />
              a=rtpmap:13 CN/8000<br />
              <br />
              a=rtpmap:110 telephone-event/48000<br />
              <br />
              a=rtpmap:112 telephone-event/32000<br />
              <br />
              a=rtpmap:113 telephone-event/16000<br />
              <br />
              a=rtpmap:126 telephone-event/8000<br />
              <br />
              m=video 9 UDP/TLS/RTP/SAVPF 96 97 98 99 100 101 125 35 36 124 123 127 37<br />
              <br />
              c=IN IP4 0.0.0.0<br />
              <br />
              a=rtcp:9 IN IP4 0.0.0.0<br />
              <br />
              a=ice-ufrag:XLOk<br />
              <br />
              a=ice-pwd:A4TWcimH+JafJN0DZtpEUXjl<br />
              <br />
              a=ice-options:trickle<br />
              <br />
              a=fingerprint:sha-256 AE:24:3C:97:4D:0A:DD:35:EA:12:9D:0A:87:C8:2D:E3:FE:BF:5E:97:A1:80:FE:A2:9C:7E:75:BC:C8:51:AF:98<br />
              <br />
              a=setup:actpass<br />
              <br />
              a=mid:video<br />
              <br />
              a=extmap:14 urn:ietf:params:rtp-hdrext:toffset<br />
              <br />
              a=extmap:2 http://www.webrtc.org/experiments/rtp-hdrext/abs-send-time<br />
              <br />
              a=extmap:13 urn:3gpp:video-orientation<br />
              <br />
              a=extmap:3 http://www.ietf.org/id/draft-holmer-rmcat-transport-wide-cc-extensions-01<br />
              <br />
              a=extmap:5 http://www.webrtc.org/experiments/rtp-hdrext/playout-delay<br />
              <br />
              a=extmap:6 http://www.webrtc.org/experiments/rtp-hdrext/video-content-type<br />
              <br />
              a=extmap:7 http://www.webrtc.org/experiments/rtp-hdrext/video-timing<br />
              <br />
              a=extmap:8 http://www.webrtc.org/experiments/rtp-hdrext/color-space<br />
              <br />
              a=recvonly<br />
              <br />
              a=rtcp-mux<br />
              <br />
              a=rtcp-rsize<br />
              <br />
              a=rtpmap:96 VP8/90000<br />
              <br />
              a=rtcp-fb:96 goog-remb<br />
              <br />
              a=rtcp-fb:96 transport-cc<br />
              <br />
              a=rtcp-fb:96 ccm fir<br />
              <br />
              a=rtcp-fb:96 nack<br />
              <br />
              a=rtcp-fb:96 nack pli<br />
              <br />
              a=rtpmap:97 rtx/90000<br />
              <br />
              a=fmtp:97 apt=96<br />
              <br />
              a=rtpmap:98 VP9/90000<br />
              <br />
              a=rtcp-fb:98 goog-remb<br />
              <br />
              a=rtcp-fb:98 transport-cc<br />
              <br />
              a=rtcp-fb:98 ccm fir<br />
              <br />
              a=rtcp-fb:98 nack<br />
              <br />
              a=rtcp-fb:98 nack pli<br />
              <br />
              a=fmtp:98 profile-id=0<br />
              <br />
              a=rtpmap:99 rtx/90000<br />
              <br />
              a=fmtp:99 apt=98<br />
              <br />
              a=rtpmap:100 VP9/90000<br />
              <br />
              a=rtcp-fb:100 goog-remb<br />
              <br />
              a=rtcp-fb:100 transport-cc<br />
              <br />
              a=rtcp-fb:100 ccm fir<br />
              <br />
              a=rtcp-fb:100 nack<br />
              <br />
              a=rtcp-fb:100 nack pli<br />
              <br />
              a=fmtp:100 profile-id=2<br />
              <br />
              a=rtpmap:101 rtx/90000<br />
              <br />
              a=fmtp:101 apt=100<br />
              <br />
              a=rtpmap:125 VP9/90000<br />
              <br />
              a=rtcp-fb:125 goog-remb<br />
              <br />
              a=rtcp-fb:125 transport-cc<br />
              <br />
              a=rtcp-fb:125 ccm fir<br />
              <br />
              a=rtcp-fb:125 nack<br />
              <br />
              a=rtcp-fb:125 nack pli<br />
              <br />
              a=fmtp:125 profile-id=1<br />
              <br />
              a=rtpmap:35 AV1/90000<br />
              <br />
              a=rtcp-fb:35 goog-remb<br />
              <br />
              a=rtcp-fb:35 transport-cc<br />
              <br />
              a=rtcp-fb:35 ccm fir<br />
              <br />
              a=rtcp-fb:35 nack<br />
              <br />
              a=rtcp-fb:35 nack pli<br />
              <br />
              a=rtpmap:36 rtx/90000<br />
              <br />
              a=fmtp:36 apt=35<br />
              <br />
              a=rtpmap:124 red/90000<br />
              <br />
              a=rtpmap:123 rtx/90000<br />
              <br />
              a=fmtp:123 apt=124<br />
              <br />
              a=rtpmap:127 ulpfec/90000<br />
              <br />
              a=rtpmap:37 flexfec-03/90000<br />
              <br />
              a=rtcp-fb:37 goog-remb<br />
              <br />
              a=rtcp-fb:37 transport-cc<br />
              <br />
              a=fmtp:37 repair-window=10000000<br />
            '''
  };


  void _create_sample() async {

    try
    {
      final response =
          await WebRTC.invokeMethod('createOffer', <String, dynamic>{
        'peerConnectionId': '1',
        'constraints': defaultSdpConstraints
      });
      String sdp = response['sdp'];
      setState(() {
        text = sdp;
      });
    }
    catch (e)
    {
      setState(() {
        text = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('CreateSample'),
      ),
      body: Center(child: Text(text)),
      floatingActionButton: FloatingActionButton(
        onPressed: _create_sample,
        child: Icon(Icons.phone),
      ),
    );
  }
}
