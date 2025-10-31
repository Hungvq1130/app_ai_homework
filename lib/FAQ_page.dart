import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart'; // SoftGradientBackground

class FaqPage extends StatelessWidget {
  const FaqPage({super.key});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    // layout responsive
    final side = (size.width * 0.06).clamp(14, 22).toDouble();
    final topGap = (size.height * 0.02).clamp(8, 16).toDouble();
    final titleSize = (size.width * 0.060).clamp(18, 22).toDouble();
    final qSize = (size.width * 0.045).clamp(14, 17).toDouble();
    final aSize = (size.width * 0.040).clamp(13, 15).toDouble();

    const qColor = Color(0xFF2D2F79);
    const aColor = Color(0xFF3A3F63);

    final items = const <_FaqItem>[
      _FaqItem(
        q: 'Học Bá AI có giải giúp toàn bộ bài tập không?',
        a: 'Không. Học Bá AI  được thiết kế để hỗ trợ quá trình học tập của người dùng. Khi bạn nhập một bài tập, hệ thống AI sẽ phân tích đề bài, đưa ra gợi ý hướng giải, giải thích từng bước một và cung cấp đáp án tham khảo nếu có.  Mục tiêu chính là giúp bạn hiểu bản chất kiến thức và phương pháp giải, từ đó có thể tự áp dụng vào những bài tương tự.',
      ),
      _FaqItem(
        q: 'Sử dụng Học Bá AI để làm bài tập có bị coi là gian lận không?',
        a:
            'Nếu bạn dùng Học Bá AI như một công cụ hỗ trợ học tập để hiểu cách giải, kiểm tra lại bài làm hoặc học thêm phương pháp mới thì đó là cách sử dụng đúng đắn và hợp pháp. Tuy nhiên, nếu bạn sao chép kết quả Học Bá AI tạo ra và nộp như bài làm của mình, đặc biệt là trong các kỳ kiểm tra, đánh giá hoặc bài tập được chấm điểm, thì điều đó có thể bị coi là gian lận học thuật theo quy định của nhà trường. '
      ),
      _FaqItem(
        q: 'Dữ liệu bài tập của tôi có bị lưu hoặc chia sẻ không?',
        a:
            'Chúng tôi có thể lưu trữ một phần thông tin về lịch sử truy vấn và nội dung bài tập để cải thiện chất lượng phản hồi của Học Bá AI, giúp hệ thống học và hỗ trợ bạn tốt hơn. Tuy nhiên, những thông tin này được ẩn danh và mã hóa, không lưu kèm thông tin cá nhân nhận dạng cụ thể nếu không cần thiết. '
      ),
      _FaqItem(
        q: 'Học Bá AI có đảm bảo kết quả luôn chính xác không?',
        a: 'Không có hệ thống AI nào đạt độ chính xác tuyệt đối 100%. Các đáp án và lời giải do ứng dụng cung cấp chỉ mang tính hỗ trợ và tham khảo, có thể có sai sót hoặc cách giải chưa hoàn toàn tối ưu. Bạn nên sử dụng kết quả này như một nguồn tham khảo để so sánh, kiểm chứng với cách làm của bản thân hoặc tài liệu chính thống.',
      ),
      _FaqItem(
        q: 'Tôi có thể sử dụng ứng dụng trong giờ kiểm tra không?',
        a:
            'Không. Học Bá AI tuyệt đối không được sử dụng trong các kỳ thi, bài kiểm tra hoặc bất kỳ hình thức đánh giá chính thức nào mà không có sự cho phép của nhà trường hoặc giáo viên phụ trách. Mục đích của ứng dụng là giúp bạn học và rèn luyện kiến thức, không phải cung cấp “đáp án hộ” trong các tình huống kiểm tra.'
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          const SoftGradientBackground(includeBaseLayer: true),

          SafeArea(
            child: Column(
              children: [
                // ===== Header: back + title center (không có card trắng) =====
                Padding(
                  padding: EdgeInsets.fromLTRB(side, topGap, side, 8),
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
                        'Câu hỏi thường gặp',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontSize: titleSize,
                          fontWeight: FontWeight.w500,
                          color: qColor,
                        ),
                      ),
                    ],
                  ),
                ),

                // ===== Q&A trực tiếp trên nền gradient =====
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(side, 6, side, side),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: List.generate(items.length, (i) {
                        final it = items[i];
                        return Padding(
                          padding: EdgeInsets.only(
                            bottom: i == items.length - 1 ? 0 : 16,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Câu hỏi (đậm + màu)
                              Text.rich(
                                TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '${i + 1}. ',
                                      style: TextStyle(
                                        fontSize: qSize,
                                        fontWeight: FontWeight.w500,
                                        color: qColor,
                                      ),
                                    ),
                                    TextSpan(
                                      text: it.q,
                                      style: TextStyle(
                                        fontSize: qSize,
                                        fontWeight: FontWeight.w500,
                                        color: qColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 6),
                              // Trả lời
                              Text(
                                it.a,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontSize: aSize,
                                  height: 1.45,
                                  color: aColor,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
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

class _FaqItem {
  final String q;
  final String a;

  const _FaqItem({required this.q, required this.a});
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
          width: 40,
          height: 40,
          child: Icon(Icons.arrow_back_rounded, color: Color(0xFF2D2F79)),
        ),
      ),
    );
  }
}
