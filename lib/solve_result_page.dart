import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solve_exercise/utility.dart';
import 'package:uuid/uuid.dart';
import 'math_html_page.dart';
import 'history_store.dart';
import 'dart:io';
import 'dart:typed_data';

class SolveResultPage extends StatefulWidget {
  const SolveResultPage({
    super.key,
    required this.taskId,
    this.initialMarkdown,
    this.problemImageDataUrl,
    this.originalQuestion,
  });

  final String taskId;
  final String? initialMarkdown;
  final String? problemImageDataUrl;
  final String? originalQuestion;

  @override
  State<SolveResultPage> createState() => _SolveResultPageState();
}

class _SolveResultPageState extends State<SolveResultPage> {
  static const _taskBaseUrl = 'https://ai-gateway.oneadx.com/v1/tasks/';

  String? _markdown; // chỉ phần "Phương pháp/Lời giải" sau khi _methodOnly
  String? _error;
  String? _tStatus;
  bool _loading = false;
  bool _saved = false;

  String _normalize(String s) => s.replaceAll('\r\n', '\n');

  String _methodOnly(String md) {
    final s = _normalize(md);

    final reMethod = RegExp(
      r'^\s{0,3}#{1,6}.*?(phương\s*pháp(\s*giải)?|phuong\s*phap(\s*giai)?|hướng\s*giải|huong\s*giai|method|approach)\b.*$',
      caseSensitive: false, multiLine: true,
    );
    final reSolution = RegExp(
      r'^\s{0,3}#{1,6}.*?(lời\s*giải\s*chi\s*tiết|loi\s*giai\s*chi\s*tiet|giải\s*chi\s*tiết|giai\s*chi\s*tiet|lời\s*giải|loi\s*giai|bài\s*giải|bai\s*giai|solution)\b.*$',
      caseSensitive: false, multiLine: true,
    );

    int start = 0;
    final m1 = reMethod.firstMatch(s);
    final m2 = reSolution.firstMatch(s);
    if (m1 != null) start = m1.start; else if (m2 != null) start = m2.start;

    var out = s.substring(start);

    final stripProblem = RegExp(
      r'^\s{0,3}#{1,6}.*?(đề\s*bài|de\s*bai|câu\s*hỏi|cau\s*hoi|bài\s*toán|bai\s*toan|problem|question)\b.*$\n'
      r'(?:[\s\S]*?)(?=^\s{0,3}#{1,6}\s|\Z)',
      caseSensitive: false, multiLine: true,
    );
    out = out.replaceAll(stripProblem, '').trimLeft();
    return out.isEmpty ? 'Chưa có nội dung.' : out;
  }

  // --- NEW: sinh Markdown cho phần "Câu hỏi" (placeholder nếu chưa có) ---
  String _problemSectionMarkdown() {
    final q = (widget.originalQuestion ?? '').trim();
    final img = (widget.problemImageDataUrl ?? '').trim();

    final b = StringBuffer('## Câu hỏi\n');
    if (q.isNotEmpty) b.writeln(_normalize(q));
    if (img.isNotEmpty) {
      b.writeln();
      b.writeln('![]($img)');
    }
    return b.toString().trim();
  }

  // --- NEW: gộp Câu hỏi + Phương pháp/Lời giải vào CÙNG 1 WebView ---
  String _composeFullMarkdown(String methodMd) {
    return '${_problemSectionMarkdown()}\n\n$methodMd';
  }

  Future<void> _saveToLocalHistory() async {
    if (_saved) return;
    final mm = (_markdown ?? '').trim();
    if (mm.isEmpty) return;

    final fullMd = _composeFullMarkdown(mm); // lưu cả 2 phần
    final path = await HistoryStore.persistImageIfNeeded(widget.problemImageDataUrl);
    final item = SolvedItem(
      id: const Uuid().v4(),
      originalQuestion: (widget.originalQuestion ?? '').trim().isEmpty
          ? null
          : widget.originalQuestion!.trim(),
      imagePath: path,
      markdown: fullMd,
      createdAt: DateTime.now(),
    );
    await HistoryStore.add(item);
    _saved = true;
  }

  @override
  void initState() {
    super.initState();
    final initial = (widget.initialMarkdown ?? '').trim();
    if (initial.isNotEmpty) {
      _markdown = _methodOnly(initial);
      setState(() {});
      _saveToLocalHistory();
    } else {
      _pollTask(widget.taskId);
    }
  }

  Future<void> _pollTask(String taskId) async {
    setState(() {
      _error = null;
      _tStatus = 'pending';
    });

    final started = DateTime.now();
    const totalTimeout = Duration(minutes: 2);
    var delay = const Duration(seconds: 1);
    var lastStatus = _tStatus; // <-- thêm

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

          if (tStatus == 'completed') {
            final result = (task?['result'] as String?) ?? '';
            final md = _methodOnly(result);
            if (!mounted) return;
            setState(() {
              _tStatus = tStatus;
              _markdown = md;
            });
            await _saveToLocalHistory();
            break;
          }

          // ✅ chỉ cập nhật UI khi status đổi (pending -> assigned, ...)
          if (tStatus != null && tStatus != lastStatus) {
            lastStatus = tStatus;
            if (mounted) setState(() => _tStatus = tStatus);
          }
        } else {
          if (!mounted) return;
          setState(() {
            _error = 'HTTP ${resp.statusCode}: ${resp.body}';
          });
          break;
        }
      } catch (e) {
        if (!mounted) return;
        setState(() => _error = 'Lỗi mạng: $e');
        break;
      }

      if (DateTime.now().difference(started) >= totalTimeout) {
        if (!mounted) return;
        setState(() => _error = 'Quá thời gian chờ xử lý. Vui lòng thử lại.');
        break;
      }

      await Future.delayed(delay);
      if (delay.inSeconds < 5) delay = Duration(seconds: delay.inSeconds + 1);
    }
  }

  // ---------- UI ----------
  @override
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const SoftGradientBackground(includeBaseLayer: true), // 👈 nền gradient
        Scaffold(
          backgroundColor: Colors.transparent,   // 👈 trong suốt để thấy gradient
          extendBody: true,                      // 👈 tránh lộ nền trắng ở mép
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            scrolledUnderElevation: 0,
            title: const Text('Xem lời giải'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
            actions: const [
              Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.notifications_none_rounded),
              ),
            ],
          ),
          body: _buildBody(),
        ),
      ],
    );
  }


  Widget _buildBody() {
    final methodMd = (_markdown ?? '').trim();
    final hasResult = methodMd.isNotEmpty && _error == null;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Card 1: CÂU HỎI
        _QuestionCard(
          text: (widget.originalQuestion ?? '').trim(),
          imageDataUrl: (widget.problemImageDataUrl ?? '').trim(),
        ),
        const SizedBox(height: 12),

        // Card 2: TRẠNG THÁI / LỖI / KẾT QUẢ
        if (_error != null) ...[
          _ErrorCard(
            message: _error!,
            onRetry: () => _pollTask(widget.taskId),
          ),
        ] else if (!hasResult) ...[
          _ProcessingCard(status: (_tStatus ?? 'pending')),
        ] else ...[
          _MethodCard(
            header: null,         // không hiện "Phương pháp giải"
            trailing: null,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: MathHtmlPage(
                markdown: methodMd,
              ),
            ),
          ),
        ],
        const SizedBox(height: 24),
      ],
    );
  }

}

/// ====== Thẻ "Câu hỏi" (khung + icon + nút chia sẻ) ======
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({
    this.text,
    this.imageDataUrl,
  });

  final String? text;
  final String? imageDataUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingGradientCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 22, height: 22,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFE9F2FF),
                  border: Border.all(color: const Color(0xFFB7D6FF)),
                ),
                child: const Icon(Icons.help_outline, size: 16, color: Color(0xFF3B82F6)),
              ),
              const SizedBox(width: 8),
              Text(
                'Câu hỏi',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(.75),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),

          // nội dung/placeholder (giữ nguyên logic bạn đã viết)
          Builder(
            builder: (_) {
              final hasText  = text != null && text!.trim().isNotEmpty;
              final hasImage = imageDataUrl != null && imageDataUrl!.trim().isNotEmpty;

              if (hasText && hasImage) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text!, style: Theme.of(context).textTheme.bodyMedium),
                    const SizedBox(height: 8),
                    _ProblemImage(image: imageDataUrl!),
                  ],
                );
              }
              if (hasText) return Text(text!, style: Theme.of(context).textTheme.bodyMedium);
              if (hasImage) return _ProblemImage(image: imageDataUrl!);
              return Text('— Đang lấy nội dung đề bài…', style: Theme.of(context).textTheme.bodyMedium);
            },
          ),

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

/// ====== Header tròn như ảnh ======
class _HeaderBar extends StatelessWidget {
  const _HeaderBar({required this.onBack});
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    final muted = Colors.black.withOpacity(.60);
    return Row(
      children: [
        _RoundIconButton(icon: Icons.arrow_back_ios_new_rounded, onTap: onBack),
        const Spacer(),
        _RoundIconButton(icon: Icons.notifications_none_rounded, onTap: () {}),
      ],
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  const _RoundIconButton({required this.icon, required this.onTap});
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withOpacity(.75),
      shape: const CircleBorder(),
      elevation: 0,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, color: Colors.black), // <— dùng icon truyền vào
        ),
      ),
    );
  }
}

class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.child,
    this.header,          // null => không vẽ header
    this.trailing,
  });

  final String? header;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return OnboardingGradientCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (header != null) ...[
            Row(
              children: [
                Container(
                  width: 22, height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE9FFF1),
                    border: Border.all(color: const Color(0xFF8FE3B4)),
                  ),
                  child: const Icon(Icons.check, size: 16, color: Color(0xFF10B981)),
                ),
                const SizedBox(width: 8),
                Text(
                  header!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: Colors.black.withOpacity(.75),
                  ),
                ),
                const Spacer(),
                if (trailing != null) trailing!,
              ],
            ),
            const SizedBox(height: 10),
          ],
          // Nội dung
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: child,
          ),
        ],
      ),
    );

  }
}

class _ProblemImage extends StatelessWidget {
  const _ProblemImage({required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    Widget child;

    try {
      if (image.startsWith('data:')) {
        // data:[mime];base64,XXXXX
        final data = UriData.parse(image);
        final Uint8List bytes = data.contentAsBytes();
        child = Image.memory(
          bytes,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
        );
      } else if (image.startsWith('http')) {
        child = Image.network(
          image,
          fit: BoxFit.contain,
          loadingBuilder: (c, w, p) =>
          p == null ? w : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorBuilder: (c, e, s) => const Center(child: Text('Không tải được ảnh')),
        );
      } else {
        // phòng khi bạn chuyển sang lưu file path cục bộ
        child = Image.file(File(image), fit: BoxFit.contain);
      }
    } catch (_) {
      child = const Center(child: Text('Không đọc được ảnh'));
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 260), // tuỳ chỉnh
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Color(0xFFE5EAF0)),
      ),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}

class _ProcessingCard extends StatelessWidget {
  const _ProcessingCard({required this.status});
  final String status; // pending / assigned / ...

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = (status == 'assigned')
        ? 'Học bá AI đang phân tích...'
        : 'Đang chờ xử lý...';

    return OnboardingGradientCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          const SizedBox(
            width: 22, height: 22,
            child: CircularProgressIndicator(strokeWidth: 2.6),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.black.withOpacity(.75),
              ),
              maxLines: 1, overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );

  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return OnboardingGradientCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Có lỗi xảy ra',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w800, color: Colors.redAccent,
            ),
          ),
          const SizedBox(height: 6),
          Text(message, style: const TextStyle(color: Colors.red)),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Thử lại'),
            ),
          ),
        ],
      ),
    );
  }
}
