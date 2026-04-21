# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# Flutter Local Notifications plugin compatibility
-keep class com.dexterous.** { *; }
-dontwarn com.dexterous.**

# Suppress warnings about bigLargeIcon method ambiguity
-dontwarn android.app.Notification$BigPictureStyle

# Keep notification related classes
-keep class android.app.Notification { *; }
-keep class android.app.Notification$* { *; }
-keep class android.app.NotificationManager { *; }
-keep class android.app.NotificationChannel { *; }
-keep class android.app.NotificationChannelGroup { *; }

# Firebase Messaging compatibility
-keep class com.google.firebase.** { *; }
-dontwarn com.google.firebase.**

# Keep device info related classes
-keep class io.flutter.plugins.deviceinfo.** { *; }
-dontwarn io.flutter.plugins.deviceinfo.** 