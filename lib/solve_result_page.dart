import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import 'math_html_page.dart';
import 'history_store.dart';

class SolveResultPage extends StatefulWidget {
  const SolveResultPage({
    super.key,
    required this.taskId,
    this.initialMarkdown,
    this.problemImageDataUrl,
    this.originalQuestion, // ✅ đề bài text (nếu có)
  });

  final String taskId;
  final String? initialMarkdown;
  final String? problemImageDataUrl;
  final String? originalQuestion; // ✅ mới thêm

  @override
  State<SolveResultPage> createState() => _SolveResultPageState();
}

class _SolveResultPageState extends State<SolveResultPage> {
  // ---------- Config ----------
  static const _taskBaseUrl = 'https://ai-gateway.oneadx.com/v1/tasks/';
  // static const _searchEndpoint = 'http://192.168.68.73:3001/api/search';

  // ---------- State ----------
  String? _markdown;
  String? _error;
  String? _tStatus; // pending / assigned / completed
  bool _loading = false;
  String? _baiGiaiHtml;

  // Bảo vệ không gọi SEARCH API trùng lặp
  bool _searchSent = false;

  bool _saved = false;

  Future<void> _saveToLocalHistory() async {
    if (_saved) return;
    final md = (_markdown ?? '').trim();
    if (md.isEmpty) return;

    final path = await HistoryStore.persistImageIfNeeded(widget.problemImageDataUrl);
    final item = SolvedItem(
      id: const Uuid().v4(),
      originalQuestion: (widget.originalQuestion ?? '').trim().isEmpty ? null : widget.originalQuestion!.trim(),
      imagePath: path,
      markdown: md,
      createdAt: DateTime.now(),
    );
    await HistoryStore.add(item);
    _saved = true;

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Đã lưu vào Lịch sử giải bài')),
      );
    }
  }

  // ---------- Utils ----------
  String _normalize(String s) => s.replaceAll('\r\n', '\n');

  void _logEscaped(String label, String text) {
    debugPrint('$label (escaped): ${jsonEncode(text)}');
  }

  /// Lắp lại section "## Đề bài"
  /// - Nếu K.O tồn tại heading "## Đề bài": tự tạo heading và chèn ảnh/text nếu có
  /// - Nếu có heading: loại phần thân cũ, giữ heading, rồi chèn ảnh/text mới (nếu có)
  String _composeProblemSection(
      String md, {
        String? imageUrl,
        String? problemText, // ✅ đề bài text để hiển thị
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

    // Helper: build block chèn vào sau heading
    String _buildProblemBlock() {
      final buf = StringBuffer();
      if ((imageUrl ?? '').isNotEmpty) {
        buf.writeln('![]($imageUrl)');
        buf.writeln();
      }
      if ((problemText ?? '').trim().isNotEmpty) {
        // Chèn đề bài text (markdown thường)
        buf.writeln(problemText!.trim());
        buf.writeln();
      }
      return buf.toString();
    }

    if (mHead == null) {
      // Không có "## Đề bài" → tạo mới
      final pbBlock = _buildProblemBlock();
      if (pbBlock.isNotEmpty) {
        return '## Đề bài\n\n$pbBlock$s';
      }
      return s; // không có ảnh/text thì giữ nguyên
    }

    // headStart: bắt đầu heading; headEnd: kết thúc heading
    final headStart = mHead.start;
    final headEnd = mHead.end;

    // Xác định thân "Đề bài": sau heading → trước "***" hoặc heading tiếp theo
    int from = headEnd;
    while (from < s.length &&
        (s[from] == '\n' || s[from] == ' ' || s[from] == '\t')) {
      from++;
    }

    int end = s.length;
    final sub = s.substring(from);
    final hrRe = RegExp(r'^\s*\*{3,}\s*$', multiLine: true); // dòng ***
    final nextHeadRe = RegExp(r'^\s{0,3}#{1,6}\s+', multiLine: true); // heading mới

    final mHr = hrRe.firstMatch(sub);
    if (mHr != null) end = from + mHr.start;
    final mNext = nextHeadRe.firstMatch(sub);
    if (mNext != null) {
      final abs = from + mNext.start;
      if (abs < end) end = abs;
    }

    // Lấy thân Đề bài cũ (để gửi SEARCH API nếu cần), sau đó loại khỏi render
    final problemBody = s
        .substring(from, end)
        .replaceFirst(RegExp(r'^\n+'), '')
        .replaceFirst(RegExp(r'\s+$'), '');
    if (problemBody.isNotEmpty) {
      onProblemRemoved?.call(problemBody);
    }

    // Lắp lại tài liệu:
    // - GIỮ heading "## Đề bài"
    // - CHỈ chèn ảnh/text (nếu có)
    // - Giữ phần sau end (***, Phương pháp, Bài giải…)
    final headLine = s.substring(headStart, headEnd);
    final after = s.substring(end);

    final buf = StringBuffer()
      ..writeln(headLine)
      ..writeln();

    final pbBlock = _buildProblemBlock();
    if (pbBlock.isNotEmpty) {
      buf.write(pbBlock);
    }

    buf.write(after);
    return buf.toString();
  }

  Future<void> _sendProblemToAnotherApi(String problemText) async {
    final query = problemText.trim();
    if (_searchSent) {
      debugPrint('SEARCH API: skipped (already sent once)');
      return;
    }
    if (query.isEmpty) {
      debugPrint('SEARCH API: skipped (empty query)');
      return;
    }

    _searchSent = true; // ✅ đảm bảo chỉ gửi 1 lần
    _logEscaped('SEARCH API query', query);

    final payload = {'query': query};

    // try {
    //   final res = await http
    //       .post(
    //     Uri.parse(_searchEndpoint),
    //     headers: {'Content-Type': 'application/json; charset=utf-8'},
    //     body: jsonEncode(payload),
    //   )
    //       .timeout(const Duration(seconds: 300));
    //
    //   debugPrint('SEARCH API status: ${res.statusCode}');
    //   // Nếu muốn, có thể parse res.body để mở HTML lời giải như trước
    //   // _logBaiGiaiFromSearchResponse(res.body);
    // } catch (e) {
    //   debugPrint('SEARCH API error: $e');
    // }
  }

  // ---------- Lifecycle ----------
  @override
  void initState() {
    super.initState();

    final initial = (widget.initialMarkdown ?? '').trim();

    if (initial.isNotEmpty) {
      // Trường hợp đã có markdown khởi tạo (giữ logic cũ), nhưng thêm hiển thị text đề bài nếu có
      var md = _normalize(initial);
      md = _composeProblemSection(
        md,
        imageUrl: widget.problemImageDataUrl,
        problemText: widget.originalQuestion, // ✅ chèn text nếu có
        onProblemRemoved: (pb) {
          _sendProblemToAnotherApi(pb); // ưu tiên text trích từ markdown
        },
      );
      _markdown = md;

      // Nếu markdown KHÔNG có phần Đề bài nội tại và ta chưa gửi SEARCH,
      // gửi SEARCH bằng originalQuestion (nếu có)
      if (!_searchSent &&
          (widget.originalQuestion ?? '').trim().isNotEmpty) {
        _sendProblemToAnotherApi(widget.originalQuestion!.trim());
      }
      setState(() {}); // render ngay
      
    } else {
      // Chưa có nội dung → poll task
      // Gửi SEARCH sớm bằng originalQuestion (nếu có) để hiển thị nhanh từ DB
      if ((widget.originalQuestion ?? '').trim().isNotEmpty) {
        _sendProblemToAnotherApi(widget.originalQuestion!.trim());
      }
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
            .get(Uri.parse('$_taskBaseUrl$taskId'),
            headers: {'Accept': 'application/json'})
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
              problemText: widget.originalQuestion, // ✅ chèn text nếu có
              onProblemRemoved: (pb) {
                _logEscaped('DE BAI_REMOVED', pb);
                _sendProblemToAnotherApi(pb); // ưu tiên text trích từ markdown
              },
            );

            // Nếu không trích được đề bài từ markdown và chưa gửi SEARCH,
            // fallback gửi bằng originalQuestion
            if (!_searchSent &&
                (widget.originalQuestion ?? '').trim().isNotEmpty) {
              _sendProblemToAnotherApi(widget.originalQuestion!.trim());
            }

            if (!mounted) return;
            setState(() {
              _markdown = md; // Đề bài = ẢNH +/hoặc TEXT; Phương pháp/Bài giải giữ nguyên
              _loading = false;
            });
            await _saveToLocalHistory();
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
      final friendly =
      st == 'assigned' ? 'Đang xử lý (assigned)…' : 'Đang chờ xử lý (pending)…';
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
              Text('task_id: ${widget.taskId}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey)),
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

    final content =
    (_markdown ?? '').trim().isNotEmpty ? _markdown! : 'Chưa có nội dung.';
    return MathHtmlPage(markdown: content);
  }
}
