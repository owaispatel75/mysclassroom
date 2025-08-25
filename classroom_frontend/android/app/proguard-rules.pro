# Keep all annotations (so R8 doesn’t choke on missing annotation types)
-keepattributes *Annotation*

# Razorpay SDK classes & interfaces must be kept
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }

# Ignore missing ProGuard annotation classes referenced by the SDK
-dontwarn proguard.annotation.**
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers

# (Optional) quiet some common libs noise
-dontwarn org.codehaus.mojo.animal_sniffer.**
-dontwarn javax.annotation.**
-dontwarn kotlin.**

# --- Razorpay + optional Google Pay (India) integration ---
# Keep Razorpay SDK
-keep class com.razorpay.** { *; }
-keep interface com.razorpay.** { *; }

# Ignore missing Google Pay (India) in-app client classes referenced by Razorpay
-dontwarn com.google.android.apps.nbu.paisa.inapp.client.api.**
-dontwarn com.razorpay.RzpGpayMerged

# Keep annotations / avoid stripping
-keepattributes *Annotation*
# If you previously saw proguard.annotation.* warnings, keep/don’t-warn:
-dontwarn proguard.annotation.**
-keep class proguard.annotation.Keep
-keep class proguard.annotation.KeepClassMembers
