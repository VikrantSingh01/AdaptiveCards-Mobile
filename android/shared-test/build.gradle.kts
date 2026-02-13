plugins {
    alias(libs.plugins.android.library)
    alias(libs.plugins.kotlin.android)
    alias(libs.plugins.compose.compiler)
    alias(libs.plugins.kotlin.serialization)
}

android {
    namespace = "com.microsoft.adaptivecards.test"
    compileSdk = 34

    defaultConfig {
        minSdk = 26
        targetSdk = 34

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
        testInstrumentationRunnerArguments["listener"] =
            "com.microsoft.adaptivecards.test.utils.ScreenshotTestRunListener"

        consumerProguardFiles("consumer-rules.pro")
    }

    buildFeatures {
        compose = true
    }

    buildTypes {
        release {
            isMinifyEnabled = false
            proguardFiles(
                getDefaultProguardFile("proguard-android-optimize.txt"),
                "proguard-rules.pro"
            )
        }
    }

    compileOptions {
        sourceCompatibility = JavaVersion.VERSION_17
        targetCompatibility = JavaVersion.VERSION_17
    }

    kotlinOptions {
        jvmTarget = "17"
    }

    sourceSets {
        getByName("androidTest") {
            assets.srcDirs("src/androidTest/assets", "../../shared/test-cards")
        }
    }

    packaging {
        resources {
            excludes += "/META-INF/{AL2.0,LGPL2.1}"
        }
    }
}

dependencies {
    // Adaptive Cards SDK modules under test
    implementation(project(":ac-core"))
    implementation(project(":ac-rendering"))
    implementation(project(":ac-inputs"))
    implementation(project(":ac-actions"))
    implementation(project(":ac-accessibility"))
    implementation(project(":ac-templating"))
    implementation(project(":ac-markdown"))
    implementation(project(":ac-charts"))
    implementation(project(":ac-fluent-ui"))
    implementation(project(":ac-copilot-extensions"))
    implementation(project(":ac-teams"))
    implementation(project(":ac-host-config"))

    // Kotlin
    implementation(libs.kotlin.stdlib)
    implementation(libs.kotlinx.serialization.json)

    // Compose
    implementation(platform(libs.compose.bom))
    implementation(libs.compose.ui)
    implementation(libs.compose.ui.graphics)
    implementation(libs.compose.ui.tooling.preview)
    implementation(libs.compose.material3)
    implementation(libs.compose.foundation)
    implementation(libs.compose.runtime)
    implementation("androidx.compose.material:material-icons-extended")
    debugImplementation(libs.compose.ui.tooling)

    // Lifecycle
    implementation(libs.lifecycle.viewmodel.compose)
    implementation(libs.lifecycle.runtime.compose)

    // Image Loading
    implementation(libs.coil.compose)

    // AndroidX Core
    implementation(libs.androidx.core.ktx)

    // Android Instrumented Testing
    androidTestImplementation(libs.androidx.test.core)
    androidTestImplementation(libs.androidx.test.runner)
    androidTestImplementation(libs.androidx.test.rules)
    androidTestImplementation(libs.androidx.test.ext.junit)
    androidTestImplementation(libs.espresso.core)
    androidTestImplementation(platform(libs.compose.bom))
    androidTestImplementation(libs.compose.ui.test.junit4)
    debugImplementation(libs.compose.ui.test.manifest)

    // Benchmarking
    androidTestImplementation(libs.androidx.benchmark.junit4)

    // Coroutines Testing
    androidTestImplementation(libs.kotlinx.coroutines.test)

    // JUnit 4 for instrumented tests
    androidTestImplementation(libs.junit4)
}
