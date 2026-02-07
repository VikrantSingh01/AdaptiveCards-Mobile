package com.microsoft.adaptivecards.teams

import android.net.Uri

class DeepLinkHandler {
    
    fun parseDeepLink(uri: Uri): DeepLinkInfo? {
        if (uri.scheme != "msteams") return null
        
        val parameters = mutableMapOf<String, String>()
        uri.queryParameterNames.forEach { name ->
            uri.getQueryParameter(name)?.let { value ->
                parameters[name] = value
            }
        }
        
        return DeepLinkInfo(
            scheme = uri.scheme ?: "",
            host = uri.host ?: "",
            path = uri.path ?: "",
            parameters = parameters
        )
    }
    
    fun handleNavigation(deepLink: DeepLinkInfo) {
        // Host app implements actual navigation
    }
}
