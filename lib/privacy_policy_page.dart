import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size  = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // responsive spacing / font sizes
    final side      = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap    = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSize = (size.width * 0.060).clamp(18, 22).toDouble();
    final hSize     = (size.width * 0.050).clamp(15, 18).toDouble();
    final bodySize  = (size.width * 0.040).clamp(13, 15).toDouble();

    const purple = Color(0xFF2D2F79);
    const text   = Color(0xFF3A3F63);

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),

          SafeArea(
            child: Column(
              children: [
                // Header: back + title giữa
                Padding(
                  padding: EdgeInsets.fromLTRB(side, topGap, side, 6),
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: _CircleBackButton(onTap: () => Navigator.pop(context)),
                      ),
                      Text(
                        'Chính sách bảo mật',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          color: purple,
                        ),
                      ),
                    ],
                  ),
                ),

                // Nội dung
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(side, 6, side, side),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _SectionTitle('Thông tin thu thập', size: hSize),
                        _Body(
                          'Chúng tôi có thể thu thập các loại thông tin sau:',
                          bodySize: bodySize,
                        ),
                        const SizedBox(height: 6),
                        _Bullets(items: const [
                          'Thông tin tài khoản (tên đăng nhập, email, mật khẩu đã mã hoá);',
                          'Dữ liệu sử dụng (câu hỏi gửi lên, lịch sử truy vấn, thống kê học tập);',
                          'Dữ liệu thiết bị (loại thiết bị, trình duyệt, IP);',
                          'Chúng tôi có thể sử dụng cookie để lưu thông tin đăng nhập, tuỳ chỉnh trải nghiệm và thống kê mức độ tương tác của người dùng.',
                        ], bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('Mục đích sử dụng thông tin', size: hSize),
                        _Bullets(items: const [
                          'Cung cấp và cải thiện trải nghiệm sử dụng Ứng dụng;',
                          'Hỗ trợ kỹ thuật, phản hồi người dùng;',
                          'Nghiên cứu và phát triển sản phẩm;',
                          'Đảm bảo bảo toàn và phát hiện hành vi lạm dụng hệ thống.',
                        ], bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('Bảo mật và lưu trữ', size: hSize),
                        _Body(
                          'Dữ liệu người dùng được mã hoá và lưu trữ trên máy chủ bảo mật. '
                              'Chúng tôi áp dụng các biện pháp kỹ thuật và tổ chức hợp lý để ngăn chặn truy cập trái phép, mất mát hoặc rò rỉ thông tin.',
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 14),
                        _SectionTitle('Chia sẻ thông tin', size: hSize),
                        _Body(
                          'Chúng tôi không bán hoặc cho thuê thông tin cá nhân cho bên thứ ba. Thông tin chỉ được chia sẻ khi:',
                          bodySize: bodySize,
                        ),
                        const SizedBox(height: 6),
                        _Bullets(items: const [
                          'Có sự đồng ý của người dùng;',
                          'Theo yêu cầu của cơ quan nhà nước có thẩm quyền;',
                          'Phục vụ vận hành kỹ thuật của Ứng dụng (ví dụ: dịch vụ lưu trữ đám mây).',
                        ], bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('Quyền của người dùng', size: hSize),
                        _Bullets(items: const [
                          'Truy cập, chỉnh sửa hoặc xoá thông tin cá nhân;',
                          'Yêu cầu ngừng xử lý dữ liệu cho mục đích phân tích;',
                          'Rút lại sự đồng ý bất cứ lúc nào (trong phạm vi pháp luật cho phép).',
                        ], bodySize: bodySize),

                        const SizedBox(height: 14),
                        _SectionTitle('Thay đổi chính sách', size: hSize),
                        _Body(
                          'Chính sách này có thể được cập nhật định kỳ. Mọi thay đổi sẽ được hiển thị trên ứng dụng.',
                          bodySize: bodySize,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ===== helper widgets =====

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
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2F79)),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text, {required this.size});
  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF2D2F79),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text, {required this.bodySize});
  final String text;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: bodySize,
        height: 1.45,
        color: const Color(0xFF3A3F63),
      ),
    );
  }
}

class _Bullets extends StatelessWidget {
  const _Bullets({required this.items, required this.bodySize});
  final List<String> items;
  final double bodySize;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium?.copyWith(
      fontSize: bodySize,
      height: 1.45,
      color: const Color(0xFF3A3F63),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items
          .map((t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('•  ', style: TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF2D2F79))),
            Expanded(child: Text(t, style: style)),
          ],
        ),
      ))
          .toList(),
    );
  }
}
