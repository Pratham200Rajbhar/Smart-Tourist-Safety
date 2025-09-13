class AppConstants {
  // App Information
  static const String appName = 'Smart Tourist Safety';
  static const String appVersion = '1.0.0';
  
  // Animation Durations
  static const Duration fastAnimation = Duration(milliseconds: 200);
  static const Duration normalAnimation = Duration(milliseconds: 300);
  static const Duration slowAnimation = Duration(milliseconds: 500);
  
  // Map Constants
  static const double defaultZoom = 10.0;
  static const double maxZoom = 18.0;
  static const double minZoom = 5.0;
  
  // SOS Constants
  static const int sosCountdownSeconds = 5;
  static const double sosButtonSize = 120.0;
  
  // Responsive Breakpoints
  static const double mobileBreakpoint = 600.0;
  static const double tabletBreakpoint = 1024.0;
  
  // Spacing Constants (percentage of screen height)
  static const double smallSpacing = 0.02; // 2%
  static const double mediumSpacing = 0.04; // 4%
  static const double largeSpacing = 0.08; // 8%
  
  // Default Locations (Jammu & Kashmir)
  static const double defaultLat = 34.0837; // Srinagar
  static const double defaultLng = 74.7973;
  
  // Digital ID Constants
  static const int minNameLength = 2;
  static const String digitalIdPrefix = 'BLK-CHAIN-';
}