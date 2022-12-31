pluginManagement {
    repositories {
        google()
        gradlePluginPortal()
        mavenCentral()
    }
}

dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }

    versionCatalogs {
        create("androidLibs") {
            from(files("gradle/android.libs.versions.toml"))
        }

        create("kmmLibs") {
            from(files("gradle/kmm.libs.versions.toml"))
        }
    }
}

rootProject.name = "kmm-template"
include(":androidApp")
include(":shared")