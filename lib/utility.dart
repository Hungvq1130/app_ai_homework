import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:flutter/material.dart';

const kAppBorderGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xFF5539DA), // 0.06%
    Color(0xFFDE8F96), // 48.43%
    Color(0xFFEEC7BF), // 102.74% ~ 1.0
  ],
  stops: [0.0006, 0.4843, 1.0],
);

class GradientBorder extends StatelessWidget {
  const GradientBorder({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(14)),
    this.strokeWidth = 1.0,
    this.gradient = kAppBorderGradient,
  });

  final Widget child;
  final BorderRadius borderRadius;
  final double strokeWidth;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      foregroundPainter: _GradientBorderPainter(
        borderRadius: borderRadius,
        strokeWidth: strokeWidth,
        gradient: gradient,
      ),
      child: ClipRRect(
        borderRadius: borderRadius,
        child: child,
      ),
    );
  }
}

class _GradientBorderPainter extends CustomPainter {
  _GradientBorderPainter({
    required this.borderRadius,
    required this.strokeWidth,
    required this.gradient,
  });

  final BorderRadius borderRadius;
  final double strokeWidth;
  final Gradient gradient;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    final paint = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..isAntiAlias = true;

    final rrect = RRect.fromRectAndCorners(
      rect.deflate(strokeWidth / 2), // vẽ gọn vào trong để không lẹm
      topLeft: borderRadius.topLeft,
      topRight: borderRadius.topRight,
      bottomLeft: borderRadius.bottomLeft,
      bottomRight: borderRadius.bottomRight,
    );

    canvas.drawRRect(rrect, paint);
  }

  @override
  bool shouldRepaint(covariant _GradientBorderPainter old) {
    return old.strokeWidth != strokeWidth ||
        old.borderRadius != borderRadius ||
        old.gradient != gradient;
  }
}

/// Chuyển (0..1) -> Alignment(-1..1)
Alignment _frac(double fx, double fy) => Alignment(-1 + 2 * fx, -1 + 2 * fy);

class SoftGradientBackground extends StatelessWidget {
  const SoftGradientBackground({
    super.key,
    this.baseColor,
    this.pinkColor = const Color(0xFFDE8F96),
    this.purpleColor = const Color(0xFF5539DA),
    this.pink1Opacity = 0.30,   // radial 1 (top-left) – hồng
    this.purple2Opacity = 0.20, // radial 2 (top-right) – tím
    this.purple3Opacity = 0.20, // radial 3 (bottom-left) – tím
    this.pink3Opacity = 0.20,   // radial 3 – hồng
    this.includeBaseLayer = true,
  });

  /// Nền lớp 0 (thường là trắng/surface). Nếu null sẽ lấy từ Theme.
  final Color? baseColor;

  /// Màu chủ đạo (hồng/tím) có thể thay theo branding.
  final Color pinkColor;
  final Color purpleColor;

  /// Opacity từng lớp để dễ tinh chỉnh theo theme sáng/tối.
  final double pink1Opacity;
  final double purple2Opacity;
  final double purple3Opacity;
  final double pink3Opacity;

  /// Có vẽ lớp baseColor hay không (ví dụ khi đã có ảnh nền riêng).
  final bool includeBaseLayer;

  @override
  Widget build(BuildContext context) {
    final Color base = baseColor ?? Theme.of(context).colorScheme.surface;

    return Stack(
      children: [
        if (includeBaseLayer)
          Positioned.fill(child: ColoredBox(color: base)),

        // radial 1: top-left 2.9% 0% — hồng -> trong
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: _frac(0.029, 0.0),
                radius: 0.9,
                colors: [
                  pinkColor.withOpacity(pink1Opacity),
                  pinkColor.withOpacity(0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),

        // radial 2: top-right (128.24% 39.14%) — tím -> trong
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: _frac(1.2824, 0.3914),
                radius: 1.1,
                colors: [
                  purpleColor.withOpacity(purple2Opacity),
                  purpleColor.withOpacity(0.0),
                ],
                stops: const [0.0, 1.0],
              ),
            ),
          ),
        ),

        // radial 3: bottom-left (-8.02% 89.2%) — tím -> hồng -> trong
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: _frac(-0.0802, 0.892),
                radius: 1.2,
                colors: [
                  purpleColor.withOpacity(purple3Opacity),
                  pinkColor.withOpacity(pink3Opacity),
                  pinkColor.withOpacity(0.0),
                ],
                stops: const [0.0, 0.5096, 1.0],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class SoftGradientPage extends StatelessWidget {
  const SoftGradientPage({
    super.key,
    required this.child,
    this.baseColor,
    this.safeAreaTop = true,
    this.safeAreaBottom = false, // thường để false để hòa chung với bottom bar
    this.pinkColor = const Color(0xFFDE8F96),
    this.purpleColor = const Color(0xFF5539DA),
    this.includeBaseLayer = true,
  });

  final Widget child;
  final Color? baseColor;
  final bool safeAreaTop;
  final bool safeAreaBottom;
  final Color pinkColor;
  final Color purpleColor;
  final bool includeBaseLayer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SoftGradientBackground(
          baseColor: baseColor,
          pinkColor: pinkColor,
          purpleColor: purpleColor,
          includeBaseLayer: includeBaseLayer,
        ),
        SafeArea(
          top: safeAreaTop,
          bottom: safeAreaBottom,
          child: child,
        ),
      ],
    );
  }
}

const double kEqualBottomBarHeight = 1;

// Góc 126.56° -> ~2.209498 rad
const kOnboardingBorderGradient = LinearGradient(
  transform: GradientRotation(2.209498),
  colors: [
    Color(0xE65539DA), // rgba(85,57,218,0.9)
    Color(0x00DE8F96), // rgba(222,143,150,0.0)
    Color(0xE6EEC7BF), // rgba(238,199,191,0.9)
  ],
  stops: [0.0, 0.4151, 1.0],
);

// ---- Card bọc sẵn viền gradient 1.6px (bo góc mặc định 22) ----
class OnboardingGradientCard extends StatelessWidget {
  const OnboardingGradientCard({
    super.key,
    required this.child,
    this.radius = 22,
    this.strokeWidth = 1.6,
    this.gradient = kOnboardingBorderGradient,
    this.backgroundColor,
    this.padding = const EdgeInsets.all(18),
  });

  final Widget child;
  final double radius;
  final double strokeWidth;
  final Gradient gradient;
  final Color? backgroundColor;
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context) {
    final bg = backgroundColor ?? Colors.white.withOpacity(0.96);
    return GradientBorder(
      strokeWidth: strokeWidth,
      borderRadius: BorderRadius.circular(radius),
      gradient: gradient,
      child: Container(
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: padding,
        child: child,
      ),
    );
  }
}