plugins {
    id("com.android.application") // Removed version and apply false here
    id("kotlin-android")
    //id("org.jetbrains.kotlin.android") version "2.0.21"
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    namespace = "com.example.graduation_project"
    compileSdk = 34
    ndkVersion = "27.0.12077973"

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }
    kotlinOptions {
        jvmTarget =  "17"// Match Java version
    }

    defaultConfig {
        applicationId = "com.example.graduation_project"
        minSdk = 23  // Changed from minSdkVersion() to property syntax
        targetSdk = 34  // Changed from targetSdkVersion() to property syntax
        versionCode = 1
        versionName = "1.0"
    }
    // In android/app/build.gradle.kts
    configurations.all {
        resolutionStrategy {
            force("org.jetbrains.kotlin:kotlin-stdlib-jdk8:1.8.0")
            force("org.jetbrains.kotlin:kotlin-stdlib:1.8.0")
            force("org.jetbrains.kotlin:kotlin-reflect:1.8.0")
        }
    }
    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

dependencies {
    implementation(platform("com.google.firebase:firebase-bom:32.7.0"))
    implementation("com.google.firebase:firebase-analytics")
}