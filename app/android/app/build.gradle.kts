import java.io.File
import java.io.FileInputStream
import java.util.Properties
import org.gradle.api.GradleException

plugins {
    id("com.android.application")
    id("kotlin-android")
    // The Flutter Gradle Plugin must be applied after the Android and Kotlin Gradle plugins.
    id("dev.flutter.flutter-gradle-plugin")
}

// Load key.properties if it exists (for release signing)
val keystorePropertiesFile = rootProject.file("key.properties")
val keystoreProperties = Properties()
if (keystorePropertiesFile.exists()) {
    keystoreProperties.load(FileInputStream(keystorePropertiesFile))
}

fun readSigningValue(propertyName: String, envName: String): String? {
    val propertyValue = keystoreProperties.getProperty(propertyName)?.trim()?.takeIf { it.isNotEmpty() }
    val envValue = System.getenv(envName)?.trim()?.takeIf { it.isNotEmpty() }
    return propertyValue ?: envValue
}

val releaseStoreFilePath = readSigningValue("storeFile", "MOBILEMARKDOWN_UPLOAD_STORE_FILE")
val releaseStoreFile = releaseStoreFilePath?.let { path ->
    if (File(path).isAbsolute) File(path) else rootProject.file(path)
}
val releaseStorePassword = readSigningValue("storePassword", "MOBILEMARKDOWN_UPLOAD_STORE_PASSWORD")
val releaseKeyAlias = readSigningValue("keyAlias", "MOBILEMARKDOWN_UPLOAD_KEY_ALIAS")
val releaseKeyPassword = readSigningValue("keyPassword", "MOBILEMARKDOWN_UPLOAD_KEY_PASSWORD")
val hasReleaseSigning = listOf(
    releaseStoreFile,
    releaseStorePassword,
    releaseKeyAlias,
    releaseKeyPassword,
).all { it != null }
val allowDebugReleaseSigning = System.getenv("MOBILEMARKDOWN_ALLOW_DEBUG_RELEASE_SIGNING")
    ?.equals("true", ignoreCase = true) == true
val releaseBuildRequested = gradle.startParameter.taskNames.any {
    it.contains("release", ignoreCase = true)
}

if (hasReleaseSigning && releaseStoreFile?.exists() != true) {
    throw GradleException(
        "Android signing storeFile does not exist: ${releaseStoreFile!!.path}",
    )
}

if (releaseBuildRequested && !hasReleaseSigning && !allowDebugReleaseSigning) {
    throw GradleException(
        "Android release signing is not configured. Copy app/android/key.properties.example to app/android/key.properties or set MOBILEMARKDOWN_UPLOAD_STORE_FILE, MOBILEMARKDOWN_UPLOAD_STORE_PASSWORD, MOBILEMARKDOWN_UPLOAD_KEY_ALIAS, and MOBILEMARKDOWN_UPLOAD_KEY_PASSWORD. For local release-like installs only, set MOBILEMARKDOWN_ALLOW_DEBUG_RELEASE_SIGNING=true.",
    )
}

android {
    namespace = "com.mobilemarkdown.mobile_markdown"
    compileSdk = flutter.compileSdkVersion
    ndkVersion = flutter.ndkVersion

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = JavaVersion.VERSION_17.toString()
    }

    defaultConfig {
        applicationId = "com.mobilemarkdown.mobile_markdown"
        minSdk = flutter.minSdkVersion
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    if (hasReleaseSigning) {
        signingConfigs {
            create("release") {
                keyAlias = releaseKeyAlias
                keyPassword = releaseKeyPassword
                storeFile = releaseStoreFile
                storePassword = releaseStorePassword
            }
        }
    }

    buildTypes {
        release {
            signingConfig = if (hasReleaseSigning) {
                signingConfigs.getByName("release")
            } else {
                signingConfigs.getByName("debug")
            }
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }
}

flutter {
    source = "../.."
}
