// ignore_for_file: avoid_print
import 'dart:core';
import 'dart:io';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:medea_flutter_webrtc/medea_flutter_webrtc.dart';

class Loopback extends StatefulWidget {
  static String tag = 'get_usermedia_sample';

  const Loopback({super.key});

  @override
  State<Loopback> createState() => _LoopbackState();
}

class _LoopbackState extends State<Loopback> {
  List<MediaDeviceInfo>? _mediaDevicesList;

  MediaStreamTrack? _videoTrack;
  MediaStreamTrack? _micAudioTrack;
  MediaStreamTrack? _systemAudioTrack;

  PeerConnection? _pc1;
  RtpTransceiver? _videoTxTr;
  RtpTransceiver? _deviceAudioTxTr;
  RtpTransceiver? _systemAudioTxTr;

  PeerConnection? _pc2;

  final _localRenderer = createVideoRenderer();
  final _remoteRenderer = createVideoRenderer();
  bool _inCalling = false;
  bool _mic = true;
  bool _cam = true;
  bool _displayAudio = Platform.isWindows;
  int _volume = -1;
  bool _microIsAvailable = false;
  double currentAudioLevel = 0.0;
  double lastDeviceAudioLevel = 0.0;
  double lastDisplayAudioLevel = 0.0;

  bool _noiseSuppressionEnabled = true;
  bool _highPassFilterEnabled = true;
  bool _echoCancellationEnabled = true;
  bool _autoGainControlEnabled = true;
  NoiseSuppressionLevel _noiseSuppressionLevel = NoiseSuppressionLevel.veryHigh;

  @override
  void initState() {
    super.initState();
    initRenderers();

    () async {
      if (await microphoneVolumeIsAvailable()) {
        var volume = await microphoneVolume();
        setState(() {
          _volume = volume;
        });
      }
    }();
  }

  @override
  void deactivate() {
    super.deactivate();
    if (_inCalling) {
      _hangUp();
    }
    _localRenderer.dispose();
    _remoteRenderer.dispose();
  }

  void initRenderers() async {
    await _localRenderer.initialize();
    await _remoteRenderer.initialize();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void _makeCall() async {
    var caps = DeviceConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.video.mandatory = DeviceVideoConstraints();
    caps.video.mandatory!.width = 640;
    caps.video.mandatory!.height = 480;
    caps.video.mandatory!.fps = 30;

    try {
      await setupForegroundService(
        ForegroundServiceConfig(
          notificationTitle: 'medea-flutter-webrtc',
          notificationText: 'Ongoing loopback test',
        ),
      );

      _mediaDevicesList = await enumerateDevices();
      var gumTracks = await getUserMedia(caps);
      _videoTrack = gumTracks.firstWhere(
        (track) => track.kind() == MediaKind.video,
      );
      _micAudioTrack = gumTracks.firstWhere(
        (track) => track.kind() == MediaKind.audio,
      );
      await _localRenderer.setSrcObject(_videoTrack!);

      try {
        var displayCaps = DisplayConstraints();
        displayCaps.audio.mandatory = AudioConstraints();

        _systemAudioTrack = (await getDisplayMedia(displayCaps))[0];
      } catch (e) {
        print("Could not capture system audio: $e");
      }

      var server = IceServer(['stun:stun.l.google.com:19302']);
      _pc1 = await PeerConnection.create(IceTransportType.all, [server]);
      _pc2 = await PeerConnection.create(IceTransportType.all, [server]);

      _pc1?.onIceCandidateError((p0) {
        print(p0.errorText);
      });
      _pc2?.onIceCandidateError((p0) {
        print(p0.errorText);
      });

      _pc2?.onTrack((track, trans) async {
        if (track.kind() == MediaKind.video) {
          await _remoteRenderer.setSrcObject(track);
        }
      });

      _videoTxTr = await _pc1?.addTransceiver(
        MediaKind.video,
        RtpTransceiverInit(TransceiverDirection.sendOnly),
      );
      _deviceAudioTxTr = await _pc1?.addTransceiver(
        MediaKind.audio,
        RtpTransceiverInit(TransceiverDirection.sendOnly),
      );
      _systemAudioTxTr = await _pc1?.addTransceiver(
        MediaKind.audio,
        RtpTransceiverInit(TransceiverDirection.sendOnly),
      );

      var offer = await _pc1?.createOffer();
      await _pc1?.setLocalDescription(offer!);
      await _pc2?.setRemoteDescription(offer!);

      var answer = await _pc2?.createAnswer();
      await _pc2?.setLocalDescription(answer!);
      await _pc1?.setRemoteDescription(answer!);

      _pc1?.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await _pc2?.addIceCandidate(candidate);
      });

      _pc2?.onIceCandidate((IceCandidate candidate) async {
        print(candidate.candidate.toString());
        await _pc1?.addIceCandidate(candidate);
      });

      if (_micAudioTrack!.isOnAudioLevelAvailable()) {
        _micAudioTrack!.onAudioLevelChanged((volume) {
          setState(() {
            lastDeviceAudioLevel = volume / 100;

            if (Platform.isWindows) {
              currentAudioLevel = max(
                lastDeviceAudioLevel,
                lastDisplayAudioLevel,
              );
            } else {
              currentAudioLevel = lastDeviceAudioLevel;
            }
          });
        });
      }

      await _videoTxTr?.sender.replaceTrack(_videoTrack!);
      await _deviceAudioTxTr?.sender.replaceTrack(_micAudioTrack!);
      if (_systemAudioTrack != null) {
        if (_systemAudioTrack!.isOnAudioLevelAvailable()) {
          _systemAudioTrack!.onAudioLevelChanged((volume) {
            setState(() {
              lastDisplayAudioLevel = volume / 100;

              currentAudioLevel = max(
                lastDeviceAudioLevel,
                lastDisplayAudioLevel,
              );
            });
          });
        }

        await _systemAudioTxTr?.sender.replaceTrack(_systemAudioTrack);
      }
    } catch (e) {
      print(e.toString());
    }
    if (!mounted) return;

    _inCalling = true;
    microphoneVolumeIsAvailable().then((value) {
      setState(() {
        _microIsAvailable = value;
      });
    });
  }

  void _hangUp() async {
    try {
      await _localRenderer.setSrcObject(null);
      await _remoteRenderer.setSrcObject(null);

      for (var track in [_videoTrack, _micAudioTrack, _systemAudioTrack]) {
        await track?.stop();
        await track?.dispose();
      }

      await _pc1?.close();
      await _pc2?.close();

      setState(() {
        _inCalling = false;
        _mic = true;
        _cam = true;
        _displayAudio = Platform.isWindows;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  void _setInputAudioId(String id) async {
    await _micAudioTrack?.stop();
    await _micAudioTrack?.dispose();
    _micAudioTrack = null;

    var caps = DeviceConstraints();
    caps.audio.mandatory = AudioConstraints();
    caps.audio.mandatory!.deviceId = id;

    var newTrack = (await getUserMedia(caps))[0];
    if (newTrack.isOnAudioLevelAvailable()) {
      newTrack.onAudioLevelChanged((volume) {
        setState(() {
          currentAudioLevel = volume / 100;
        });
      });
    }
    await _deviceAudioTxTr!.sender.replaceTrack(newTrack);

    _micAudioTrack = newTrack;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'WebRTC loopback test. ${_inCalling ? (_microIsAvailable ? 'Micro volume: $_volume .' : 'Micro volume is not available') : ''}',
        ),
        actions: _inCalling
            ? <Widget>[
                PopupMenuButton<String>(
                  itemBuilder: (context) {
                    return [
                      PopupMenuItem(
                        enabled: false,
                        child: StatefulBuilder(
                          builder: (context, setStatePopup) {
                            return Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CheckboxListTile(
                                      dense: true,
                                      title: Text("Noise Suppression"),
                                      value: _noiseSuppressionEnabled,
                                      onChanged: (bool? value) async {
                                        await _micAudioTrack
                                            ?.setNoiseSuppressionEnabled(
                                              value!,
                                            );

                                        setState(() {
                                          _noiseSuppressionEnabled = value!;
                                        });
                                        setStatePopup(() {});
                                      },
                                    )
                                    as StatelessWidget,
                                CheckboxListTile(
                                  dense: true,
                                  title: Text("High Pass Filter"),
                                  value: _highPassFilterEnabled,
                                  onChanged: (bool? value) async {
                                    await _micAudioTrack
                                        ?.setHighPassFilterEnabled(value!);

                                    setState(() {
                                      _highPassFilterEnabled = value!;
                                    });
                                    setStatePopup(() {});
                                  },
                                ),
                                CheckboxListTile(
                                  dense: true,
                                  title: Text("Echo cancellation"),
                                  value: _echoCancellationEnabled,
                                  onChanged: (bool? value) async {
                                    await _micAudioTrack
                                        ?.setEchoCancellationEnabled(value!);

                                    setState(() {
                                      _echoCancellationEnabled = value!;
                                    });
                                    setStatePopup(() {});
                                  },
                                ),
                                CheckboxListTile(
                                  dense: true,
                                  title: Text("Auto gain control"),
                                  value: _autoGainControlEnabled,
                                  onChanged: (bool? value) async {
                                    await _micAudioTrack
                                        ?.setAutoGainControlEnabled(value!);

                                    setState(() {
                                      _autoGainControlEnabled = value!;
                                    });
                                    setStatePopup(() {});
                                  },
                                ),
                                Text('Noise suppression level'),
                                RadioGroup<NoiseSuppressionLevel>(
                                  groupValue: _noiseSuppressionLevel,
                                  onChanged:
                                      (NoiseSuppressionLevel? value) async {
                                        await _micAudioTrack
                                            ?.setNoiseSuppressionLevel(value!);

                                        setState(() {
                                          if (value != null) {
                                            _noiseSuppressionLevel = value;
                                          }
                                        });
                                        setStatePopup(() {});
                                      },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: <Widget>[
                                      Text("Auto gain control"),
                                      ...NoiseSuppressionLevel.values.map((
                                        level,
                                      ) {
                                        return ListTile(
                                          title: Text(level.name),
                                          leading: Radio<NoiseSuppressionLevel>(
                                            value: level,
                                          ),
                                        );
                                      }),
                                    ],
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),
                    ];
                  },
                  icon: const Icon(Icons.multitrack_audio),
                ),
                IconButton(
                  icon: const Icon(Icons.remove),
                  tooltip: 'Micro lower',
                  onPressed: _microIsAvailable
                      ? () async {
                          setState(() {
                            _volume = _volume >= 10 ? _volume - 10 : 0;
                          });
                          await setMicrophoneVolume(_volume);
                        }
                      : null,
                ),
                IconButton(
                  icon: const Icon(Icons.add),
                  tooltip: 'Micro louder',
                  onPressed: _microIsAvailable
                      ? () async {
                          setState(() {
                            _volume = _volume <= 90 ? _volume + 10 : 100;
                          });
                          await setMicrophoneVolume(_volume);
                        }
                      : null,
                ),
                IconButton(
                  icon: _mic
                      ? const Icon(Icons.mic_off)
                      : const Icon(Icons.mic),
                  tooltip: _mic
                      ? 'Disable device audio rec'
                      : 'Enable device audio rec',
                  onPressed: () {
                    setState(() {
                      _mic = !_mic;
                    });
                    _micAudioTrack?.setEnabled(_mic);
                  },
                ),
                Visibility(
                  visible: Platform.isWindows,
                  child: IconButton(
                    icon: _displayAudio
                        ? const Icon(Icons.volume_off)
                        : const Icon(Icons.volume_up),
                    tooltip: _displayAudio
                        ? 'Disable display audio rec'
                        : 'Enable display audio rec',
                    onPressed: () async {
                      setState(() {
                        _displayAudio = !_displayAudio;
                      });
                      _systemAudioTrack?.setEnabled(_displayAudio);
                    },
                  ),
                ),
                IconButton(
                  icon: _cam
                      ? const Icon(Icons.videocam_off)
                      : const Icon(Icons.videocam),
                  tooltip: _cam ? 'Disable video rec' : 'Enable video rec',
                  onPressed: () {
                    setState(() {
                      _cam = !_cam;
                    });
                    _videoTrack?.setEnabled(_cam);
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: "Choose audio input device",
                  icon: const Icon(Icons.mic),
                  onSelected: (id) {
                    _setInputAudioId(id);
                  },
                  itemBuilder: (BuildContext context) {
                    if (_mediaDevicesList != null) {
                      return _mediaDevicesList!
                          .where(
                            (device) =>
                                device.kind == MediaDeviceKind.audioinput,
                          )
                          .map((device) {
                            return PopupMenuItem<String>(
                              value: device.deviceId,
                              child: Text(device.label),
                            );
                          })
                          .toList();
                    }
                    return [];
                  },
                ),
                PopupMenuButton<String>(
                  tooltip: "Choose audio output device",
                  icon: const Icon(Icons.volume_down),
                  onSelected: (id) {
                    setOutputAudioId(id);
                  },
                  itemBuilder: (BuildContext context) {
                    if (_mediaDevicesList != null) {
                      return _mediaDevicesList!
                          .where(
                            (device) =>
                                device.kind == MediaDeviceKind.audiooutput,
                          )
                          .map((device) {
                            return PopupMenuItem<String>(
                              value: device.deviceId,
                              child: Text(device.label),
                            );
                          })
                          .toList();
                    }
                    return [];
                  },
                ),
              ]
            : null,
      ),
      body: OrientationBuilder(
        builder: (context, orientation) {
          return Center(
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height - 66,
                      decoration: const BoxDecoration(color: Colors.black54),
                      child: VideoView(_localRenderer, mirror: true),
                    ),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0.0, 0.0, 0.0, 0.0),
                      width: MediaQuery.of(context).size.width / 2,
                      height: MediaQuery.of(context).size.height - 66,
                      decoration: const BoxDecoration(color: Colors.black54),
                      child: VideoView(_remoteRenderer, mirror: true),
                    ),
                  ],
                ),
                LinearProgressIndicator(
                  value: currentAudioLevel,
                  minHeight: 10.0,
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _inCalling ? _hangUp : _makeCall,
        tooltip: _inCalling ? 'Hangup' : 'Call',
        child: Icon(_inCalling ? Icons.call_end : Icons.phone),
      ),
    );
  }
}
