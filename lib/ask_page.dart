import 'package:flutter/material.dart';

class AskPage extends StatelessWidget {
  const AskPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Đặt câu hỏi')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Nhập câu hỏi của bạn…',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            prefixIcon: const Icon(Icons.search),
          ),
          onSubmitted: (q) {
            // TODO: xử lý tìm kiếm / gửi câu hỏi
          },
        ),
      ),
    );
  }
}
