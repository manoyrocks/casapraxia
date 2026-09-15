package com.praxia.child

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.material3.windowsizeclass.ExperimentalMaterial3WindowSizeClassApi
import androidx.compose.material3.windowsizeclass.WindowWidthSizeClass
import androidx.compose.material3.windowsizeclass.calculateWindowSizeClass
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.praxia.child.ui.theme.PraxiaChildTheme
import com.praxia.child.ui.screens.PraxiaApp
import com.praxia.child.storage.TrialDatabase
import com.praxia.child.service.LocalTrialServiceMock
import com.praxia.child.service.TrialServiceGRPCClientBuilder
import com.praxia.child.ui.viewmodel.PraxiaViewModelFactory

class MainActivity : ComponentActivity() {
    private lateinit var database: TrialDatabase
    private lateinit var viewModelFactory: PraxiaViewModelFactory

    @OptIn(ExperimentalMaterial3WindowSizeClassApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize dependencies
        database = TrialDatabase.getInstance(this)

        // Use environment-based service selection
        val trialService = if (BuildConfig.DEBUG) {
            LocalTrialServiceMock()  // Use mock in debug builds
        } else {
            TrialServiceGRPCClientBuilder.build()  // Use gRPC in release builds
        }

        viewModelFactory = PraxiaViewModelFactory(trialService, database)

        setContent {
            PraxiaChildTheme {
                // A surface container using the 'background' color from the theme
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    val windowSizeClass = calculateWindowSizeClass(activity = this@MainActivity)

                    PraxiaApp(
                        windowWidthSizeClass = windowSizeClass.widthSizeClass,
                        viewModelFactory = viewModelFactory
                    )
                }
            }
        }
    }
}
