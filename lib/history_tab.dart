// lib/history_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:intl/intl.dart';
import 'package:solve_exercise/utility.dart';
import 'history_detail_page.dart';
import 'history_store.dart';
import '../main.dart' show routeObserver;

class HistoryTab extends StatefulWidget {
  const HistoryTab({super.key});
  @override
  HistoryTabState createState() => HistoryTabState();
}

class HistoryTabState extends State<HistoryTab> with RouteAware {
  final List<SolvedItem> _items = <SolvedItem>[];
  bool _loading = true;

  void refresh() {
    if (mounted) setState(() {});
  }

  Future<void> _load() async {
    final items = await HistoryStore.getAll();
    if (!mounted) return;
    setState(() {
      _items
        ..clear()
        ..addAll(items);
      _loading = false;
    });
  }

  Future<void> _pullToRefresh() async {
    await _load();
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  void didPopNext() {
    // khi quay về từ trang chi tiết, cập nhật lại nếu có thay đổi
    _load();
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
    const double kThumb = 56;
    const BorderRadius kBR = BorderRadius.all(Radius.circular(12));
    final path = it.imagePath;
    if (path != null && path.isNotEmpty && File(path).existsSync()) {
      return SizedBox(
        width: kThumb,
        height: kThumb,
        child: ClipRRect(
          borderRadius: kBR,
          child: Image.file(File(path), fit: BoxFit.cover),
        ),
      );
    }
    return const SizedBox(
      width: kThumb,
      height: kThumb,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: Color(0xFFEFF4FF),
          borderRadius: kBR,
        ),
        child: Center(
          child: Icon(Icons.description, size: 28, color: Color(0xFF1E3A8A)),
        ),
      ),
    );
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
        children: [
          const SizedBox(height: 160),
          Center(child: Text('history.empty'.tr())),
          const SizedBox(height: 160),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.paddingOf(context).top + kToolbarHeight + 8;
    final bottomPad = _bottomOverlapPadding(context);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('history.page_title'.tr()),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        actions: [
          IconButton(
            tooltip: 'history.clear_all'.tr(),
            icon: const Icon(Icons.delete_sweep_outlined),
            onPressed: () async {
              if (_items.isEmpty) return;
              final ok = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: Text('history.dialog.title'.tr()),
                  content: Text('history.dialog.content'.tr()),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: Text('history.dialog.cancel'.tr()),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: Text('history.dialog.delete'.tr()),
                    ),
                  ],
                ),
              );
              if (ok == true) {
                await HistoryStore.clear();
                if (!mounted) return;
                setState(() {
                  _items.clear(); // cập nhật UI ngay, không reload FutureBuilder
                });
              }
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          const SoftGradientBackground(),
          Padding(
            padding: EdgeInsets.only(top: topPad),
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : (_items.isEmpty
                ? _emptyRefreshable(context)
                : RefreshIndicator(
              onRefresh: _pullToRefresh,
              child: ListView.separated(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.fromLTRB(12, 12, 12, bottomPad),
                itemCount: _items.length,
                separatorBuilder: (_, __) =>
                const SizedBox(height: 8),
                itemBuilder: (context, i) {
                  final it = _items[i];

                  final timeStr = DateFormat
                      .yMd(context.locale.toString())
                      .add_Hm()
                      .format(it.createdAt.toLocal());
                  final fallback = 'history.item.solved_at'
                      .tr(namedArgs: {'time': timeStr});

                  final title = (it.originalQuestion?.trim().isNotEmpty == true)
                      ? it.originalQuestion!.trim()
                      : fallback;

                  final preview = _plainPreview(it.markdown);

                  // Không vuốt xóa, không icon xóa từng item
                  return _HistoryItemCard(
                    leading: _leadingThumb(it),
                    title: title,
                    subtitle: preview,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => HistoryDetailPage(item: it),
                        ),
                      );
                    },
                  );
                },
              ),
            )),
          ),
        ],
      ),
    );
  }
}

class _HistoryItemCard extends StatelessWidget {
  const _HistoryItemCard({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8E8EE)),
        boxShadow: const [
          BoxShadow(
            blurRadius: 10,
            offset: Offset(0, 3),
            color: Color(0x12000000),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: SizedBox(
            height: kHistoryItemHeight,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(width: 56, height: 56, child: leading),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(fontWeight: FontWeight.w500),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          subtitle,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.black.withOpacity(.65),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Không còn nút xoá từng item
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const double kHistoryItemHeight = 90;
