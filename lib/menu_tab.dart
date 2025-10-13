import 'package:flutter/material.dart';

class MenuTab extends StatelessWidget {
  const MenuTab({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SwitchListTile(
          value: isDark,
          onChanged: (_) {
            // Demo: gắn state manager (Provider/Bloc) để toggle theme toàn app
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Demo: hãy gắn state để đổi theme')),
            );
          },
          title: const Text('Chế độ tối'),
          secondary: const Icon(Icons.dark_mode_outlined),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.settings_outlined),
          title: Text('Cài đặt'),
          subtitle: Text('Tùy chỉnh ứng dụng'),
        ),
        const Divider(),
        const ListTile(
          leading: Icon(Icons.info_outline),
          title: Text('Giới thiệu'),
          subtitle: Text('Phiên bản 1.0.0'),
        ),
      ],
    );
  }
}
