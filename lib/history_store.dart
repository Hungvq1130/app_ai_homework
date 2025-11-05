// lib/history_store.dart
import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

class SolvedItem {
  final String id;
  final String? originalQuestion;
  final String? imagePath; // path nội bộ hoặc http(s)
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
    createdAt:
    DateTime.tryParse(j['createdAt'] as String? ?? '') ?? DateTime.now(),
  );
}

/// Lưu TRONG PHIÊN (memory) + file TẠM. Mỗi lần app khởi động sẽ xoá sạch.
class HistoryStore {
  HistoryStore._();
  static final _uuid = const Uuid();

  /// Danh sách chỉ tồn tại trong RAM suốt vòng đời process.
  static final List<SolvedItem> _items = <SolvedItem>[];

  /// Thư mục tạm cho phiên hiện tại: <tmp>/solves_session
  static Directory? _sessionDir;

  /// Gọi ở `main()` trước `runApp()` để dọn rác phiên cũ và tạo phiên mới.
  static Future<void> initSession() async {
    final tmp = await getTemporaryDirectory();
    _sessionDir = Directory('${tmp.path}/solves_session');

    // Xoá mọi thứ của phiên trước (nếu có) -> đảm bảo "thoát app là giải phóng"
    if (await _sessionDir!.exists()) {
      try {
        await _sessionDir!.delete(recursive: true);
      } catch (_) {}
    }
    await _sessionDir!.create(recursive: true);

    // Dọn RAM (phòng trường hợp hot-restart)
    _items.clear();
  }

  static Directory _ensureSessionDirSync() {
    final dir = _sessionDir;
    if (dir == null) {
      throw StateError(
          'HistoryStore.initSession() chưa được gọi. Hãy gọi trong main() trước runApp().');
    }
    return dir;
  }

  /// Lưu ảnh nếu là data URL -> ghi file vào thư mục tạm của phiên, trả về path.
  /// Nếu không phải data URL thì trả nguyên string (http/https/path).
  static Future<String?> persistImageIfNeeded(String? maybeDataUrl) async {
    if (maybeDataUrl == null || maybeDataUrl.isEmpty) return null;

    final m = RegExp(r'^data:image/(\w+);base64,(.*)$', dotAll: true)
        .firstMatch(maybeDataUrl);
    if (m == null) {
      // Không phải data URL -> giữ nguyên
      return maybeDataUrl;
    }
    final ext = (m.group(1) ?? 'png').toLowerCase();
    final b64 = m.group(2) ?? '';
    final bytes = base64Decode(b64);

    final dir = _ensureSessionDirSync();
    final path = '${dir.path}/${_uuid.v4()}.$ext';
    final f = File(path);
    await f.writeAsBytes(bytes, flush: true);
    return path;
  }

  /// Trả về bản sao đã sort (mới nhất trước).
  static Future<List<SolvedItem>> getAll() async {
    final out = List<SolvedItem>.from(_items);
    out.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return out;
  }

  /// Thêm vào đầu danh sách (RAM). Không ghi SharedPreferences.
  /// Ứng với yêu cầu "chỉ lưu local (trong phiên)".
  static Future<void> add(SolvedItem item, {int maxItems = 100}) async {
    // chặn trùng đơn giản theo id (hoặc theo chữ ký nội dung)
    if (_items.isNotEmpty && _items.first.id == item.id) return;

    _items.insert(0, item);

    // Nếu vượt quá quota, xoá các mục cũ + xoá file ảnh tạm của chúng (nếu có)
    while (_items.length > maxItems) {
      final last = _items.removeLast();
      await _maybeDeleteSessionFile(last.imagePath);
    }
  }

  static Future<void> remove(String id) async {
    final idx = _items.indexWhere((e) => e.id == id);
    if (idx >= 0) {
      final it = _items.removeAt(idx);
      await _maybeDeleteSessionFile(it.imagePath);
    }
  }

  /// Xoá toàn bộ lịch sử trong phiên + file tạm của phiên (không đụng gì ngoài phiên).
  static Future<void> clear() async {
    // Xoá file ảnh tạm
    for (final it in _items) {
      await _maybeDeleteSessionFile(it.imagePath);
    }
    _items.clear();

    // Làm sạch thư mục phiên
    final dir = _sessionDir;
    if (dir != null && await dir.exists()) {
      try {
        await dir.delete(recursive: true);
      } catch (_) {}
      await dir.create(recursive: true);
    }
  }

  /// Xoá file nếu nó thuộc thư mục phiên.
  static Future<void> _maybeDeleteSessionFile(String? path) async {
    if (path == null || path.isEmpty) return;
    final dir = _sessionDir;
    if (dir == null) return;
    try {
      final f = File(path);
      if (await f.exists() && path.startsWith(dir.path)) {
        await f.delete();
      }
    } catch (_) {}
  }
}
