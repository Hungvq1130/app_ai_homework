// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'math_html_page.dart';
//
// class HomeShell extends StatefulWidget {
//   const HomeShell({super.key, this.taskId, this.initialMarkdown});
//
//   final String? taskId;           // ⬅️ task_id để poll
//   final String? initialMarkdown;  // nếu đã có sẵn nội dung thì hiển thị ngay
//
//   @override
//   State<HomeShell> createState() => _HomeShellState();
// }
//
// class _HomeShellState extends State<HomeShell> {
//   int _index = 0;
//
//   String? _markdown;     // nội dung kết quả để render
//   String? _error;        // lỗi (nếu có)
//   String? _tStatus;      // pending / assigned / completed
//   bool _loading = false;
//
//   @override
//   void initState() {
//     super.initState();
//     if (widget.initialMarkdown != null && widget.initialMarkdown!.trim().isNotEmpty) {
//       _markdown = _normalize(widget.initialMarkdown!);
//     } else if (widget.taskId != null && widget.taskId!.isNotEmpty) {
//       _pollTask(widget.taskId!);
//     }
//   }
//
//   String _normalize(String s) {
//     // chuẩn hoá xuống dòng để Markdown/MathJax render mượt
//     return s.replaceAll('\r\n', '\n');
//   }
//
//   Future<void> _pollTask(String taskId) async {
//     setState(() {
//       _loading = true;
//       _error = null;
//       _tStatus = 'pending';
//     });
//
//     final started = DateTime.now();
//     const totalTimeout = Duration(minutes: 2); // giới hạn 2 phút
//     var delay = const Duration(seconds: 1);    // backoff 1→5s
//
//     while (mounted) {
//       try {
//         final url = Uri.parse('https://ai-gateway.oneadx.com/v1/tasks/$taskId');
//         final resp = await http.get(url, headers: {'Accept': 'application/json'});
//
//         if (resp.statusCode >= 200 && resp.statusCode < 300) {
//           final map = jsonDecode(resp.body) as Map<String, dynamic>;
//           // Ví dụ JSON bạn đưa:
//           // top-level "status": "success"
//           // task: { status: pending|assigned|completed, result: "...", ... }
//           final task = map['task'] as Map<String, dynamic>?;
//           final tStatus = (task?['status'] as String?)?.toLowerCase();
//
//           setState(() => _tStatus = tStatus ?? _tStatus);
//
//           if (tStatus == 'completed') {
//             final result = (task?['result'] as String?) ?? '';
//             setState(() {
//               _markdown = _normalize(result);
//               _loading = false;
//             });
//             break;
//           }
//
//           // pending/assigned → tiếp tục chờ
//         } else {
//           setState(() {
//             _error = 'HTTP ${resp.statusCode}: ${resp.body}';
//             _loading = false;
//           });
//           break;
//         }
//       } catch (e) {
//         setState(() {
//           _error = 'Lỗi mạng: $e';
//           _loading = false;
//         });
//         break;
//       }
//
//       // kiểm tra timeout
//       if (DateTime.now().difference(started) > totalTimeout) {
//         setState(() {
//           _error = 'Quá thời gian chờ xử lý. Vui lòng thử lại.';
//           _loading = false;
//         });
//         break;
//       }
//
//       // backoff tăng dần 1→5s
//       await Future.delayed(delay);
//       if (delay.inSeconds < 5) {
//         delay = Duration(seconds: delay.inSeconds + 1);
//       }
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // Trang Math hiển thị kết quả
//     final mathPage = _buildMathPage();
//
//     final pages = [mathPage];
//     final titles = ['Giải Toán'];
//
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(titles[_index]),
//         centerTitle: true,
//       ),
//       body: IndexedStack(index: _index, children: pages),
//       bottomNavigationBar: BottomNavigationBar(
//         currentIndex: _index,
//         type: BottomNavigationBarType.fixed,
//         items: const [
//           BottomNavigationBarItem(
//             icon: Icon(Icons.calculate_outlined),
//             activeIcon: Icon(Icons.calculate),
//             label: 'Math',
//           ),
//           // Nếu muốn giữ tab Crop, có thể thêm vào đây sau.
//         ],
//         onTap: (i) => setState(() => _index = i),
//       ),
//     );
//   }
//
//   Widget _buildMathPage() {
//     if (_loading) {
//       final st = (_tStatus ?? 'pending');
//       final friendly =
//       st == 'assigned' ? 'Đang xử lý (assigned)…' : 'Đang chờ xử lý (pending)…';
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(24),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               const CircularProgressIndicator(),
//               const SizedBox(height: 12),
//               Text(friendly, textAlign: TextAlign.center),
//               if (widget.taskId != null) ...[
//                 const SizedBox(height: 4),
//                 Text('task_id: ${widget.taskId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
//               ]
//             ],
//           ),
//         ),
//       );
//     }
//
//     if (_error != null) {
//       return Center(
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             children: [
//               Text(_error!, style: const TextStyle(color: Colors.red)),
//               const SizedBox(height: 12),
//               FilledButton.icon(
//                 onPressed: () {
//                   if (widget.taskId != null && widget.taskId!.isNotEmpty) {
//                     _pollTask(widget.taskId!);
//                   }
//                 },
//                 icon: const Icon(Icons.refresh),
//                 label: const Text('Thử lại'),
//               ),
//             ],
//           ),
//         ),
//       );
//     }
//
//     final content = (_markdown != null && _markdown!.trim().isNotEmpty)
//         ? _markdown!
//         : 'Chưa có nội dung.';
//
//     // Nếu MathHtmlPage nhận 'html' thì đổi thành html: content
//     return MathHtmlPage(markdown: content);
//   }
// }
