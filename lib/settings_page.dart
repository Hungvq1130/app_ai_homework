import 'package:flutter/material.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoSaveSearch = true;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        centerTitle: false,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final w = constraints.maxWidth;
          // Responsive padding: 16 → 24 theo màn hình
          final hPad = w < 400 ? 16.0 : w < 720 ? 20.0 : 24.0;
          // Giới hạn bề rộng nội dung để đẹp trên tablet
          const maxContentWidth = 720.0;

          // Style chung: tăng line-height
          final headerStyle = TextStyle(
            color: cs.onSurface.withOpacity(0.38),
            fontSize: 14,
            fontWeight: FontWeight.w600,
            letterSpacing: .2,
            height: 0.1, // giãn nhẹ
          );
          final titleStyle = const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            height: 0.1, // giãn dòng cho item đậm
          );
          final normalTitleStyle = const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            height: 0.1, // giãn dòng cho item thường
          );

          final dividerBlock = Divider(
            height: 16,
            thickness: 2,
            color: cs.surfaceVariant.withOpacity(0.35),
          );

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: maxContentWidth),
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 1),
                children: [
                  // ===== Hỗ trợ =====
                  _SectionHeader('Hỗ trợ', style: headerStyle, hPad: hPad),
                  _NavTile(
                    title: 'Thông báo',
                    titleStyle: normalTitleStyle,
                    hPad: hPad,
                    onTap: () {/* TODO */},
                  ),
                  _NavTile(
                    title: 'Sự kiện',
                    titleStyle: normalTitleStyle,
                    hPad: hPad,
                    onTap: () {/* TODO */},
                  ),
                  _NavTile(
                    title: 'Chăm sóc khách hàng',
                    titleStyle: normalTitleStyle,
                    hPad: hPad,
                    onTap: () {/* TODO */},
                  ),
                  _NavTile(
                    title: 'Ngôn ngữ / Language',
                    titleStyle: normalTitleStyle,
                    hPad: hPad,
                    onTap: () {/* TODO */},
                  ),

                  dividerBlock,

                  // ===== Tìm kiếm =====
                  _SectionHeader('Tìm kiếm', style: headerStyle, hPad: hPad),
                  _SwitchTile(
                    title: 'Tự động lưu lịch sử tìm kiếm',
                    titleStyle: normalTitleStyle,
                    value: _autoSaveSearch,
                    activeColor: Colors.blue,
                    hPad: hPad,
                    onChanged: (v) => setState(() => _autoSaveSearch = v),
                  ),

                  dividerBlock,

                  // ===== Thông báo =====
                  _SectionHeader('Thông báo', style: headerStyle, hPad: hPad),
                  _NavTile(
                    title: 'Cài đặt thông báo đẩy',
                    titleStyle: titleStyle,
                    hPad: hPad,
                    onTap: () {/* TODO */},
                  ),

                  dividerBlock,

                  // ===== Key-Value =====
                  _KeyValueTile(
                    title: 'Tài khoản',
                    value: 'abcxyz@gmail.com', // TODO: bind từ user
                    hPad: hPad,
                  ),
                  _KeyValueTile(
                    title: 'Phiên bản',
                    value: '1.1.0', // TODO: package_info_plus
                    hPad: hPad,
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/* ---------------------- Widgets con ---------------------- */

class _SectionHeader extends StatelessWidget {
  const _SectionHeader(this.text, {required this.hPad, this.style});
  final String text;
  final double hPad;
  final TextStyle? style;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 8),
      child: Text(text, style: style),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({
    required this.title,
    required this.hPad,
    this.onTap,
    this.titleStyle,
  });

  final String title;
  final double hPad;
  final VoidCallback? onTap;
  final TextStyle? titleStyle;

  @override
  Widget build(BuildContext context) {
    // Không có dấu ">" nữa
    return ListTile(
      title: Text(title, style: titleStyle),
      dense: false,
      // tăng padding dọc để giãn dòng cả tile
      contentPadding: EdgeInsets.symmetric(horizontal: hPad),
      onTap: onTap,
    );
  }
}

class _SwitchTile extends StatelessWidget {
  const _SwitchTile({
    required this.title,
    required this.value,
    required this.onChanged,
    required this.hPad,
    this.titleStyle,
    this.activeColor,
  });

  final String title;
  final bool value;
  final ValueChanged<bool> onChanged;
  final double hPad;
  final TextStyle? titleStyle;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title, style: titleStyle),
      dense: false,
      contentPadding: EdgeInsets.symmetric(horizontal: hPad),
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: activeColor,
      ),
      onTap: () => onChanged(!value),
    );
  }
}

class _KeyValueTile extends StatelessWidget {
  const _KeyValueTile({
    required this.title,
    required this.value,
    required this.hPad,
  });

  final String title;
  final String value;
  final double hPad;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(height: 1.3), // giãn chữ
      ),
      trailing: Text(
        value,
        textAlign: TextAlign.right,
        style: TextStyle(
          height: 1.3,
          color: cs.onSurface.withOpacity(0.7),
          fontWeight: FontWeight.w500,
        ),
      ),
      dense: false,
      contentPadding: EdgeInsets.symmetric(horizontal: hPad),
    );
  }
}
