import 'package:flutter/material.dart';
import 'package:solve_exercise/terms_policies.dart';
import 'package:solve_exercise/utility.dart';
import 'FAQ_page.dart';
import 'about_us.dart';
import 'language_page.dart'; // ⬅️ THÊM

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
    final theme = Theme.of(context);

    final side   = (size.width * 0.06).clamp(14, 24).toDouble();
    final topGap = (size.height * 0.06).clamp(16, 32).toDouble();
    final heroH  = (size.height * 0.34).clamp(220, 360).toDouble();
    final vGap   = (size.height * 0.018).clamp(10, 16).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),
          SafeArea(
            child: SingleChildScrollView(
              // ❌ bỏ topGap ở đây để ảnh không bị đẩy xuống
              padding: EdgeInsets.only(bottom: side),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Ảnh full width, không nhận padding
                  Image.asset(
                    heroAsset,
                    width: double.infinity,
                    fit: BoxFit.fitWidth, // full theo chiều ngang, không crop
                    // Nếu muốn fill & chấp nhận crop: dùng BoxFit.cover + chiều cao cố định
                    // height: 240, fit: BoxFit.cover,
                  ),

                  SizedBox(height: vGap),

                  // ✅ Chỉ padding cho phần settings
                  Padding(
                    padding: EdgeInsets.fromLTRB(side, topGap, side, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _SettingsTile(
                          title: 'Về chúng tôi',
                          onTap: onAbout ??
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const AboutUsPage()),
                              ),
                        ),
                        SizedBox(height: vGap),

                        _SettingsTile(
                          title: 'Câu hỏi thường gặp',
                          onTap: onFaq ??
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const FaqPage()),
                              ),
                        ),
                        SizedBox(height: vGap),

                        _SettingsTile(
                          title: 'Điều khoản & Chính sách',
                          onTap: onTerms ??
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const TermsMenuPage()),
                              ),
                        ),
                        SizedBox(height: vGap),

                        _SettingsTile(
                          title: 'Ngôn ngữ',
                          onTap: onLanguage ??
                                  () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => const LanguagePage()),
                              ),
                        ),
                        SizedBox(height: vGap * 1.2),

                        _ShareCard(
                          title: 'Chia sẻ với bạn bè',
                          subtitle: 'Hoàn thành bài tập cùng nhau',
                          buttonText: 'Chia sẻ',
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

/// Thẻ trắng bo góc, clip antiAlias, KHÔNG shadow đậm ở mép góc
class _SettingsTile extends StatelessWidget {
  const _SettingsTile({required this.title, this.onTap});

  final String title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,                     // nền trắng sạch
      borderRadius: BorderRadius.circular(12), // bo lớn như mock
      clipBehavior: Clip.antiAlias,            // ⬅️ cắt chuẩn theo radius (hết “tối sẫm” ở góc)
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
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

/// Thẻ "Chia sẻ với bạn bè" — nền trắng, không còn gradient nền
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
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,                     // ⬅️ nền trắng
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,            // cắt gọn bo góc
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Row(
          children: [
            // text block
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w500,
                      color: const Color(0xFF262A41),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: const Color(0x80262A41),
                      height: 1.25,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            // nút gradient
            DecoratedBox(
              decoration: const BoxDecoration(
                gradient: kAppBorderGradient,
                borderRadius: BorderRadius.all(Radius.circular(18)),
              ),
              child: TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                ),
                onPressed: onPressed,
                child: Text(
                  buttonText,
                  style: theme.textTheme.labelLarge?.copyWith(
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
