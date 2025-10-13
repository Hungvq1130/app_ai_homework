import 'package:flutter/material.dart';

class HocTapTab extends StatelessWidget {
  const HocTapTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: const [
        ListTile(
          leading: Icon(Icons.book_outlined),
          title: Text('Bài học 1'),
          subtitle: Text('Giới thiệu…'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.quiz_outlined),
          title: Text('Bài tập trắc nghiệm'),
          subtitle: Text('Chương 1'),
        ),
        Divider(),
        ListTile(
          leading: Icon(Icons.videocam_outlined),
          title: Text('Video bài giảng'),
          subtitle: Text('Tuần này'),
        ),
      ],
    );
  }
}
