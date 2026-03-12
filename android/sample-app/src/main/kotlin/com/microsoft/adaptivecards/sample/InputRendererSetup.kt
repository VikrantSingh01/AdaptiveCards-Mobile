package com.microsoft.adaptivecards.sample

import com.microsoft.adaptivecards.core.models.*
import com.microsoft.adaptivecards.inputs.composables.*
import com.microsoft.adaptivecards.rendering.composables.LocalCardViewModel
import com.microsoft.adaptivecards.rendering.registry.GlobalElementRendererRegistry

/**
 * Registers all ac-inputs composables into the GlobalElementRendererRegistry.
 *
 * This bridges ac-rendering (which cannot depend on ac-inputs) with the actual
 * input composables. Call once at app startup before any card is rendered.
 */
fun registerInputRenderers() {
    GlobalElementRendererRegistry.register("Input.Text") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? InputText ?: return@register
        TextInputView(input, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Number") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? InputNumber ?: return@register
        NumberInputView(input, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Date") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? InputDate ?: return@register
        DateInputView(input, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Time") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? InputTime ?: return@register
        TimeInputView(input, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Toggle") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? InputToggle ?: return@register
        ToggleInputView(input, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.ChoiceSet") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? InputChoiceSet ?: return@register
        ChoiceSetInputView(input, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.DataGrid") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? InputDataGrid ?: return@register
        DataGridInputView(input, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Rating") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        val input = element as? RatingInput ?: return@register
        RatingInputView(input, vm, modifier)
    }
}
