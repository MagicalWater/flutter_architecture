import com.flutter.gradle.tasks.FlutterTask
import java.util.Base64

plugins {
    id("com.android.application")
    id("kotlin-android")
    id("dev.flutter.flutter-gradle-plugin")
}

data class AndroidEnvironment(
    val name: String,
    val applicationId: String,
    val displayName: String,
    val dartEntrypoint: String,
)

val androidEnvironments = listOf(
    AndroidEnvironment(
        name = "development",
        applicationId = "com.example.flutterarchitecture.development",
        displayName = "Flutter Architecture Dev",
        dartEntrypoint = "lib/main_development.dart",
    ),
    AndroidEnvironment(
        name = "staging",
        applicationId = "com.example.flutterarchitecture.staging",
        displayName = "Flutter Architecture Staging",
        dartEntrypoint = "lib/main_staging.dart",
    ),
    AndroidEnvironment(
        name = "production",
        applicationId = "com.example.flutterarchitecture",
        displayName = "Flutter Architecture",
        dartEntrypoint = "lib/main_production.dart",
    ),
)

fun FlutterTask.environmentForTask(): AndroidEnvironment? {
    val normalizedTaskName = name.lowercase()
    val matches = androidEnvironments.filter { normalizedTaskName.contains(it.name) }
    if (matches.size > 1) {
        throw GradleException("Flutter task $name matches multiple environments: ${matches.map { it.name }}")
    }
    return matches.singleOrNull()
}

fun requestedAndroidEnvironment(): AndroidEnvironment? {
    val requestedTasks = gradle.startParameter.taskNames.map { it.lowercase() }
    val matches = androidEnvironments.filter { environment ->
        requestedTasks.any { it.contains(environment.name) }
    }
    if (matches.size > 1) {
        throw GradleException(
            "A single Gradle invocation cannot build multiple Android environments: " +
                matches.joinToString { it.name },
        )
    }
    return matches.singleOrNull()
}

fun appendDartDefine(current: String?, value: String): String {
    val encoded = Base64.getEncoder().encodeToString(value.toByteArray(Charsets.UTF_8))
    val values = current.orEmpty().split(',').filter { it.isNotBlank() }
    return (values + encoded).distinct().joinToString(",")
}

android {
    namespace = "com.example.flutterarchitecture"
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
        applicationId = "com.example.flutterarchitecture"
        minSdk = maxOf(flutter.minSdkVersion, 23)
        targetSdk = flutter.targetSdkVersion
        versionCode = flutter.versionCode
        versionName = flutter.versionName
    }

    flavorDimensions += "environment"
    productFlavors {
        androidEnvironments.forEach { environment ->
            create(environment.name) {
                dimension = "environment"
                applicationId = environment.applicationId
                manifestPlaceholders["appDisplayName"] = environment.displayName
                manifestPlaceholders["nativeEnvironment"] = environment.name
                buildConfigField(
                    "String",
                    "NATIVE_ENVIRONMENT",
                    "\"${environment.name}\"",
                )
            }
        }
    }

    buildFeatures {
        buildConfig = true
    }

    buildTypes {
        release {
            // Template baseline intentionally uses debug signing for local
            // release artifact verification. Production apps must replace it.
            signingConfig = signingConfigs.getByName("debug")
        }
    }
}

flutter {
    source = "../.."
}

tasks.withType<FlutterTask>().configureEach {
    val environment = environmentForTask() ?: return@configureEach
    val requestedEnvironment = requestedAndroidEnvironment() ?: return@configureEach
    if (environment != requestedEnvironment) return@configureEach
    val explicitTarget = project.findProperty("target")?.toString()
    val isFlutterDefaultTarget = explicitTarget == null || explicitTarget == "lib/main.dart"
    if (!isFlutterDefaultTarget && explicitTarget != environment.dartEntrypoint) {
        throw GradleException(
            "Android flavor ${environment.name} requires target " +
                "${environment.dartEntrypoint}, but received $explicitTarget",
        )
    }

    targetPath = environment.dartEntrypoint
    dartDefines = appendDartDefine(
        dartDefines,
        "NATIVE_ENVIRONMENT=${environment.name}",
    )
}
