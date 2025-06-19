import 'package:flutter/material.dart';
import 'package:reactive_mind_map/reactive_mind_map.dart';
import 'package:reactive_mind_map/src/controllers/mind_map_controller.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Reactive Mind Map Example',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const MindMapExamplePage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MindMapExamplePage extends StatefulWidget {
  const MindMapExamplePage({super.key});

  @override
  State<MindMapExamplePage> createState() => _MindMapExamplePageState();
}

class _MindMapExamplePageState extends State<MindMapExamplePage> {
  late final MindMapController _controller;
  MindMapStyle _currentStyle = const MindMapStyle();

  @override
  void initState() {
    super.initState();
    _controller = MindMapController(DemoData.flutterDev);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reactive Mind Map Package'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.palette),
            onPressed: _showStyleDialog,
            tooltip: '스타일 변경',
          ),
          IconButton(
            icon: const Icon(Icons.data_array),
            onPressed: _showDataDialog,
            tooltip: '데이터 변경',
          ),
        ],
      ),
      body: MindMapWidget(
        controller: _controller,
        style: _currentStyle,
        onNodeTap: (node) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('탭: ${node.title}')));
        },
        onNodeLongPress: (node) {
          _showNodeDetails(node);
        },
        onNodeDoubleTap: (node) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('더블 탭: ${node.title}')));
        },
        onNodeExpandChanged: (node, isExpanded) {
          // Debug output removed for production
        },
      ),
    );
  }

  void _showStyleDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('스타일 변경'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildLayoutButtons(),
                  const SizedBox(height: 16),
                  _buildShapeButtons(),
                  const SizedBox(height: 16),
                  _buildThemeButtons(),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
    );
  }

  Widget _buildLayoutButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('레이아웃:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              MindMapLayout.values.map((layout) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStyle = _currentStyle.copyWith(layout: layout);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentStyle.layout == layout
                            ? Colors.blue
                            : Colors.grey[300],
                    foregroundColor:
                        _currentStyle.layout == layout
                            ? Colors.white
                            : Colors.black,
                  ),
                  child: Text(_getLayoutName(layout)),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildShapeButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('노드 모양:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children:
              NodeShape.values.map((shape) {
                return ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _currentStyle = _currentStyle.copyWith(nodeShape: shape);
                    });
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        _currentStyle.nodeShape == shape
                            ? Colors.blue
                            : Colors.grey[300],
                    foregroundColor:
                        _currentStyle.nodeShape == shape
                            ? Colors.white
                            : Colors.black,
                  ),
                  child: Text(_getShapeName(shape)),
                );
              }).toList(),
        ),
      ],
    );
  }

  Widget _buildThemeButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('테마:', style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          children: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStyle = const MindMapStyle(); // 기본 테마
                });
                Navigator.of(context).pop();
              },
              child: const Text('기본'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStyle = _currentStyle.copyWith(
                    backgroundColor: Colors.black87,
                    connectionColor: Colors.white54,
                    defaultTextStyle: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('다크'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _currentStyle = _currentStyle.copyWith(
                    backgroundColor: const Color(0xFFF0F8FF),
                    defaultNodeColors: [
                      Colors.pink[400]!,
                      Colors.purple[400]!,
                      Colors.indigo[400]!,
                      Colors.cyan[400]!,
                      Colors.teal[400]!,
                      Colors.green[400]!,
                      Colors.lime[400]!,
                      Colors.orange[400]!,
                    ],
                  );
                });
                Navigator.of(context).pop();
              },
              child: const Text('파스텔'),
            ),
          ],
        ),
      ],
    );
  }

  void _showDataDialog() {
    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  '테스트 데이터 선택',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _controller.root = DemoData.flutterDev;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('Flutter 개발'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _controller.root = DemoData.businessPlan;
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('사업 계획'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _controller.root = DemoData.generateLargeData(25);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('25개 노드'),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          _controller.root = DemoData.generateLargeData(50);
                        });
                        Navigator.pop(context);
                      },
                      child: const Text('50개 노드'),
                    ),
                  ],
                ),
              ],
            ),
          ),
    );
  }

  void _showNodeDetails(MindMapData node) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(node.title),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID: ${node.id}'),
                const SizedBox(height: 8),
                Text('설명: ${node.description}'),
                const SizedBox(height: 8),
                Text('자식 수: ${node.children.length}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('닫기'),
              ),
            ],
          ),
    );
  }

  String _getLayoutName(MindMapLayout layout) {
    switch (layout) {
      case MindMapLayout.right:
        return '오른쪽';
      case MindMapLayout.left:
        return '왼쪽';
      case MindMapLayout.top:
        return '위쪽';
      case MindMapLayout.bottom:
        return '아래쪽';
      case MindMapLayout.radial:
        return '원형';
      case MindMapLayout.horizontal:
        return '좌우';
      case MindMapLayout.vertical:
        return '상하';
    }
  }

  String _getShapeName(NodeShape shape) {
    switch (shape) {
      case NodeShape.roundedRectangle:
        return '둥근 사각형';
      case NodeShape.circle:
        return '원형';
      case NodeShape.rectangle:
        return '사각형';
      case NodeShape.diamond:
        return '다이아몬드';
      case NodeShape.hexagon:
        return '육각형';
      case NodeShape.ellipse:
        return '타원';
    }
  }
}

/// 데모 데이터 클래스
class DemoData {
  static const MindMapData flutterDev = MindMapData(
    id: 'root',
    title: 'Flutter\n개발',
    description: 'Flutter 앱 개발 완벽 가이드',
    color: Color(0xFF2563EB),
    children: [
      MindMapData(
        id: 'ui',
        title: 'UI & 위젯',
        description: 'Flutter의 UI 구성 요소들',
        color: Color(0xFF7C3AED),
        children: [
          MindMapData(
            id: 'stateless',
            title: 'StatelessWidget',
            description: '상태가 없는 위젯',
            color: Color(0xFF9333EA),
          ),
          MindMapData(
            id: 'stateful',
            title: 'StatefulWidget',
            description: '상태를 가지는 위젯',
            color: Color(0xFF9333EA),
          ),
          MindMapData(
            id: 'layout',
            title: 'Layout 위젯',
            description: '레이아웃 위젯들',
            color: Color(0xFF9333EA),
          ),
        ],
      ),
      MindMapData(
        id: 'navigation',
        title: '네비게이션',
        description: '화면 간 이동과 라우팅',
        color: Color(0xFF059669),
        children: [
          MindMapData(
            id: 'basic_nav',
            title: 'Basic Navigation',
            description: '기본 네비게이션',
            color: Color(0xFF10B981),
          ),
          MindMapData(
            id: 'go_router',
            title: 'GoRouter',
            description: '선언적 라우팅',
            color: Color(0xFF10B981),
          ),
        ],
      ),
      MindMapData(
        id: 'state',
        title: '상태 관리',
        description: '앱 상태 관리 패턴들',
        color: Color(0xFFDC2626),
        children: [
          MindMapData(
            id: 'provider',
            title: 'Provider',
            description: 'Provider 패턴',
            color: Color(0xFFEF4444),
          ),
          MindMapData(
            id: 'riverpod',
            title: 'Riverpod',
            description: '강력한 상태 관리',
            color: Color(0xFFEF4444),
          ),
          MindMapData(
            id: 'bloc',
            title: 'BLoC',
            description: 'BLoC 패턴',
            color: Color(0xFFEF4444),
          ),
        ],
      ),
    ],
  );

  static const MindMapData businessPlan = MindMapData(
    id: 'business',
    title: '사업 계획',
    description: '새로운 사업 아이디어 구상',
    color: Color(0xFF059669),
    children: [
      MindMapData(
        id: 'market',
        title: '시장 분석',
        description: '타겟 시장과 경쟁 분석',
        color: Color(0xFF0EA5E9),
        children: [
          MindMapData(id: 'target', title: '타겟 고객', description: '주요 고객층 정의'),
          MindMapData(
            id: 'competition',
            title: '경쟁사 분석',
            description: '주요 경쟁사와 차별점',
          ),
        ],
      ),
      MindMapData(
        id: 'product',
        title: '제품/서비스',
        description: '핵심 제품과 서비스',
        color: Color(0xFF7C3AED),
        children: [
          MindMapData(id: 'features', title: '핵심 기능', description: '주요 기능과 특징'),
          MindMapData(id: 'pricing', title: '가격 전략', description: '가격 모델과 전략'),
        ],
      ),
      MindMapData(
        id: 'marketing',
        title: '마케팅',
        description: '마케팅 전략과 채널',
        color: Color(0xFFDC2626),
        children: [
          MindMapData(
            id: 'channels',
            title: '마케팅 채널',
            description: '온라인/오프라인 채널',
          ),
          MindMapData(id: 'budget', title: '마케팅 예산', description: '예산 배분과 계획'),
        ],
      ),
    ],
  );

  static MindMapData generateLargeData(int nodeCount) {
    final colors = [
      const Color(0xFF7C3AED),
      const Color(0xFF059669),
      const Color(0xFFDC2626),
      const Color(0xFFF59E0B),
      const Color(0xFF7C2D12),
      const Color(0xFF6B21A8),
      const Color(0xFF0EA5E9),
      const Color(0xFF10B981),
      const Color(0xFFEF4444),
    ];

    List<MindMapData> mainCategories = [];
    int remainingNodes = nodeCount - 1;
    int mainCategoryCount = (remainingNodes / 8).ceil().clamp(1, 12);
    int nodesPerCategory = (remainingNodes / mainCategoryCount).floor();

    for (int i = 0; i < mainCategoryCount; i++) {
      int categoryNodes =
          nodesPerCategory + (i < remainingNodes % mainCategoryCount ? 1 : 0);

      List<MindMapData> subNodes = [];
      for (int j = 1; j < categoryNodes && j < 15; j++) {
        subNodes.add(
          MindMapData(
            id: 'node_${i}_$j',
            title: '노드 ${i + 1}-$j',
            description: '카테고리 ${i + 1}의 서브 노드 $j',
            color: colors[i % colors.length].withValues(alpha: 0.8),
          ),
        );
      }

      mainCategories.add(
        MindMapData(
          id: 'category_$i',
          title: '카테고리 ${i + 1}',
          description: '메인 카테고리 ${i + 1}에 대한 설명',
          color: colors[i % colors.length],
          children: subNodes,
        ),
      );
    }

    return MindMapData(
      id: 'root',
      title: '대용량\n데이터',
      description: '$nodeCount개 노드 테스트',
      color: const Color(0xFF2563EB),
      children: mainCategories,
    );
  }
}
