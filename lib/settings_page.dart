import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // ⬅️ THÊM
import 'package:solve_exercise/terms_policies.dart';
import 'package:solve_exercise/utility.dart';
import 'FAQ_page.dart';
import 'about_us.dart';
import 'language_page.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({
    super.key,
    this.heroAsset = 'assets/onboarding/calender1.png',
    this.onAbout,
    this.onFaq,
    this.onTerms,
    this.onLanguage,
    this.onShare,
  });

  final String heroAsset;
  final VoidCallback? onAbout;
  final VoidCallback? onFaq;
  final VoidCallback? onTerms;
  final VoidCallback? onLanguage;
  final VoidCallback? onShare;

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;

    final side   = (size.width * 0.06).clamp(14, 24).toDouble();
    final topGap = (size.height * 0.06).clamp(16, 32).toDouble();
    final vGap   = (size.height * 0.018).clamp(10, 16).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.only(bottom: side),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Image.asset(
                    heroAsset,
                    width: double.infinity,
                    fit: BoxFit.fitWidth,
                  ),
                  SizedBox(height: vGap),

                  Padding(
                    padding: EdgeInsets.fromLTRB(side, topGap, side, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SettingsTile(
                          title: 'settings.about'.tr(),
                          onTap: onAbout ??
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AboutUsPage()),
                              ),
                        ),
                        SizedBox(height: vGap),

                        _SettingsTile(
                          title: 'settings.faq'.tr(),
                          onTap: onFaq ??
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FaqPage()),
                              ),
                        ),
                        SizedBox(height: vGap),

                        _SettingsTile(
                          title: 'settings.terms_policies'.tr(),
                          onTap: onTerms ??
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TermsMenuPage()),
                              ),
                        ),
                        SizedBox(height: vGap),

                        _SettingsTile(
                          title: 'settings.language'.tr(),
                          onTap: onLanguage ??
                                  () async {
                                // Mở trang chọn ngôn ngữ; LanguagePage tự setLocale.
                                final changed = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const LanguagePage(
                                      isOnboarding: false, // ⬅️ quay lại Settings sau khi áp dụng
                                      nextRoute: null,
                                    ),
                                  ),
                                );
                              },
                        ),
                        SizedBox(height: vGap * 1.2),

                        _ShareCard(
                          title: 'settings.share_card.title'.tr(),
                          subtitle: 'settings.share_card.subtitle'.tr(),
                          buttonText: 'settings.share_card.button'.tr(),
                          onPressed: onShare ?? () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, this.onTap});
  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF262A41),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, color: Color(0x33262A41)),
            ],
          ),
        ),
      ),
    );
  }
}

class _ShareCard extends StatelessWidget {
  const _ShareCard({
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF262A41),
                      )),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: const Color(0x80262A41),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: kAppBorderGradient,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: TextButton(
                onPressed: onPressed,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                child: Text(
                  buttonText,
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
