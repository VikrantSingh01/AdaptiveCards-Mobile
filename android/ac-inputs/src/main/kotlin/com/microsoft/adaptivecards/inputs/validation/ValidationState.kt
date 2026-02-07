package com.microsoft.adaptivecards.inputs.validation

import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * Validation state for tracking errors
 */
class ValidationState {
    private val _errors = MutableStateFlow<Map<String, String>>(emptyMap())
    val errors: StateFlow<Map<String, String>> = _errors.asStateFlow()
    
    fun setError(id: String, error: String?) {
        _errors.value = _errors.value.toMutableMap().apply {
            if (error != null) {
                put(id, error)
            } else {
                remove(id)
            }
        }
    }
    
    fun getError(id: String): String? {
        return _errors.value[id]
    }
    
    fun clearErrors() {
        _errors.value = emptyMap()
    }
    
    fun hasErrors(): Boolean {
        return _errors.value.isNotEmpty()
    }
}
