# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.2.2] - 2025-01-27
- **Fixed pub.dev warnings**: Removed unused function declarations and imports

## [1.2.1] - 2025-01-27

### 🔧 Code Quality Improvements
- **Fixed pub.dev warnings**: Removed unused function declarations and imports
- **Updated repository URL formatting**: Improved pubspec.yaml formatting for better pub.dev compatibility
- **Enhanced code analysis**: Cleaned up unused variables and declarations

### 🐛 Bug Fixes
- **Fixed unused import warnings**: Removed unused dart:math import
- **Fixed unused variable warnings**: Cleaned up unused local variables
- **Fixed unused function warnings**: Commented out unused function declarations

## [1.2.0] - 2025-07-16

### 🎯 Enhanced User Experience
- **Unified Custom Node Approach**: Single `nodeBuilder` property in `MindMapStyle`
  - Consistent theming across all custom nodes
  - Easier to understand and implement
  - Better integration with existing style system

### 📖 Documentation Updates
- Updated README to reflect simplified API
- Removed widget-level custom node builder examples
- Streamlined documentation for single approach

### 🐛 Bug Fixes
- **Fixed API confusion**: Eliminated duplicate functionality between style and widget levels
- **Improved code clarity**: Single source of truth for custom node builders

## [1.2.0] - 2025-07-16

### 🎯 New Features
- **Widget-Level Custom Node Builder**: Added `customNodeBuilder` parameter to `MindMapWidget`
  - Create complex custom node designs with full widget customization
  - Support for custom data, icons, and priority tags
  - Overflow prevention with `SingleChildScrollView`
  - Independent from style-level customization

### 🎨 Enhanced Customization
- **Two Custom Node Approaches**:
  - Style-Level: Use `MindMapStyle.nodeBuilder` for consistent theme changes
  - Widget-Level: Use `MindMapWidget.customNodeBuilder` for instance-specific designs
- **Comprehensive Test Data**: Added 25-node project management system example
- **Korean Language Support**: Added Korean UI elements and documentation

### 🔧 Technical Improvements
- **Overflow Prevention**: Implemented `SingleChildScrollView` in custom node builders
- **Enhanced Node Size Calculation**: Improved `getActualNodeSize` method with better text measurement
- **Better Positioning**: Added canvas boundary constraints for node positioning
- **Optimized Rendering**: Improved node widget rendering with `SizedBox` constraints

### 📖 Documentation
- Added comprehensive Custom Node Builders guide to README
- Provided detailed examples for both style-level and widget-level customization
- Added comparison table for different customization approaches
- Updated usage examples with Korean language support

### 🐛 Bug Fixes
- **Fixed overflow issues**: Resolved bottom overflow in custom node builders
- **Improved text rendering**: Better text overflow handling with `TextOverflow.ellipsis`
- **Enhanced canvas sizing**: More accurate canvas size calculation with safety margins

### Usage Examples

#### Style-Level Custom Node Builder
```dart
MindMapWidget(
  data: myData,
  style: MindMapStyle(
    nodeBuilder: (node, isSelected, onTap, onLongPress, onDoubleTap) {
      final icon = node.customData?['icon'] as String? ?? '📋';
      final priority = node.customData?['priority'] as String? ?? 'medium';
      
      return GestureDetector(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(
            color: node.color,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _getPriorityColor(priority), width: 3),
          ),
          child: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Text(icon, style: TextStyle(fontSize: 14)),
                  Text(node.title, style: TextStyle(fontSize: 11)),
                ],
              ),
            ),
          ),
        ),
      );
    },
  ),
)
```

## [1.1.1] - 2025-06-20

### Fixed
- Fixed homepage URL in pubspec.yaml to point to correct repository
- Updated CHANGELOG.md to use English as primary language for pub.dev compliance

## [1.1.0] - 2025-06-20

### 🎯 New Features
- **NodeExpandCameraBehavior**: Added camera behavior control when nodes are expanded/collapsed
  - `none`: No camera movement (default)
  - `focusClickedNode`: Focus on the clicked node
  - `fitExpandedChildren`: Fit newly expanded children nodes to view
  - `fitExpandedSubtree`: Fit entire expanded subtree to view

### 🐛 Bug Fixes
- **Fixed camera drift on node toggle**: Resolved issue where mind map would gradually move down when toggling nodes
- **Improved root node position stability**: Root node position is now fixed during node toggle operations

### 🔧 Technical Improvements
- Optimized camera control logic
- Enhanced node toggle state management

## [1.0.5] - 2025-06-20

### 🎯 New Features
- **Smart Camera Focus System**: Added intelligent camera focus system
  - `CameraFocus.rootNode`: Focus on root node (default)
  - `CameraFocus.center`: Focus on canvas center
  - `CameraFocus.fitAll`: Auto-fit all nodes to view
  - `CameraFocus.firstLeaf`: Focus on first leaf node
  - `CameraFocus.custom`: Focus on specific node using `focusNodeId`

### 🔧 Camera Control Options
- `cameraFocus`: Set camera focus option
- `focusNodeId`: Specify target node ID for custom focus
- `focusAnimation`: Set focus transition animation duration (default: 300ms)
- `focusMargin`: Set margin around focused content (default: 20px)

### 🎨 Enhanced User Experience
- Perfect mind map display in small containers
- Smooth camera transition animations
- Pixel-perfect focus calculations for accurate centering

### 📖 Documentation
- Added Camera Focus Control usage guide to README
- Provided 4 practical usage examples
- Added focus options reference table

## [1.0.4] - 2024-06-19

### Added
- 🎯 **Auto-centering feature**: Root node automatically centers on initial load
- 📏 **Initial zoom scale**: `initialScale` property for default zoom level control
- 📂 **Default node expansion state**: `isNodesCollapsed` property for initial node state control
- 📸 **Image capture feature**: `captureKey` property for saving mind map as image
- 🔄 **TransformationController support**: Programmatic viewport and zoom control

### Improved
- 🔧 **Text rendering quality**: Applied `softWrap: true` to prevent text overflow
- ⚡ **Initial loading performance**: Auto-centering improves user experience
- 🎨 **InteractiveViewer optimization**: Smoother pan/zoom interactions
- 📱 **Responsive improvements**: Better adaptation to various screen sizes

### Fixed
- ❌ **Initial viewport issue**: Fixed root node appearing outside viewport
- 🔤 **Text clipping issue**: Fixed display errors with long text
- 🎯 **Node focus issue**: Fixed difficulty finding mind map content

### Usage Examples
```dart
MindMapWidget(
  data: yourMindMapData,
  initialScale: 0.8,           // Initial 80% zoom level
  isNodesCollapsed: false,     // Expand all nodes by default
  captureKey: GlobalKey(),     // Key for image capture
  style: MindMapStyle(
    // ... existing style settings
  ),
)
```

## [1.0.3] - 2025-06-13

### Added
- Enhanced documentation with comprehensive examples
- Improved error handling in layout calculations
- Better performance for large mind maps

### Fixed
- Fixed animation glitches in certain scenarios
- Resolved layout calculation edge cases

## [1.0.2] - 2025-06-11

### Added
- Dynamic node sizing based on content
- Improved connection line rendering
- Better memory management for animations

### Fixed
- Fixed overflow issues in small containers
- Resolved animation controller disposal issues

## [1.0.1] - 2025-06-11

### Added
- Initial release with basic mind map functionality
- Multiple layout options (right, left, top, bottom, radial, horizontal, vertical)
- Customizable node shapes and colors
- Interactive expand/collapse animations
- Touch interactions (tap, long press, double tap)
- Pan and zoom capabilities

### Features
- **Layouts**: 7 different layout options
- **Node Shapes**: 6 different shape options
- **Animations**: Smooth expand/collapse with customizable curves
- **Interactions**: Full touch interaction support
- **Styling**: Comprehensive styling options

## [1.0.0] - 2025-06-11

### Added
- Initial release of Reactive Mind Map package
- Multiple layout options (right, left, top, bottom, radial, horizontal, vertical)
- Six node shapes (rounded rectangle, circle, rectangle, diamond, hexagon, ellipse)
- Comprehensive styling system with MindMapStyle
- Interactive features (tap, long press, double tap, expand/collapse)
- Smooth animations with customizable curves and duration
- Pan and zoom functionality
- Rich customization options for colors, fonts, and effects
- Shadow effects for nodes
- Connection line customization
- Comprehensive test suite
- Example application demonstrating all features
- MIT License
- Complete documentation

### 기술적 특징
- Flutter 3.0+ 지원
- 반응형 디자인
- 접근성 고려
- 타입 안전성

### 지원 플랫폼
- Android
- iOS  
- Web
- Windows
- macOS
- Linux 