import 'package:flutter/material.dart';
import 'ask_page.dart';
import 'crop_page.dart';
import 'hoc_tap_tab.dart';
import 'menu_tab.dart';
import 'settings_page.dart'; // ⬅️ import trang Cài đặt

class HomePage extends StatefulWidget {
  const HomePage({super.key, this.initialIndex = 0, this.incomingTaskId});

  final int initialIndex;
  final String? incomingTaskId;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _index;
  late List<Widget> _pages;
  final _titles = const ['Trang chủ', 'Học tập', 'Menu'];

  @override
  void initState() {
    super.initState();
    _index = widget.initialIndex;
    _pages = [
      const TrangChuTab(),
      HocTapTab(),
      const MenuTab(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // AppBar chỉ hiện khi _index != 0; thêm icon settings ở actions
      appBar: _index == 0
          ? null
          : AppBar(
        title: Text(_titles[_index]),
        actions: [
          if (_index == 2)
          IconButton(
            tooltip: 'Cài đặt',
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsPage()),
              );
            },
          ),
        ],
      ),
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: EqualBottomBar(
        currentIndex: _index,
        onChanged: (i) => setState(() => _index = i),
        items: const [
          BarItem(label: 'Trang chủ', icon: Icons.home_outlined, selectedIcon: Icons.home_rounded),
          BarItem(label: 'Học tập',   icon: Icons.school_outlined, selectedIcon: Icons.school_rounded),
          BarItem(label: 'Menu',      icon: Icons.menu_rounded,     selectedIcon: Icons.menu_rounded),
        ],
      ),
    );
  }
}



/// ----------------- TRANG CHỦ (Responsive) -----------------
class TrangChuTab extends StatelessWidget {
  const TrangChuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.sizeOf(context).width;

    // Breakpoints & kích thước co giãn
    final isTablet = w >= 600;
    final maxContentWidth = isTablet ? 720.0 : 560.0;
    final hPad = (w * 0.04).clamp(16.0, 24.0);      // padding ngang
    final vGap = (w * 0.04).clamp(12.0, 24.0);      // khoảng cách dọc
    final titleSize = (w * 0.04).clamp(20.0, 28.0); // cỡ tiêu đề
    final searchH = (w * 0.13).clamp(48.0, 64.0);   // chiều cao ô tìm kiếm
    final camSize = (searchH - 12).clamp(36.0, 52.0);
    final avatarR = (searchH * 0.4).clamp(18.0, 26.0);

    return SafeArea(
      bottom: false,
      child: Align(
        alignment: Alignment.topCenter,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxContentWidth),
          child: ListView(
            padding: EdgeInsets.fromLTRB(hPad, vGap * 0.7, hPad, 0),
            children: [
              // Hàng avatar + 2 icon góc phải
              Row(
                children: [
                  CircleAvatar(
                    radius: avatarR,
                    backgroundColor: theme.colorScheme.primaryContainer,
                    child: Icon(
                      Icons.person_outline_outlined,
                      size: avatarR + 4,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                  ),
                  const Spacer(),
                  _IconButtonDot(icon: Icons.bookmark_border_outlined, onTap: () {}),
                  const SizedBox(width: 4),
                  _IconButtonDot(
                    icon: Icons.notifications_none_outlined,
                    showDot: true,
                    onTap: () {},
                  ),
                ],
              ),

              SizedBox(height: vGap * 5),

              // Tiêu đề lớn
              Text(
                'Hỏi về bất kỳ điều gì!',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                  fontSize: titleSize,
                  height: 1,
                ),
              ),

              SizedBox(height: vGap * 0.8),

              // Ô tìm kiếm + nút camera tròn
              Row(
                children: [
                  // Ô "Đặt câu hỏi..." có border nhẹ, bấm để sang trang khác
                  Expanded(
                    child: _AskBox(
                      height: searchH,
                      hint: 'Đặt câu hỏi về mọi môn học',
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const AskPage()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Nút camera tròn riêng, bấm là vào CropPage
                  _RoundIconButton(
                    size: camSize,
                    icon: Icons.camera_alt_outlined,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(builder: (_) => const CropPage()),
                      );
                    },
                  ),
                ],
              ),
              SizedBox(height: vGap),

            ],
          ),
        ),
      ),
    );
  }
}

/// --------- Widgets phụ ---------

class _SearchWithCamera extends StatelessWidget {
  final String hint;
  final double height;
  final double cameraSize;
  final VoidCallback? onTapField;
  final VoidCallback onCamera;

  const _SearchWithCamera({
    required this.hint,
    required this.height,
    required this.cameraSize,
    required this.onCamera,
    this.onTapField,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(height / 2);

    return SizedBox(
      height: height,
      child: Stack(
        children: [
          Positioned.fill(
            child: GestureDetector(
              onTap: onTapField,
              child: AbsorbPointer(
                child: TextField(
                  readOnly: true,
                  decoration: InputDecoration(
                    hintText: hint,
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerLowest,
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: height * 0.35, vertical: 0),
                    border: OutlineInputBorder(
                      borderSide: BorderSide.none,
                      borderRadius: radius,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
          ),
          Positioned(
            right: 6,
            top: (height - cameraSize) / 2,
            child: Material(
              color: const Color(0xFFFF6A00),
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: onCamera,
                child: SizedBox(
                  width: cameraSize,
                  height: cameraSize,
                  child: const Icon(Icons.camera_alt_outlined, color: Colors.white),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconButtonDot extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool showDot;
  const _IconButtonDot({
    required this.icon,
    required this.onTap,
    this.showDot = false,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        IconButton(onPressed: onTap, icon: Icon(icon)),
      ],
    );
  }
}

class BarItem {
  final String label;
  final IconData icon;
  final IconData selectedIcon;
  const BarItem({required this.label, required this.icon, required this.selectedIcon});
}

class EqualBottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onChanged;
  final List<BarItem> items;

  const EqualBottomBar({
    super.key,
    required this.currentIndex,
    required this.onChanged,
    required this.items,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final w = MediaQuery.sizeOf(context).width;

    // Responsive sizing
    final bool compact = w < 360;
    final bool roomy = w >= 600;
    final double barHeight = roomy ? 68 : (compact ? 56 : 60);
    final double iconSize = roomy ? 28 : (compact ? 22 : 24);
    final double fontSize = roomy ? 13 : (compact ? 11 : 12);
    final double vGap = roomy ? 6 : (compact ? 3 : 4);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 6,
      child: SafeArea(
        top: false,
        bottom: true,
        child: SizedBox(
          height: barHeight,
          child: Row(
            children: List.generate(items.length, (i) {
              final selected = i == currentIndex;
              final Color fg = selected ? theme.colorScheme.primary : Colors.grey;

              return Expanded(
                child: InkWell(
                  onTap: () => onChanged(i),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        selected ? items[i].selectedIcon : items[i].icon,
                        size: iconSize,
                        color: fg,
                      ),
                      SizedBox(height: vGap),
                      // Chữ nằm dưới icon
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                        child: Text(
                          items[i].label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
                            color: fg,
                            letterSpacing: 0.1,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _AskBox extends StatelessWidget {
  final double height;
  final String hint;
  final VoidCallback onTap;
  const _AskBox({
    required this.height,
    required this.hint,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final radius = BorderRadius.circular(height / 2);

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      shape: RoundedRectangleBorder(borderRadius: radius),
      child: InkWell(
        borderRadius: radius,
        onTap: onTap,
        child: Container(
          height: height,
          padding: EdgeInsets.symmetric(horizontal: height * 0.35),
          decoration: BoxDecoration(
            borderRadius: radius,
            // Viền mảnh, màu nhẹ (responsive theo theme)
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withOpacity(0.6),
              width: 1,
            ),
          ),
          alignment: Alignment.centerLeft,
          child: Row(
            children: [
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  hint,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 16,
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

class _RoundIconButton extends StatelessWidget {
  final double size;
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({
    required this.size,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: const Color(0xFFFF6A00), // cam tươi
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          width: size,
          height: size,
          child: Icon(icon, color: Colors.white, size: size * 0.55),
        ),
      ),
    );
  }
}




