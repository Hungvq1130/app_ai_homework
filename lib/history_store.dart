// lib/history_store.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

class SolvedItem {
  final String id;
  final String? originalQuestion;
  final String? imagePath; // file:///... hoặc path nội bộ; cũng có thể là http(s)
  final String markdown;
  final DateTime createdAt;

  SolvedItem({
    required this.id,
    required this.markdown,
    required this.createdAt,
    this.originalQuestion,
    this.imagePath,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'originalQuestion': originalQuestion,
    'imagePath': imagePath,
    'markdown': markdown,
    'createdAt': createdAt.toIso8601String(),
  };

  factory SolvedItem.fromJson(Map<String, dynamic> j) => SolvedItem(
    id: j['id'] as String,
    originalQuestion: j['originalQuestion'] as String?,
    imagePath: j['imagePath'] as String?,
    markdown: j['markdown'] as String? ?? '',
    createdAt: DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

class HistoryStore {
  static const _prefsKey = 'solve_history_v1';
  static final _uuid = const Uuid();

  /// Lưu ảnh nếu là data URL -> trả về đường dẫn file; nếu không thì trả về nguyên string (http/https/path)
  static Future<String?> persistImageIfNeeded(String? maybeDataUrl) async {
    if (maybeDataUrl == null || maybeDataUrl.isEmpty) return null;

    final m = RegExp(r'^data:image/(\w+);base64,(.*)$', dotAll: true).firstMatch(maybeDataUrl);
    if (m == null) {
      // Không phải data URL -> giữ nguyên (chấp nhận http/https hoặc path sẵn có)
      return maybeDataUrl;
    }
    final ext = m.group(1) ?? 'png';
    final b64 = m.group(2) ?? '';
    final bytes = base64Decode(b64);

    final dir = await getApplicationDocumentsDirectory();
    final solvesDir = Directory('${dir.path}/solves');
    if (!await solvesDir.exists()) {
      await solvesDir.create(recursive: true);
    }
    final path = '${solvesDir.path}/${_uuid.v4()}.$ext';
    final f = File(path);
    await f.writeAsBytes(bytes, flush: true);
    return path; // lưu path nội bộ
  }

  static Future<List<SolvedItem>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getStringList(_prefsKey) ?? const [];
    final items = <SolvedItem>[];
    for (final s in raw) {
      try {
        items.add(SolvedItem.fromJson(jsonDecode(s) as Map<String, dynamic>));
      } catch (_) {}
    }
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  static Future<void> add(SolvedItem item, {int maxItems = 200}) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? <String>[];
    // chặn trùng đơn giản theo hash nội dung
    final sig = jsonEncode(item.toJson());
    if (list.isNotEmpty && list.first == sig) return;

    list.insert(0, sig);
    if (list.length > maxItems) list.removeRange(maxItems, list.length);
    await prefs.setStringList(_prefsKey, list);
  }

  static Future<void> remove(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_prefsKey) ?? <String>[];
    list.removeWhere((s) {
      try {
        final m = SolvedItem.fromJson(jsonDecode(s) as Map<String, dynamic>);
        return m.id == id;
      } catch (_) {
        return false;
      }
    });
    await prefs.setStringList(_prefsKey, list);
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }
}
