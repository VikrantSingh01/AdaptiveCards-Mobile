pluginManagement {
    repositories {
        google()
        mavenCentral()
        gradlePluginPortal()
    }
}

dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        google()
        mavenCentral()
    }
}

rootProject.name = "AdaptiveCards-Android"

include(":ac-core")
include(":ac-rendering")
include(":ac-inputs")
include(":ac-actions")
include(":ac-host-config")
include(":ac-accessibility")
include(":ac-templating")
