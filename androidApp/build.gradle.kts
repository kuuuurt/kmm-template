import java.io.FileInputStream
import java.util.Properties

plugins {
    id("com.android.application")
    kotlin("android")
}

// Version Metadata
val versionPropertiesFile = project.file("version.properties")
val versionProperties = Properties()
versionProperties.load(FileInputStream(versionPropertiesFile))

val productionVersionName = versionProperties["production.version.name"] as String
val productionVersionCode = versionProperties["production.version.code"] as String

val stgVersionCode = versionProperties["stg.version.code"] as String
val stgReleaseVersionCode = versionProperties["stg.release.version.code"] as String

val devVersionCode = versionProperties["dev.version.code"] as String
val devReleaseVersionCode = versionProperties["dev.release.version.code"] as String

android {
    namespace = "com.kuuuurt.template"
    compileSdk = TARGET_SDK_VERSION

    defaultConfig {
        applicationId = "com.kuuuurt.template"

        minSdk = MIN_SDK_VERSION
        targetSdk = TARGET_SDK_VERSION

        versionName = productionVersionName
    }

    buildFeatures {
        compose = true
    }

    composeOptions {
        kotlinCompilerExtensionVersion = "1.3.2"
    }
    packagingOptions {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }

    signingConfigs {
        create("release") {
            val keystorePropertiesFile = project.file("keystore.properties")
            val keystoreProperties = Properties()
            if (keystorePropertiesFile.exists()) {
                keystoreProperties.load(FileInputStream(keystorePropertiesFile))

                keyAlias = keystoreProperties.getProperty("keyAlias")
                keyPassword = keystoreProperties.getProperty("keyPassword")
                storeFile = project.file(keystoreProperties.getProperty("storeFile"))
                storePassword = keystoreProperties.getProperty("storePassword")
            }

            enableV1Signing = false
            enableV2Signing = true
            enableV3Signing = true
            enableV4Signing = true
        }
    }

    productFlavors {
        flavorDimensions("env")
        create("dev") {
            dimension = "env"
            applicationIdSuffix = ".dev"
            versionCode = devVersionCode.toInt()
            versionNameSuffix = "-dev-$devReleaseVersionCode"
        }
        create("staging") {
            dimension = "env"
            applicationIdSuffix = ".stg"
            versionCode = stgVersionCode.toInt()
            versionNameSuffix = "-stg-$stgReleaseVersionCode"
        }
        create("production") {
            dimension = "env"
            versionCode = productionVersionCode.toInt()
        }
    }

    buildTypes {
        getByName("debug") {
            applicationIdSuffix = ".debug"
            versionNameSuffix = "+debug"
        }
        getByName("release") {
            signingConfig = signingConfigs.getByName("release")

            isCrunchPngs = true
            isMinifyEnabled = true

            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

dependencies {
    // KMM
    implementation(project(":shared"))

    // Compose
    val composeBom = platform(androidLibs.androidx.compose.bom)
    implementation(composeBom)
    implementation("androidx.compose.ui:ui-tooling")
    implementation("androidx.compose.ui:ui-tooling-preview")
    implementation("androidx.compose.foundation:foundation")
    implementation("androidx.compose.material:material")
    implementation("androidx.compose.material3:material3")

    // Misc
    implementation(androidLibs.androidx.activity.compose)
}