import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:solve_exercise/solve_result_page.dart';
import 'home_page.dart';

class CropPage extends StatefulWidget {
  const CropPage({super.key});

  @override
  State<CropPage> createState() => _CropPageState();
}

class _CropPageState extends State<CropPage> {
  static const _ch = MethodChannel('image_cropper');

  bool _launched = false;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCameraAndSend());
  }

  Future<void> _openCameraAndSend() async {
    if (_launched) return;
    _launched = true;
    setState(() {
      _error = null;
      _loading = true;
    });

    try {
      final res = await _ch.invokeMapMethod<String, dynamic>('cameraAndCrop');
      if (!mounted) return;

      if (res == null) {
        setState(() {
          _error = 'Không nhận được dữ liệu từ hệ thống.';
          _loading = false;
          _launched = false;
        });
        return;
      }

      final b64  = res['base64'] as String?;
      final mime = (res['mime'] as String?) ?? 'image/jpeg';
      if (b64 == null || b64.isEmpty) {
        setState(() {
          _error = 'Ảnh rỗng hoặc không hợp lệ.';
          _loading = false;
          _launched = false;
        });
        return;
      }

      final dataUrl = 'data:$mime;base64,$b64';
      await _submitToApi(dataUrl);
    } on PlatformException catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.message ?? 'Đã xảy ra lỗi không xác định.';
        _loading = false;
        _launched = false;
      });
    }
  }

  Future<void> _submitToApi(String dataUrl) async {
    const endpoint = 'https://ai-gateway.oneadx.com/v1/chat/';

    final payload = {
      "image_url": dataUrl,
      "language": "Vietnamese",
      "subject": "math",
      "time": DateTime.now().millisecondsSinceEpoch,
      "api_key": "tyff8tkw1t0rfz0bcs8yo3gzrt9wajkd",
    };

    try {
      final resp = await http.post(
        Uri.parse(endpoint),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(payload),
      );

      if (!mounted) return;

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final json = jsonDecode(resp.body) as Map<String, dynamic>;
        final taskId = json['task_id'] as String?;
        final status = json['status'] as String?;

        if (status == 'success' && taskId != null) {
          // ✅ Sang trang hiển thị kết quả (không dính bottom bar)
          if (!mounted) return;
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => SolveResultPage(taskId: taskId)),
          );
          return;
        } else {
          setState(() {
            _error = 'Phản hồi không hợp lệ (status=$status).';
            _loading = false;
            _launched = false;
          });
        }
      } else {
        setState(() {
          _error = 'Gọi API lỗi (HTTP ${resp.statusCode}). Thông điệp: ${resp.body}';
          _loading = false;
          _launched = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = 'Lỗi mạng: $e';
        _loading = false;
        _launched = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
            ),
          ),
        ),
      ),
    );
  }
}
