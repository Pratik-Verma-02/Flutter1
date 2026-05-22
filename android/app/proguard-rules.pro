# Flutter-specific ProGuard rules

# Keep Flutter wrapper classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }

# Keep Pointycastle classes
-keep class org.bouncycastle.** { *; }
-keep class org.spongycastle.** { *; }

# Keep Hive
-keep class * extends androidx.room.RoomDatabase
-keep @androidx.room.Entity class *

# Keep generated model files
-keep class com.primexkey.app.** { *; }

# General rules
-dontwarn org.bouncycastle.**
-dontwarn org.spongycastle.**
-dontwarn io.flutter.embedding.**

# Keep annotations
-keepattributes *Annotation*
-keepattributes SourceFile,LineNumberTable
-keepattributes Signature
