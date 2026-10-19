import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CardLayout {
  final String id;
  double x;
  double y;
  double width;
  double height;
  int zIndex;
  bool visible;

  CardLayout({
    required this.id,
    this.x = 20,
    this.y = 20,
    this.width = 320,
    this.height = 220,
    this.zIndex = 0,
    this.visible = true,
  });

  CardLayout copyWith({
    String? id,
    double? x,
    double? y,
    double? width,
    double? height,
    int? zIndex,
    bool? visible,
  }) {
    return CardLayout(
      id: id ?? this.id,
      x: x ?? this.x,
      y: y ?? this.y,
      width: width ?? this.width,
      height: height ?? this.height,
      zIndex: zIndex ?? this.zIndex,
      visible: visible ?? this.visible,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'x': x,
      'y': y,
      'width': width,
      'height': height,
      'zIndex': zIndex,
      'visible': visible,
    };
  }

  factory CardLayout.fromJson(Map<String, dynamic> json) {
    return CardLayout(
      id: json['id'] as String,
      x: (json['x'] as num?)?.toDouble() ?? 20,
      y: (json['y'] as num?)?.toDouble() ?? 20,
      width: (json['width'] as num?)?.toDouble() ?? 320,
      height: (json['height'] as num?)?.toDouble() ?? 220,
      zIndex: json['zIndex'] as int? ?? 0,
      visible: json['visible'] as bool? ?? true,
    );
  }
}


class LayoutService extends ChangeNotifier {
  static const String _storageKey = 'workspace_card_layouts';

  final Map<String, CardLayout> _cards = {};

  Map<String, CardLayout> get cards => Map.unmodifiable(_cards);

  List<CardLayout> get visibleCards {
    final result = _cards.values
        .where((card) => card.visible)
        .toList();

    result.sort(
      (a, b) => a.zIndex.compareTo(b.zIndex),
    );

    return result;
  }

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    if (raw == null || raw.isEmpty) {
      return;
    }

    try {
      final List<dynamic> data = jsonDecode(raw);

      _cards.clear();

      for (final item in data) {
        final card = CardLayout.fromJson(
          Map<String, dynamic>.from(item),
        );

        _cards[card.id] = card;
      }

      notifyListeners();
    } catch (_) {
      // Corrupted local layout should not crash the workspace.
      _cards.clear();
    }
  }

  Future<void> save() async {
    final prefs = await SharedPreferences.getInstance();

    final data = _cards.values
        .map((card) => card.toJson())
        .toList();

    await prefs.setString(
      _storageKey,
      jsonEncode(data),
    );
  }

  void registerCard({
    required String id,
    double x = 20,
    double y = 20,
    double width = 320,
    double height = 220,
  }) {
    if (_cards.containsKey(id)) {
      return;
    }

    _cards[id] = CardLayout(
      id: id,
      x: x,
      y: y,
      width: width,
      height: height,
      zIndex: _cards.length,
    );

    notifyListeners();
    save();
  }

  void moveCard({
    required String id,
    required double x,
    required double y,
  }) {
    final card = _cards[id];

    if (card == null) {
      return;
    }

    card.x = x;
    card.y = y;

    _bringToFront(card);

    notifyListeners();
  }

  void resizeCard({
    required String id,
    required double width,
    required double height,
  }) {
    final card = _cards[id];

    if (card == null) {
      return;
    }

    card.width = width.clamp(180, 1200);
    card.height = height.clamp(120, 900);

    notifyListeners();

    save();
  }

  void toggleCard(String id) {
    final card = _cards[id];

    if (card == null) {
      return;
    }

    card.visible = !card.visible;

    notifyListeners();
    save();
  }

  void removeCard(String id) {
    _cards.remove(id);

    notifyListeners();
    save();
  }

  void bringToFront(String id) {
    final card = _cards[id];

    if (card == null) {
      return;
    }

    _bringToFront(card);

    notifyListeners();
    save();
  }

  void _bringToFront(CardLayout card) {
    final highest = _cards.values.fold<int>(
      0,
      (max, item) => item.zIndex > max ? item.zIndex : max,
    );

    card.zIndex = highest + 1;
  }

  void snapCard({
    required String id,
    double grid = 16,
  }) {
    final card = _cards[id];

    if (card == null) {
      return;
    }

    card.x = (card.x / grid).round() * grid;
    card.y = (card.y / grid).round() * grid;

    notifyListeners();
    save();
  }

  void reset() {
    _cards.clear();

    notifyListeners();
    save();
  }
}