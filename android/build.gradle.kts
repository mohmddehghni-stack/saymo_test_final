import org.gradle.api.file.Directory

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

/**
 * Force all modules to use compileSdk 36
 * (حل مشکل file_picker و flutter_plugin_android_lifecycle)
 */
subprojects {
    afterEvaluate {
        extensions.findByName("android")?.let { androidExt ->
            (androidExt as com.android.build.gradle.BaseExtension).apply {
                compileSdkVersion(36)
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory.dir("../../build").get()

rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}