allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Fix 1: isar_flutter_libs missing namespace (AGP 8+ requirement)
subprojects {
    plugins.withId("com.android.library") {
        extensions.configure<com.android.build.gradle.LibraryExtension> {
            if (namespace == null) {
                namespace = "dev.isar.isar_flutter_libs"
            }
        }
    }
}

// Fix 2: isar sets compileSdk 30, but dependencies need 33+
subprojects {
    afterEvaluate {
        extensions.findByType<com.android.build.gradle.LibraryExtension>()?.apply {
            if (compileSdk != null && compileSdk!! < 34) {
                compileSdk = 34
            }
        }
    }
}

val newBuildDir: Directory =
    rootProject.layout.buildDirectory
        .dir("../../build")
        .get()
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
