allprojects {
    repositories {
        google()
        mavenCentral()
        maven { 
            url = uri("https://dl.google.com/dl/android/maven2/")
            isAllowInsecureProtocol = true
        }
        maven { 
            url = uri("https://maven.google.com/")
            isAllowInsecureProtocol = true
        }
        maven { 
            url = uri("https://repo1.maven.org/maven2/")
            isAllowInsecureProtocol = true
        }
        maven { 
            url = uri("https://plugins.gradle.org/m2/")
            isAllowInsecureProtocol = true
        }
        @Suppress("DEPRECATION")
        jcenter()
        maven { 
            url = uri("https://maven.aliyun.com/repository/google")
            isAllowInsecureProtocol = true
        }
        maven { 
            url = uri("https://maven.aliyun.com/repository/public")
            isAllowInsecureProtocol = true
        }
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
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
