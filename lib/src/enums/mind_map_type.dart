/// 마인드맵 타입 / Mind map type
enum MindMapType {
  /// 기본 마인드맵 / Default mind map
  default_,

  // /// 마크맵 스타일 마인드맵 / Markmap style mind map
  // markmap, // 개발 중
}

/// 마인드맵 타입 확장 메서드 / Mind map type extension methods
extension MindMapTypeExtension on MindMapType {
  /// 마인드맵 타입의 표시 이름 / Display name of mind map type
  String get displayName {
    switch (this) {
      case MindMapType.default_:
        return '기본';
      // case MindMapType.markmap:
      //   return '마크맵';
    }
  }

  /// 마인드맵 타입의 설명 / Description of mind map type
  String get description {
    switch (this) {
      case MindMapType.default_:
        return '기본적인 마인드맵 구조';
      // case MindMapType.markmap:
      //   return 'markmap.js 스타일의 수평 트리 구조';
    }
  }

  /// 마인드맵 타입의 아이콘 / Icon of mind map type
  String get icon {
    switch (this) {
      case MindMapType.default_:
        return '🧠';
      // case MindMapType.markmap:
      //   return '📈';
    }
  }
}
