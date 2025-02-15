allprojects {
    repositories {
        google()
        mavenCentral()
        // `flutter clean` and comment the following lines to work on Android app.
        // [required] background_fetch
        maven(url = "${project(":background_fetch").projectDir}/libs")
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    afterEvaluate {
        if (plugins.hasPlugin("com.android.application") || plugins.hasPlugin("com.android.library")) {
            if (name == "eventide") {
                extensions.configure<com.android.build.gradle.BaseExtension>("android") {
                    compileOptions {
                        sourceCompatibility = JavaVersion.VERSION_1_8
                        targetCompatibility = JavaVersion.VERSION_1_8
                    }
                    (this as? org.jetbrains.kotlin.gradle.dsl.KotlinJvmOptions)?.jvmTarget = JavaVersion.VERSION_1_8.toString()
                }
            }
        }
    }
}

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
