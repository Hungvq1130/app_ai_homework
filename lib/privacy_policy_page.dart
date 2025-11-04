import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ⬅️ i18n
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // responsive spacing / font sizes
    final side      = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap    = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSize = (size.width * 0.060).clamp(18, 22).toDouble();
    final hSize     = (size.width * 0.050).clamp(15, 18).toDouble();
    final bodySize  = (size.width * 0.040).clamp(13, 15).toDouble();

    const purple = Color(0xFF2D2F79);
    const text   = Color(0xFF3A3F63);

    // ⬇️ Bullets theo i18n (KHÔNG const để nhận cập nhật)
    final collectBullets = <String>[
      'privacy.sections.collect.b1'.tr(),
      'privacy.sections.collect.b2'.tr(),
      'privacy.sections.collect.b3'.tr(),
      'privacy.sections.collect.b4'.tr(),
    ];

    final purposeBullets = <String>[
      'privacy.sections.purpose.b1'.tr(),
      'privacy.sections.purpose.b2'.tr(),
      'privacy.sections.purpose.b3'.tr(),
      'privacy.sections.purpose.b4'.tr(),
    ];

    final sharingBullets = <String>[
      'privacy.sections.sharing.b1'.tr(),
      'privacy.sections.sharing.b2'.tr(),
      'privacy.sections.sharing.b3'.tr(),
    ];

    final rightsBullets = <String>[
      'privacy.sections.rights.b1'.tr(),
      'privacy.sections.rights.b2'.tr(),
      'privacy.sections.rights.b3'.tr(),
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
                        child: _CircleBackButton(onTap: () => Navigator.pop(context)),
                      ),
                      Text(
                        'privacy.title'.tr(), // ⬅️ i18n
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
                        _SectionTitle('privacy.sections.collect.title'.tr(), size: hSize),
                        _Body('privacy.sections.collect.intro'.tr(), bodySize: bodySize),
                        const SizedBox(height: 6),
                        _Bullets(items: collectBullets, bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('privacy.sections.purpose.title'.tr(), size: hSize),
                        _Bullets(items: purposeBullets, bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('privacy.sections.security.title'.tr(), size: hSize),
                        _Body('privacy.sections.security.body'.tr(), bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('privacy.sections.sharing.title'.tr(), size: hSize),
                        _Body('privacy.sections.sharing.intro'.tr(), bodySize: bodySize),
                        const SizedBox(height: 6),
                        _Bullets(items: sharingBullets, bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('privacy.sections.rights.title'.tr(), size: hSize),
                        _Bullets(items: rightsBullets, bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('privacy.sections.changes.title'.tr(), size: hSize),
                        _Body('privacy.sections.changes.body'.tr(), bodySize: bodySize),
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

// ===== helper widgets =====

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
        fontWeight: FontWeight.w500,
        color: const Color(0xFF2D2F79),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text, {required this.bodySize});
  final String text;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: bodySize,
        height: 1.45,
        color: const Color(0xFF3A3F63),
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
      children: items
          .map((t) => Padding(
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
      ))
          .toList(),
    );
  }
}
