plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

android {
    namespace = "com.mti.travel.investment"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
        // Enable more aggressive optimizations
        isCoreLibraryDesugaringEnabled = true
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
        // Enable Kotlin compiler optimizations
        freeCompilerArgs = freeCompilerArgs + listOf("-Xopt-in=kotlin.RequiresOptIn")
    }

    defaultConfig {
        applicationId = "com.mti.travel.investment"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
        
        // Enable multidex support for better performance with large app size
        multiDexEnabled = true
        
        // Resource optimization
        resourceConfigurations += listOf("en", "xxhdpi")
        
        // Explicitly set dimensions for vector drawables
        vectorDrawables.useSupportLibrary = true
    }

    buildTypes {
        release {
            // Enable minification for better performance and smaller APK size
            isMinifyEnabled = true
            proguardFiles(getDefaultProguardFile("proguard-android-optimize.txt"), "proguard-rules.pro")
            
            // Signing with debug keys for now
            signingConfig = signingConfigs.getByName("debug")
            
            // Enable resource shrinking
            isShrinkResources = true
        }
        
        debug {
            // Enable app inspection in debug builds
            isDebuggable = true
            applicationIdSuffix = ".debug"
        }
    }
    
    // Increase build performance
    packagingOptions {
        resources.excludes.add("META-INF/LICENSE")
        resources.excludes.add("META-INF/NOTICE")
        resources.excludes.add("META-INF/*.kotlin_module")
    }
}

dependencies {
    // Add core desugaring library for modern Java features on older Android
    coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")
}

flutter {
    source = "../.."
}
