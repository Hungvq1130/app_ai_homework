import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart';
import 'package:solve_exercise/welcome_page.dart';
import 'home_page.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _visible = false;

  @override
  void initState() {
    super.initState();
    _startUp();
  }

  Future<void> _startUp() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (!mounted) return;
    setState(() => _visible = true);

    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const OnboardingWelcomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    // Khoảng cách responsive giữa TextLogo và tagline (24–56 px)
    final double gapPx = (size.height * 0.05).clamp(250.0, 300.0);

    return Scaffold(
      body: Stack(
        children: [
          // Nền gradient thương hiệu
          const SoftGradientBackground(includeBaseLayer: true),

          // ===== Logos PNG đã xoay sẵn (không xoay nữa) =====
          // logo1: trên trái
          Positioned(
            left: -size.width * 0.01,
            top: size.height * 0.10,
            child: const _FadedLogo(
              asset: 'assets/splash/fi_617333.png',
              widthFactor: 0.36,
              opacity: 0.7, // tăng/giảm nếu muốn
            ),
          ),
          // logo2: phải giữa
          Positioned(
            right: size.width * 0.01,
            top: size.height * 0.46,
            child: const _FadedLogo(
              asset: 'assets/splash/fi_3360739.png',
              widthFactor: 0.28,
              opacity: 0.7,
            ),
          ),
          // logo3: dưới trái
          Positioned(
            left: size.width * 0.06,
            bottom: size.height * 0.10,
            child: const _FadedLogo(
              asset: 'assets/splash/fi_171322.png',
              widthFactor: 0.26,
              opacity: 0.7,
            ),
          ),

          // ===== TextLogo + Tagline =====
          Center(
            child: AnimatedScale(
              scale: _visible ? 1.0 : 0.9,
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutBack,
              child: AnimatedOpacity(
                opacity: _visible ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeOut,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // "TextLogo"
                    RichText(
                      text: TextSpan(
                        style: DefaultTextStyle.of(context)
                            .style
                            .copyWith(fontSize: 36, color: Colors.black),
                        children: const [
                          TextSpan(
                            text: 'Text',
                            style: TextStyle(fontWeight: FontWeight.w800),
                          ),
                          TextSpan(
                            text: 'Logo',
                            style: TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: gapPx),
                    Text(
                      'Bài Nào Khó\nCó AI Lo!',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        height: 1.24,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
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

/// Logo trắng mờ, kích thước theo tỉ lệ chiều rộng màn hình, KHÔNG xoay.
class _FadedLogo extends StatelessWidget {
  final String asset;
  final double widthFactor; // tỉ lệ theo size.width
  final double opacity;

  const _FadedLogo({
    required this.asset,
    required this.widthFactor,
    this.opacity = 0.5,
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.of(context).size.width;
    final s = w * widthFactor;

    return Opacity(
      opacity: opacity,
      child: Image.asset(
        asset,
        width: s,
        height: s,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
