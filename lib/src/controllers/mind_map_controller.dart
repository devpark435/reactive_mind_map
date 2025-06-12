import 'package:flutter/foundation.dart';
import '../models/mind_map_data.dart';

class MindMapController extends ChangeNotifier {
  MindMapData _root;
  MindMapController(this._root);

  MindMapData get root => _root;

  /// Replace the entire tree and notify listeners
  set root(MindMapData newRoot) {
    _root = newRoot;
    notifyListeners();
  }

  /// Add a new child under the node with [parentId].
  /// Returns true if the parent is found.
  bool addNode({required String parentId, required MindMapData newNode}) {
    MindMapData? updatedRoot = _addRecursively(_root, parentId, newNode);
    if (updatedRoot == null) return false; // parent not found
    _root = updatedRoot;
    notifyListeners();
    return true;
  }

  MindMapData? _addRecursively(
    MindMapData current,
    String targetId,
    MindMapData newNode,
  ) {
    // if the current node is the parent, add the new node to the children
    if (current.id == targetId) {
      final newChildren = List<MindMapData>.from(current.children)
        ..add(newNode);
      return current.copyWith(children: newChildren);
    }
    // if the current node is not the parent, recursively add the new node to the children
    bool changed = false;
    final updatedChildren = current.children
        .map((c) {
          final res = _addRecursively(c, targetId, newNode);
          if (res != null) {
            changed = true;
            return res;
          }
          return c;
        })
        .toList(growable: true);

    return changed ? current.copyWith(children: updatedChildren) : null;
  }

  /// Remove node (and its subtree)
  bool removeNode(String nodeId) {
    if (_root.id == nodeId) return false; // don't remove root

    MindMapData? updatedRoot = _removeRecursively(_root, nodeId);
    if (updatedRoot == null) return false; // target not found

    _root = updatedRoot;
    notifyListeners();
    return true;
  }

  MindMapData? _removeRecursively(MindMapData current, String targetId) {
    // Filter out target from immediate children
    final newChildren = current.children
        .where((c) => c.id != targetId)
        .map((c) => _removeRecursively(c, targetId) ?? c)
        .toList(growable: true);

    // If length changed, a child was removed somewhere down the tree
    final removed = newChildren.length != current.children.length;

    // Also changed if any deeper child changed (copy returned)
    if (removed || !_listEquals(newChildren, current.children)) {
      return current.copyWith(children: newChildren);
    }

    return null;
  }

  /// Check if two lists are equal
  bool _listEquals(List a, List b) {
    if (a.length != b.length) return false;
    for (int i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  /// Update title or description of a node.
  bool updateNode({
    required String nodeId,
    String? newTitle,
    String? newDescription,
  }) {
    MindMapData? updatedRoot = _updateRecursively(
      _root,
      nodeId,
      newTitle,
      newDescription,
    );
    if (updatedRoot == null) return false;

    _root = updatedRoot;
    notifyListeners();
    return true;
  }

  MindMapData? _updateRecursively(
    MindMapData current,
    String targetId,
    String? newTitle,
    String? newDescription,
  ) {
    // if the current node is the node to update, update the title and description
    if (current.id == targetId) {
      return current.copyWith(
        title: newTitle ?? current.title,
        description: newDescription ?? current.description,
      );
    }
    // if the current node is not the node to update, recursively update the node in the children
    bool changed = false;
    final updatedChildren = current.children
        .map((c) {
          final res = _updateRecursively(c, targetId, newTitle, newDescription);
          if (res != null) {
            changed = true;
            return res;
          }
          return c;
        })
        .toList(growable: true);

    return changed ? current.copyWith(children: updatedChildren) : null;
  }
}
