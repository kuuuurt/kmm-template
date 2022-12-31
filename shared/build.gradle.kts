import org.jetbrains.kotlin.gradle.plugin.mpp.NativeBuildType
import java.io.FileInputStream
import java.util.Properties

plugins {
    kotlin("multiplatform")
    kotlin("native.cocoapods")
    id("com.android.library")
    id("com.codingfeline.buildkonfig") version "0.13.3"
    kotlin("plugin.serialization") version "1.7.20"
}

kotlin {
    android()
    ios()
    iosSimulatorArm64()

    cocoapods {
        summary = "Some description for the Shared Module"
        homepage = "Link to the Shared Module homepage"
        version = "1.0"
        ios.deploymentTarget = "14.1"
        podfile = project.file("../iosApp/Podfile")
        framework {
            baseName = "shared"
        }
        xcodeConfigurationToNativeBuildType["Dev"] = NativeBuildType.DEBUG
        xcodeConfigurationToNativeBuildType["Staging"] = NativeBuildType.RELEASE
        xcodeConfigurationToNativeBuildType["Production"] = NativeBuildType.RELEASE
    }
    
    sourceSets {
        val commonMain by getting {
            dependencies {
                implementation(kmmLibs.coroutines)
                implementation(kmmLibs.kermit)
                implementation(kmmLibs.kotlinx.datetime)
                implementation(kmmLibs.ktor)
                implementation(kmmLibs.ktor.json)
                implementation(kmmLibs.ktor.logging)
                implementation(kmmLibs.ktor.serialization.json)
                implementation(kmmLibs.ktor.content.negotiation)
                implementation(kmmLibs.multiplatform.settings)
                implementation(kmmLibs.serialization.json)
            }
        }
        val commonTest by getting

        val androidMain by getting {
            dependencies {
                implementation(kmmLibs.ktor.android)
            }
        }
        val androidTest by getting

        val iosSimulatorArm64Main by getting
        val iosSimulatorArm64Test by getting

        val iosMain by getting {
            iosSimulatorArm64Main.dependsOn(this)
            dependencies {
                implementation(kmmLibs.ktor.ios)
            }
        }
        val iosTest by getting {
            iosSimulatorArm64Test.dependsOn(this)
        }
    }
}

android {
    compileSdk = TARGET_SDK_VERSION
    defaultConfig {
        minSdk = MIN_SDK_VERSION
        targetSdk = TARGET_SDK_VERSION
    }
}

buildkonfig {
    packageName = "com.kuuuurt.template"
    exposeObjectWithName = "KmmBuildConfig"

    val apiPropertiesFile = project.parent!!.file("secrets.properties")
    val apiProperties = Properties()

    if (apiPropertiesFile.exists()) {
        apiProperties.load(FileInputStream(apiPropertiesFile))

        defaultConfigs("dev") {
        }

        defaultConfigs("staging") {
        }

        defaultConfigs("production") {
        }
    } else {
        defaultConfigs {
        }
    }
}