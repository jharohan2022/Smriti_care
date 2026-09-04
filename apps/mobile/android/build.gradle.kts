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

// Some older Flutter plugins (e.g. isar_flutter_libs 3.1.0+1) never declare an
// Android `namespace`, which AGP 8+ makes mandatory — so their :android module
// fails to configure ("Namespace not specified"). Inject it from the module's
// Gradle group (which for these plugins equals their legacy manifest package)
// when missing. Reflection keeps this off the AGP classpath; modules that already
// set a namespace are untouched.
fun setNamespaceIfMissing(project: Project) {
    val android = project.extensions.findByName("android") ?: return
    val getNamespace = runCatching { android.javaClass.getMethod("getNamespace") }
        .getOrNull() ?: return
    if (getNamespace.invoke(android) == null) {
        runCatching {
            android.javaClass
                .getMethod("setNamespace", String::class.java)
                .invoke(android, project.group.toString())
        }
    }
}

subprojects {
    val sub = this
    // evaluationDependsOn(":app") above can already have evaluated a subproject,
    // and afterEvaluate on an evaluated project throws — so apply directly then.
    if (sub.state.executed) setNamespaceIfMissing(sub) else sub.afterEvaluate { setNamespaceIfMissing(sub) }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
