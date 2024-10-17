import 'dart:math';
import 'package:flutter/material.dart';
import '../widgets/home_meeting_button.dart';
import 'package:zoom_clone/resources/jitsi_meet_wrapper_method.dart';
import 'package:zoom_clone/screens/video_call_screen.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({Key? key}) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}

class _MeetingScreenState extends State<MeetingScreen> {
  final JitsiMeetMethod _jitsiMeetMethods = JitsiMeetMethod();

  // Function to generate an 8-digit meeting ID
  String generateMeetingID() {
    var random = Random();
    return (random.nextInt(90000000) + 10000000).toString();
  }

  // Function to create a new meeting
  createNewMeeting(BuildContext context) async {
    String meetingID = generateMeetingID();
    String? meetingPassword = await _showPasswordDialog(context);

    if (meetingPassword != null && meetingPassword.isNotEmpty) {
      // Create and join the meeting immediately
      _jitsiMeetMethods.createMeeting(
        roomName: meetingID,
        isAudioMuted: true,
        isVideoMuted: true,
        password: meetingPassword, // Pass the password to the meeting
      );

      // Automatically join the meeting after creation
      _joinMeeting(meetingID, meetingPassword);
    } else {
      // Handle case if no password is entered or dialog is dismissed
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Password is required to create a meeting")),
      );
    }
  }

  // Join the created meeting
  void _joinMeeting(String meetingID, String meetingPassword) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => VideoCallScreen(
          meetingID: meetingID,
          meetingPassword: meetingPassword,
        ),
      ),
    );
  }

  // Dialog to ask user for a meeting password
  Future<String?> _showPasswordDialog(BuildContext context) async {
    TextEditingController passwordController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Set Meeting Password'),
          content: TextField(
            controller: passwordController,
            decoration: InputDecoration(hintText: "Enter password"),
            obscureText: true,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(passwordController.text);
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  // Prompt for joining a meeting with ID and password
  joinMeeting(BuildContext context) async {
    String? meetingID = await _showJoinMeetingDialog(context);
    if (meetingID != null) {
      String? meetingPassword = await _showPasswordDialog(context);
      if (meetingPassword != null && meetingPassword.isNotEmpty) {
        _jitsiMeetMethods.createMeeting(
          roomName: meetingID,
          isAudioMuted: true,
          isVideoMuted: true,
          password: meetingPassword, // Pass the password to the meeting
        );
      }
    }
  }

  // Dialog for entering meeting ID
  Future<String?> _showJoinMeetingDialog(BuildContext context) async {
    TextEditingController meetingIDController = TextEditingController();

    return showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Join Meeting'),
          content: TextField(
            controller: meetingIDController,
            decoration: InputDecoration(hintText: "Enter Meeting ID"),
            keyboardType: TextInputType.number,
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(meetingIDController.text);
              },
              child: Text('Join'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(null);
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            HomeMeetingButton(
              onPressed: () {
                createNewMeeting(context);
              },
              text: 'New Meeting',
              icon: Icons.videocam,
            ),
            HomeMeetingButton(
              onPressed: () => joinMeeting(context),
              text: 'Join Meeting',
              icon: Icons.add_box_rounded,
            ),
            HomeMeetingButton(
              onPressed: () {},
              text: 'Schedule',
              icon: Icons.calendar_today,
            ),
            HomeMeetingButton(
              onPressed: () {},
              text: 'Share Screen',
              icon: Icons.arrow_upward_rounded,
            ),
          ],
        ),
        const Expanded(
          child: Center(
            child: Text(
              'Create/Join Meeting with just a click',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
