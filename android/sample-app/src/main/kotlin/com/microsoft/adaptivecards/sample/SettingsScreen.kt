package com.microsoft.adaptivecards.sample

import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun SettingsScreen(settingsState: SettingsState) {
    Scaffold(
        topBar = {
            TopAppBar(title = { Text("Settings") })
        }
    ) { padding ->
        Column(
            modifier = Modifier
                .padding(padding)
                .fillMaxSize()
        ) {
            // Appearance section
            SettingsSection("Appearance") {
                SettingsDropdown(
                    label = "Theme",
                    value = settingsState.theme,
                    onValueChange = { settingsState.theme = it },
                    options = SettingsState.Theme.values().toList()
                )

                SettingsSlider(
                    label = "Font Scale",
                    value = settingsState.fontScale,
                    onValueChange = { settingsState.fontScale = it },
                    valueRange = 0.8f..1.5f,
                    steps = 6,
                    valueLabel = { "${(it * 100).toInt()}%" }
                )
            }

            Divider()

            // Accessibility section
            SettingsSection("Accessibility") {
                SettingsSwitch(
                    label = "Enhanced Accessibility",
                    checked = settingsState.enableAccessibility,
                    onCheckedChange = { settingsState.enableAccessibility = it },
                    description = "Enable enhanced screen reader support"
                )
            }

            Divider()

            // Developer section
            SettingsSection("Developer") {
                SettingsSwitch(
                    label = "Performance Metrics",
                    checked = settingsState.enablePerformanceMetrics,
                    onCheckedChange = { settingsState.enablePerformanceMetrics = it },
                    description = "Show parse and render time metrics"
                )
            }

            Divider()

            // About section
            SettingsSection("About") {
                SettingsItem(label = "SDK Version", value = "1.0.0")
                SettingsItem(label = "Build", value = "1")
                
                TextButton(
                    onClick = { /* Open docs */ },
                    modifier = Modifier.fillMaxWidth()
                ) {
                    Text("View Documentation")
                }
            }

            Divider()

            // Reset section
            Column(modifier = Modifier.padding(16.dp)) {
                Button(
                    onClick = {
                        settingsState.theme = SettingsState.Theme.SYSTEM
                        settingsState.fontScale = 1.0f
                        settingsState.enableAccessibility = true
                        settingsState.enablePerformanceMetrics = false
                    },
                    modifier = Modifier.fillMaxWidth(),
                    colors = ButtonDefaults.buttonColors(
                        containerColor = MaterialTheme.colorScheme.error
                    )
                ) {
                    Text("Reset to Defaults")
                }
            }
        }
    }
}

@Composable
fun SettingsSection(
    title: String,
    content: @Composable ColumnScope.() -> Unit
) {
    Column(modifier = Modifier.padding(16.dp)) {
        Text(
            title,
            style = MaterialTheme.typography.titleMedium,
            color = MaterialTheme.colorScheme.primary,
            modifier = Modifier.padding(bottom = 8.dp)
        )
        content()
    }
}

@Composable
fun SettingsSwitch(
    label: String,
    checked: Boolean,
    onCheckedChange: (Boolean) -> Unit,
    description: String? = null
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Column(modifier = Modifier.weight(1f)) {
            Text(label, style = MaterialTheme.typography.bodyLarge)
            if (description != null) {
                Text(
                    description,
                    style = MaterialTheme.typography.bodySmall,
                    color = MaterialTheme.colorScheme.onSurfaceVariant
                )
            }
        }
        Switch(checked = checked, onCheckedChange = onCheckedChange)
    }
}

@Composable
fun <T> SettingsDropdown(
    label: String,
    value: T,
    onValueChange: (T) -> Unit,
    options: List<T>
) {
    var expanded by remember { mutableStateOf(false) }
    
    Column(modifier = Modifier.fillMaxWidth()) {
        Text(label, style = MaterialTheme.typography.bodyLarge)
        Box {
            OutlinedButton(
                onClick = { expanded = true },
                modifier = Modifier.fillMaxWidth()
            ) {
                Text(value.toString())
            }
            DropdownMenu(
                expanded = expanded,
                onDismissRequest = { expanded = false }
            ) {
                options.forEach { option ->
                    DropdownMenuItem(
                        text = { Text(option.toString()) },
                        onClick = {
                            onValueChange(option)
                            expanded = false
                        }
                    )
                }
            }
        }
    }
}

@Composable
fun SettingsSlider(
    label: String,
    value: Float,
    onValueChange: (Float) -> Unit,
    valueRange: ClosedFloatingPointRange<Float>,
    steps: Int = 0,
    valueLabel: (Float) -> String
) {
    Column(modifier = Modifier.fillMaxWidth()) {
        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.SpaceBetween
        ) {
            Text(label, style = MaterialTheme.typography.bodyLarge)
            Text(
                valueLabel(value),
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
        }
        Slider(
            value = value,
            onValueChange = onValueChange,
            valueRange = valueRange,
            steps = steps
        )
    }
}

@Composable
fun SettingsItem(label: String, value: String) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(vertical = 8.dp),
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(label, style = MaterialTheme.typography.bodyLarge)
        Text(
            value,
            style = MaterialTheme.typography.bodyMedium,
            color = MaterialTheme.colorScheme.onSurfaceVariant
        )
    }
}
