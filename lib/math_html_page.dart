import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'k_math_database_html.dart';
import 'k_math_html.dart';

class MathHtmlPage extends StatefulWidget {
  final String markdown;        // giữ tên cũ để đỡ sửa nhiều chỗ
  final String htmlTemplate;
  final String title;
  final bool isHtml;            // ⬅️ mới

  const MathHtmlPage({
    super.key,
    required this.markdown,
    this.htmlTemplate = kMathHtml,
    this.title = 'Lời giải',
    this.isHtml = false,        // ⬅️ mặc định là Markdown
  });

  /// Dùng riêng cho AI (template cũ, render Markdown)
  factory MathHtmlPage.ai({
    required String markdown,
    String? title,
  }) => MathHtmlPage(
    markdown: markdown,
    htmlTemplate: kMathHtml,
    title: title ?? 'Lời giải (AI)',
    isHtml: false,
  );

  /// Dùng riêng cho DB (template mới, render Markdown)
  factory MathHtmlPage.db({
    required String markdown,
    String? title,
  }) => MathHtmlPage(
    markdown: markdown,
    htmlTemplate: kMathHtmlDb,
    title: title ?? 'Lời giải (DB)',
    isHtml: false,
  );

  /// ✅ Render **HTML thuần** trên template DB
  factory MathHtmlPage.dbHtml({
    required String html,
    String? title,
  }) => MathHtmlPage(
    markdown: html,
    htmlTemplate: kMathHtmlDb,
    title: title ?? 'Lời giải (DB)',
    isHtml: true,            // ⬅️ báo là HTML
  );

  @override
  State<MathHtmlPage> createState() => _MathHtmlPageState();
}

class _MathHtmlPageState extends State<MathHtmlPage> {
  late final WebViewController _wc;

  @override
  void initState() {
    super.initState();

    _wc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            // Định nghĩa renderHtml nếu template chưa có
            await _wc.runJavaScript('''
              if (!window.renderHtml) {
                window.renderHtml = function(html) {
                  var target = document.getElementById('content') 
                            || document.getElementById('app') 
                            || document.getElementById('root') 
                            || document.body;
                  target.innerHTML = html;
                  if (window.MathJax && MathJax.typesetPromise) { MathJax.typesetPromise(); }
                };
              }
            ''');

            final payload = jsonEncode(
              widget.isHtml ? _normalizeHtml(widget.markdown)
                  : _normalizeMarkdown(widget.markdown),
            );

            if (widget.isHtml) {
              await _wc.runJavaScript('window.renderHtml($payload)');
            } else {
              await _wc.runJavaScript('window.renderMarkdown($payload)');
            }
          },
        ),
      )
      ..loadHtmlString(widget.htmlTemplate);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.title)),
      body: WebViewWidget(controller: _wc),
    );
  }
}

String _normalizeMarkdown(String s) {
  return s
      .replaceAll(r'\r\n', '\n')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\u003E', '>')
      .replaceAll('&gt;', '>')
      .replaceAll('&lt;', '<')
      .replaceAll('&amp;', '&');
}

String _normalizeHtml(String s) {
  // Với HTML, chỉ cần chuẩn hóa xuống dòng/các escape phổ biến;
  // không làm "markdown-like" replacements để tránh phá HTML.
  return s
      .replaceAll(r'\r\n', '\n')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\u003E', '>')
      .replaceAll('&amp;', '&'); // giữ &lt; &gt; vì có thể là markup hợp lệ
}
