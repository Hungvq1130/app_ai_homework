import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AskPage extends StatefulWidget {
  const AskPage({super.key});

  @override
  State<AskPage> createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> {
  final _controller = TextEditingController();

  void _send() {
    final q = _controller.text.trim();
    if (q.isEmpty) return;
    FocusScope.of(context).unfocus();
    // TODO: xử lý gửi câu hỏi / điều hướng
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Đã gửi: $q')));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      // APPBAR mới
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

      // Nội dung trang
      body: SafeArea(
        child: Column(
          children: const [
            SizedBox(height: 12),
            Icon(Icons.bolt, size: 20, color: Colors.redAccent),
            SizedBox(height: 6),
            Text('Giải Bài tập AI',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Nhập câu hỏi cho tất cả các môn học dưới dạng văn bản.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ),
            SizedBox(height: 16),
            Expanded(child: SizedBox()), // vùng trống (chat sau này)
          ],
        ),
      ),

      // Thanh nhập luôn ở đáy + tự nhấc theo bàn phím
      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: _InputBar(
          controller: _controller,
          onSend: _send,
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({required this.controller, required this.onSend, super.key});

  final TextEditingController controller;
  final VoidCallback onSend;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      minimum: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Stack(
        children: [
          Container(
            height: 56,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE0E0E0)),
            ),
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.only(left: 16, right: 64),
            child: TextField(
              controller: controller,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => onSend(),
              onTapOutside: (_) => FocusScope.of(context).unfocus(),
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'Vui lòng nhập câu hỏi của bạn.',
                hintStyle: TextStyle(color: Colors.black45),
              ),
            ),
          ),
          Positioned(
            right: 6,
            bottom: 6,
            child: Material(
              color: const Color(0xFFE53935),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: onSend,
                child: const SizedBox(
                  height: 44,
                  width: 44,
                  child: Icon(Icons.send, size: 20, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
