# Flutter Local Notifications
-keep class com.dexterous.** { *; }
-keep class androidx.core.app.** { *; }
-keep class androidx.media.** { *; }

# Flutter Wrapper
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Firebase
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# ObjectBox
-keep class io.objectbox.** { *; }
-keep class ** { @io.objectbox.annotation.Entity <fields>; }

# Kotlin
-keep class kotlin.** { *; }
-keep class kotlinx.** { *; }

# Hive
-keep class hive.** { *; }
-keep class ** { @hive.annotations.HiveType <fields>; } 