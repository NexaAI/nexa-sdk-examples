# Nexa AI Android Tutorial

## Overview

This is an Android tutorial project demonstrating how to use the Nexa AI SDK to run AI models on Android devices. The project includes model downloading, loading, text generation, and visual question answering functionality.

## Features

- Model download management
- Support for LLM and VLM models
- Real-time chat conversation
- Visual question answering
- Model parameter configuration
- Local file caching

## Supported Models

### LLM Models
- Qwen3-0.6B-Q8_0: Lightweight Chinese dialogue model
- Qwen3-1.8B-Q8_0: Medium-scale Chinese dialogue model
- Qwen3-4B-Q8_0: Large-scale Chinese dialogue model

### VLM Models
- SmolVLM-256M-Instruct-Q8_0: Lightweight vision-language model
- SmolVLM-256M-Instruct-f16: High-quality vision-language model

## Quick Start

### 1. Requirements

- Android Studio Arctic Fox or higher
- Android SDK 27 or higher
- Kotlin 1.9.23 or higher

### 2. Project Setup

Configure Maven Central repository in `settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 3. Dependencies

The project uses Nexa AI SDK from Maven Central in `app/build.gradle.kts`:

```kotlin
dependencies {
    implementation("io.github.nfl-nexa:core:0.0.2")
    // Other dependencies...
}
```

### 4. Running the Project

1. Clone or download the project
2. Open the project in Android Studio
3. Connect an Android device or start an emulator
4. Click the run button

## Usage Guide

### Model Download

1. Launch the app and select a model to download
2. Click the "Download" button to start downloading
3. The model will be automatically loaded after download completion

### LLM Chat

1. Ensure an LLM model is loaded
2. Enter your question in the input field
3. Click "Send" to start the conversation
4. The model will stream responses in real-time

### VLM Visual Q&A

1. Ensure a VLM model is loaded
2. Enter a question in the input field
3. Click "Send" to get the response
4. The model will process the text input

## Project Structure

```
nexa-sdk-examples/
├── android/
│   ├── app/
│   │   ├── src/main/
│   │   │   ├── java/com/nexa/demo/
│   │   │   │   ├── MainActivity.kt          # Main activity
│   │   │   │   ├── bean/
│   │   │   │   │   ├── ModelData.kt         # Model data structure
│   │   │   │   │   └── DownloadableFile.kt  # Downloadable file structure
│   │   │   │   ├── FileConfig.kt            # File configuration
│   │   │   │   └── GenerationConfigSample.kt # Generation config sample
│   │   │   ├── assets/
│   │   │   │   ├── model_list.json          # Model list configuration
│   │   │   │   ├── model_list_local.json    # Local model configuration
│   │   │   │   └── model_list_all.json      # Complete model configuration
│   │   │   └── res/                         # Resource files
│   │   └── build.gradle.kts                 # App-level build configuration
│   ├── build.gradle.kts                     # Project-level build configuration
│   ├── gradle/                              # Gradle wrapper and dependencies
│   ├── gradlew                              # Gradle wrapper script
│   ├── gradle.properties                    # Gradle properties
│   └── settings.gradle.kts                  # Project settings
└── README.md                               # Project documentation
```

## Step-by-Step Implementation

### Step 0: Preparing to Download the Model File

```kotlin
// Parse model list from assets
val baseJson = assets.open("model_list.json").bufferedReader().use { it.readText() }
modelList = Json.decodeFromString<List<ModelData>>(baseJson)

// Set download directory
downloadDir = modelList.first().modelDir(this)
if (!downloadDir.exists()) {
    downloadDir.mkdirs()
}
```

### Step 1: Initialize Nexa SDK Environment

```kotlin
// Initialize Nexa SDK environment
private fun initNexaSdk(nativeLibPath: String) {
    Os.setenv("ADSP_LIBRARY_PATH", nativeLibPath, true)
    Os.setenv("LD_LIBRARY_PATH", nativeLibPath, true)
    Os.setenv("NEXA_PLUGIN_PATH", nativeLibPath, true)
}

// Get native library path and initialize
val nativeLibPath: String = applicationContext.applicationInfo.nativeLibraryDir
initNexaSdk(nativeLibPath)
```

### Step 2: Add System Prompt (Optional)

```kotlin
// Add system prompt for LLM
private fun addSystemPrompt(sysPrompt: String) {
    llmSystemPrompt = ChatMessage("system", sysPrompt)
    chatList.add(llmSystemPrompt)
    
    // Add system prompt for VLM
    vlmSystemPrompty = VlmChatMessage(
        role = "system", 
        contents = listOf(VlmContent("text", sysPrompt))
    )
    vlmChatList.add(vlmSystemPrompty)
}
```

### Step 3: Download Model

```kotlin
// Download model files using OkDownload
val downloadTask = DownloadTask.Builder(modelUrl, downloadDir)
    .setFilename(filename)
    .setPassIfAlreadyCompleted(true)
    .build()

downloadTask.enqueue(listener)
```

### Step 4: Load Model

```kotlin
// Load LLM Model
LlmWrapper.builder().llmCreateInput(
    LlmCreateInput(
        model_path = selectModelData.modelFile(this@MainActivity)!!.absolutePath,
        tokenizer_path = selectModelData.tokenFile(this@MainActivity)?.absolutePath,
        config = ModelConfig(
            nCtx = 1024,
            max_tokens = 2048,
            nThreads = 4,
            nThreadsBatch = 4,
            nBatch = 1,
            nUBatch = 1,
            nSeqMax = 1
        ),
        plugin_id = pluginId
    )
).build().onSuccess {
    llmWrapper = it
    // Model loaded successfully
}.onFailure {
    // Handle loading failure
    Log.e("LLM", "Model loading failed", it)
}

// Load VLM Model
VlmWrapper.builder().vlmCreateInput(
    VlmCreateInput(
        model_path = selectModelData.modelFile(this@MainActivity)!!.absolutePath,
        tokenizer_path = null,
        mmproj_path = selectModelData.mmprojTokenFile(this@MainActivity)?.absolutePath,
        config = ModelConfig(
            nCtx = 1024,
            max_tokens = 2048,
            nThreads = 4,
            nThreadsBatch = 4,
            nBatch = 1,
            nUBatch = 1,
            nSeqMax = 1
        ),
        plugin_id = pluginId
    )
).build().onSuccess {
    vlmWrapper = it
    // Model loaded successfully
}.onFailure {
    // Handle loading failure
    Log.e("VLM", "Model loading failed", it)
}
```

### Step 5: Send Message

**Important: You cannot directly pass text to `generateStreamFlow`. You must first use `applyChatTemplate` to convert chat messages.**

```kotlin
// Generate text with LLM
// Step 1: Add user message to chat list
chatList.add(ChatMessage("user", inputString))

// Step 2: Apply chat template to convert messages to formatted text
llmWrapper.applyChatTemplate(chatList.toTypedArray(), tools, false).onSuccess { result ->
    // Step 3: Use the formatted text for generation
    llmWrapper.generateStreamFlow(
        result.formattedText,  // This is the converted text, not the raw input
        GenerationConfigSample().toGenerationConfig(grammarString)
    ).collect { streamResult ->
        handleResult(sb, streamResult)
    }
}.onFailure {
    // Handle template application failure
    Log.e("LLM", "Template application failed", it)
}

// Generate response with VLM
// Step 1: Create and add VLM chat message
val sendMsg = VlmChatMessage(
    role = "user", 
    contents = listOf(VlmContent("text", inputString))
)
vlmChatList.add(sendMsg)

// Step 2: Apply chat template to convert VLM messages
vlmWrapper.applyChatTemplate(vlmChatList.toTypedArray(), tools, false)
    .onSuccess { result ->
        // Step 3: Use the formatted text for generation
        vlmWrapper.generateStreamFlow(
            result.formattedText,  // This is the converted text, not the raw input
            GenerationConfigSample().toGenerationConfig(grammarString)
        ).collect { streamResult ->
            handleResult(sb, streamResult)
        }
    }.onFailure {
        // Handle template application failure
        Log.e("VLM", "Template application failed", it)
    }
```

### Step 6: Others (Stop & Unload)

```kotlin
// Stop current stream generation
llmWrapper.stopStream()
// or for VLM
vlmWrapper.stopStream()

// Stop streaming and destroy model resources
llmWrapper.stopStream()
llmWrapper.destroy()

// or for VLM
vlmWrapper.stopStream()
vlmWrapper.destroy()
```

## Configuration Options

### ModelConfig

```kotlin
ModelConfig(
    nCtx = 1024,           // Context length
    max_tokens = 2048,     // Maximum generation tokens
    nThreads = 4,          // CPU threads
    nThreadsBatch = 4,     // Batch processing threads
    nBatch = 1,            // Batch size
    nUBatch = 1,           // Physical batch size
    nSeqMax = 1,           // Maximum sequences
    nGpuLayers = 0,        // GPU layers (0 for CPU only)
    config_file_path = "", // Config file path
    verbose = false        // Verbose logging
)
```

### GenerationConfig

```kotlin
// Create GenerationConfig using GenerationConfigSample
val config = GenerationConfigSample(
    maxTokens = 32,
    topK = 40,
    topP = 0.95f,
    temperature = 0.8f,
    penaltyLastN = 1.0f,
    penaltyPresent = 0.0f,
    seed = -1
).toGenerationConfig(grammarString)
```

## Best Practices

### Prompt Template Conversion

```kotlin
// ❌ Wrong: Direct text input
llm.generateStreamFlow("Hello, how are you?", config)

// ✅ Correct: Use applyChatTemplate first
chatList.add(ChatMessage("user", "Hello, how are you?"))
llmWrapper.applyChatTemplate(chatList.toTypedArray(), tools, false).onSuccess { result ->
    llm.generateStreamFlow(result.formattedText, config)
}
```

### Memory Management

```kotlin
// Stop streaming and destroy model resources
llmWrapper.stopStream()
llmWrapper.destroy()

// or for VLM
vlmWrapper.stopStream()
vlmWrapper.destroy()
```

### Error Handling

```kotlin
// Handle initialization errors
val result = LlmWrapper.builder()
    .llmCreateInput(input)
    .build()

result.onSuccess { llm ->
    // Model loaded successfully
    Log.d("LLM", "Model loaded successfully")
}.onFailure { error ->
    // Handle loading failure
    Log.e("LLM", "Model loading failed", error)
}
```

### Async Operations

```kotlin
// Perform model operations on background thread
lifecycleScope.launch(Dispatchers.IO) {
    llm.generateStreamFlow(prompt, config)
        .collect { streamResult ->
            withContext(Dispatchers.Main) {
                updateUI(streamResult)
            }
        }
}
```

## Troubleshooting

### Common Issues

1. **Model Loading Failure**
   - Check if model file path is correct
   - Verify model file integrity
   - Ensure sufficient device memory

2. **Slow Generation Speed**
   - Reduce `nCtx` and `max_tokens` parameters
   - Lower `nThreads` count
   - Ensure no other apps are consuming CPU

3. **Out of Memory**
   - Choose smaller models
   - Reduce batch size
   - Close unnecessary applications

### Debug Tips

```kotlin
// Enable verbose logging
ModelConfig(
    verbose = true
)

// Check model status
Log.d("Model", "Loaded: ${llm != null}")
Log.d("Model", "Context size: ${config.nCtx}")
```

## License

This project is licensed under the MIT License. See the LICENSE file for details.

## Contributing

Issues and Pull Requests are welcome to improve this tutorial project.

## Related Links

- [Nexa AI SDK Documentation](./README.md)
- [Project Source Code](https://github.com/nfl-nexa/nexa-sdk)
- [Issue Tracker](https://github.com/nfl-nexa/nexa-sdk/issues)