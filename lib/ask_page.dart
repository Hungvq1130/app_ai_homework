import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:solve_exercise/solve_result_page.dart';

/// TODO: Đưa các hằng số này ra env/secure storage khi lên prod
const String _apiUrl = 'https://ai-gateway.oneadx.com/v1/chat/';
const String _apiKey = 'tyff8tkw1t0rfz0bcs8yo3gzrt9wajkd';

class AskPage extends StatefulWidget {
  const AskPage({super.key});

  @override
  State<AskPage> createState() => _AskPageState();
}

class _AskPageState extends State<AskPage> {
  final _controller = TextEditingController();
  bool _loading = false;

  Future<void> _send() async {
    if (_loading) return;

    final q = _controller.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung câu hỏi')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final body = {
        "language": "Vietnamese",
        "content": q,                 // đề bài người dùng nhập
        "subject": "math",            // có thể thay bằng dropdown nếu bạn muốn
        "time": DateTime.now().millisecondsSinceEpoch,
        "api_key": _apiKey,
      };

      final resp = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        final status = data['status']?.toString();
        final taskId = data['task_id']?.toString();

        if (status == 'success' && taskId != null && taskId.isNotEmpty) {
          if (!mounted) return;
          // Điều hướng sang trang xử lý kết quả theo task_id
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SolveResultPage(
                taskId: taskId,
                originalQuestion: q,
              ),
            ),
          );
          _controller.clear();
        } else {
          _showError(
            'Gửi câu hỏi thất bại: ${data['message'] ?? 'Không nhận được task_id'}',
          );
        }
      } else {
        _showError('Máy chủ trả về mã lỗi ${resp.statusCode}');
      }
    } catch (e) {
      _showError('Không thể gửi câu hỏi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true,

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        centerTitle: true,
        title: const Text(''),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarBrightness: Brightness.light,
          statusBarIconBrightness: Brightness.dark,
        ),
      ),

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
            Expanded(child: SizedBox()),
          ],
        ),
      ),

      bottomNavigationBar: AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: _InputBar(
          controller: _controller,
          onSend: _send,
          loading: _loading,
        ),
      ),
    );
  }
}

class _InputBar extends StatelessWidget {
  const _InputBar({
    required this.controller,
    required this.onSend,
    required this.loading,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback onSend;
  final bool loading;

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
              enabled: !loading,
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
                onTap: loading ? null : onSend,
                child: SizedBox(
                  height: 44,
                  width: 44,
                  child: Center(
                    child: loading
                        ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                        : const Icon(Icons.send, size: 20, color: Colors.white),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
