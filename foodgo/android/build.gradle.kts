// Thêm buildscript để khai báo plugin Google Services
buildscript {
    repositories {
        google()
        mavenCentral()
    }
    dependencies {
        // Plugin Google Services cho Firebase
        classpath("com.google.gms:google-services:4.3.15") // bạn có thể thay bằng bản mới hơn nếu cần
    }
}

allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

// Giữ nguyên phần custom build directory
val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}

subprojects {
    project.evaluationDependsOn(":app")
}

// Task clean
tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
