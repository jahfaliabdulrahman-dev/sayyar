# Isar Database - keep native/JNI classes
-keep class dev.isar.** { *; }
-keep class isar.** { *; }
-dontwarn dev.isar.**

# Flutter
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# url_launcher
-keep class io.flutter.plugins.urllauncher.** { *; }

# font_awesome_flutter
-keep class com.mikepenz.fontawesome_typeface_library.** { *; }

# Keep annotations
-keepattributes *Annotation*
-keepattributes Signature
-keepattributes InnerClasses
-keepattributes EnclosingMethod

# Google Play Core (not needed for sideloaded APK)
-dontwarn com.google.android.play.core.**
-dontwarn com.google.android.play.core.splitcompat.**
-dontwarn com.google.android.play.core.splitinstall.**
-dontwarn com.google.android.play.core.tasks.**

# OkHttp / networking
-dontwarn okhttp3.**
-dontwarn okio.**
