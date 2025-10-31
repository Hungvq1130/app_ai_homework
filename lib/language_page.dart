// language_page.dart
import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground + kAppBorderGradient

enum AppLanguage { en, vi }

class LanguagePage extends StatefulWidget {
  const LanguagePage({
    super.key,
    this.initial = AppLanguage.vi,
    this.onChanged,
    this.flagUS = 'assets/flags/us.png',
    this.flagVN = 'assets/flags/vn.png',
  });

  final AppLanguage initial;
  final ValueChanged<AppLanguage>? onChanged;
  final String flagUS;
  final String flagVN;

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  late AppLanguage _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initial;
  }

  void _pick(AppLanguage lang) {
    setState(() => _selected = lang);
    widget.onChanged?.call(lang);
  }

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final side   = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSize = (size.width * 0.060).clamp(18, 22).toDouble();

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
                  // Header: back + title center
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _CircleBackButton(onTap: () => Navigator.pop(context)),
                      ),
                      Text(
                        'Ngôn ngữ',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFF2D2F79),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tile: English
                  _LanguageTile(
                    flagPath: widget.flagUS,
                    label: 'Tiếng Anh',
                    selected: _selected == AppLanguage.en,
                    onTap: () => _pick(AppLanguage.en),
                  ),
                  const SizedBox(height: 12),

                  // Tile: Vietnamese
                  _LanguageTile(
                    flagPath: widget.flagVN,
                    label: 'Tiếng Việt',
                    selected: _selected == AppLanguage.vi,
                    onTap: () => _pick(AppLanguage.vi),
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
              // Flag
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: Image.asset(flagPath, width: 28, height: 20, fit: BoxFit.cover),
              ),
              const SizedBox(width: 10),
              // Label
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                    color: const Color(0xFF2B2E47),
                  ),
                ),
              ),
              // Check box gradient (selected) / outline (unselected)
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
        border: selected
            ? null
            : Border.all(color: const Color(0xFFE6E2F5), width: 2),
        boxShadow: selected
            ? [
          BoxShadow(
            color: const Color(0xFF5539DA).withOpacity(0.18),
            blurRadius: 8,
            offset: const Offset(0, 3),
          )
        ]
            : null,
      ),
      alignment: Alignment.center,
      child: selected
          ? const Icon(Icons.check, size: 16, color: Colors.white)
          : const SizedBox.shrink(),
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
