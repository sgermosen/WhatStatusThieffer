# Project specific ProGuard / R8 rules.

# Flutter wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Flutter's deferred-components code references Play Core, which this app does
# not ship. Without this, R8 fails release builds with "Missing class
# com.google.android.play.core...".
-dontwarn com.google.android.play.core.**
