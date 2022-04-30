import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import 'package:twich_clone/config/appid.dart';
import 'package:twich_clone/models/user.dart';
import 'package:twich_clone/providers/user_provider.dart';

import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:twich_clone/resources/firestore_methods.dart';
import 'package:twich_clone/responsive/responsive_layout.dart';
import 'package:twich_clone/routes/routes.dart';
import 'package:twich_clone/widgets/chat.dart';

import 'package:http/http.dart' as http;
import 'package:twich_clone/widgets/custom_botton.dart';

class BroadCastScreen extends StatefulWidget {
  const BroadCastScreen(
      {Key? key, required this.isBroadCaster, required this.channelId})
      : super(key: key);

  final bool isBroadCaster;
  final String channelId;

  @override
  State<BroadCastScreen> createState() => _BroadCastScreenState();
}

class _BroadCastScreenState extends State<BroadCastScreen> {
  late final RtcEngine _engine;

  List<int> remoteUid = [];

  late User user;

  bool switchCamera = true;
  bool isMuted = false;

  String baseUsrl = "https://agora-token-2022.herokuapp.com";
  String? token;

  bool isScrennSharing = false;

  Future<void> getToken() async {
    final res = await http.get(
      Uri.parse(baseUsrl +
          '/rtc/' +
          widget.channelId +
          "/publisher/userAccount/" +
          user.uid +
          "/"),
    );
    if (res.statusCode == 200) {
      setState(() {
        token = res.body;
        token = jsonDecode(token!)["rtcToken"];
        print(token);
      });
    } else {
      debugPrint("Failed to fetch the token");
    }
  }

  @override
  void initState() {
    super.initState();
    _initEngine();
  }

  void _initEngine() async {
    user = Provider.of<UserProvider>(context, listen: false).user;
    await getToken();
    _engine = await RtcEngine.createWithContext(RtcEngineContext(appId));
    _addListeners();

    await _engine.enableVideo();
    await _engine.startPreview();
    await _engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    if (widget.isBroadCaster) {
      _engine.setClientRole(ClientRole.Broadcaster);
    } else {
      _engine.setClientRole(ClientRole.Audience);
    }

    _joinChannel();
  }

  void _addListeners() {
    _engine.setEventHandler(
      RtcEngineEventHandler(joinChannelSuccess: (channel, uid, elapsed) {
        debugPrint("joinChannelSuccess $channel $uid $elapsed");
      }, userJoined: (uid, elapsed) {
        debugPrint("userJoined $uid $elapsed");
        setState(() {
          remoteUid.add(uid);
        });
      }, userOffline: (uid, reason) {
        debugPrint("userOffile $uid $reason");
        setState(() {
          remoteUid.removeWhere((element) => element == uid);
        });
      }, leaveChannel: (stats) {
        debugPrint("leaveChannel $stats");
        setState(() {
          remoteUid.clear();
        });
      }, tokenPrivilegeWillExpire: (token) async {
        await getToken();
        await _engine.renewToken(token);
      }),
    );
  }

  void _joinChannel() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      await [Permission.microphone, Permission.camera].request();
    }
    await _engine.joinChannelWithUserAccount(
      token,
      widget.channelId,
      user.uid,
    );
  }

  _leaveChannel() async {
    await _engine.leaveChannel();
    if ('${user.uid}${user.username}' == widget.channelId) {
      await FirestoreMhetods().endLiveStream(widget.channelId);
    } else {
      await FirestoreMhetods().updateViewCount(widget.channelId, false);
    }
    Navigator.pushReplacementNamed(context, Routes.home);
  }

  void _swichCamera() async {
    _engine.switchCamera().then((value) {
      setState(() {
        switchCamera = !switchCamera;
      });
    }).catchError((err) {
      debugPrint("swithCamera" + err);
    });
  }

  void _onToggleMute() async {
    setState(() {
      isMuted = !isMuted;
    });
    await _engine.muteLocalAudioStream(isMuted);
  }

  void _startScreenShare() async {
    final helper = await _engine.getScreenShareHelper(
        appGroup: kIsWeb || Platform.isWindows ? null : "io.agora");
    await helper.disableAudio();
    await helper.enableVideo();
    await helper.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await helper.setClientRole(ClientRole.Broadcaster);
    var windowId = 0;
    if (!kIsWeb &&
        (Platform.isWindows || Platform.isMacOS || Platform.isAndroid)) {
      final windows = _engine.enumerateWindows();
      if (windows.isNotEmpty) {
        final index = Random().nextInt(windows.length - 1);
        debugPrint("ScreenSharing window with index $index");
        windowId = windows[index].id;
      }
    }
    await helper.startScreenCaptureByWindowId(windowId);
    setState(() {
      isScrennSharing = true;
    });
    await helper.joinChannelWithUserAccount(
        token, widget.channelId, Provider.of<UserProvider>(context).user.uid);
  }

  void _stopScreenShare() async {
    final helper = await _engine.getScreenShareHelper();
    await helper.destroy().then((value) {
      setState(() {
        isScrennSharing = false;
      });
    }).catchError((err) {
      debugPrint("StropScrfeenShre $err");
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;
    return WillPopScope(
      onWillPop: () async {
        await _leaveChannel();
        return Future.value(true);
      },
      child: Scaffold(
        bottomNavigationBar: widget.isBroadCaster
            ? Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: CustomButton(
                  text: "End Strem",
                  ontTap: _leaveChannel,
                ),
              )
            : null,
        body: Padding(
          padding: const EdgeInsets.all(
            8,
          ),
          child: ResponsiveLayout(
            desktopBody: Row(
              children: [
                Expanded(
                    child: Column(
                  children: [
                    _renderVideo(user, isScrennSharing),
                    if ("${user.uid}${user.username}" == widget.channelId)
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          InkWell(
                            onTap: _swichCamera,
                            child: const Text("Switch Camera"),
                          ),
                          InkWell(
                            onTap: _onToggleMute,
                            child: Text(isMuted ? "UnMute" : "Mute"),
                          ),
                          InkWell(
                            onTap: isScrennSharing
                                ? _stopScreenShare
                                : _startScreenShare,
                            child: Text(isScrennSharing
                                ? "Stop Screen Shared"
                                : "Screnn share"),
                          ),
                        ],
                      ),
                  ],
                )),
                Chat(channelId: widget.channelId)
              ],
            ),
            mobileBody: Column(
              children: [
                _renderVideo(user, isScrennSharing),
                if ("${user.uid}${user.username}" == widget.channelId)
                  Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: _swichCamera,
                        child: const Text("Switch Camera"),
                      ),
                      InkWell(
                        onTap: _onToggleMute,
                        child: Text(isMuted ? "UnMute" : "Mute"),
                      ),
                    ],
                  ),
                Expanded(
                  child: Chat(
                    channelId: widget.channelId,
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  _renderVideo(User user, bool isScrennSharing) {
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: "${user.uid}${user.username}" == widget.channelId
          ? isScrennSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : const RtcLocalView.SurfaceView(
                  zOrderMediaOverlay: true,
                  zOrderOnTop: true,
                )
          : isScrennSharing
              ? kIsWeb
                  ? const RtcLocalView.SurfaceView.screenShare()
                  : const RtcLocalView.TextureView.screenShare()
              : remoteUid.isNotEmpty
                  ? kIsWeb
                      ? RtcRemoteView.SurfaceView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                      : RtcRemoteView.TextureView(
                          uid: remoteUid[0],
                          channelId: widget.channelId,
                        )
                  : const SizedBox(),
    );
  }
}
