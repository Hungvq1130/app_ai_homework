// lib/history_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:solve_exercise/utility.dart';
import 'history_store.dart';
import 'math_html_page.dart';
import '../main.dart' show routeObserver; // ⬅️ import routeObserver

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  HistoryTabState createState() => HistoryTabState(); // ⬅️ public
}

class HistoryTabState extends State<HistoryTab> with RouteAware {
  void refresh() {
    if (mounted) setState(() {}); // FutureBuilder sẽ đọc lại HistoryStore.getAll()
  }

  Future<void> _pullToRefresh() async {
    refresh();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // đăng ký lắng nghe route lifecycle
    final route = ModalRoute.of(context);
    if (route != null) {
      routeObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  // Khi có route khác pop về (VD: từ SolveResultPage back lại)
  @override
  void didPopNext() {
    refresh(); // Tự nạp mới
  }

  String _plainPreview(String md, {int maxLen = 120}) {
    var s = md
        .replaceAll(RegExp(r'`{1,3}.*?`{1,3}', dotAll: true), ' ')
        .replaceAll(RegExp(r'!\[.*?\]\(.*?\)'), '[img]')
        .replaceAll(RegExp(r'\[([^\]]+)\]\((.*?)\)'), r'\1')
        .replaceAll(RegExp(r'[#>*_\-`]+'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    if (s.length > maxLen) s = '${s.substring(0, maxLen)}…';
    return s;
  }

  Widget _leadingThumb(SolvedItem it) {
    final path = it.imagePath;
    if (path != null && path.isNotEmpty) {
      final f = File(path);
      if (f.existsSync()) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.file(f, width: 56, height: 56, fit: BoxFit.cover),
        );
      }
    }
    return const CircleAvatar(child: Icon(Icons.description));
  }

  double _bottomOverlapPadding(BuildContext context) {
    final sysInset = MediaQuery.of(context).padding.bottom;
    return kEqualBottomBarHeight + sysInset + 1;
  }

  Widget _emptyRefreshable(BuildContext context) {
    return RefreshIndicator(
      onRefresh: _pullToRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: EdgeInsets.only(bottom: _bottomOverlapPadding(context)),
        children: const [
          SizedBox(height: 160),
          Center(child: Text('Chưa có mục nào trong lịch sử.\nKéo xuống để làm mới.')),
          SizedBox(height: 160),
        ],
      ),
    );
  }
  // nơi bạn đặt SoftGradientBackground/SoftGradientPage

  @override
  Widget build(BuildContext context) {
    // nếu trang này hiển thị trong Home có bottom bar, có thể cộng thêm bottomPad cho ListView (xem ghi chú phía dưới)
    final topPad = MediaQuery.paddingOf(context).top + kToolbarHeight + 8;
    final bottomPad = _bottomOverlapPadding(context);

    return Scaffold(
      extendBodyBehindAppBar: true, // 👈 body tràn ra sau AppBar để AppBar ăn chung nền
      appBar: AppBar(
        title: const Text('Lịch sử giải bài'),
        backgroundColor: Colors.transparent, // 👈 trong suốt để thấy gradient
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'Xoá tất cả',
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              final ok = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('Xoá tất cả lịch sử?'),
                  content: const Text('Thao tác này không thể hoàn tác.'),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Huỷ')),
                    FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xoá')),
                  ],
                ),
              );
              if (ok == true) {
                await HistoryStore.clear();
                refresh();
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const SoftGradientBackground(), // 👈 nền gradient tái dùng
          // Đẩy nội dung xuống dưới AppBar
          Padding(
            padding: EdgeInsets.only(top: topPad),
            child: FutureBuilder<List<SolvedItem>>(
              future: HistoryStore.getAll(), // luôn đọc mới mỗi lần build
              builder: (context, snap) {
                if (snap.connectionState != ConnectionState.done) {
                  return const Center(child: CircularProgressIndicator());
                }
                final items = snap.data ?? const <SolvedItem>[];
                if (items.isEmpty) return _emptyRefreshable(context);

                return RefreshIndicator(
                  onRefresh: _pullToRefresh,
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPad),  // 👈 có thể tăng bottom nếu bị che bởi bottom bar
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, i) {
                      final it = items[i];
                      final title = (it.originalQuestion?.trim().isNotEmpty == true)
                          ? it.originalQuestion!.trim()
                          : 'Bài giải lúc ${it.createdAt.toLocal().toString().split('.').first}';
                      final preview = _plainPreview(it.markdown);

                      return Dismissible(
                        key: ValueKey(it.id),
                        background: Container(
                          alignment: Alignment.centerLeft,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          color: Colors.red.shade400,
                          child: const Icon(Icons.delete, color: Colors.white),
                        ),
                        direction: DismissDirection.startToEnd,
                        onDismissed: (_) async {
                          await HistoryStore.remove(it.id);
                          refresh();
                        },
                        child: ListTile(
                          leading: _leadingThumb(it),
                          title: Text(title, maxLines: 2, overflow: TextOverflow.ellipsis),
                          subtitle: Text(preview, maxLines: 2, overflow: TextOverflow.ellipsis),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => HistoryDetailPage(item: it)),
                            );
                          },
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class HistoryDetailPage extends StatelessWidget {
  final SolvedItem item;
  const HistoryDetailPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MathHtmlPage(markdown: item.markdown),
    );
  }
}
