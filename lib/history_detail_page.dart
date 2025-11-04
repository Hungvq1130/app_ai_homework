import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground
import 'math_html_page.dart';
import 'history_store.dart'; // SolvedItem

class HistoryDetailPage extends StatelessWidget {
  final SolvedItem item;
  const HistoryDetailPage({super.key, required this.item});

  // --- copy lại logic tách "Phương pháp/Lời giải" giống SolveResultPage ---
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

  @override
  Widget build(BuildContext context) {
    final methodMd = _methodOnly(item.markdown);

    return Stack(
      children: [
        const SoftGradientBackground(includeBaseLayer: true),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Xem lời giải'),
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _QuestionCard(
                text: (item.originalQuestion ?? '').trim(),
                image: (item.imagePath ?? '').trim(), // có thể là file path / http / data:
              ),
              const SizedBox(height: 12),
              _MethodCard(
                header: null, // đồng bộ SolveResultPage: không hiện title card
                trailing: null,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: MathHtmlPage(
                    markdown: methodMd,
                    maxHeight: MediaQuery.sizeOf(context).height * 0.9,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }
}

/// ====== Thẻ "Câu hỏi" ======
class _QuestionCard extends StatelessWidget {
  const _QuestionCard({this.text, this.image});
  final String? text;
  final String? image;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final hasImg = image != null && image!.trim().isNotEmpty;
    final showText = text != null && text!.trim().isNotEmpty;
    final showPlaceholder = !showText && !hasImg;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(0, 3), color: Color(0x14000000)),
        ],
      ),
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
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: Colors.black.withOpacity(.75),
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Chỉ hiện text khi có nội dung
          if (showText)
            Text(
              text!.trim(),
              style: theme.textTheme.bodyMedium,
            ),

          // Placeholder chỉ hiện khi không có text và không có ảnh
          if (showPlaceholder)
            Text(
              '— Không có nội dung đề bài.',
              style: theme.textTheme.bodyMedium,
            ),

          // Ảnh: nếu có text/placeholder phía trên thì chèn thêm khoảng cách 8px
          if (hasImg) ...[
            if (showText || showPlaceholder) const SizedBox(height: 8),
            _ProblemImage(image: image!),
          ],

          const SizedBox(height: 8),
        ],
      ),
    );
  }
}


/// ====== Card "Lời giải/Phương pháp" (khung trắng + shadow) ======
class _MethodCard extends StatelessWidget {
  const _MethodCard({
    required this.child,
    this.header,
    this.trailing,
  });

  final String? header;
  final Widget child;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: const [
          BoxShadow(blurRadius: 8, offset: Offset(0,3), color: Color(0x14000000)),
        ],
      ),
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
                  style: theme.textTheme.titleMedium?.copyWith(
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
          child,
        ],
      ),
    );
  }
}

/// ====== Hiển thị ảnh đề bài (file path / http / data:) ======
class _ProblemImage extends StatelessWidget {
  const _ProblemImage({required this.image});
  final String image;

  @override
  Widget build(BuildContext context) {
    Widget child;
    try {
      if (image.startsWith('data:')) {
        final data = UriData.parse(image);
        final Uint8List bytes = data.contentAsBytes();
        child = Image.memory(bytes, fit: BoxFit.contain, filterQuality: FilterQuality.medium);
      } else if (image.startsWith('http')) {
        child = Image.network(
          image,
          fit: BoxFit.contain,
          loadingBuilder: (c, w, p) =>
          p == null ? w : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
          errorBuilder: (c, e, s) => const Center(child: Text('Không tải được ảnh')),
        );
      } else {
        child = Image.file(File(image), fit: BoxFit.contain);
      }
    } catch (_) {
      child = const Center(child: Text('Không đọc được ảnh'));
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 260),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFFE5EAF0)),
      ),
      padding: const EdgeInsets.all(6),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: child,
      ),
    );
  }
}
