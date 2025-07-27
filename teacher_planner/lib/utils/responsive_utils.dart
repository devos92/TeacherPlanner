// lib/utils/responsive_utils.dart

import 'package:flutter/material.dart';

class ResponsiveUtils {
  // Breakpoints for different device types
  static const double mobileBreakpoint = 480;
  static const double tabletBreakpoint = 768;
  static const double desktopBreakpoint = 1024;
  
  // Device type detection
  static DeviceType getDeviceType(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (screenWidth < mobileBreakpoint) {
      return DeviceType.mobile;
    } else if (screenWidth < tabletBreakpoint) {
      return DeviceType.largeMobile;
    } else if (screenWidth < desktopBreakpoint) {
      return DeviceType.tablet;
    } else {
      return DeviceType.desktop;
    }
  }
  
  // Simple device type checks
  static bool isMobile(BuildContext context) {
    return MediaQuery.of(context).size.width < tabletBreakpoint;
  }
  
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    return width >= tabletBreakpoint && width < desktopBreakpoint;
  }
  
  static bool isDesktop(BuildContext context) {
    return MediaQuery.of(context).size.width >= desktopBreakpoint;
  }
  
  static bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }
  
  // Adaptive sizing methods
  static double getAdaptiveWidth(BuildContext context, {
    double mobile = 1.0,
    double tablet = 0.8,
    double desktop = 0.6,
  }) {
    final screenWidth = MediaQuery.of(context).size.width;
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return screenWidth * mobile;
      case DeviceType.tablet:
        return screenWidth * tablet;
      case DeviceType.desktop:
        return screenWidth * desktop;
    }
  }
  
  // Adaptive padding
  static EdgeInsets getAdaptivePadding(BuildContext context, {
    EdgeInsets mobile = const EdgeInsets.all(16),
    EdgeInsets tablet = const EdgeInsets.all(24),
    EdgeInsets desktop = const EdgeInsets.all(32),
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
  
  // Adaptive font sizes
  static double getAdaptiveFontSize(BuildContext context, {
    double mobile = 14,
    double tablet = 16,
    double desktop = 18,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
  
  // Adaptive icon sizes
  static double getAdaptiveIconSize(BuildContext context, {
    double mobile = 24,
    double tablet = 28,
    double desktop = 32,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
  
  // Adaptive grid column count
  static int getAdaptiveGridColumns(BuildContext context, {
    int mobile = 1,
    int tablet = 2,
    int desktop = 3,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
  
  // Adaptive spacing
  static double getAdaptiveSpacing(BuildContext context, {
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
  
  // Adaptive dialog width
  static double getAdaptiveDialogWidth(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    
    if (isMobile(context)) {
      return screenWidth * 0.9;
    } else if (isTablet(context)) {
      return 500;
    } else {
      return 600;
    }
  }
  
  // Adaptive app bar height
  static double getAdaptiveAppBarHeight(BuildContext context) {
    return isMobile(context) ? 56 : 64;
  }
  
  // Adaptive bottom navigation bar height
  static double getAdaptiveBottomNavHeight(BuildContext context) {
    return isMobile(context) ? 60 : 70;
  }
  
  // Check if device has physical home button (for padding adjustments)
  static bool hasPhysicalHomeButton(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.padding.bottom == 0 && 
           mediaQuery.viewInsets.bottom == 0;
  }
  
  // Safe area padding that accounts for notches and system UI
  static EdgeInsets getSafeAreaPadding(BuildContext context) {
    return MediaQuery.of(context).padding;
  }
  
  // Check if keyboard is visible
  static bool isKeyboardVisible(BuildContext context) {
    return MediaQuery.of(context).viewInsets.bottom > 0;
  }
  
  // Get available screen height (excluding system UI)
  static double getAvailableHeight(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.height - 
           mediaQuery.padding.top - 
           mediaQuery.padding.bottom;
  }
  
  // Get available screen width (excluding system UI)
  static double getAvailableWidth(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width - 
           mediaQuery.padding.left - 
           mediaQuery.padding.right;
  }
  
  // Adaptive border radius
  static BorderRadius getAdaptiveBorderRadius(BuildContext context, {
    double mobile = 8,
    double tablet = 12,
    double desktop = 16,
  }) {
    final deviceType = getDeviceType(context);
    double radius;
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        radius = mobile;
        break;
      case DeviceType.tablet:
        radius = tablet;
        break;
      case DeviceType.desktop:
        radius = desktop;
        break;
    }
    
    return BorderRadius.circular(radius);
  }
  
  // Adaptive elevation
  static double getAdaptiveElevation(BuildContext context, {
    double mobile = 2,
    double tablet = 4,
    double desktop = 6,
  }) {
    final deviceType = getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet;
      case DeviceType.desktop:
        return desktop;
    }
  }
}

enum DeviceType {
  mobile,
  largeMobile,
  tablet,
  desktop,
}

// Extension methods for easier access
extension ResponsiveContext on BuildContext {
  bool get isMobile => ResponsiveUtils.isMobile(this);
  bool get isTablet => ResponsiveUtils.isTablet(this);
  bool get isDesktop => ResponsiveUtils.isDesktop(this);
  bool get isLandscape => ResponsiveUtils.isLandscape(this);
  bool get isKeyboardVisible => ResponsiveUtils.isKeyboardVisible(this);
  
  DeviceType get deviceType => ResponsiveUtils.getDeviceType(this);
  
  double get availableHeight => ResponsiveUtils.getAvailableHeight(this);
  double get availableWidth => ResponsiveUtils.getAvailableWidth(this);
  
  EdgeInsets get safeAreaPadding => ResponsiveUtils.getSafeAreaPadding(this);
}

// Responsive widget wrapper
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  @override
  Widget build(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
}

// Responsive value provider
class ResponsiveValue<T> {
  const ResponsiveValue({
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  final T mobile;
  final T? tablet;
  final T? desktop;

  T getValue(BuildContext context) {
    final deviceType = ResponsiveUtils.getDeviceType(context);
    
    switch (deviceType) {
      case DeviceType.mobile:
      case DeviceType.largeMobile:
        return mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
    }
  }
} 