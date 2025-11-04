import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:solve_exercise/privacy_policy_page.dart';
import 'package:solve_exercise/term_of_services.dart';
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground

/// === Đổi đường dẫn nếu bạn đã có file nội dung ===
/// (có thể để null rồi truyền content trực tiếp khi push)
const String? kTermsAssetPath   = 'assets/legal/terms_vi.txt';   // hoặc .md/.txt
const String? kPrivacyAssetPath = 'assets/legal/privacy_vi.txt';

class TermsMenuPage extends StatelessWidget {
  const TermsMenuPage({
    super.key,
    this.termsAssetPath = kTermsAssetPath,
    this.privacyAssetPath = kPrivacyAssetPath,
  });

  final String? termsAssetPath;
  final String? privacyAssetPath;

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final side   = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap = (size.height * 0.02).clamp(8, 16).toDouble();
    const titleColor = Color(0xFF2D2F79);

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
                  // Header: back + title bên trái (giống ảnh)
                  Row(
                    children: [
                      _BackButton(onTap: () => Navigator.pop(context)),
                      const SizedBox(width: 8),
                      Text(
                        'legal.menu.title'.tr(),
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w500,
                          color: titleColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Tiles
                  _LegalTile(
                    title: 'legal.menu.terms'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => TermsOfServicePage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  _LegalTile(
                    title: 'legal.menu.privacy'.tr(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => PrivacyPolicyPage(
                          ),
                        ),
                      );
                    },
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

/// Trang chi tiết: đọc nội dung từ asset (txt/md) hoặc nhận thẳng content.

/// Nút back tròn như ảnh
class _BackButton extends StatelessWidget {
  const _BackButton({required this.onTap});
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

/// Tile trắng bo góc + chevron
class _LegalTile extends StatelessWidget {
  const _LegalTile({required this.title, required this.onTap});
  final String title;
  final VoidCallback onTap;

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
