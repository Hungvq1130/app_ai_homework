import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart';
import 'home_page.dart';
import 'onboarding_page.dart';

/// === ĐỔI ĐƯỜNG DẪN Ở ĐÂY CHO TIỆN ===
/// Logo: để null sẽ hiện ô xám placeholder
const String? _kLogoAssetPath = 'assets/logo/logo.png';
const String  _kHeroAssetPath = 'assets/onboarding/onboarding1.png';

class OnboardingWelcomePage extends StatelessWidget {
  const OnboardingWelcomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final double side = (size.width * 0.08).clamp(16, 28);
    final double topGap = (size.height * 0.10).clamp(24, 64);
    final double titleSize = (size.width * 0.074).clamp(22, 32);
    final double titleGap = (size.height * 0.04).clamp(16, 32);
    final double heroMaxW = size.width * 1;
    final double heroMaxH = size.height * 0.6;
    final double bottomPad = (size.height * 0.04).clamp(16, 32);
    final double buttonWidth = MediaQuery.of(context).size.width * 0.84;

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: side),
              child: Column(
                children: [
                  SizedBox(height: topGap),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.asset(
                        _kLogoAssetPath!, // đảm bảo bạn set biến này trước khi build
                        width: size.width * 0.35,
                        height: size.width * 0.35,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(), // không hiện ô xám
                      ),
                    ),
                  // --- Tiêu đề ---
                  Text(
                    'Chào mừng đến với\nHọc Bá AI',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineMedium?.copyWith(
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      color: const Color(0xFF27335C),
                      height: 1.25,
                    ),
                  ),
                  // --- Ảnh minh hoạ ---
                  ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: heroMaxW, maxHeight: heroMaxH),
                    child: Image.asset(
                      _kHeroAssetPath,
                      fit: BoxFit.contain,
                      errorBuilder: (_, __, ___) => Container(
                        width: heroMaxW,
                        height: heroMaxH,
                        alignment: Alignment.center,
                        child: const Text('Thiếu ảnh minh hoạ', style: TextStyle(color: Colors.black45)),
                      ),
                    ),
                  ),

                  const Spacer(),

                  // --- Điều khoản & Chính sách ---
                  RichText(
                    textAlign: TextAlign.center,
                    text: TextSpan(
                      style: theme.textTheme.bodySmall?.copyWith(color: Colors.black54, height: 1.3),
                      children: [
                        const TextSpan(text: 'Tôi đồng ý với các '),
                        TextSpan(
                          text: 'Điều khoản',
                          style: const TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // mở trang điều khoản
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Điều khoản')),
                              );
                            },
                        ),
                        const TextSpan(text: ' và '),
                        TextSpan(
                          text: 'Chính sách',
                          style: const TextStyle(decoration: TextDecoration.underline, fontWeight: FontWeight.w600),
                          recognizer: TapGestureRecognizer()
                            ..onTap = () {
                              // mở trang chính sách
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Chính sách')),
                              );
                            },
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: size.height * 0.016),

                  // --- Nút gradient ---
                  Center(
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(28),
                      child: InkWell(
                        onTap: () {
                          Navigator.of(context).pushReplacement(
                            MaterialPageRoute(builder: (_) => const OnboardingFlow()),
                          );
                        },
                        borderRadius: BorderRadius.circular(28),
                        child: Ink(
                          width: buttonWidth,
                          height: 56,
                          decoration: const BoxDecoration(
                            gradient: kAppBorderGradient,
                            borderRadius: BorderRadius.all(Radius.circular(28)),
                          ),
                          child: Center(
                            child: Text(
                              'Đồng ý & tiếp tục',
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: bottomPad),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
