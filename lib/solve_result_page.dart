import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'math_html_page.dart';

class SolveResultPage extends StatefulWidget {
  const SolveResultPage({
    super.key,
    required this.taskId,
    this.initialMarkdown,
    this.problemImageDataUrl,
  });

  final String taskId;
  final String? initialMarkdown;
  final String? problemImageDataUrl;

  @override
  State<SolveResultPage> createState() => _SolveResultPageState();
}

class _SolveResultPageState extends State<SolveResultPage> {
  // ---------- Config ----------
  static const _taskBaseUrl = 'https://ai-gateway.oneadx.com/v1/tasks/';
  static const _searchEndpoint = 'http://192.168.68.70:3001/api/search';

  // ---------- State ----------
  String? _markdown;
  String? _error;
  String? _tStatus; // pending / assigned / completed
  bool _loading = false;
  String? _baiGiaiHtml;

  // ---------- Utils ----------
  String _normalize(String s) => s.replaceAll('\r\n', '\n');

  void _logEscaped(String label, String text) {
    debugPrint('$label (escaped): ${jsonEncode(text)}');
  }

  /// Tái cấu trúc phần "Đề bài":
  /// - **Bỏ** toàn bộ phần mô tả trước "## Đề bài" (không hiển thị).
  /// - **Cắt** thân "Đề bài" (không hiển thị), gọi onProblemRemoved để log/gửi API.
  /// - **Chỉ chèn ảnh** đề bài (nếu có) ngay dưới heading.
  String _composeProblemSection(
      String md, {
        String? imageUrl,
        void Function(String problemRemoved)? onProblemRemoved,
      }) {
    final s = _normalize(md);

    // Tìm heading "## Đề bài"
    final headRe = RegExp(
      r'^\s{0,3}#{1,6}\s*đề\s*bài\s*$',
      caseSensitive: false,
      multiLine: true,
    );
    final mHead = headRe.firstMatch(s);

    if (mHead == null) {
      // Không có Đề bài → nếu có ảnh thì tạo khối mới với ảnh; giữ nguyên phần còn lại
      if ((imageUrl ?? '').isNotEmpty) {
        return '## Đề bài\n\n![]($imageUrl)\n\n$s';
      }
      return s;
    }

    // headStart: bắt đầu heading; headEnd: kết thúc heading
    final headStart = mHead.start;
    final headEnd = mHead.end;

    // (1) BỎ mô tả trước heading: không chèn vào đâu cả
    // (2) Xác định thân "Đề bài": sau heading → trước "***" hoặc heading tiếp theo
    int from = headEnd;
    while (from < s.length && (s[from] == '\n' || s[from] == ' ' || s[from] == '\t')) from++;

    int end = s.length;
    final sub = s.substring(from);
    final hrRe = RegExp(r'^\s*\*{3,}\s*$', multiLine: true);         // dòng ***
    final nextHeadRe = RegExp(r'^\s{0,3}#{1,6}\s+', multiLine: true); // heading mới

    final mHr = hrRe.firstMatch(sub);
    if (mHr != null) end = from + mHr.start;
    final mNext = nextHeadRe.firstMatch(sub);
    if (mNext != null) {
      final abs = from + mNext.start;
      if (abs < end) end = abs;
    }

    // (3) Lấy thân Đề bài để log/gửi API, sau đó loại khỏi render
    final problemBody = s.substring(from, end)
        .replaceFirst(RegExp(r'^\n+'), '')
        .replaceFirst(RegExp(r'\s+$'), '');
    if (problemBody.isNotEmpty) onProblemRemoved?.call(problemBody);

    // (4) Lắp lại tài liệu:
    // - BỎ phần trước heading (mô tả)
    // - GIỮ heading "## Đề bài"
    // - CHỈ chèn ảnh (nếu có)
    // - Giữ phần sau end (***, Phương pháp, Bài giải…)
    final headLine = s.substring(headStart, headEnd);
    final after = s.substring(end);

    final buf = StringBuffer()
      ..writeln(headLine)
      ..writeln();

    if ((imageUrl ?? '').isNotEmpty) {
      buf
        ..writeln('![]($imageUrl)')
        ..writeln();
    }

    buf.write(after);
    return buf.toString();
  }

  void _logBaiGiaiFromSearchResponse(String body) {
    try {
      final obj = jsonDecode(body);
      final data = obj['data'];
      if (data is List && data.isNotEmpty) {
        final first = data.first as Map<String, dynamic>;
        final baiGiai = (first['baiGiai'] ?? '') as String;
        if (baiGiai.isNotEmpty) {
          debugPrint('SEARCH API baiGiai (escaped): ${jsonEncode(baiGiai)}');
          debugPrint('SEARCH API baiGiai length: ${baiGiai.length}');

          // 👉 Lưu và mở trang HTML theo template DB
          if (mounted) {
            setState(() => _baiGiaiHtml = baiGiai);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => MathHtmlPage.dbHtml(
                  html: _baiGiaiHtml!,   // HTML thuần
                  title: 'Lời giải (DB)',// tuỳ chỉnh
                ),
              ),
            );
          }
        } else {
          debugPrint('SEARCH API: không có baiGiai trong phần tử đầu tiên.');
        }
      } else {
        debugPrint('SEARCH API: data rỗng hoặc không phải List.');
      }
    } catch (e) {
      debugPrint('SEARCH API parse error: $e');
    }
  }


  Future<void> _sendProblemToAnotherApi(String problemText) async {
    final query = problemText.trim();
    _logEscaped('SEARCH API query', query);
    if (query.isEmpty) {
      debugPrint('SEARCH API: skipped (empty query)');
      return;
    }

    final payload = {'query': query};

    try {
      final res = await http
          .post(
        Uri.parse(_searchEndpoint),
        headers: {'Content-Type': 'application/json; charset=utf-8'},
        body: jsonEncode(payload),
      )
          .timeout(const Duration(seconds: 600));

      debugPrint('SEARCH API status: ${res.statusCode}');
      // 👉 Log riêng baiGiai
      _logBaiGiaiFromSearchResponse(res.body);
    } catch (e) {
      debugPrint('SEARCH API error: $e');
    }
  }




  // ---------- Lifecycle ----------
  @override
  void initState() {
    super.initState();

    final initial = (widget.initialMarkdown ?? '').trim();
    if (initial.isNotEmpty) {
      var md = _normalize(initial);
      md = _composeProblemSection(
        md,
        imageUrl: widget.problemImageDataUrl,
        onProblemRemoved: (pb) {
          _sendProblemToAnotherApi(pb);
        },
      );
      _markdown = md;
    } else {
      _pollTask(widget.taskId);
    }
  }

  // ---------- Networking ----------
  Future<void> _pollTask(String taskId) async {
    setState(() {
      _loading = true;
      _error = null;
      _tStatus = 'pending';
    });

    final started = DateTime.now();
    const totalTimeout = Duration(minutes: 2);
    var delay = const Duration(seconds: 1);

    while (mounted) {
      try {
        final resp = await http
            .get(Uri.parse('$_taskBaseUrl$taskId'), headers: {'Accept': 'application/json'})
            .timeout(const Duration(seconds: 20));

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          final map = jsonDecode(resp.body) as Map<String, dynamic>;
          final task = map['task'] as Map<String, dynamic>?;
          final tStatus = (task?['status'] as String?)?.toLowerCase();
          setState(() => _tStatus = tStatus ?? _tStatus);

          if (tStatus == 'completed') {
            final result = (task?['result'] as String?) ?? '';
            var md = _normalize(result);

            md = _composeProblemSection(
              md,
              imageUrl: widget.problemImageDataUrl,
              onProblemRemoved: (pb) {
                _logEscaped('DE BAI_REMOVED', pb);
                _sendProblemToAnotherApi(pb);
              },
            );

            if (!mounted) return;
            setState(() {
              _markdown = md; // Đề bài = CHỈ ẢNH; Phương pháp/Bài giải giữ nguyên
              _loading = false;
            });
            break;
          }
          // else: pending/assigned → tiếp tục
        } else {
          if (!mounted) return;
          setState(() {
            _error = 'HTTP ${resp.statusCode}: ${resp.body}';
            _loading = false;
          });
          break;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() {
          _error = 'Lỗi mạng: $e';
          _loading = false;
        });
        break;
      }

      if (DateTime.now().difference(started) >= totalTimeout) {
        if (!mounted) return;
        setState(() {
          _error = 'Quá thời gian chờ xử lý. Vui lòng thử lại.';
          _loading = false;
        });
        break;
      }

      await Future.delayed(delay);
      if (delay.inSeconds < 5) delay = Duration(seconds: delay.inSeconds + 1);
    }
  }



  // ---------- UI ----------
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: _buildBody());
  }

  Widget _buildBody() {
    if (_loading) {
      final st = (_tStatus ?? 'pending');
      final friendly = st == 'assigned' ? 'Đang xử lý (assigned)…' : 'Đang chờ xử lý (pending)…';
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 12),
              Text(friendly, textAlign: TextAlign.center),
              const SizedBox(height: 4),
              Text('task_id: ${widget.taskId}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.red)),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => _pollTask(widget.taskId),
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    final content = (_markdown ?? '').trim().isNotEmpty ? _markdown! : 'Chưa có nội dung.';
    return MathHtmlPage(markdown: content);
  }
}
