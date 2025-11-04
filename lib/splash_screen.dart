import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart';
import 'package:solve_exercise/welcome_page.dart';
import 'home_page.dart';
import 'language_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  // ✅ Đường dẫn logo lớn (PNG trong suốt) – thay bằng của bạn
  static const String kBigLogoAsset = 'assets/logo/logo_big.png';

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  Future<void> _startUp() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _visible = true);

    await Future.delayed(const Duration(seconds: 3));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const LanguagePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    // Kích thước & khoảng cách theo ảnh mẫu
    final double logoSide = (size.width * 0.8).clamp(320.0, 380.0);
    final double titleGap = (size.height * 0.02).clamp(16.0, 24.0);
    final double subGap = 8.0;

    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient thương hiệu
          const SoftGradientBackground(includeBaseLayer: true),

          // ===== Icon mờ trang trí (trắng, theo ảnh) =====
          // Biểu đồ tròn – góc trên trái
          Positioned(
            left: -size.width * 0.02,
            top: size.height * 0.08,
            child: const _FadedIcon(
              asset: 'assets/splash/fi_617333.png',
              widthFactor: 0.36,
              opacity: 0.25,
            ),
          ),
          // Thước – phải giữa
          Positioned(
            right: size.width * 0.02,
            top: size.height * 0.42,
            child: const _FadedIcon(
              asset: 'assets/splash/fi_3360739.png',
              widthFactor: 0.30,
              opacity: 0.22,
            ),
          ),
          // Quyển sách – dưới trái
          Positioned(
            left: size.width * 0.06,
            bottom: size.height * 0.10,
            child: const _FadedIcon(
              asset: 'assets/splash/fi_171322.png',
              widthFactor: 0.26,
              opacity: 0.22,
            ),
          ),

          // ===== Logo lớn + tiêu đề + tagline =====
          Center(
            child: AnimatedScale(
              scale: _visible ? 1.0 : 0.92,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Logo lớn (thay TextLogo cũ)
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Image.asset(
                        kBigLogoAsset,
                        width: logoSide,
                        height: logoSide,
                        fit: BoxFit.contain,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        filterQuality: FilterQuality.high,
                      ),
                    ),

                    SizedBox(height: titleGap),

                    Text(
                      'splash.brand'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 54,               // gần với mẫu
                        letterSpacing: .2,
                        color: const Color(0xFF27335C), // xanh đậm như ảnh
                        height: 1.1,
                      ),
                    ),

                    SizedBox(height: subGap),

                    // Tagline: "Bài tập khó, có AI lo!"
                    Text(
                      'splash.tagline'.tr(),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                        fontSize: 24,
                        color: Colors.black54,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Icon trắng mờ, kích thước theo tỉ lệ chiều rộng màn hình.
class _FadedIcon extends StatelessWidget {
  final String asset;
  final double widthFactor; // tỉ lệ theo size.width
  final double opacity;

  const _FadedIcon({
    required this.asset,
    required this.widthFactor,
    this.opacity = 0.25,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s = w * widthFactor;

    return Image.asset(
      asset,
      width: s,
      height: s,
      fit: BoxFit.contain,
      // tô trắng và giảm opacity để giống ảnh mẫu
      color: Colors.white.withOpacity(opacity),
      colorBlendMode: BlendMode.srcATop,
      filterQuality: FilterQuality.high,
    );
  }
}
