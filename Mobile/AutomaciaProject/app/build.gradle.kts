plugins {
    alias(libs.plugins.android.application)
    alias(libs.plugins.google.services)

}

android {
    namespace = "com.automacia.mobile"
    compileSdk = 35

    defaultConfig {
        applicationId = "com.automacia.mobile"
        minSdk = 24
        targetSdk = 35
        versionCode = 1
        versionName = "1.0"

        testInstrumentationRunner = "androidx.test.runner.AndroidJUnitRunner"
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
        sourceCompatibility = JavaVersion.VERSION_11
        targetCompatibility = JavaVersion.VERSION_11
    }

    buildFeatures {
        viewBinding = true
        dataBinding = true
    }

    packaging {
        resources {
            excludes.addAll(
                listOf(
                    "META-INF/NOTICE.md",
                    "META-INF/NOTICE",
                    "META-INF/NOTICE.txt",
                    "META-INF/LICENSE",
                    "META-INF/LICENSE.txt",
                    "META-INF/LICENSE.md",
                    "META-INF/DEPENDENCIES",
                    "META-INF/DEPENDENCIES.txt"
                )
            )
        }
    }
}

dependencies {

    implementation(libs.appcompat)
    implementation(libs.material)
    implementation(libs.activity)
    implementation(libs.constraintlayout)
    implementation(libs.annotation)
    implementation(libs.lifecycle.livedata.ktx)
    implementation(libs.lifecycle.viewmodel.ktx)
    implementation(libs.coordinatorlayout)
    implementation(libs.swiperefreshlayout)
    implementation(libs.circleimageview)
    implementation(libs.nafisbottomnav)
    implementation(libs.socket.io.client)
    implementation(libs.net.jtds)
    implementation(libs.android.mail)
    implementation(libs.android.activation)
    implementation(libs.kotlin.stdlib.jdk7)
    implementation(libs.firebase.auth)
    implementation(libs.firebase.bom)
    testImplementation(libs.junit)
    androidTestImplementation(libs.ext.junit)
    androidTestImplementation(libs.espresso.core)
}