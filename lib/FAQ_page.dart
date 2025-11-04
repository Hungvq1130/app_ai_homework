import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ⬅️ i18n
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // layout responsive
    final side      = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap    = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSize = (size.width * 0.45).clamp(16, 20).toDouble();
    final qSize     = (size.width * 0.045).clamp(14, 17).toDouble();
    final aSize     = (size.width * 0.040).clamp(13, 15).toDouble();

    const qColor = Color(0xFF2D2F79);
    const aColor = Color(0xFF3A3F63);

    // ⬇️ LẤY I18N (KHÔNG const để nhận cập nhật khi đổi ngôn ngữ)
    final items = <_FaqItem>[
      _FaqItem(q: 'faq.q1'.tr(), a: 'faq.a1'.tr()),
      _FaqItem(q: 'faq.q2'.tr(), a: 'faq.a2'.tr()),
      _FaqItem(q: 'faq.q3'.tr(), a: 'faq.a3'.tr()),
      _FaqItem(q: 'faq.q4'.tr(), a: 'faq.a4'.tr()),
      _FaqItem(q: 'faq.q5'.tr(), a: 'faq.a5'.tr()),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),

          SafeArea(
            child: Column(
              children: [
                // ===== Header: back + title center (không có card trắng) =====
                Padding(
                  padding: EdgeInsets.fromLTRB(side, topGap, side, 8),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _CircleBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      Text(
                        'faq.title'.tr(), // ⬅️ i18n
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          color: qColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Q&A trực tiếp trên nền gradient =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(side, 6, side, side),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(items.length, (i) {
                        final it = items[i];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: i == items.length - 1 ? 0 : 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Câu hỏi (đậm + màu)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${i + 1}. ',
                                      style: TextStyle(
                                        fontSize: qSize,
                                        fontWeight: FontWeight.w500,
                                        color: qColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: it.q,
                                      style: TextStyle(
                                        fontSize: qSize,
                                        fontWeight: FontWeight.w500,
                                        color: qColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Trả lời
                              Text(
                                it.a,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: aSize,
                                  height: 1.45,
                                  color: aColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FaqItem {
  final String q;
  final String a;
  const _FaqItem({required this.q, required this.a});
}

class _CircleBackButton extends StatelessWidget {
  const _CircleBackButton({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: const SizedBox(
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2F79)),
        ),
      ),
    );
  }
}
