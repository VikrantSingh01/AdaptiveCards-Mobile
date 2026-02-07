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
include(":ac-markdown")
include(":ac-charts")
include(":ac-fluent-ui")
include(":ac-copilot-extensions")
include(":ac-teams")
include(":sample-app")
