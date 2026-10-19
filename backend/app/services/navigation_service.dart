import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NavigationItem {
  final String id;
  final String label;
  final String icon;
  bool visible;
  int order;
  int? badge;

  NavigationItem({
    required this.id,
    required this.label,
    required this.icon,
    this.visible = true,
    this.order = 0,
    this.badge,
  });

  NavigationItem copyWith({
    String? id,
    String? label,
    String? icon,
    bool? visible,
    int? order,
    int? badge,
  }) {
    return NavigationItem(
      id: id ?? this.id,
      label: label ?? this.label,
      icon: icon ?? this.icon,
      visible: visible ?? this.visible,
      order: order ?? this.order,
      badge: badge ?? this.badge,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'label': label,
      'icon': icon,
      'visible': visible,
      'order': order,
      'badge': badge,
    };
  }

  factory NavigationItem.fromJson(
    Map<String, dynamic> json,
  ) {
    return NavigationItem(
      id: json['id'] as String,
      label: json['label'] as String,
      icon: json['icon'] as String,
      visible: json['visible'] as bool? ?? true,
      order: json['order'] as int? ?? 0,
      badge: json['badge'] as int?,
    );
  }
}


class NavigationService extends ChangeNotifier {
  static const String _storageKey =
      'workspace_navigation';

  final List<NavigationItem> _items = [];

  String _selectedId = '';

  List<NavigationItem> get items =>
      List.unmodifiable(_items);

  List<NavigationItem> get visibleItems {
    final result = _items
        .where((item) => item.visible)
        .toList();

    result.sort(
      (a, b) => a.order.compareTo(b.order),
    );

    return result;
  }

  String get selectedId => _selectedId;

  Future<void> initialize() async {
    if (_items.isEmpty) {
      _items.addAll([
        NavigationItem(
          id: 'home',
          label: 'Home',
          icon: 'home',
          order: 0,
        ),
        NavigationItem(
          id: 'workspace',
          label: 'Workspace',
          icon: 'grid',
          order: 1,
        ),
        NavigationItem(
          id: 'documents',
          label: 'Documents',
          icon: 'file',
          order: 2,
        ),
        NavigationItem(
          id: 'ai',
          label: 'AI',
          icon: 'sparkles',
          order: 3,
        ),
        NavigationItem(
          id: 'settings',
          label: 'Settings',
          icon: 'settings',
          order: 4,
        ),
      ]);
    }

    final prefs =
        await SharedPreferences.getInstance();

    final raw = prefs.getString(_storageKey);

    if (raw != null && raw.isNotEmpty) {
      try {
        final List<dynamic> data =
            jsonDecode(raw);

        _items.clear();

        for (final item in data) {
          _items.add(
            NavigationItem.fromJson(
              Map<String, dynamic>.from(item),
            ),
          );
        }
      } catch (_) {
        // Keep defaults.
      }
    }

    if (_selectedId.isEmpty &&
        _items.isNotEmpty) {
      _selectedId = _items.first.id;
    }

    notifyListeners();
  }

  void select(String id) {
    final exists =
        _items.any((item) => item.id == id);

    if (!exists) {
      return;
    }

    _selectedId = id;

    notifyListeners();
  }

  void reorder(
    int oldIndex,
    int newIndex,
  ) {
    final visible = visibleItems;

    if (oldIndex < 0 ||
        oldIndex >= visible.length) {
      return;
    }

    if (newIndex < 0 ||
        newIndex > visible.length) {
      return;
    }

    final moved = visible.removeAt(oldIndex);

    if (newIndex > oldIndex) {
      newIndex -= 1;
    }

    visible.insert(
      newIndex,
      moved,
    );

    for (int i = 0;
        i < visible.length;
        i++) {
      visible[i].order = i;
    }

    notifyListeners();
    save();
  }

  void setVisibility(
    String id,
    bool visible,
  ) {
    final item = _find(id);

    if (item == null) {
      return;
    }

    item.visible = visible;

    notifyListeners();
    save();
  }

  void setBadge(
    String id,
    int? value,
  ) {
    final item = _find(id);

    if (item == null) {
      return;
    }

    item.badge = value;

    notifyListeners();
    save();
  }

  Future<void> save() async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.setString(
      _storageKey,
      jsonEncode(
        _items
            .map((item) => item.toJson())
            .toList(),
      ),
    );
  }

  NavigationItem? _find(String id) {
    for (final item in _items) {
      if (item.id == id) {
        return item;
      }
    }

    return null;
  }

  void reset() {
    _items.clear();

    initialize();
  }
}