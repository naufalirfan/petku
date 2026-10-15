# Flutter + Hive + flame — keep
-keep class io.flutter.** { *; }
-keep class com.petku.** { *; }
-keep class org.hive.** { *; }
-keepattributes *Annotation*
# flutter_local_notifications keep
-keep class com.dexterous.flutterlocalnotifications.** { *; }
# play core — app tidak pakai deferred component/split install, Flutter embedding cuma reference
-dontwarn com.google.android.play.core.**
