// math_html_page.dart
import 'dart:convert'; // <-- để dùng jsonEncode
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'k_math_html.dart';

class MathHtmlPage extends StatefulWidget {
  final String markdown;

  const MathHtmlPage({super.key, required this.markdown});

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
      ..setNavigationDelegate(NavigationDelegate(
        onPageFinished: (_) async {
          final md = _normalizeMarkdown(widget.markdown);
          // Dùng JSON để truyền chuỗi an toàn vào JS (không bị vỡ bởi **, $, backslash,...)
          final jsArg = jsonEncode(md);
          await _wc.runJavaScript('window.renderMarkdown($jsArg)');
        },
      ))
      ..loadHtmlString(kMathHtml); // KHÔNG replace __CONTENT__ nữa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Lời giải Toán')),
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
