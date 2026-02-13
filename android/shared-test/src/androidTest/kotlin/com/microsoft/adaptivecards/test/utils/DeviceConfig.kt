package com.microsoft.adaptivecards.test.utils

/**
 * Represents a device form factor configuration for visual regression tests.
 *
 * @property name Human-readable label (e.g., "Phone Portrait").
 * @property widthDp Viewport width in dp.
 * @property heightDp Viewport height in dp.
 * @property densityDpi Screen density in dpi.
 */
data class DeviceConfig(
    val name: String,
    val widthDp: Int,
    val heightDp: Int,
    val densityDpi: Int = 420
) {
    /** A filesystem-safe key derived from the name. */
    val key: String get() = name.replace("\\s+".toRegex(), "_").lowercase()

    companion object {
        // -- Standard device configurations --

        val PHONE_PORTRAIT = DeviceConfig(
            name = "Phone Portrait",
            widthDp = 360,
            heightDp = 640,
            densityDpi = 420
        )

        val PHONE_LANDSCAPE = DeviceConfig(
            name = "Phone Landscape",
            widthDp = 640,
            heightDp = 360,
            densityDpi = 420
        )

        val TABLET_PORTRAIT = DeviceConfig(
            name = "Tablet Portrait",
            widthDp = 600,
            heightDp = 960,
            densityDpi = 320
        )

        val TABLET_LANDSCAPE = DeviceConfig(
            name = "Tablet Landscape",
            widthDp = 960,
            heightDp = 600,
            densityDpi = 320
        )

        val FOLDABLE_UNFOLDED = DeviceConfig(
            name = "Foldable Unfolded",
            widthDp = 840,
            heightDp = 900,
            densityDpi = 420
        )

        val FOLDABLE_FOLDED = DeviceConfig(
            name = "Foldable Folded",
            widthDp = 360,
            heightDp = 748,
            densityDpi = 420
        )

        val SMALL_PHONE = DeviceConfig(
            name = "Small Phone",
            widthDp = 320,
            heightDp = 568,
            densityDpi = 320
        )

        /** All standard configurations used in the full visual regression suite. */
        val ALL = listOf(
            PHONE_PORTRAIT,
            PHONE_LANDSCAPE,
            TABLET_PORTRAIT,
            TABLET_LANDSCAPE,
            FOLDABLE_UNFOLDED,
            FOLDABLE_FOLDED,
            SMALL_PHONE
        )

        /** Minimal set for quick smoke tests. */
        val SMOKE = listOf(
            PHONE_PORTRAIT,
            TABLET_PORTRAIT
        )
    }
}

/**
 * Theme configuration used in visual regression tests.
 */
enum class ThemeConfig(val key: String) {
    LIGHT("light"),
    DARK("dark");

    companion object {
        val ALL = values().toList()
    }
}

/**
 * Font scale configuration for accessibility testing.
 */
enum class FontScaleConfig(val scale: Float, val key: String) {
    DEFAULT(1.0f, "font_1x"),
    LARGE(1.3f, "font_1.3x"),
    EXTRA_LARGE(1.5f, "font_1.5x"),
    MAXIMUM(2.0f, "font_2x");

    companion object {
        val ALL = values().toList()
        val ESSENTIAL = listOf(DEFAULT, LARGE)
    }
}

/**
 * Locale/layout direction configuration.
 */
enum class LocaleConfig(val locale: String, val isRtl: Boolean, val key: String) {
    ENGLISH("en", false, "en_ltr"),
    ARABIC("ar", true, "ar_rtl"),
    HEBREW("he", true, "he_rtl"),
    JAPANESE("ja", false, "ja_ltr"),
    GERMAN("de", false, "de_ltr");

    companion object {
        val ALL = values().toList()
        val ESSENTIAL = listOf(ENGLISH, ARABIC)
    }
}

/**
 * A complete test configuration combining device, theme, font scale, and locale.
 */
data class TestConfiguration(
    val device: DeviceConfig,
    val theme: ThemeConfig,
    val fontScale: FontScaleConfig = FontScaleConfig.DEFAULT,
    val locale: LocaleConfig = LocaleConfig.ENGLISH
) {
    /** Unique key for identifying this configuration in file names and reports. */
    val configKey: String get() = "${device.key}_${theme.key}_${fontScale.key}_${locale.key}"

    /** Human-readable description. */
    val description: String
        get() = "${device.name} / ${theme.name} / ${fontScale.name} (${fontScale.scale}x) / ${locale.locale}"

    companion object {
        /**
         * Generate the full matrix of test configurations.
         * This produces device x theme x fontScale x locale combinations.
         */
        fun fullMatrix(
            devices: List<DeviceConfig> = DeviceConfig.ALL,
            themes: List<ThemeConfig> = ThemeConfig.ALL,
            fontScales: List<FontScaleConfig> = FontScaleConfig.ALL,
            locales: List<LocaleConfig> = LocaleConfig.ALL
        ): List<TestConfiguration> {
            return devices.flatMap { device ->
                themes.flatMap { theme ->
                    fontScales.flatMap { fontScale ->
                        locales.map { locale ->
                            TestConfiguration(device, theme, fontScale, locale)
                        }
                    }
                }
            }
        }

        /** Minimal configuration set for CI quick checks. */
        fun smokeTestMatrix(): List<TestConfiguration> {
            return fullMatrix(
                devices = DeviceConfig.SMOKE,
                themes = ThemeConfig.ALL,
                fontScales = FontScaleConfig.ESSENTIAL,
                locales = LocaleConfig.ESSENTIAL
            )
        }

        /** Core configurations covering the most critical scenarios. */
        fun coreMatrix(): List<TestConfiguration> {
            return listOf(
                // Phone light/dark at default font
                TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.LIGHT),
                TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.DARK),
                // Tablet
                TestConfiguration(DeviceConfig.TABLET_PORTRAIT, ThemeConfig.LIGHT),
                // Foldable
                TestConfiguration(DeviceConfig.FOLDABLE_UNFOLDED, ThemeConfig.LIGHT),
                // Large font
                TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.LIGHT, FontScaleConfig.LARGE),
                // RTL
                TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.LIGHT, locale = LocaleConfig.ARABIC),
                // Maximum font + dark
                TestConfiguration(DeviceConfig.PHONE_PORTRAIT, ThemeConfig.DARK, FontScaleConfig.MAXIMUM),
                // Small phone
                TestConfiguration(DeviceConfig.SMALL_PHONE, ThemeConfig.LIGHT)
            )
        }
    }
}
