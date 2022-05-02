import 'package:flutter/material.dart';
import 'package:twich_clone/screens/feed_screnn.dart';
import 'package:twich_clone/screens/go_live_screen.dart';
import 'package:twich_clone/screens/join_channel_audio.dart';
import 'package:twich_clone/utils/colors.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _page = 0;

  List<Widget> pages = [
    const FeedScreen(),
    const GoLiveScreen(),
    const JoinChannelAudio()
  ];

  void onPageChange(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      bottomNavigationBar: BottomNavigationBar(
          selectedItemColor: buttonColor,
          unselectedItemColor: primaryColor,
          backgroundColor: backgroundColor,
          onTap: onPageChange,
          unselectedFontSize: 12,
          currentIndex: _page,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(
                Icons.favorite,
              ),
              label: "Following",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.add,
              ),
              label: "Go Live",
            ),
            BottomNavigationBarItem(
              icon: Icon(
                Icons.copy,
              ),
              label: "Browse",
            ),
          ]),
      body: pages[_page],
    );
  }
}
