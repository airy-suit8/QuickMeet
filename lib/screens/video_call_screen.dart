import 'package:flutter/material.dart';
import 'package:zoom_clone/resources/auth_methods.dart';
import 'package:zoom_clone/resources/jitsi_meet_wrapper_method.dart';
import 'package:zoom_clone/utils/colors.dart';

import '../widgets/meeting_option.dart';

class VideoCallScreen extends StatefulWidget {
  final String? meetingID;
  final String? meetingPassword; 

  const VideoCallScreen({
    Key? key,
    this.meetingID,     // Optional meeting ID
    this.meetingPassword, // Optional meeting password
  }) : super(key: key);

  @override
  State<VideoCallScreen> createState() => _VideoCallScreenState();
}

class _VideoCallScreenState extends State<VideoCallScreen> {
  final AuthMethods _authMethods = AuthMethods();

  late TextEditingController meetingIdController;
  late TextEditingController nameController;
  late TextEditingController passwordController; 

  bool isAudioMuted = true;
  bool isVideoMuted = true;

  @override
  void initState() {
    meetingIdController = TextEditingController(
      text: widget.meetingID ?? '',  // If meetingID is passed, use it
    );
    nameController = TextEditingController(
      text: _authMethods.user.displayName ?? '',
    );
    passwordController = TextEditingController(
      text: widget.meetingPassword ?? '',  // If password is passed, use it
    );
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    meetingIdController.dispose();
    nameController.dispose();
    passwordController.dispose(); 
  }
_joinMeeting() {
  // Ensure you're not trying to assign this to a variable
  JitsiMeetMethod().createMeeting(
    roomName: meetingIdController.text,
    isAudioMuted: isAudioMuted,
    isVideoMuted: isVideoMuted,
    username: nameController.text,
    password: passwordController.text, // Pass the password to the meeting
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.blueAccent,
        title: const Text(
          'Join Meeting',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          // Show Meeting ID and Password fields only if they are not provided
          if (widget.meetingID == null)
            SizedBox(
              height: 60,
              child: TextField(
                controller: meetingIdController,
                maxLines: 1,
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  fillColor: secondaryBackgroundColor,
                  filled: true,
                  border: InputBorder.none,
                  hintText: 'Room ID',
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                ),
              ),
            ),
          SizedBox(
            height: 60,
            child: TextField(
              controller: nameController,
              maxLines: 1,
              textAlign: TextAlign.center,
              keyboardType: TextInputType.text,
              decoration: const InputDecoration(
                fillColor: secondaryBackgroundColor,
                filled: true,
                border: InputBorder.none,
                hintText: 'Name',
                contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
              ),
            ),
          ),
          if (widget.meetingPassword == null)
            SizedBox(
              height: 60,
              child: TextField(
                controller: passwordController, 
                maxLines: 1,
                textAlign: TextAlign.center,
                obscureText: true, 
                decoration: const InputDecoration(
                  fillColor: secondaryBackgroundColor,
                  filled: true,
                  border: InputBorder.none,
                  hintText: 'Password',
                  contentPadding: EdgeInsets.fromLTRB(16, 8, 0, 0),
                ),
              ),
            ),
          const SizedBox(
            height: 20,
          ),
          InkWell(
            onTap: _joinMeeting,
            child: const Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                'Join',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          MeetingOption(
            text: 'Mute Audio',
            isMute: isAudioMuted,
            onChange: (bool value) {
              onAudioMuted(value);
            },
          ),
          const SizedBox(
            height: 20,
          ),
          MeetingOption(
            text: 'Turn off My video',
            isMute: isVideoMuted,
            onChange: (bool value) {
              onVideoMuted(value);
            },
          ),
        ],
      ),
    );
  }

  onAudioMuted(bool? value) {
    setState(() {
      isAudioMuted = value!;
    });
  }

  onVideoMuted(bool? value) {
    setState(() {
      isVideoMuted = value!;
    });
  }
}
