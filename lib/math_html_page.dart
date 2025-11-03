import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'k_math_database_html.dart';
import 'k_math_html.dart';

class MathHtmlPage extends StatefulWidget {
  final String markdown;        // giữ tên cũ
  final String htmlTemplate;
  final String title;
  final bool isHtml;            // true = nạp HTML thuần, false = Markdown

  const MathHtmlPage({
    super.key,
    required this.markdown,
    this.htmlTemplate = kMathHtml,
    this.title = 'Lời giải',
    this.isHtml = false,
  });

  factory MathHtmlPage.ai({
    required String markdown,
    String? title,
  }) => MathHtmlPage(
    markdown: markdown,
    htmlTemplate: kMathHtml,
    title: title ?? 'Lời giải (AI)',
    isHtml: false,
  );

  @override
  State<MathHtmlPage> createState() => _MathHtmlPageState();
}

class _MathHtmlPageState extends State<MathHtmlPage> with TickerProviderStateMixin {
  late final WebViewController _wc;

  // Chiều cao nội dung (dp). Đặt min để tránh giật layout lần đầu.
  double _contentHeight = 200;

  @override
  void initState() {
    super.initState();

    if (Platform.isAndroid) {
      // WebView.platform = SurfaceAndroidWebView(); // nếu project dùng plugin cũ, mở dòng này
    }

    _wc = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..enableZoom(true)
      ..addJavaScriptChannel(
        'Resize',
        onMessageReceived: (JavaScriptMessage msg) {
          final h = double.tryParse(msg.message);
          if (h != null && h > 0 && (h - _contentHeight).abs() > 1) {
            setState(() => _contentHeight = h.clamp(100, 100000).toDouble());
          }
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (_) async {
            // Bổ sung helpers (renderHtml + đo chiều cao + quan sát thay đổi)
            await _wc.runJavaScript(_injectResizeJs);

            final payload = jsonEncode(
              widget.isHtml
                  ? _normalizeHtml(widget.markdown)
                  : _normalizeMarkdown(widget.markdown),
            );

            if (widget.isHtml) {
              await _wc.runJavaScript('window.renderHtml($payload);');
            } else {
              await _wc.runJavaScript('window.renderMarkdown($payload);');
            }

            // Gọi đo lần đầu
            await _wc.runJavaScript('window.__sendHeight && window.__sendHeight();');
          },
        ),
      )
      ..loadHtmlString(widget.htmlTemplate);
  }

  @override
  void didUpdateWidget(covariant MathHtmlPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Khi nội dung đổi -> render lại và đo lại
    if (oldWidget.markdown != widget.markdown || oldWidget.isHtml != widget.isHtml) {
      final payload = jsonEncode(
        widget.isHtml ? _normalizeHtml(widget.markdown) : _normalizeMarkdown(widget.markdown),
      );
      if (widget.isHtml) {
        _wc.runJavaScript('window.renderHtml($payload); window.__sendHeight&&window.__sendHeight();');
      } else {
        _wc.runJavaScript('window.renderMarkdown($payload); window.__sendHeight&&window.__sendHeight();');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // KHÔNG bọc Scaffold, KHÔNG đặt gestureRecognizers dọc
    // để ListView bên ngoài cuộn 1 mạch
    return AnimatedSize(
      duration: const Duration(milliseconds: 160),
      curve: Curves.easeOutCubic,
      child: SizedBox(
        height: _contentHeight,
        child: WebViewWidget(controller: _wc),
      ),
    );
  }
}

// JS được inject: đo chiều cao và gửi về qua kênh 'Resize'
const String _injectResizeJs = r'''
(function(){
  // fallback nếu template không có
  if (!window.renderHtml) {
    window.renderHtml = function(html) {
      var target = document.getElementById('content')
             || document.getElementById('output')
             || document.getElementById('app')
             || document.getElementById('root')
             || document.body;
      target.innerHTML = html;
      if (window.MathJax && MathJax.typesetPromise) { MathJax.typesetPromise(); }
    };
  }

  function pxHeight(){
    var out = document.getElementById('output');
    var h = 0;
    if (out) {
      // đo theo container nội dung
      h = Math.max(out.scrollHeight, out.getBoundingClientRect().height);
    } else {
      var b = document.body, html = document.documentElement;
      h = Math.max(b.scrollHeight, b.offsetHeight, html.clientHeight, html.scrollHeight, html.offsetHeight);
    }
    // KHÔNG chia cho devicePixelRatio: CSS px ≈ logical px trong Flutter
    return Math.ceil(h + 16); // +buffer nhỏ tránh cắt bóng/bo góc
  }

  window.__sendHeight = function(){
    try { Resize.postMessage(String(pxHeight())); } catch(e) {}
  };

  // Debounce
  var deb;
  function debounce(fn, t){ clearTimeout(deb); deb = setTimeout(fn, t||80); }

  // Sự kiện chung
  window.addEventListener('load', function(){ debounce(window.__sendHeight, 0); });
  window.addEventListener('resize', function(){ debounce(window.__sendHeight, 60); });

  // Quan sát thay đổi DOM
  try{
    var ro = new ResizeObserver(function(){ debounce(window.__sendHeight, 60); });
    ro.observe(document.body);
  }catch(e){}

  // Khi ảnh load xong -> đo lại
  Array.prototype.forEach.call(document.images || [], function(img){
    if (!img.complete) {
      img.addEventListener('load', function(){ debounce(window.__sendHeight, 60); });
      img.addEventListener('error', function(){ debounce(window.__sendHeight, 60); });
    }
  });

  // Khi MathJax typeset xong -> đo lại
  if (window.MathJax && MathJax.typesetPromise){
    MathJax.typesetPromise().then(function(){ debounce(window.__sendHeight, 60); });
  }
})();
''';


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
  return s
      .replaceAll(r'\r\n', '\n')
      .replaceAll(r'\n', '\n')
      .replaceAll(r'\u003E', '>')
      .replaceAll('&amp;', '&'); // giữ &lt; &gt; vì có thể là markup hợp lệ
}

