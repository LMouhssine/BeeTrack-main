pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

plugins {
    id("com.android.application") version "8.2.0" apply false
    id("org.jetbrains.kotlin.android") version "1.9.0" apply false
}

include(":app")

val localPropertiesFile = File(rootProject.projectDir, "local.properties")
val properties = java.util.Properties()
localPropertiesFile.inputStream().use { properties.load(it) }
val flutterSdkPath = properties.getProperty("flutter.sdk")
    ?: throw Exception("Flutter SDK not found. Define location with flutter.sdk in local.properties file.")

apply(from = "$flutterSdkPath/packages/flutter_tools/gradle/app_plugin_loader.gradle")
