import com.flutter.gradle.tasks.FlutterTask
import groovy.json.JsonSlurper
import java.io.File
import java.nio.file.Path

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

val environmentManifest = JsonSlurper().parse(file("../../config/environments.json")) as Map<*, *>
val baseIdentifier = environmentManifest["baseIdentifier"] as String
val androidEnvironments = (environmentManifest["environments"] as List<*>).map { raw ->
    val environment = raw as Map<*, *>
    AndroidEnvironment(
        name = environment["name"] as String,
        applicationId = environment["androidApplicationId"] as String,
        displayName = environment["displayName"] as String,
        dartEntrypoint = environment["dartEntrypoint"] as String,
    )
}

val firebaseConfigCandidates = androidEnvironments.map { environment ->
    file("src/${environment.name}/google-services.json")
}
val hasFirebaseConfig = firebaseConfigCandidates.any { it.isFile }
if (hasFirebaseConfig) {
    pluginManager.apply("com.google.gms.google-services")
    pluginManager.apply("com.google.firebase.crashlytics")

    tasks.configureEach {
        val normalizedTaskName = name.lowercase()
        val environment = androidEnvironments.singleOrNull { candidate ->
            normalizedTaskName.contains(candidate.name)
        }
        if (environment != null &&
            (normalizedTaskName.contains("googleservices") ||
                normalizedTaskName.contains("crashlytics"))) {
            val config = file("src/${environment.name}/google-services.json")
            if (!config.isFile) {
                logger.lifecycle(
                    "Firebase task $name disabled because ${environment.name} config is absent.",
                )
                enabled = false
            }
        }
    }
} else {
    logger.lifecycle(
        "Firebase Android config not present; Google Services and Crashlytics Gradle plugins are skipped.",
    )
}

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

val flutterAppRoot = file("../..").canonicalFile.toPath()
val systemTempRoot = File(System.getProperty("java.io.tmpdir")).canonicalFile.toPath()

fun normalizedPlatformTarget(rawTarget: String): File {
    if (rawTarget.isBlank()) {
        throw GradleException("Android Flutter target cannot be blank.")
    }
    val platformPath = rawTarget
        .replace('\\', File.separatorChar)
        .replace('/', File.separatorChar)
    val rawSegments = platformPath.split(File.separatorChar)
    if (rawSegments.any { it == ".." }) {
        throw GradleException("Android Flutter target cannot contain parent traversal: $rawTarget")
    }
    return File(platformPath)
}

fun canonicalTargetPath(rawTarget: String): Path {
    val targetFile = normalizedPlatformTarget(rawTarget)
    return if (targetFile.isAbsolute) {
        targetFile.canonicalFile.toPath()
    } else {
        flutterAppRoot.resolve(targetFile.path).toFile().canonicalFile.toPath()
    }
}

fun isFlutterManagedTestListener(resolvedTarget: Path): Boolean {
    if (!resolvedTarget.startsWith(systemTempRoot)) return false
    val relative = systemTempRoot.relativize(resolvedTarget)
    if (relative.nameCount != 3) return false

    val toolsDirectory = relative.getName(0).toString()
    val listenerDirectory = relative.getName(1).toString()
    return toolsDirectory.startsWith("flutter_tools.") &&
        toolsDirectory.length > "flutter_tools.".length &&
        listenerDirectory.startsWith("flutter_test_listener.") &&
        listenerDirectory.length > "flutter_test_listener.".length &&
        relative.getName(2).toString() == "listener.dart"
}

fun canonicalAppRelativeTarget(resolvedTarget: Path, rawTarget: String): String {

    if (!resolvedTarget.startsWith(flutterAppRoot)) {
        throw GradleException(
            "Android Flutter target must resolve inside app root $flutterAppRoot, " +
                "but received $rawTarget",
        )
    }

    return flutterAppRoot.relativize(resolvedTarget)
        .toString()
        .replace(File.separatorChar, '/')
}

data class AndroidFlutterTarget(
    val canonicalPath: String?,
    val isFlutterDefault: Boolean,
    val isIntegrationTest: Boolean,
    val isFlutterManagedTestListener: Boolean,
) {
    fun isAllowedFor(environment: AndroidEnvironment): Boolean =
        isFlutterDefault || isIntegrationTest || isFlutterManagedTestListener ||
            canonicalPath == environment.dartEntrypoint
}

fun resolveAndroidFlutterTarget(rawTarget: String?): AndroidFlutterTarget {
    if (rawTarget == null) {
        return AndroidFlutterTarget(
            canonicalPath = null,
            isFlutterDefault = true,
            isIntegrationTest = false,
            isFlutterManagedTestListener = false,
        )
    }

    val resolvedTarget = canonicalTargetPath(rawTarget)
    if (isFlutterManagedTestListener(resolvedTarget)) {
        return AndroidFlutterTarget(
            canonicalPath = null,
            isFlutterDefault = false,
            isIntegrationTest = false,
            isFlutterManagedTestListener = true,
        )
    }

    val canonicalTarget = canonicalAppRelativeTarget(resolvedTarget, rawTarget)
    return AndroidFlutterTarget(
        canonicalPath = canonicalTarget,
        isFlutterDefault = canonicalTarget == "lib/main.dart",
        isIntegrationTest = canonicalTarget.startsWith("integration_test/"),
        isFlutterManagedTestListener = false,
    )
}

android {
    namespace = baseIdentifier
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
        applicationId = baseIdentifier
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
            isMinifyEnabled = true
            isShrinkResources = true
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro",
            )
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
    val resolvedTarget = resolveAndroidFlutterTarget(explicitTarget)
    if (!resolvedTarget.isAllowedFor(environment)) {
        throw GradleException(
            "Android flavor ${environment.name} requires target " +
                "${environment.dartEntrypoint}, but received $explicitTarget",
        )
    }

    if (!resolvedTarget.isIntegrationTest && !resolvedTarget.isFlutterManagedTestListener) {
        targetPath = environment.dartEntrypoint
    }
}

tasks.register("verifyFlutterTargetPathContract") {
    group = "verification"
    description = "Verifies Android Flutter target canonicalization and environment fail-fast semantics."

    doLast {
        val development = androidEnvironments.single { it.name == "development" }
        val staging = androidEnvironments.single { it.name == "staging" }
        val developmentAbsolute = flutterAppRoot.resolve(development.dartEntrypoint).toString()
        val windowsStyleRelative = development.dartEntrypoint.replace('/', '\\')
        val managedListener = systemTempRoot
            .resolve("flutter_tools.template")
            .resolve("flutter_test_listener.template")
            .resolve("listener.dart")
            .toString()

        check(resolveAndroidFlutterTarget(development.dartEntrypoint).isAllowedFor(development))
        check(resolveAndroidFlutterTarget(developmentAbsolute).isAllowedFor(development))
        check(resolveAndroidFlutterTarget(windowsStyleRelative).isAllowedFor(development))
        check(resolveAndroidFlutterTarget("lib/main.dart").isAllowedFor(development))
        check(
            resolveAndroidFlutterTarget("integration_test/security_lifecycle_smoke_test.dart")
                .isAllowedFor(development),
        )
        check(!resolveAndroidFlutterTarget(staging.dartEntrypoint).isAllowedFor(development))
        check(resolveAndroidFlutterTarget(managedListener).isAllowedFor(development))

        val externalTarget = File(
            System.getProperty("java.io.tmpdir"),
            "flutter_architecture_external/${development.dartEntrypoint}",
        ).absolutePath
        val externalRejected = runCatching {
            resolveAndroidFlutterTarget(externalTarget)
        }.exceptionOrNull() is GradleException
        check(externalRejected) {
            "External Android Flutter target with matching suffix must remain rejected."
        }

        val unrelatedListener = systemTempRoot.resolve("unrelated/listener.dart").toString()
        check(runCatching { resolveAndroidFlutterTarget(unrelatedListener) }.isFailure)

        val wrongListenerHierarchy = systemTempRoot
            .resolve("flutter_tools.template")
            .resolve("unrelated")
            .resolve("listener.dart")
            .toString()
        check(runCatching { resolveAndroidFlutterTarget(wrongListenerHierarchy) }.isFailure)

        val extraListenerHierarchy = systemTempRoot
            .resolve("flutter_tools.template")
            .resolve("flutter_test_listener.template")
            .resolve("nested")
            .resolve("listener.dart")
            .toString()
        check(runCatching { resolveAndroidFlutterTarget(extraListenerHierarchy) }.isFailure)

        val traversalTarget = systemTempRoot
            .resolve("flutter_tools.template")
            .resolve("ignored")
            .resolve("..")
            .resolve("flutter_test_listener.template")
            .resolve("listener.dart")
            .toString()
        check(runCatching { resolveAndroidFlutterTarget(traversalTarget) }.isFailure)
    }
}
