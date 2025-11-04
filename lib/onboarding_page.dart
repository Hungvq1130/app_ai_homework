import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground + OnboardingGradientCard + kAppBorderGradient
import 'home_page.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final _controller = PageController();
  int _index = 0;

  // === Chỉ cần đổi đường dẫn & text ở đây ===
  final _pages = [
    _OBData(
      hero: 'assets/onboarding/onboarding3.png',
      title: 'onboarding.slide1.title'.tr(),
      subtitle: 'onboarding.slide1.subtitle'.tr(),
      button: 'onboarding.button.continue'.tr(),
    ),
    _OBData(
      hero: 'assets/onboarding/onboarding2.png',
      title: 'onboarding.slide2.title'.tr(),
      subtitle: 'onboarding.slide2.subtitle'.tr(),
      button: 'onboarding.button.continue'.tr(),
    ),
    _OBData(
      hero: 'assets/onboarding/calender1.png',
      title: 'onboarding.slide3.title'.tr(),
      subtitle: 'onboarding.slide3.subtitle'.tr(),
      button: 'onboarding.button.start'.tr(),
    ),
  ];

  void _next() async {
    if (_index < _pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeOut,
      );
    } else {
      // ✅ Kết thúc flow → đánh dấu đã hoàn tất
      final sp = await SharedPreferences.getInstance();
      await sp.setBool('onboarding_done', true);

      // → HomePage
      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const HomePage()),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final side = (size.width * 0.06).clamp(14, 24).toDouble();
    final topGap = (size.height * 0.06).clamp(12, 28).toDouble();
    final heroMaxH = (size.height * 0.44).clamp(260, 360).toDouble();
    final cardRadius = 24.0;
    final bottomLift    = (size.height * 0.03).clamp(16.0, 32.0);
    final cardFrac      = 0.4; // 0.40–0.50 tuỳ ý
    final cardHeight    = (size.height * cardFrac).clamp(300.0, size.height * 0.65);

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),

          // Ảnh hero theo từng trang (không có indicator/skip)
          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(side, topGap, side, 0),
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: _pages.length,
                itemBuilder: (context, i) {
                  final data = _pages[i];
                  return Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: heroMaxH),
                      child: Image.asset(
                        data.hero,
                        fit: BoxFit.contain,
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          // CARD nội dung GHIM DƯỚI (bottom)
          Positioned(
            left: side,
            right: side,
            bottom: bottomLift,
            child: SafeArea(
              top: false,
              child: OnboardingGradientCard(
                radius: cardRadius,
                strokeWidth: 1.6,
                padding: const EdgeInsets.fromLTRB(20, 22, 20, 14),
                child: SizedBox( // ⬅️ BOUNDED HEIGHT để Spacer hoạt động
                  height: cardHeight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tiêu đề
                      Text(
                        _pages[_index].title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D2F79),
                          height: 1.25,
                          fontSize: 30,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Mô tả
                      Text(
                        _pages[_index].subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                          height: 1.35,
                        ),
                      ),

                      const Spacer(), // đẩy nút xuống đáy card

                      // Nút gradient to, bo tròn, có bóng nhẹ
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            gradient: kAppBorderGradient,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF5539DA).withOpacity(0.25),
                                blurRadius: 16,
                                offset: const Offset(0, 8),
                              ),
                            ],
                          ),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
                              ),
                            ),
                            onPressed: _next,
                            child: Text(
                              _pages[_index].button,
                              style: theme.textTheme.titleMedium?.copyWith(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OBData {
  final String hero;
  final String title;
  final String subtitle;
  final String button;
  const _OBData({
    required this.hero,
    required this.title,
    required this.subtitle,
    required this.button,
  });
}
