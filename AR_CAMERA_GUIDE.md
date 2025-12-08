# AR Camera Feature Guide

## Overview

The AR Camera feature provides advanced capture capabilities for the PMFBY app, including real-time quality validation, multi-angle capture guidance, GPS verification, and crop segmentation.

## Architecture

```
┌─────────────────────────────────────────────────────────────────┐
│                      AR Camera Screen                            │
├─────────────────────────────────────────────────────────────────┤
│  ┌─────────────────┐  ┌─────────────────┐  ┌─────────────────┐  │
│  │ Camera Preview  │  │  AR Overlays    │  │ UI Controls     │  │
│  │                 │  │                 │  │                 │  │
│  │ - CameraX       │  │ - BoundingBox   │  │ - Flash         │  │
│  │ - Image Stream  │  │ - TiltIndicator │  │ - Grid          │  │
│  │ - Focus Control │  │ - GhostFrame    │  │ - Zoom          │  │
│  │                 │  │ - QualityBanner │  │ - Capture       │  │
│  └────────┬────────┘  └────────┬────────┘  └─────────────────┘  │
│           │                    │                                 │
│           ▼                    ▼                                 │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                    Validation Engine                         ││
│  │  ┌─────────────┐ ┌─────────────┐ ┌─────────────┐            ││
│  │  │ Quality     │ │ Stability   │ │ GPS         │            ││
│  │  │ Analyzer    │ │ Tracker     │ │ Verifier    │            ││
│  │  │             │ │             │ │             │            ││
│  │  │ - Blur      │ │ - Accel.    │ │ - Position  │            ││
│  │  │ - Exposure  │ │ - Gyro      │ │ - Boundary  │            ││
│  │  │ - Backlight │ │ - Variance  │ │ - Accuracy  │            ││
│  │  └─────────────┘ └─────────────┘ └─────────────┘            ││
│  └─────────────────────────────────────────────────────────────┘│
│                              │                                   │
│                              ▼                                   │
│  ┌─────────────────────────────────────────────────────────────┐│
│  │                 Capture Task Manager                         ││
│  │  - Multi-angle capture workflow                              ││
│  │  - Task progress tracking                                    ││
│  │  - Session management                                        ││
│  └─────────────────────────────────────────────────────────────┘│
└─────────────────────────────────────────────────────────────────┘
```

## Features

### 1. Real-time Bounding Box & Distance Guidance

The camera displays a dynamic bounding box that changes color based on distance:
- **Green**: Optimal distance (0.5m - 3.0m)
- **Yellow**: Too far - move closer
- **Red**: Too close - move back

Corner brackets provide visual guidance for framing the subject.

### 2. Image Quality Analysis

Real-time analysis of camera frames for:
- **Blur Detection**: Uses Laplacian variance algorithm to detect motion blur
- **Exposure Analysis**: Histogram-based analysis for under/overexposure
- **Backlight Detection**: Compares center vs edge brightness
- **Quality Score**: 0-100% combined score displayed on screen

### 3. Multi-Angle Capture Guidance

For comprehensive crop documentation:
- **Top View**: Bird's eye view of the crop
- **Side View**: Profile view showing plant structure
- **Close-up**: Detailed view of leaves/damage
- **Wide Angle**: Field overview for context

Ghost frames guide users to capture from the correct angles.

### 4. Stability & Tilt Indicator

A bubble-level indicator shows:
- **Green**: Camera is level (< 7.5° tilt)
- **Yellow**: Slightly tilted (7.5° - 15°)
- **Red**: Too tilted (> 15°)

Stability tracking ensures the camera is steady before capture.

### 5. GPS Verification

Location verification features:
- **Real-time GPS tracking** with accuracy indicator
- **Farm boundary verification** using polygon point-in-polygon
- **Mini-map** showing current position relative to farm boundary
- **Status indicators**: Inside/Outside boundary

### 6. Crop Segmentation

Basic color-based crop detection:
- Green region identification
- Bounding box calculation
- Coverage percentage
- Growth stage estimation

## Usage

### Basic Usage

```dart
import 'package:pmfby/src/features/camera/ar_camera.dart';

// Simple single capture
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const ARCameraScreen(),
  ),
);
```

### Multi-Angle Capture

```dart
// Multi-angle capture for comprehensive documentation
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ARCameraScreen(
      multiAngleMode: true,
      purpose: 'crop_loss_assessment',
      farmPlotId: 'FARM-001',
      farmBoundary: farmBoundaryPositions,
    ),
  ),
);
```

### Custom Tasks

```dart
// Custom task set for damage assessment
final tasks = CaptureTaskFactory.createDamageAssessmentTasks();

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ARCameraScreen(
      customTasks: tasks,
      multiAngleMode: true,
    ),
  ),
);
```

### Growth Stage Monitoring

```dart
// Tasks tailored for specific growth stage
final tasks = CaptureTaskFactory.createGrowthMonitoringTasks(
  CropGrowthStage.flowering,
);

Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => ARCameraScreen(
      customTasks: tasks,
      multiAngleMode: true,
    ),
  ),
);
```

## Configuration

### Validation Thresholds

```dart
// Standard thresholds (default)
ValidationThresholds.standard

// Strict thresholds for high-quality requirements
ValidationThresholds.strict

// Relaxed thresholds for difficult conditions
ValidationThresholds.relaxed

// Custom thresholds
const customThresholds = ValidationThresholds(
  minBlurScore: 50.0,
  minExposureScore: 40.0,
  maxTiltAngle: 12.0,
  stableDurationMs: 600,
  gpsAccuracyThreshold: 8.0,
);
```

### Task Types

| Type | Description | Use Case |
|------|-------------|----------|
| `topView` | Top-down view | Canopy coverage |
| `sideView` | Profile view | Plant height, structure |
| `closeUp` | Detailed view | Leaf condition, damage |
| `wideAngle` | Field overview | Context, extent |
| `stageSpecific` | Growth-stage specific | Monitoring |

## Components

### Models (`ar_camera_models.dart`)

- `CaptureTaskType` - Types of capture tasks
- `CropGrowthStage` - Plant growth stages
- `DistanceEstimate` - Distance measurement result
- `TiltEstimate` - Device tilt measurement
- `ImageQualityResult` - Image quality analysis
- `GpsVerificationResult` - GPS verification status
- `CropSegmentationResult` - Crop detection result
- `CaptureTask` - Individual capture task
- `ValidationState` - Combined validation state

### Services

#### `ImageQualityAnalyzer`
Analyzes camera frames for blur, exposure, and backlight.

#### `ValidationEngine`
Orchestrates all validation checks and provides real-time feedback.

#### `CaptureTaskManager`
Manages multi-angle capture workflow with progress tracking.

#### `CropSegmentationService`
Detects crop regions using color-based segmentation.

### Painters

#### `AROverlayPainter`
Main overlay combining bounding box, tilt, and crop mask.

#### `GhostFramePainter`
Displays guidance frames for multi-angle capture.

#### `StabilityIndicatorPainter`
Renders the bubble-level indicator.

#### `GpsOverlayPainter`
Displays GPS status and mini-map.

### Widgets

#### `GpsVerificationWidget`
Expandable GPS status display with mini-map.

## Color Scheme

```dart
// Standard AR colors
ARColors.valid    // #4CAF50 - Green (good/ready)
ARColors.warning  // #FF9800 - Orange (warning)
ARColors.error    // #F44336 - Red (error/outside)
ARColors.neutral  // #2196F3 - Blue (neutral/info)
ARColors.ghost    // White @ 30% opacity (guides)
ARColors.overlay  // Black @ 50% opacity (masks)
```

## Error Handling

The system handles various error conditions:

1. **Camera not available**: Displays error with retry option
2. **GPS permission denied**: Shows permission request UI
3. **Low memory**: Reduces frame processing frequency
4. **Frame processing errors**: Graceful degradation with cached results

## Performance Considerations

- Frame processing is throttled to 100ms intervals
- Quality history uses 5-frame sliding window for smoothing
- Segmentation samples every 8th pixel for efficiency
- Animations use hardware-accelerated Canvas operations

## Future Enhancements

1. **ML Model Integration**: Replace color-based segmentation with TensorFlow Lite model
2. **Distance Estimation**: Use ML or depth sensors for accurate distance
3. **Offline Mode**: Enhanced offline capture with deferred validation
4. **AR Markers**: Support for physical reference markers
5. **Voice Guidance**: Audio instructions for hands-free operation

## Dependencies

- `camera: ^0.10.5+5`
- `geolocator: ^10.1.0`
- `sensors_plus: ^3.1.0`
- `google_fonts: ^6.1.0`
- `provider: ^6.1.1`
