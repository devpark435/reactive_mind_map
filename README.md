# Reactive Mind Map / 반응형 마인드맵

[![pub package](https://img.shields.io/pub/v/reactive_mind_map.svg)](https://pub.dev/packages/reactive_mind_map)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)

A highly customizable and interactive mind map package for Flutter with multiple layouts, dynamic sizing, and rich styling options.

Flutter용 다중 레이아웃, 동적 크기 조절, 다양한 스타일링 옵션을 제공하는 고도로 커스터마이징 가능한 인터랙티브 마인드맵 패키지입니다.

## Screenshots / 스크린샷

<p align="center">
  <img src="https://raw.githubusercontent.com/devpark435/reactive_mind_map/main/screenshots/mindmap_demo.png" alt="Reactive Mind Map Demo" width="800"/>
</p>

_Multiple layouts and customization options / 다양한 레이아웃과 커스터마이징 옵션_

## Demo / 데모

<p align="center">
  <img src="https://raw.githubusercontent.com/devpark435/reactive_mind_map/main/screenshots/mindmap_animation.gif" alt="Interactive Mind Map Animation" width="600"/>
</p>

_Interactive expand/collapse and smooth animations / 인터랙티브 확장/축소 및 부드러운 애니메이션_

## Features / 특징

🎨 **완전한 커스터마이징 / Complete Customization**

- 노드 모양 선택 (둥근 사각형, 원형, 다이아몬드, 육각형 등) / Node shapes (rounded rectangle, circle, diamond, hexagon, etc.)
- 색상, 텍스트 스타일, 그림자 효과 커스터마이징 / Colors, text styles, shadow effects customization
- 동적 노드 크기 조절 / Dynamic node sizing
- 연결선 스타일과 애니메이션 설정 / Connection line styles and animation settings

🎯 **다양한 레이아웃 / Multiple Layouts**

- 오른쪽/왼쪽/위/아래 방향 레이아웃 / Right/Left/Top/Bottom direction layouts
- 원형(Radial) 레이아웃 / Radial layout
- 좌우/상하 분할 레이아웃 / Horizontal/Vertical split layouts

⚡ **부드러운 애니메이션 / Smooth Animations**

- 노드 확장/축소 애니메이션 / Node expand/collapse animations
- 커스터마이징 가능한 애니메이션 곡선과 지속시간 / Customizable animation curves and duration
- 하드웨어 가속 트랜지션 / Hardware-accelerated transitions

🖱️ **풍부한 인터랙션 / Rich Interactions**

- 탭, 길게 누르기, 더블 탭 이벤트 / Tap, long press, double tap events
- 확대/축소, 팬 기능 / Pan & zoom functionality
- 노드 확장/축소 상태 추적 / Node expand/collapse state tracking

## Installation / 설치

Add this to your package's `pubspec.yaml` file:
`pubspec.yaml` 파일에 다음을 추가하세요:

```yaml
dependencies:
  reactive_mind_map: ^1.0.3
```

Then run / 그다음 실행하세요:

```bash
flutter pub get
```

## Quick Start / 빠른 시작

### With MindMapController (add / edit / delete)

```dart
import 'package:flutter/material.dart';
import 'package:reactive_mind_map/reactive_mind_map.dart';

class MyMindMap extends StatelessWidget {
  final MindMapController controller = MindMapController(const MindMapData(
    id: 'root',
    title: 'My Project',
    children: [
      MindMapData(id: '1', title: 'Planning'),
      MindMapData(id: '2', title: 'Development'),
      MindMapData(id: '3', title: 'Testing'),
    ],
  ));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MindMapWidget(
        controller: controller,
        style: const MindMapStyle(
          layout: MindMapLayout.right,
          nodeShape: NodeShape.roundedRectangle,
        ),
        onNodeTap: (node) => print('Tapped: ${node.title}'),
      ),
    );
  }
}
```

> If you only need a _read-only_ map, you can still pass `data:` instead of `controller:` – nothing changes.

## 중요 사용법 주의사항 / Important Usage Notes

⚠️ **화면 크기 최적화** / Screen Size Optimization

- `MindMapWidget`은 기본적으로 화면 크기에 맞게 자동 조정됩니다
- `Expanded` 위젯 안에서 사용할 때는 추가 설정이 필요하지 않습니다
- 팬/줌 기능이 기본으로 활성화되어 있어 큰 마인드맵도 쉽게 탐색할 수 있습니다

```dart
// ✅ 올바른 사용법 - 화면에 맞게 자동 조정
Widget build(BuildContext context) {
  return Scaffold(
    body: MindMapWidget(
      controller: MindMapController(root.value),
      style: MindMapStyle(
        layout: MindMapLayout.right,
        nodeShape: NodeShape.roundedRectangle,
      ),
      onNodeTap: (node) => print('Tapped: ${node.title}'),
    ),
  );
}

// ✅ Expanded 안에서 사용하는 경우
Widget build(BuildContext context) {
  return Scaffold(
    body: Column(
      children: [
        SomeHeaderWidget(),
        Expanded(
          child: MindMapWidget(
            controller: MindMapController(root.value),
            style: MindMapStyle(
              layout: MindMapLayout.right,
              nodeShape: NodeShape.roundedRectangle,
            ),
            onNodeTap: (node) => print('Tapped: ${node.title}'),
          ),
        ),
      ],
    ),
  );
}
```

## Advanced Usage / 고급 사용법

### Custom Styling / 커스텀 스타일링

```dart
final customStyle = MindMapStyle(
  layout: MindMapLayout.radial,
  nodeShape: NodeShape.circle,
  enableAutoSizing: true,
  connectionColor: Colors.blue,
  animationDuration: Duration(milliseconds: 600),
  defaultNodeColors: [Colors.blue, Colors.green, Colors.orange],
);
```

### Event Handling / 이벤트 처리

```dart
MindMapWidget(
  controller: MindMapController(myData),
  onNodeTap: (node) => print('Node tapped: ${node.title}'),
  onNodeLongPress: (node) => _showNodeOptions(node),
  onNodeExpandChanged: (node, isExpanded) =>
    print('${node.title} ${isExpanded ? 'expanded' : 'collapsed'}'),
);
```

## Available Options / 사용 가능한 옵션

### Layouts / 레이아웃

| Layout / 레이아웃          | Description / 설명                        |
| -------------------------- | ----------------------------------------- |
| `MindMapLayout.right`      | Traditional right-expanding / 오른쪽 확장 |
| `MindMapLayout.left`       | Left-expanding / 왼쪽 확장                |
| `MindMapLayout.top`        | Upward-expanding / 위쪽 확장              |
| `MindMapLayout.bottom`     | Downward-expanding / 아래쪽 확장          |
| `MindMapLayout.radial`     | Circular arrangement / 원형 배치          |
| `MindMapLayout.horizontal` | Left-right split / 좌우 분할              |
| `MindMapLayout.vertical`   | Top-bottom split / 상하 분할              |

### Node Shapes / 노드 모양

| Shape / 모양                 | Description / 설명                             |
| ---------------------------- | ---------------------------------------------- |
| `NodeShape.roundedRectangle` | Rounded corners (default) / 둥근 모서리 (기본) |
| `NodeShape.circle`           | Perfect circle / 완전한 원                     |
| `NodeShape.rectangle`        | Sharp corners / 날카로운 모서리                |
| `NodeShape.diamond`          | Diamond shape / 다이아몬드 모양                |
| `NodeShape.hexagon`          | Six-sided polygon / 육각형                     |
| `NodeShape.ellipse`          | Oval shape / 타원형                            |

## Performance / 성능

- **최적화된 렌더링** / Optimized rendering with custom painters
- **동적 간격 계산** / Smart spacing based on content
- **메모리 효율적** / Minimal widget tree overhead
- **부드러운 애니메이션** / Hardware-accelerated animations

## License / 라이선스

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

이 프로젝트는 MIT 라이선스 하에 있습니다 - 자세한 내용은 [LICENSE](LICENSE) 파일을 참조하세요.

## Contributing / 기여

We welcome contributions! Whether you're fixing bugs, adding features, or improving documentation, your help is appreciated.

기여를 환영합니다! 버그 수정, 기능 추가, 문서 개선 등 모든 도움을 감사히 받겠습니다.

### Quick Contributing Guide / 빠른 기여 가이드

1. **🐛 Found a bug?** / 버그를 발견하셨나요?

   - Check [existing issues](https://github.com/devpark435/reactive_mind_map/issues) first / [기존 이슈들](https://github.com/devpark435/reactive_mind_map/issues)을 먼저 확인하세요
   - Use our [Bug Report template](https://github.com/devpark435/reactive_mind_map/issues/new?template=bug_report.yml) / [버그 리포트 템플릿](https://github.com/devpark435/reactive_mind_map/issues/new?template=bug_report.yml)을 사용하세요

2. **💡 Have a feature idea?** / 기능 아이디어가 있으신가요?

   - Use our [Feature Request template](https://github.com/devpark435/reactive_mind_map/issues/new?template=feature_request.yml) / [기능 요청 템플릿](https://github.com/devpark435/reactive_mind_map/issues/new?template=feature_request.yml)을 사용하세요

3. **❓ Need help?** / 도움이 필요하신가요?

   - Use our [Question template](https://github.com/devpark435/reactive_mind_map/issues/new?template=question.yml) / [질문 템플릿](https://github.com/devpark435/reactive_mind_map/issues/new?template=question.yml)을 사용하세요

4. **🔧 Want to contribute code?** / 코드 기여를 원하시나요?
   - Read our detailed [**Contributing Guide**](CONTRIBUTING.md) / 상세한 [**기여 가이드**](CONTRIBUTING.md)를 읽어보세요
   - Fork the repo, make changes, and submit a PR / 저장소를 포크하고 변경사항을 만든 후 PR을 제출하세요

### Development Setup / 개발 환경 설정

```bash
git clone https://github.com/YOUR_USERNAME/reactive_mind_map.git
cd reactive_mind_map
flutter pub get
flutter run
```

For detailed development guidelines, coding standards, and contribution process, please see our [**Contributing Guide**](CONTRIBUTING.md).

자세한 개발 가이드라인, 코딩 표준, 기여 과정은 [**기여 가이드**](CONTRIBUTING.md)를 참조하세요.

## Issues / 이슈

If you encounter any issues or have feature requests, please file them in the [GitHub Issues](https://github.com/devpark435/reactive_mind_map/issues) section.

이슈가 발생하거나 기능 요청이 있으시면 [GitHub Issues](https://github.com/devpark435/reactive_mind_map/issues) 섹션에 등록해 주세요.

## 변경 이력

최신 변경사항은 [CHANGELOG.md](CHANGELOG.md)를 확인하세요.
