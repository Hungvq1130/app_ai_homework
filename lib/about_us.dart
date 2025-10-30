import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart';

// ==== ĐƯỜNG DẪN ẢNH (đổi theo file của bạn) ====
const String kAboutMidHero = 'assets/about/abt_us2.png';
const String kAboutBottomHero = 'assets/about/abt_us1.png';
const String kIconHeaderSun = 'assets/about/light.png'; // 40x40 cạnh H1
const String kIconLeftBook =
    'assets/about/Group48.png'; // icon nhỏ bên trái đoạn 1
const String kIconRightBackpack =
    'assets/about/backpack.png'; // icon nhỏ bên phải đoạn 2

class AboutUsPage extends StatelessWidget {
  const AboutUsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    final side = (size.width * 0.07).clamp(16, 22).toDouble();
    final topGap = (size.height * 0.04).clamp(14, 24).toDouble();
    final h1 = (size.width * 0.072).clamp(20, 28).toDouble();
    final h2 = (size.width * 0.064).clamp(18, 24).toDouble();
    final bodySize = (size.width * 0.040).clamp(13, 16).toDouble();
    final paraGap = (size.height * 0.018).clamp(10, 16).toDouble();

    // Ảnh giữa to vừa, ảnh cuối to hơn 1 chút như mock
    final hero1MaxH = (size.height * 0.20).clamp(120, 180).toDouble();
    final hero2MaxH = (size.height * 0.28).clamp(170, 260).toDouble();
    final bulletStyle = theme.textTheme.bodyMedium?.copyWith(
      height: 1.4,
      color: const Color(0xFF3A3F63),
    );

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),
          SafeArea(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(side, topGap, side, topGap),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ===== H1 + icon mặt trời (40x40) =====
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Flexible(
                        child: Text(
                          'Học Bá AI là gì?',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontSize: h1,
                            fontWeight: FontWeight.w500,
                            color: const Color(0xFF2D2F79),
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Image.asset(kIconHeaderSun, width: 40, height: 40),
                    ],
                  ),

                  // Đoạn 1 + icon nhỏ bên trái (lọt mép)
                  ParagraphWithSideIcon(
                    text:
                        'Học Bá AI là ứng dụng giải bài tập nhưng không phải để làm bài hộ. '
                        'Không phải để rút ngắn đường học bằng lối tắt. Mà để trở thành một “trợ lý học tập thông minh”, '
                        'luôn kiên nhẫn giải thích, hướng dẫn từng bước và giúp người học tự hiểu bài.',
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: bodySize,
                      height: 1.45,
                      color: const Color(0xFF3A3F63),
                    ),
                    side: AxisDirection.left,
                    iconPath: kIconLeftBook,
                    iconSize: const Size(48, 40),
                    // đẩy icon ra ngoài mép trái 8px, nằm hơi cao hơn dòng đầu ~2px
                    offset: const Offset(10, 250),
                  ),


                  // Ảnh giữa
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: hero1MaxH),
                      child: Image.asset(kAboutMidHero, fit: BoxFit.contain),
                    ),
                  ),


                  // ===== H2 =====
                  Center(
                    child: Text(
                      'Câu chuyện về Học bá AI',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: h2,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFF2D2F79),
                        height: 1.2,
                      ),
                    ),
                  ),

                  // Đoạn 2 + icon nhỏ bên phải (lọt mép)
                  ParagraphWithSideIcon(
                    text:
                        'Trước khi trở thành những người làm công nghệ, chúng tôi cũng từng là những học sinh ham học – ham chơi, '
                        'từng mất hàng giờ loay hoay với những bài tập hack não. Chúng tôi hiểu rằng mỗi người có cách học khác nhau, '
                        'và không ai nên bị ép đi theo một lối học duy nhất.\n\n'
                        'Từ trải nghiệm đó, Học Bá AI ra đời — như một trợ lý học tập thông minh luôn ở bên, '
                        'giúp bạn hiểu bài theo cách phù hợp nhất với chính mình. '
                        'Không phải để làm bài hộ, mà để biến bài khó thành cơ hội học thông minh hơn.',
                    textStyle: theme.textTheme.bodyMedium?.copyWith(
                      fontSize: bodySize,
                      height: 1.45,
                      color: const Color(0xFF3A3F63),
                    ),
                    side: AxisDirection.right,
                    iconPath: kIconRightBackpack,
                    iconSize: const Size(40, 45),
                    // đẩy ra mép phải 6px, đặt thấp hơn đầu đoạn ~4px
                    offset: const Offset(-6, 160),
                  ),

                  SizedBox(height: paraGap),

                  // --- Bullets (không dùng class, giữ đúng format 👉Nội dung) ---
                  Text(
                    '👉 Học dễ hơn với bài giải mẫu chi tiết.',
                    style: bulletStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '👉 Hiểu sâu hơn khi nắm rõ phương pháp giải.',
                    style: bulletStyle,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '👉 Học mọi lúc mọi nơi chỉ với chiếc điện thoại nhỏ.',
                    style: bulletStyle,
                  ),

                  // Ảnh cuối (to hơn)
                  Center(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(maxHeight: hero2MaxH),
                      child: Image.asset(kAboutBottomHero, fit: BoxFit.contain),
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

/// Bullet “👉 …”
class _Bullet extends StatelessWidget {
  const _Bullet({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text('👉', style: TextStyle(fontSize: 16, height: 1.25)),
        SizedBox(width: 8),
        Expanded(
          child: Text(
            // text được truyền ngoài, nhưng để const không được;
            // ở đây chỉ là layout mẫu, bạn giữ nguyên bản dùng ở trên (không const).
            '',
          ),
        ),
      ],
    );
  }
}

/// Đặt một đoạn văn và “ghim” icon ảnh ở mép trái/phải với offset mịn.
class ParagraphWithSideIcon extends StatelessWidget {
  const ParagraphWithSideIcon({
    super.key,
    required this.text,
    required this.textStyle,
    required this.side,
    required this.iconPath,
    this.iconSize = const Size(40, 40),
    this.offset = Offset.zero,
  });

  final String text;
  final TextStyle? textStyle;
  final AxisDirection side; // AxisDirection.left / right
  final String iconPath;
  final Size iconSize;
  final Offset offset;

  @override
  Widget build(BuildContext context) {
    final paragraph = Text(text, style: textStyle);
    final icon = Transform.translate(
      offset: offset,
      child: Image.asset(
        iconPath,
        width: iconSize.width,
        height: iconSize.height,
      ),
    );

    // Dùng Stack để icon có thể “lọt” ra mép container
    return Stack(
      clipBehavior: Clip.none,
      children: [
        paragraph,
        Positioned(
          top: 0,
          left: side == AxisDirection.left ? -iconSize.width * 0.35 : null,
          right: side == AxisDirection.right ? -iconSize.width * 0.35 : null,
          child: icon,
        ),
      ],
    );
  }
}

/// Tiêu đề có icon dán cạnh (nếu cần), mặc định căn giữa.
class SectionTitleWithSideIcon extends StatelessWidget {
  const SectionTitleWithSideIcon({
    super.key,
    required this.title,
    required this.textStyle,
    required this.iconPath,
    this.iconSize = const Size(40, 40),
    this.gap = 6,
  });

  final String title;
  final TextStyle? textStyle;
  final String iconPath;
  final Size iconSize;
  final double gap;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Flexible(
          child: Text(title, textAlign: TextAlign.center, style: textStyle),
        ),
        SizedBox(width: gap),
        Image.asset(iconPath, width: iconSize.width, height: iconSize.height),
      ],
    );
  }
}
