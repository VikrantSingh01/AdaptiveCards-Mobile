// Shared Maven publishing configuration for all library modules.
// Apply in each module's build.gradle.kts:
//   apply(from = "$rootDir/publishing.gradle.kts")

apply(plugin = "maven-publish")

val sdkVersion = findProperty("version")?.toString() ?: "2.0.0-SNAPSHOT"
val sdkGroup = "com.microsoft.adaptivecards"

configure<PublishingExtension> {
    publications {
        create<MavenPublication>("release") {
            groupId = sdkGroup
            version = sdkVersion
            // artifactId is set per-module via the project name (e.g., "ac-core")
            artifactId = project.name

            afterEvaluate {
                from(components.findByName("release") ?: components["java"])
            }

            pom {
                name.set("Adaptive Cards Mobile SDK - ${project.name}")
                description.set("Cross-platform Adaptive Cards v1.6 rendering library for Android")
                url.set("https://github.com/AzureAD/AdaptiveCards-Mobile")

                licenses {
                    license {
                        name.set("MIT License")
                        url.set("https://opensource.org/licenses/MIT")
                    }
                }

                developers {
                    developer {
                        id.set("AzureAD")
                        name.set("Microsoft")
                        email.set("AzureAD@microsoft.com")
                    }
                }

                scm {
                    connection.set("scm:git:git://github.com/AzureAD/AdaptiveCards-Mobile.git")
                    developerConnection.set("scm:git:ssh://github.com/AzureAD/AdaptiveCards-Mobile.git")
                    url.set("https://github.com/AzureAD/AdaptiveCards-Mobile")
                }
            }
        }
    }

    repositories {
        maven {
            name = "local"
            url = uri(layout.buildDirectory.dir("repo"))
        }
        // Maven Central via Sonatype OSSRH
        maven {
            name = "ossrh"
            url = uri(
                if (sdkVersion.endsWith("-SNAPSHOT"))
                    "https://oss.sonatype.org/content/repositories/snapshots/"
                else
                    "https://oss.sonatype.org/service/local/staging/deploy/maven2/"
            )
            credentials {
                username = findProperty("ossrhUsername")?.toString() ?: System.getenv("OSSRH_USERNAME")
                password = findProperty("ossrhPassword")?.toString() ?: System.getenv("OSSRH_PASSWORD")
            }
        }
    }
}
