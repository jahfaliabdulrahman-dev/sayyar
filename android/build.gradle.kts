allprojects {
    repositories {
        google()
        mavenCentral()
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

// isar_flutter_libs 3.1.0+1 predates AGP 8 namespace + uses compileSdk 30; align with app toolchain.
subprojects {
    plugins.withId("com.android.library") {
        if (name == "isar_flutter_libs") {
            val androidExt = extensions.getByName("android")
            androidExt
                .javaClass
                .getMethod("setNamespace", String::class.java)
                .invoke(androidExt, "dev.isar.isar_flutter_libs")
        }
    }
}

subprojects {
    if (name == "isar_flutter_libs") {
        afterEvaluate {
            val androidExt = extensions.getByName("android")
            val compileSdkTarget = 35
            try {
                androidExt
                    .javaClass
                    .getMethod("setCompileSdk", Int::class.javaPrimitiveType)
                    .invoke(androidExt, compileSdkTarget)
            } catch (_: NoSuchMethodException) {
                androidExt
                    .javaClass
                    .getMethod("setCompileSdkVersion", Int::class.javaPrimitiveType)
                    .invoke(androidExt, compileSdkTarget)
            }
        }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
