plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
    id("com.google.gms.google-services")
}

android {
    // Namespace correto conforme o teu google-services.json
    namespace = "com.example.as_built_app"
    
    // ATUALIZADO: Necessário para os plugins image_picker, sqflite, etc.
    compileSdk = 36 
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    defaultConfig {
        applicationId = "com.example.as_built_app"
        
        // CORRIGIDO: multiDexEnabled deve ser booleano
        multiDexEnabled = true 
        
        // Garante compatibilidade com dispositivos mais antigos
        minSdk = flutter.minSdkVersion 
        
        // ATUALIZADO: Alinhado com o compileSdk
        targetSdk = 36
        
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    buildTypes {
        release {
            signingConfig = signingConfigs.getByName("debug")
            isMinifyEnabled = false
            isShrinkResources = false
        }
    }
}

flutter {
    source = "../.."
}
