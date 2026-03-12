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
        TextInputView(element as InputText, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Number") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        NumberInputView(element as InputNumber, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Date") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        DateInputView(element as InputDate, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Time") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        TimeInputView(element as InputTime, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Toggle") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        ToggleInputView(element as InputToggle, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.ChoiceSet") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        ChoiceSetInputView(element as InputChoiceSet, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.DataGrid") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        DataGridInputView(element as InputDataGrid, vm, modifier)
    }

    GlobalElementRendererRegistry.register("Input.Rating") { element, modifier ->
        val vm = LocalCardViewModel.current ?: return@register
        RatingInputView(element as RatingInput, vm, modifier)
    }
}
