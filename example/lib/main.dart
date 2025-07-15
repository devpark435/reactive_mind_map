import 'package:flutter/material.dart';
import 'package:reactive_mind_map/reactive_mind_map.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Camera Focus 테스트',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const TestScreen(),
    );
  }
}

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  CameraFocus currentFocus = CameraFocus.rootNode;
  String? targetNodeId;
  String lastAction = '시작';
  NodeExpandCameraBehavior expandBehavior = NodeExpandCameraBehavior.none;

  // 간단한 테스트 데이터
  final mindMapData = MindMapData(
    id: 'root',
    title: '🎯 메인',
    children: [
      MindMapData(
        id: 'node1',
        title: '📝 노드1',
        children: [
          MindMapData(id: 'sub1', title: '서브1'),
          MindMapData(id: 'sub2', title: '서브2'),
        ],
      ),
      MindMapData(id: 'node2', title: '🎨 노드2'),
      MindMapData(id: 'node3', title: '🔧 노드3'),
      MindMapData(
        id: 'node4',
        title: '🚀 노드4',
        children: [MindMapData(id: 'final', title: '마지막')],
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('카메라 포커스 테스트'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // 간단한 버튼들
          Container(
            padding: const EdgeInsets.all(16),
            child: Wrap(
              spacing: 8,
              children: [
                _buildButton(
                  '🎯 루트',
                  () => _focusToNode(CameraFocus.rootNode, null),
                ),
                _buildButton(
                  '🔍 전체보기',
                  () => _focusToNode(CameraFocus.fitAll, null),
                ),
                _buildButton(
                  '📝 노드1',
                  () => _focusToNode(CameraFocus.custom, 'node1'),
                ),
                _buildButton(
                  '서브1',
                  () => _focusToNode(CameraFocus.custom, 'sub1'),
                ),
                _buildButton(
                  '마지막',
                  () => _focusToNode(CameraFocus.custom, 'final'),
                ),
                _buildButton(
                  '🍃 첫리프',
                  () => _focusToNode(CameraFocus.firstLeaf, null),
                ),
              ],
            ),
          ),

          // 🆕 노드 확장 동작 선택
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '📂 노드 확장 시 카메라 동작:',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 4,
                  children: [
                    _buildExpandBehaviorButton(
                      '❌ 이동없음',
                      NodeExpandCameraBehavior.none,
                    ),
                    _buildExpandBehaviorButton(
                      '🎯 클릭노드',
                      NodeExpandCameraBehavior.focusClickedNode,
                    ),
                    _buildExpandBehaviorButton(
                      '👶 자식들만',
                      NodeExpandCameraBehavior.fitExpandedChildren,
                    ),
                    _buildExpandBehaviorButton(
                      '🌳 전체트리',
                      NodeExpandCameraBehavior.fitExpandedSubtree,
                    ),
                  ],
                ),
              ],
            ),
          ),

          // 상태 표시
          Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text('현재 포커스: ${_getFocusName()}'),
                Text('마지막 동작: $lastAction'),
                Text('확장 동작: ${_getExpandBehaviorName()}'),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 마인드맵
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue[300]!, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: MindMapWidget(
                  data: mindMapData,
                  style: const MindMapStyle(
                    backgroundColor: Color(0xFFF8F9FA),
                    defaultNodeColors: [
                      Color(0xFF4CAF50),
                      Color(0xFF2196F3),
                      Color(0xFFFF9800),
                      Color(0xFFE91E63),
                    ],
                    levelSpacing: 120,
                    nodeMargin: 15,
                  ),
                  cameraFocus: CameraFocus.fitAll,
                  focusNodeId: targetNodeId,
                  focusAnimation: const Duration(
                    milliseconds: 1000,
                  ), // 더 긴 애니메이션
                  isNodesCollapsed: false, // 모든 노드 펼쳐져 있음
                  nodeExpandCameraBehavior: expandBehavior,
                  onNodeTap: (node) {
                    debugPrint('탭된 노드: ${node.title} (${node.id})');
                    setState(() {
                      lastAction = '노드 탭: ${node.title}';
                    });
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton(String text, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  void _focusToNode(CameraFocus focus, String? nodeId) {
    setState(() {
      currentFocus = focus;
      targetNodeId = nodeId;
      lastAction =
          '${_getFocusName()} ${nodeId != null ? '→ $nodeId' : ''}로 이동';
    });
  }

  String _getFocusName() {
    switch (currentFocus) {
      case CameraFocus.rootNode:
        return '루트';
      case CameraFocus.fitAll:
        return '전체보기';
      case CameraFocus.custom:
        return '커스텀';
      case CameraFocus.firstLeaf:
        return '첫리프';
      case CameraFocus.center:
        return '중앙';
    }
  }

  Widget _buildExpandBehaviorButton(
    String text,
    NodeExpandCameraBehavior behavior,
  ) {
    return ElevatedButton(
      onPressed: () => setState(() => expandBehavior = behavior),
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(text, style: const TextStyle(fontSize: 12)),
    );
  }

  String _getExpandBehaviorName() {
    switch (expandBehavior) {
      case NodeExpandCameraBehavior.none:
        return '❌ 이동없음';
      case NodeExpandCameraBehavior.focusClickedNode:
        return '🎯 클릭노드';
      case NodeExpandCameraBehavior.fitExpandedChildren:
        return '👶 자식들만';
      case NodeExpandCameraBehavior.fitExpandedSubtree:
        return '🌳 전체트리';
    }
  }
}
