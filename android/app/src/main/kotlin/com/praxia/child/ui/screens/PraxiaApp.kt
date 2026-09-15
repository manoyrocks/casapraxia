package com.praxia.child.ui.screens

import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.material3.windowsizeclass.WindowWidthSizeClass
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.text.style.TextAlign
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.compose.runtime.livedata.observeAsState
import com.praxia.child.ui.components.*
import com.praxia.child.ui.viewmodel.SessionViewModel
import com.praxia.child.ui.viewmodel.TrialViewModel
import com.praxia.child.ui.viewmodel.PraxiaViewModelFactory
import com.praxia.child.ui.viewmodel.SessionState
import com.praxia.child.ui.viewmodel.TargetState

/**
 * Main Praxia app with responsive layout
 *
 * - Compact (<600dp): Mobile layout with navigation rail
 * - Medium (600-840dp): Tablet layout with side navigation
 * - Expanded (>840dp): Large tablet with permanent sidebar
 */
@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun PraxiaApp(
    windowWidthSizeClass: WindowWidthSizeClass,
    viewModelFactory: PraxiaViewModelFactory
) {
    var currentScreen by remember { mutableStateOf(Screen.PLAY) }
    var showParentPanel by remember { mutableStateOf(false) }

    // Initialize ViewModels
    val sessionViewModel: SessionViewModel = viewModel(factory = viewModelFactory)
    val trialViewModel: TrialViewModel = viewModel(factory = viewModelFactory)

    // Observe ViewModel state
    val sessionState by sessionViewModel.sessionState.observeAsState()
    val targetList by sessionViewModel.targetList.observeAsState(emptyList())

    // Load targets on composition
    LaunchedEffect(Unit) {
        trialViewModel.loadTargets()
    }

    // Only render layouts if we have valid state
    if (sessionState != null && targetList != null) {
        val safeTargets = targetList ?: emptyList()
        val safeSessionState = sessionState ?: SessionState(
            sessionID = "",
            childID = "",
            isActive = false,
            trialCount = 0,
            totalTrials = 0,
            elapsedSeconds = 0
        )

        when (windowWidthSizeClass) {
            WindowWidthSizeClass.Compact -> {
                // Mobile layout with bottom navigation
                MobileLayout(
                    currentScreen = currentScreen,
                    onScreenChange = { currentScreen = it },
                    onShowParentPanel = { showParentPanel = it },
                    sessionViewModel = sessionViewModel,
                    trialViewModel = trialViewModel,
                    sessionState = safeSessionState,
                    targets = safeTargets
                )
            }

            WindowWidthSizeClass.Medium -> {
                // Tablet 7" layout with collapsible sidebar
                TabletLayout(
                    currentScreen = currentScreen,
                    onScreenChange = { currentScreen = it },
                    onShowParentPanel = { showParentPanel = it },
                    sessionViewModel = sessionViewModel,
                    trialViewModel = trialViewModel,
                    sessionState = safeSessionState,
                    targets = safeTargets
                )
            }

            WindowWidthSizeClass.Expanded -> {
                // Large tablet 10"+ layout with permanent sidebar
                LargeTabletLayout(
                    currentScreen = currentScreen,
                    onScreenChange = { currentScreen = it },
                    onShowParentPanel = { showParentPanel = it },
                    sessionViewModel = sessionViewModel,
                    trialViewModel = trialViewModel,
                    sessionState = safeSessionState,
                    targets = safeTargets
                )
            }
        }

        // Parent panel overlay (mobile only)
        if (showParentPanel && windowWidthSizeClass == WindowWidthSizeClass.Compact) {
            ParentPanelOverlay(
                onDismiss = { showParentPanel = false },
                sessionState = safeSessionState
            )
        }
    }
}

// MARK: - Screen Type Enum

enum class Screen {
    PLAY, TALK, COLLECTION
}

// MARK: - Mobile Layout (Compact)

@Composable
private fun MobileLayout(
    currentScreen: Screen,
    onScreenChange: (Screen) -> Unit,
    onShowParentPanel: (Boolean) -> Unit,
    sessionViewModel: SessionViewModel,
    trialViewModel: TrialViewModel,
    sessionState: SessionState,
    targets: List<TargetState>
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Praxia") },
                actions = {
                    IconButton(onClick = { onShowParentPanel(true) }) {
                        Icon(Icons.Filled.Settings, contentDescription = "Parent Panel")
                    }
                }
            )
        },
        bottomBar = {
            NavigationBar {
                NavigationBarItem(
                    icon = { Icon(Icons.Filled.PlayArrow, contentDescription = "Play") },
                    label = { Text("Play") },
                    selected = currentScreen == Screen.PLAY,
                    onClick = { onScreenChange(Screen.PLAY) }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Filled.Mic, contentDescription = "Talk") },
                    label = { Text("Talk") },
                    selected = currentScreen == Screen.TALK,
                    onClick = { onScreenChange(Screen.TALK) }
                )
                NavigationBarItem(
                    icon = { Icon(Icons.Filled.BarChart, contentDescription = "Progress") },
                    label = { Text("Progress") },
                    selected = currentScreen == Screen.COLLECTION,
                    onClick = { onScreenChange(Screen.COLLECTION) }
                )
            }
        }
    ) { padding ->
        Box(modifier = Modifier.padding(padding)) {
            when (currentScreen) {
                Screen.PLAY -> PlaySurface(
                    targets = targets,
                    sessionState = sessionState,
                    sessionViewModel = sessionViewModel
                )

                Screen.TALK -> TalkSurface(targets = targets)
                Screen.COLLECTION -> CollectionSurface(
                    targets = targets,
                    sessionState = sessionState,
                    trialViewModel = trialViewModel
                )
            }
        }
    }
}

// MARK: - Tablet Layout (Medium)

@Composable
private fun TabletLayout(
    currentScreen: Screen,
    onScreenChange: (Screen) -> Unit,
    onShowParentPanel: (Boolean) -> Unit,
    sessionViewModel: SessionViewModel,
    trialViewModel: TrialViewModel,
    sessionState: SessionState,
    targets: List<TargetState>
) {
    var showSidebar by remember { mutableStateOf(true) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Praxia") },
                navigationIcon = {
                    IconButton(onClick = { showSidebar = !showSidebar }) {
                        Icon(Icons.Filled.Menu, contentDescription = "Menu")
                    }
                },
                actions = {
                    IconButton(onClick = { onShowParentPanel(true) }) {
                        Icon(Icons.Filled.Settings, contentDescription = "Parent Panel")
                    }
                }
            )
        }
    ) { padding ->
        Row(modifier = Modifier.padding(padding)) {
            if (showSidebar) {
                NavigationSidebar(
                    currentScreen = currentScreen,
                    onScreenChange = onScreenChange,
                    modifier = Modifier.width(240.dp)
                )
            }

            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .weight(1f)
            ) {
                when (currentScreen) {
                    Screen.PLAY -> PlaySurface(
                        targets = targets,
                        sessionState = sessionState,
                        sessionViewModel = sessionViewModel
                    )

                    Screen.TALK -> TalkSurface(targets = targets)
                    Screen.COLLECTION -> CollectionSurface(
                        targets = targets,
                        sessionState = sessionState,
                        trialViewModel = trialViewModel
                    )
                }
            }
        }
    }
}

// MARK: - Large Tablet Layout (Expanded)

@Composable
private fun LargeTabletLayout(
    currentScreen: Screen,
    onScreenChange: (Screen) -> Unit,
    onShowParentPanel: (Boolean) -> Unit,
    sessionViewModel: SessionViewModel,
    trialViewModel: TrialViewModel,
    sessionState: SessionState,
    targets: List<TargetState>
) {
    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Praxia - Speech Therapy") },
                actions = {
                    IconButton(onClick = { onShowParentPanel(true) }) {
                        Icon(Icons.Filled.Settings, contentDescription = "Parent Panel")
                    }
                }
            )
        }
    ) { padding ->
        Row(modifier = Modifier.padding(padding)) {
            // Permanent sidebar
            NavigationSidebar(
                currentScreen = currentScreen,
                onScreenChange = onScreenChange,
                modifier = Modifier
                    .width(240.dp)
                    .fillMaxHeight()
            )

            Divider(modifier = Modifier
                .fillMaxHeight()
                .width(1.dp))

            // Main content area
            Box(
                modifier = Modifier
                    .fillMaxSize()
                    .weight(1f)
            ) {
                when (currentScreen) {
                    Screen.PLAY -> PlaySurface(
                        targets = targets,
                        sessionState = sessionState,
                        sessionViewModel = sessionViewModel
                    )

                    Screen.TALK -> TalkSurface(targets = targets)
                    Screen.COLLECTION -> CollectionSurface(
                        targets = targets,
                        sessionState = sessionState,
                        trialViewModel = trialViewModel
                    )
                }
            }
        }
    }
}

// MARK: - Navigation Sidebar

@Composable
private fun NavigationSidebar(
    currentScreen: Screen,
    onScreenChange: (Screen) -> Unit,
    modifier: Modifier = Modifier
) {
    Column(
        modifier = modifier
            .background(MaterialTheme.colorScheme.surfaceVariant)
            .padding(vertical = 12.dp)
    ) {
        NavigationDrawerItem(
            label = { Text("Play") },
            icon = { Icon(Icons.Filled.PlayArrow, contentDescription = "Play") },
            selected = currentScreen == Screen.PLAY,
            onClick = { onScreenChange(Screen.PLAY) },
            modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding)
        )

        NavigationDrawerItem(
            label = { Text("Talk") },
            icon = { Icon(Icons.Filled.Mic, contentDescription = "Talk") },
            selected = currentScreen == Screen.TALK,
            onClick = { onScreenChange(Screen.TALK) },
            modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding)
        )

        NavigationDrawerItem(
            label = { Text("Progress") },
            icon = { Icon(Icons.Filled.BarChart, contentDescription = "Progress") },
            selected = currentScreen == Screen.COLLECTION,
            onClick = { onScreenChange(Screen.COLLECTION) },
            modifier = Modifier.padding(NavigationDrawerItemDefaults.ItemPadding)
        )
    }
}
