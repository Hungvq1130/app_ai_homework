// terms_of_service_page.dart
import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // responsive
    final side = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSize = (size.width * 0.060).clamp(18, 22).toDouble();
    final hSize = (size.width * 0.050).clamp(15, 18).toDouble();
    final bodySize = (size.width * 0.040).clamp(13, 15).toDouble();

    const purple = Color(0xFF2D2F79);
    const text = Color(0xFF3A3F63);

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
                        child: _CircleBackButton(
                          onTap: () => Navigator.pop(context),
                        ),
                      ),
                      Text(
                        'Điều khoản dịch vụ',
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
                        _Body(
                          'Chào mừng bạn đến với ứng dụng Học Bá AI. Khi truy cập hoặc sử dụng Ứng dụng, '
                          'bạn đồng ý tuân thủ và bị ràng buộc bởi các Điều khoản Dịch vụ này.',
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 14),
                        _SectionTitle('Mục đích sử dụng', size: hSize),
                        _Body(
                          'Ứng dụng cung cấp các tính năng hỗ trợ học tập bằng trí tuệ nhân tạo (AI), bao gồm nhưng không giới hạn ở:',
                          bodySize: bodySize,
                        ),
                        const SizedBox(height: 6),
                        _Bullets(
                          items: const [
                            'Gợi ý hướng giải và gợi ý cách giải bài tập;',
                            'Cung cấp đáp án tham khảo;',
                            'Hỗ trợ người học rèn luyện và nâng cao kiến thức.',
                          ],
                          bodySize: bodySize,
                        ),
                        const SizedBox(height: 6),
                        _Body(
                          'Ứng dụng KHÔNG nhằm mục đích thay thế cho quá trình học tập, làm bài; '
                          'không phục vụ gian lận học thuật.',
                          bodySize: bodySize,
                          strong: true,
                        ),

                        const SizedBox(height: 14),
                        _SectionTitle('Trách nhiệm người dùng', size: hSize),
                        _Bullets(
                          items: const [
                            'Không sử dụng Ứng dụng để gian lận trong thi cử, làm bài kiểm tra hoặc vi phạm quy định học đường;',
                            'Không khai thác, phát tán hoặc sử dụng nội dung do AI tạo ra vào các mục đích trái pháp luật hoặc gian lận học thuật;',
                            'Chịu hoàn toàn trách nhiệm về mọi hậu quả phát sinh từ việc sử dụng Ứng dụng.',
                          ],
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 14),
                        _SectionTitle(
                          'Điều khoản dành riêng cho học sinh',
                          size: hSize,
                        ),

                        const SizedBox(height: 10),
                        _SubTitle('1. Mục đích giáo dục', size: hSize - 2),
                        _Body(
                          'Ứng dụng được thiết kế nhằm hỗ trợ học sinh hiểu và làm chủ kiến thức, '
                          'không phải để thay thế quá trình học tập.',
                          bodySize: bodySize,
                        ),
                        const SizedBox(height: 6),
                        _Bullets(
                          items: const [
                            'Tham khảo phương pháp giải;',
                            'Củng cố từng bước giải / kiến thức;',
                            'Nâng cao năng lực học tự duy và tự phân biện.',
                          ],
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 10),
                        _SubTitle(
                          '2. Cam kết đạo đức học tập',
                          size: hSize - 2,
                        ),
                        _Bullets(
                          items: const [
                            'Không dùng ứng dụng để nộp bài giải AI tạo ra như sản phẩm của mình;',
                            'Không vận dụng kết quả để lách các điều chỉnh chính sách kiểm tra/đánh giá;',
                            'Nỗ lực rèn luyện đạo đức học tập, chịu trách nhiệm với các nội dung đã nộp.',
                          ],
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 10),
                        _SubTitle(
                          '3. Kiểm soát và xử lý vi phạm',
                          size: hSize - 2,
                        ),
                        _Body(
                          'Nhà trường hoặc tổ chức giáo dục có thể áp dụng các biện pháp kiểm tra, phát hiện hành vi gian lận liên quan đến việc sử dụng AI. Nếu phát hiện người dùng vi phạm, chúng tôi có quyền:',
                          bodySize: bodySize,
                        ),
                        _Bullets(
                          items: const [
                            'Cảnh báo, tạm khóa hoặc chấm dứt tài khoản;',
                            'Cung cấp thông tin cần thiết cho cơ quan/đơn vị giáo dục liên quan khi có yêu cầu hợp pháp.',
                            'Nỗ lực rèn luyện đạo đức học tập, chịu trách nhiệm với các nội dung đã nộp.',
                          ],
                          bodySize: bodySize,
                        ),
                        _Body(
                          'Người dùng vi phạm chịu hoàn toàn trách nhiệm trước quy định của nhà trường (nếu có).',
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 10),
                        _SubTitle(
                          '4. Khuyến khích sử dụng có trách nhiệm',
                          size: hSize - 2,
                        ),
                        _Body(
                          'Chúng tôi khuyến khích học sinh:',
                          bodySize: bodySize,
                        ),
                        _Bullets(
                          items: const [
                            'Sử dụng AI như một trợ giảng cá nhân, không phải người làm bài hộ;',
                            'Tự kiểm chứng mọi kết quả do AI cung cấp;',
                            'Chủ động học hỏi, đặt câu hỏi, thảo luận thay vì phụ thuộc vào máy.',
                          ],
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 14),
                        _SectionTitle('Miễn trừ trách nhiệm', size: hSize),
                        const SizedBox(height: 10),
                        _Body(
                          'Chào mừng bạn đến với ứng dụng Học Bá AI. Khi truy cập hoặc sử dụng Ứng dụng, ',
                          bodySize: bodySize,
                        ),
                        const SizedBox(height: 10),
                        _Body(
                              'Việc sử dụng AI cần được thực hiện một cách có trách nhiệm, trung thực và minh bạch. Chúng tôi KHÔNG chịu trách nhiệm đối với bất kỳ thiệt hại nào phát sinh từ việc người dùng lạm dụng AI để gian lận học tập, vi phạm quy chế thi cử hoặc quy định của học đường.',
                          bodySize: bodySize,
                        ),
                        const SizedBox(height: 10),
                        _Body(
                              'Kết quả do AI cung cấp chỉ mang tính chất tham khảo. Người dùng cần kiểm chứng và chịu trách nhiệm về quyết định sử dụng.',
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 14),
                        _SectionTitle('Quyền sở hữu trí tuệ', size: hSize),

                        const SizedBox(height: 10),
                        _Body(
                          'Mọi nội dung, thiết kế, nhãn hiệu, mã nguồn và công nghệ liên quan đến Ứng dụng thuộc quyền sở hữu của Công ty TNHH ONEADX.',
                          bodySize: bodySize,
                        ),

                        const SizedBox(height: 14),
                        _SectionTitle('Thay đổi điều khoản', size: hSize),

                        const SizedBox(height: 10),
                        _Body(
                          'Chúng tôi có quyền cập nhật hoặc sửa đổi các Điều khoản này bất kỳ lúc nào. Mọi thay đổi sẽ có hiệu lực kể từ khi được đăng tải trên Ứng dụng.',
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

// ===== Helpers (giống các trang legal khác) =====

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
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D2F79),
      ),
    );
  }
}

class _SubTitle extends StatelessWidget {
  const _SubTitle(this.text, {required this.size});

  final String text;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontSize: size,
        fontWeight: FontWeight.w600,
        color: const Color(0xFF2D2F79),
      ),
    );
  }
}

class _Body extends StatelessWidget {
  const _Body(this.text, {required this.bodySize, this.strong = false});

  final String text;
  final double bodySize;
  final bool strong;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        fontSize: bodySize,
        height: 1.45,
        color: const Color(0xFF3A3F63),
        fontWeight: strong ? FontWeight.w700 : FontWeight.w400,
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
          .map(
            (t) => Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '•  ',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF2D2F79),
                    ),
                  ),
                  Expanded(child: Text(t, style: style)),
                ],
              ),
            ),
          )
          .toList(),
    );
  }
}
