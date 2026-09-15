package com.praxia.child.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.praxia.child.trial.TrialEngine
import com.praxia.child.service.TrialServiceProtocol
import com.praxia.child.storage.TrialDatabase

/**
 * Factory for creating Praxia ViewModels with proper dependency injection.
 */
class PraxiaViewModelFactory(
    private val trialService: TrialServiceProtocol,
    private val database: TrialDatabase
) : ViewModelProvider.Factory {

    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return when (modelClass) {
            SessionViewModel::class.java -> {
                SessionViewModel(database) as T
            }
            TrialViewModel::class.java -> {
                TrialViewModel(trialService, database) as T
            }
            else -> throw IllegalArgumentException("Unknown ViewModel class: ${modelClass.name}")
        }
    }
}
