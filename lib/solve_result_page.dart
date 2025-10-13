import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'math_html_page.dart';
import 'crop_page.dart';

class SolveResultPage extends StatefulWidget {
  const SolveResultPage({super.key, required this.taskId, this.initialMarkdown});

  final String taskId;
  final String? initialMarkdown;

  @override
  State<SolveResultPage> createState() => _SolveResultPageState();
}

class _SolveResultPageState extends State<SolveResultPage> {
  String? _markdown;
  String? _error;
  String? _tStatus; // pending / assigned / completed
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if ((widget.initialMarkdown ?? '').trim().isNotEmpty) {
      _markdown = _normalize(widget.initialMarkdown!);
    } else {
      _pollTask(widget.taskId);
    }
  }

  String _normalize(String s) => s.replaceAll('\r\n', '\n');

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
        final resp = await http.get(
          Uri.parse('https://ai-gateway.oneadx.com/v1/tasks/$taskId'),
          headers: {'Accept': 'application/json'},
        );

        if (resp.statusCode >= 200 && resp.statusCode < 300) {
          final map = jsonDecode(resp.body) as Map<String, dynamic>;
          final task = map['task'] as Map<String, dynamic>?;
          final tStatus = (task?['status'] as String?)?.toLowerCase();
          setState(() => _tStatus = tStatus ?? _tStatus);

          if (tStatus == 'completed') {
            final result = (task?['result'] as String?) ?? '';
            setState(() {
              _markdown = _normalize(result);
              _loading = false;
            });
            break;
          }
          // pending/assigned → tiếp tục
        } else {
          setState(() {
            _error = 'HTTP ${resp.statusCode}: ${resp.body}';
            _loading = false;
          });
          break;
        }
      } catch (e) {
        setState(() {
          _error = 'Lỗi mạng: $e';
          _loading = false;
        });
        break;
      }

      if (DateTime.now().difference(started) > totalTimeout) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      final st = (_tStatus ?? 'pending');
      final friendly = st == 'assigned'
          ? 'Đang xử lý (assigned)…'
          : 'Đang chờ xử lý (pending)…';
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

    final content = (_markdown ?? '').trim().isNotEmpty
        ? _markdown!
        : 'Chưa có nội dung.';
    return MathHtmlPage(markdown: content); // hoặc html: content nếu bạn dùng HTML
  }
}
