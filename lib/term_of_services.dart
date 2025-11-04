// terms_of_service_page.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ⬅️ i18n
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // responsive
    final side      = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap    = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSize = (size.width * 0.060).clamp(18, 22).toDouble();
    final hSize     = (size.width * 0.050).clamp(15, 18).toDouble();
    final bodySize  = (size.width * 0.040).clamp(13, 15).toDouble();

    const purple = Color(0xFF2D2F79);

    // bullets (KHÔNG const để nhận cập nhật khi đổi ngôn ngữ)
    final purposeBullets = <String>[
      'terms.sections.purpose.b1'.tr(),
      'terms.sections.purpose.b2'.tr(),
      'terms.sections.purpose.b3'.tr(),
    ];
    final userBullets = <String>[
      'terms.sections.user.b1'.tr(),
      'terms.sections.user.b2'.tr(),
      'terms.sections.user.b3'.tr(),
    ];
    final s1Bullets = <String>[
      'terms.sections.students.s1.b1'.tr(),
      'terms.sections.students.s1.b2'.tr(),
      'terms.sections.students.s1.b3'.tr(),
    ];
    final s2Bullets = <String>[
      'terms.sections.students.s2.b1'.tr(),
      'terms.sections.students.s2.b2'.tr(),
      'terms.sections.students.s2.b3'.tr(),
    ];
    final s3Bullets = <String>[
      'terms.sections.students.s3.b1'.tr(),
      'terms.sections.students.s3.b2'.tr(),
      'terms.sections.students.s3.b3'.tr(),
    ];
    final s4Bullets = <String>[
      'terms.sections.students.s4.b1'.tr(),
      'terms.sections.students.s4.b2'.tr(),
      'terms.sections.students.s4.b3'.tr(),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),

          SafeArea(
            child: Column(
              children: [
                // Header: back + title giữa
                Padding(
                  padding: EdgeInsets.fromLTRB(side, topGap, side, 6),
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
                        'terms.title'.tr(), // ⬅️ i18n
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          color: purple,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nội dung
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(side, 6, side, side),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _Body('terms.intro'.tr(), bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('terms.sections.purpose.title'.tr(), size: hSize),
                        _Body('terms.sections.purpose.intro'.tr(), bodySize: bodySize),
                        const SizedBox(height: 6),
                        _Bullets(items: purposeBullets, bodySize: bodySize),
                        const SizedBox(height: 6),
                        _Body('terms.sections.not_replace_learning'.tr(), bodySize: bodySize, strong: true),

                        const SizedBox(height: 14),
                        _SectionTitle('terms.sections.user.title'.tr(), size: hSize),
                        _Bullets(items: userBullets, bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('terms.sections.students.title'.tr(), size: hSize),

                        const SizedBox(height: 10),
                        _SubTitle('terms.sections.students.s1.title'.tr(), size: hSize - 2),
                        _Body('terms.sections.students.s1.body'.tr(), bodySize: bodySize),
                        const SizedBox(height: 6),
                        _Bullets(items: s1Bullets, bodySize: bodySize),

                        const SizedBox(height: 10),
                        _SubTitle('terms.sections.students.s2.title'.tr(), size: hSize - 2),
                        _Bullets(items: s2Bullets, bodySize: bodySize),

                        const SizedBox(height: 10),
                        _SubTitle('terms.sections.students.s3.title'.tr(), size: hSize - 2),
                        _Body('terms.sections.students.s3.body'.tr(), bodySize: bodySize),
                        _Bullets(items: s3Bullets, bodySize: bodySize),
                        _Body('terms.sections.students.s3.tail'.tr(), bodySize: bodySize),

                        const SizedBox(height: 10),
                        _SubTitle('terms.sections.students.s4.title'.tr(), size: hSize - 2),
                        _Body('terms.sections.students.s4.body'.tr(), bodySize: bodySize),
                        _Bullets(items: s4Bullets, bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('terms.sections.disclaimer.title'.tr(), size: hSize),
                        const SizedBox(height: 10),
                        _Body('terms.sections.disclaimer.p1'.tr(), bodySize: bodySize),
                        const SizedBox(height: 10),
                        _Body('terms.sections.disclaimer.p2'.tr(), bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('terms.sections.ip.title'.tr(), size: hSize),
                        const SizedBox(height: 10),
                        _Body('terms.sections.ip.body'.tr(), bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('terms.sections.changes.title'.tr(), size: hSize),
                        const SizedBox(height: 10),
                        _Body('terms.sections.changes.body'.tr(), bodySize: bodySize),
                      ],
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

// ===== Helpers (giống các trang legal khác) =====

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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D2F79),
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text, {required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D2F79),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text, {required this.bodySize, this.strong = false});
  final String text;
  final double bodySize;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: bodySize,
        height: 1.45,
        color: const Color(0xFF3A3F63),
        fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items, required this.bodySize});
  final List<String> items;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: bodySize,
      height: 1.45,
      color: const Color(0xFF3A3F63),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.map(
            (t) => Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('•  ',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF2D2F79),
                  )),
              Expanded(child: Text(t, style: style)),
            ],
          ),
        ),
      ).toList(),
    );
  }
}
