# Flutter ProGuard Rules

# Keep Flutter classes
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

# Keep Supabase / Postgrest
-keep class io.supabase.** { *; }
-keep class com.supabase.** { *; }

# Keep JSON models used in fromJson()
-keepclassmembers class * {
    <init>(...);
    @com.google.gson.annotations.SerializedName <fields>;
}

# General
-dontwarn java.**
-dontwarn javax.**
-dontwarn com.google.**
