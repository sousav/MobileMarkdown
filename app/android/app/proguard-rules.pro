# Flutter-specific ProGuard rules
# Keep Flutter engine classes
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep annotation classes used by Flutter plugins
-keep class androidx.annotation.** { *; }
