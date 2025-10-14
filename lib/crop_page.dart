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

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _openCameraAndSend());
  }

  Future<void> _openCameraAndSend() async {
    if (_launched) return;
    _launched = true;

    try {
      final res = await _ch.invokeMapMethod<String, dynamic>('cameraAndCrop');
      if (!mounted) return;

      // Nếu người dùng huỷ hoặc lib trả về null -> thoát trang này luôn (không để lại “trang trắng”)
      if (res == null) {
        _leaveThisPage();
        return;
      }

      final b64  = res['base64'] as String?;
      final mime = (res['mime'] as String?) ?? 'image/png';
      if (b64 == null || b64.isEmpty) {
        _leaveThisPage();
        return;
      }

      final dataUrl = 'data:$mime;base64,$b64';
      await _submitToApi(dataUrl);
    } on PlatformException catch (e) {
      if (!mounted) return;

      // Bắt case cancel từ native (“CAMERA_CANCEL”, “GALLERY_CANCEL”, có thể là “CROP_ERROR” do user back)
      final code = e.code.toUpperCase();
      if (code.contains('CANCEL')) {
        _leaveThisPage();
        return;
      }

      // Lỗi khác -> cũng rời trang, không để người dùng mắc kẹt ở CropPage trắng
      _leaveThisPage();
    } catch (_) {
      if (!mounted) return;
      _leaveThisPage();
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
          // Thay thế CropPage bằng trang kết quả ⇒ back sẽ KHÔNG quay về CropPage trắng
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => SolveResultPage(taskId: taskId)),
          );
          return;
        }
      }

      // Bất kỳ lỗi/response không hợp lệ -> không để người dùng ở lại CropPage trắng
      _leaveThisPage();
    } catch (_) {
      if (!mounted) return;
      _leaveThisPage();
    }
  }

  void _leaveThisPage() {
    // Pop nếu còn trang phía sau; nếu không thì thay bằng HomePage
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Trang này chỉ là “trạm trung chuyển” → show loader ngắn rồi tự biến mất
    return WillPopScope(
      onWillPop: () async {
        _leaveThisPage(); // vuốt back → không quay về “trang trắng”, mà thoát hẳn CropPage
        return false;     // chặn pop mặc định (đã tự xử lý ở trên)
      },
      child: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 12),
                  Text('Đang mở camera...'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
