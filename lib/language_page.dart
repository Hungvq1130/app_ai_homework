// language_page.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:solve_exercise/utility.dart';
import 'package:solve_exercise/welcome_page.dart';

import 'home_page.dart';
import 'onboarding_page.dart'; // SoftGradientBackground + kAppBorderGradient

enum AppLanguage { en, vi }

extension AppLanguageX on AppLanguage {
  Locale toLocale() {
    switch (this) {
      case AppLanguage.en:
        return const Locale('en');
      case AppLanguage.vi:
        return const Locale('vi');
    }
  }

  static AppLanguage fromLocale(Locale l) {
    switch (l.languageCode) {
      case 'vi':
        return AppLanguage.vi;
      case 'en':
      default:
        return AppLanguage.en;
    }
  }
}

class LanguagePage extends StatefulWidget {
  const LanguagePage({
    super.key,
    this.initial,               // Nếu không truyền sẽ đọc từ context.locale
    this.onChanged,
    this.flagUS = 'assets/flags/us.png',
    this.flagVN = 'assets/flags/vn.png',
    this.isOnboarding = true,   // Ẩn/hiện nút back
    this.nextRoute = '/onboarding', // Route sẽ chuyển đến sau khi áp dụng
  });

  final AppLanguage? initial;
  final ValueChanged<AppLanguage>? onChanged;
  final String flagUS;
  final String flagVN;
  final bool isOnboarding;
  final String? nextRoute;

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late AppLanguage _selected;
  bool _initedFromLocale = false; // ⬅️ flag để chỉ init 1 lần

  @override
  void initState() {
    super.initState();
    // Đặt tạm (ví dụ VI) hoặc từ widget.initial nếu có
    _selected = widget.initial ?? AppLanguage.en;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_initedFromLocale) {
      // ⬅️ Lúc này mới an toàn để đọc context.locale
      final current = context.locale; // require: import easy_localization
      _selected = widget.initial ?? AppLanguageX.fromLocale(current);
      _initedFromLocale = true;
      // KHÔNG cần setState vì didChangeDependencies() chạy trước build đầu tiên
    }
  }

  void _pick(AppLanguage lang) {
    setState(() => _selected = lang);
    widget.onChanged?.call(lang);
  }

  Future<void> _applyAndContinue() async {
    await context.setLocale(_selected.toLocale());
    if (!mounted) return;

    if (widget.isOnboarding) {
      final sp = await SharedPreferences.getInstance();
      final done = sp.getBool('onboarding_done') ?? false;

      if (done) {
        // ✅ Không phải lần đầu → LanguagePage → HomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomePage()),
        );
      } else {
        // ✅ Lần đầu → LanguagePage → OnboardingWelcomePage
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const OnboardingWelcomePage()),
        );
      }
    } else {
      // Mở từ Settings: quay lại
      Navigator.of(context).pop(true);
    }
  }



  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final side     = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap   = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSz  = (size.width * 0.060).clamp(18, 22).toDouble();
    final btnH     = (size.height * 0.07).clamp(44, 56).toDouble();

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.fromLTRB(side, topGap, side, side),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header: back (nếu !isOnboarding) + title center
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      if (!widget.isOnboarding)
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _CircleBackButton(onTap: () => Navigator.pop(context)),
                        ),
                      Text(
                        'language_page.title'.tr(),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: titleSz,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D2F79),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  _LanguageTile(
                    flagPath: widget.flagUS,
                    label: 'language_page.english'.tr(),
                    selected: _selected == AppLanguage.en,
                    onTap: () => _pick(AppLanguage.en),
                  ),
                  const SizedBox(height: 12),

                  _LanguageTile(
                    flagPath: widget.flagVN,
                    label: 'language_page.vietnamese'.tr(),
                    selected: _selected == AppLanguage.vi,
                    onTap: () => _pick(AppLanguage.vi),
                  ),

                  const Spacer(),
                  // Nút Áp dụng & tiếp tục
                  SizedBox(
                    height: btnH,
                    width: double.infinity,
                    child: _GradientPrimaryButton(
                      text: 'language_page.apply_continue'.tr(),
                      onTap: _applyAndContinue,
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

// ==== Widgets ====

class _LanguageTile extends StatelessWidget {
  const _LanguageTile({
    required this.flagPath,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String flagPath;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(flagPath, width: 28, height: 20, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2B2E47),
                  ),
                ),
              ),
              _GradientCheck(selected: selected),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientCheck extends StatelessWidget {
  const _GradientCheck({required this.selected});
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(8);
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        borderRadius: radius,
        gradient: selected ? kAppBorderGradient : null,
        color: selected ? null : Colors.white,
        border: selected ? null : Border.all(color: const Color(0xFFE6E2F5), width: 2),
        boxShadow: selected
            ? [BoxShadow(color: const Color(0xFF5539DA).withOpacity(0.18), blurRadius: 8, offset: const Offset(0, 3))]
            : null,
      ),
      alignment: Alignment.center,
      child: selected ? const Icon(Icons.check, size: 16, color: Colors.white) : const SizedBox.shrink(),
    );
  }
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
          width: 36,
          height: 36,
          child: Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2F79), size: 22),
        ),
      ),
    );
  }
}

/// Nút primary nền gradient, đồng bộ style app
class _GradientPrimaryButton extends StatelessWidget {
  const _GradientPrimaryButton({required this.text, required this.onTap});
  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(14);
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      borderRadius: radius,
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: radius,
            gradient: kAppBorderGradient,
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF5539DA).withOpacity(0.22),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Center(
            child: Text(
              text,
              style: theme.textTheme.titleMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
