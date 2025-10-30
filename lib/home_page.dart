import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:solve_exercise/solve_result_page.dart';
import 'package:solve_exercise/utility.dart';
import 'ask_page.dart';
import 'crop_page.dart';
import 'history_tab.dart';
import 'menu_tab.dart';
import 'settings_page.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  // Nếu muốn mở app vào Trang chủ, set mặc định = 1
  const HomePage({super.key, this.initialIndex = 1, this.incomingTaskId});

  final int initialIndex;
  final String? incomingTaskId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _index;
  late List<Widget> _pages;

  // ⬇️ Key để gọi refresh() của HistoryTab
  final GlobalKey<HistoryTabState> _historyKey = GlobalKey<HistoryTabState>();

  @override
  void initState() {
    super.initState();

    // Nếu có incomingTaskId (vừa solve xong), ưu tiên nhảy sang tab Lịch sử
    _index = (widget.incomingTaskId != null) ? 0 : widget.initialIndex;

    _pages = [
      HistoryTab(key: _historyKey), // ⬅️ gắn key public state
      const TrangChuTab(),
      const SettingsPage(),
    ];

    // Sau frame đầu, nếu đang đứng ở tab Lịch sử thì tự refresh
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_index == 0) {
        _historyKey.currentState?.refresh();
      }
    });
  }

  void _onTabChanged(int i) {
    setState(() => _index = i);
    // Mỗi lần bấm sang tab Lịch sử -> tự làm mới
    if (i == 0) {
      _historyKey.currentState?.refresh();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBody: true,

      body: IndexedStack(index: _index, children: _pages),

      bottomNavigationBar: EqualBottomBar(
        currentIndex: _index,
        onChanged: _onTabChanged,
        items: const [
          BarItem(label: 'Lịch sử',   icon: Icons.history_outlined,  selectedIcon: Icons.history_rounded),
          BarItem(label: 'Trang chủ', icon: Icons.home_outlined,     selectedIcon: Icons.home_rounded),
          BarItem(label: 'Cài đặt',   icon: Icons.settings_outlined, selectedIcon: Icons.settings_rounded),
        ],
      ),
    );
  }
}




/// ----------------- TRANG CHỦ (Responsive) -----------------
class TrangChuTab extends StatefulWidget {
  const TrangChuTab({super.key});

  @override
  State<TrangChuTab> createState() => _TrangChuTabState();
}

class _TrangChuTabState extends State<TrangChuTab> {
  // ---- State / controller ----
  final _controller = TextEditingController();
  final _focusNode = FocusNode();
  bool _loading = false;

  // ---- Config API (đổi theo của bạn) ----
  final String _apiUrl = 'https://ai-gateway.oneadx.com/v1/chat/';
  final String _apiKey = 'tyff8tkw1t0rfz0bcs8yo3gzrt9wajkd';

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _showError(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _send() async {
    if (_loading) return;

    final q = _controller.text.trim();
    if (q.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập nội dung câu hỏi')),
      );
      return;
    }

    FocusScope.of(context).unfocus();
    setState(() => _loading = true);

    try {
      final body = {
        "language": "Vietnamese",
        "content": q,
        "subject": "math", // TODO: thay bằng dropdown nếu cần
        "time": DateTime.now().millisecondsSinceEpoch,
        "api_key": _apiKey,
      };

      final resp = await http.post(
        Uri.parse(_apiUrl),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode(body),
      );

      if (resp.statusCode >= 200 && resp.statusCode < 300) {
        final data = jsonDecode(resp.body);
        final status = data['status']?.toString();
        final taskId = data['task_id']?.toString();

        if (status == 'success' && taskId != null && taskId.isNotEmpty) {
          if (!mounted) return;
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => SolveResultPage(
                taskId: taskId,
                // nếu SolveResultPage của bạn KHÔNG có originalQuestion thì bỏ dòng đó
                // originalQuestion: q,
              ),
            ),
          );
          _controller.clear();
        } else {
          _showError('Gửi câu hỏi thất bại: ${data['message'] ?? 'Không nhận được task_id'}');
        }
      } else {
        _showError('Máy chủ trả về mã lỗi ${resp.statusCode}');
      }
    } catch (e) {
      _showError('Không thể gửi câu hỏi: $e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.sizeOf(context);
    final w = size.width;

    final isTablet = w >= 600;
    final maxContentWidth = isTablet ? 720.0 : 560.0;
    final hPad = (w * 0.06).clamp(16.0, 24.0);
    final titleSize = (w * 0.06).clamp(22.0, 28.0);
    final subSize = (w * 0.038).clamp(13.0, 16.0);

    const double askBarH = 54;
    const double sideGap = 10;
    final double sideW = askBarH;

    final bottomBarH = EqualBottomBar.heightForWidth(w);
    final sysBottom = MediaQuery.viewPaddingOf(context).bottom;

    return Stack(
      children: [
        const SoftGradientBackground(),
        // Nội dung phía trên
        SafeArea(
          bottom: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: maxContentWidth),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(),
                    const SizedBox(height: 24),
                    Text(
                      'Giải bài tập AI',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontSize: titleSize,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Nhập câu hỏi cho tất cả các môn học dưới dạng văn bản',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontSize: subSize,
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Pill gợi ý -> điền text + focus (không điều hướng)
                    _AdaptivePillGridEqual(
                      maxColumns: 2,
                      minItemWidth: 160,
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        _PillSuggestion(
                          text: 'Tại sao Bức tường\nBerlin được xây dựng?',
                          onTap: () {
                            _controller.text = 'Tại sao Bức tường Berlin được xây dựng?';
                            _focusNode.requestFocus();
                          },
                        ),
                        _PillSuggestion(
                          text: 'Điệp âm là gì?',
                          onTap: () {
                            _controller.text = 'Điệp âm là gì?';
                            _focusNode.requestFocus();
                          },
                        ),
                      ],
                    ),

                    const Spacer(),
                    // chừa khoảng trống để nội dung không bị đè bởi thanh hỏi nổi
                    SizedBox(height: (bottomBarH + sysBottom) + 72),
                  ],
                ),
              ),
            ),
          ),
        ),

        // 👉 Thanh hỏi nổi (thu hẹp bên phải để chừa chỗ cho nút crop)
        Positioned(
          left: hPad,
          right: hPad + sideW + sideGap,
          bottom: bottomBarH + sysBottom + 12,
          child: _BottomAskBarInput(
            controller: _controller,
            focusNode: _focusNode,
            loading: _loading,
            hint: 'Gửi đề bài bạn muốn Học Bá AI giải',
            onSend: _send,
          ),
        ),

        // 👉 Nút Crop giữ nguyên
        Positioned(
          right: hPad,
          bottom: bottomBarH + sysBottom + 12,
          child: _RectSideButton(
            width: sideW,
            height: askBarH,
            icon: Icons.add_photo_alternate_outlined,
            iconColor: Colors.black,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CropPage()),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _PillSuggestion extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  const _PillSuggestion({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(14);

    return GradientBorder(
      borderRadius: radius,
      strokeWidth: 2.0,
      child: Material(
        color: theme.colorScheme.surface,
        shape: RoundedRectangleBorder(borderRadius: radius),
        child: InkWell(
          onTap: onTap,
          borderRadius: radius,
          child: Container(
            constraints: const BoxConstraints(minHeight: 52),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            alignment: Alignment.center,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomAskBarInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final VoidCallback onSend;
  final bool loading;
  final String hint;

  const _BottomAskBarInput({
    required this.controller,
    required this.focusNode,
    required this.onSend,
    required this.loading,
    this.hint = 'Gửi đề bài bạn muốn Học Bá AI giải',
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(15);

    return GradientBorder(
      borderRadius: radius,
      strokeWidth: 1.2,
      child: Material(
        elevation: 0,
        color: Colors.white.withOpacity(0.9),
        borderRadius: radius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  focusNode: focusNode,
                  minLines: 1,
                  maxLines: 4,
                  textInputAction: TextInputAction.send,
                  onSubmitted: (_) => onSend(),
                  decoration: InputDecoration(
                    hintText: hint,
                    border: InputBorder.none,
                  ),
                  style: theme.textTheme.bodyMedium,
                ),
              ),
              const SizedBox(width: 8),
              loading
                  ? const SizedBox(
                width: 28,
                height: 28,
                child: Padding(
                  padding: EdgeInsets.all(2.0),
                  child: CircularProgressIndicator(strokeWidth: 2.6),
                ),
              )
                  : GestureDetector(
                onTap: onSend,
                child: DecoratedBox(
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFF5539DA),
                        Color(0xFFDE8F96),
                        Color(0xFFEEC7BF),
                      ],
                    ),
                  ),
                  child: const SizedBox(
                    width: 34,
                    height: 34,
                    child: Icon(Icons.arrow_forward_rounded,
                        color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class EqualBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<BarItem> items;

  // 👇 thêm: độ dày viền riêng cho bottom bar
  final double borderWidth;

  static double heightForWidth(double w) {
    final roomy = w >= 600;
    return roomy ? 86 : 78;
  }

  const EqualBottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
    this.borderWidth = 1.0, // 👈 set tùy ý theo ý bạn
  });

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final roomy = w >= 600;

    // Kích thước theo màn hình
    final double barHeight = roomy ? 86 : 78;
    final double circle = roomy ? 56 : 48;
    final double iconSize = roomy ? 30 : 28;

    final topOnlyRadius = const BorderRadius.only(
      topLeft: Radius.circular(24),
      topRight: Radius.circular(24),
    );

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        top: false,
        child: GradientBorder(
          // 👇 viền gradient dùng chung
          borderRadius: topOnlyRadius,
          strokeWidth: borderWidth,
          gradient: kAppBorderGradient,
          child: Container
            (
            height: barHeight,
            decoration: BoxDecoration(
              color: Colors.white, // giống mockup: nền trắng
              borderRadius: topOnlyRadius,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  blurRadius: 24,
                  offset: const Offset(0, -8),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(items.length, (i) {
                final selected = i == currentIndex;

                Widget icon = Icon(
                  selected ? items[i].selectedIcon : items[i].icon,
                  size: iconSize,
                  color: selected ? Colors.white : Colors.black87,
                );

                // Icon có nền tròn gradient khi được chọn
                if (selected) {
                  icon = Container(
                    width: circle,
                    height: circle,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF5539DA), // 0.06%
                          Color(0xFFDE8F96), // 48.43%
                          Color(0xFFEEC7BF), // 102.74%
                        ],
                      ),
                    ),
                    child: Center(child: icon),
                  );
                }

                return Expanded(
                  child: Center(
                    child: InkResponse(
                      onTap: () => onChanged(i),
                      radius: circle,
                      containedInkWell: false,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 6), // nhìn thoáng như ảnh
                        child: icon,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _AdaptivePillGridEqual extends StatelessWidget {
  const _AdaptivePillGridEqual({
    super.key,
    required this.children,
    this.minItemWidth = 160,
    this.spacing = 12,
    this.runSpacing = 12,
    this.maxColumns = 2, // 2 gợi ý => 2 cột
  });

  final List<Widget> children;
  final double minItemWidth;
  final double spacing;
  final double runSpacing;
  final int maxColumns;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final maxW = constraints.maxWidth;

      // Tính số cột theo bề rộng khả dụng (giới hạn bởi maxColumns)
      int cols = (maxW + spacing) ~/ (minItemWidth + spacing);
      cols = cols.clamp(1, maxColumns);

      // Chia children theo hàng
      final rows = <List<Widget>>[];
      for (int i = 0; i < children.length; i += cols) {
        rows.add(children.sublist(i, math.min(i + cols, children.length)));
      }

      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (int r = 0; r < rows.length; r++) ...[
            IntrinsicHeight( // 👈 đảm bảo chiều cao hàng = cao nhất trong hàng
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch, // 👈 các ô cao bằng nhau
                children: [
                  for (int c = 0; c < cols; c++) ...[
                    Expanded(
                      child: c < rows[r].length
                          ? rows[r][c]
                          : const SizedBox.shrink(), // ô trống nếu thiếu
                    ),
                    if (c != cols - 1) SizedBox(width: spacing),
                  ],
                ],
              ),
            ),
            if (r != rows.length - 1) SizedBox(height: runSpacing),
          ],
        ],
      );
    });
  }
}

const kAppBrandGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [
    Color(0xFF5539DA),
    Color(0xFFDE8F96),
    Color(0xFFEEC7BF),
  ],
  stops: [0.0006, 0.4843, 1.0],
);

class _RectSideButton extends StatelessWidget {
  const _RectSideButton({
    super.key,
    required this.width,
    required this.height,
    required this.icon,
    required this.onTap,
    this.iconColor = Colors.black,
    this.iconSize = 25,
  });

  final double width;
  final double height;
  final IconData icon;
  final VoidCallback onTap;
  final Color iconColor;
  final double iconSize;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        width: width,
        height: height,
        decoration: BoxDecoration(// ❗ không bo góc
          borderRadius: BorderRadius.zero,
        ),
        child: InkWell(
          onTap: onTap,
          child: Center(
            child: Icon(icon, color: iconColor, size: iconSize),
          ),
        ),
      ),
    );
  }
}

/// --------- Widgets phụ ---------

class BarItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const BarItem({required this.label, required this.icon, required this.selectedIcon});
}





