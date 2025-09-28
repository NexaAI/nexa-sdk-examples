# Nexa AI Android Tutorial

## Overview

This is a comprehensive Android tutorial project demonstrating how to use the Nexa AI SDK to run AI models on Android devices. The project includes complete functionality for model downloading, loading, text generation, and visual question answering.

## Features

- **Model Download Management**: Download AI models from HuggingFace and other sources
- **Multi-Model Support**: LLM (Large Language Models) and VLM (Vision-Language Models)
- **Real-time Chat**: Streaming generation based on Kotlin Flow
- **Visual Question Answering**: Support for image input and visual understanding
- **Model Configuration**: Flexible model parameter configuration
- **Local Storage**: Model file caching and management

## Supported Models

### LLM Models
- **Qwen3-0.6B-Q8_0**: Lightweight Chinese dialogue model
- **Qwen3-1.8B-Q8_0**: Medium-scale Chinese dialogue model
- **Qwen3-4B-Q8_0**: Large-scale Chinese dialogue model

### VLM Models
- **SmolVLM-256M-Instruct-Q8_0**: Lightweight vision-language model
- **SmolVLM-256M-Instruct-f16**: High-quality vision-language model

## Quick Start

### 1. Requirements

- Android Studio Arctic Fox or higher
- Android SDK 27 or higher
- Kotlin 1.9.23 or higher

### 2. Project Setup

Ensure Maven Central repository is configured in `android/settings.gradle.kts`:

```kotlin
dependencyResolutionManagement {
    repositories {
        google()
        mavenCentral()
    }
}
```

### 3. Dependencies

The project uses Nexa AI SDK from Maven Central in `android/app/build.gradle.kts`:

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
2. Select or capture an image
3. Enter a question about the image
4. Click "Send" to get visual analysis

## Project Structure

```
android-tutorial/
├── app/
│   ├── src/main/
│   │   ├── java/com/nexa/demo/
│   │   │   ├── MainActivity.kt          # Main activity
│   │   │   ├── bean/
│   │   │   │   ├── ModelData.kt         # Model data structure
│   │   │   │   └── DownloadableFile.kt  # Downloadable file structure
│   │   │   ├── FileConfig.kt            # File configuration
│   │   │   └── GenerationConfigSample.kt # Generation config sample
│   │   ├── assets/
│   │   │   ├── model_list.json          # Model list configuration
│   │   │   ├── model_list_local.json    # Local model configuration
│   │   │   └── model_list_all.json      # Complete model configuration
│   │   └── res/                         # Resource files
│   └── build.gradle.kts                 # App-level build configuration
├── build.gradle.kts                     # Project-level build configuration
└── README.md                           # Project documentation
```

## Core Code Examples

### LLM Model Initialization

```kotlin
// Initialize LLM model
val llm = LlmWrapper.builder()
    .llmCreateInput(LlmCreateInput(
        model_path = modelPath,
        tokenizer_path = tokenizerPath,
        config = ModelConfig(
            nCtx = 1024,
            max_tokens = 2048,
            nThreads = 4,
            nThreadsBatch = 4,
            nBatch = 1,
            nUBatch = 1,
            nSeqMax = 1
        ),
        plugin_id = "llama_cpp"
    ))
    .build()
    .getOrThrow()
```

### VLM Model Initialization

```kotlin
// Initialize VLM model
val vlm = VlmWrapper.builder()
    .vlmCreateInput(VlmCreateInput(
        model_path = modelPath,
        mmproj_path = mmprojPath,
        tokenizer_path = null,
        config = ModelConfig(
            nCtx = 1024,
            max_tokens = 2048,
            nThreads = 4,
            nThreadsBatch = 4,
            nBatch = 1,
            nUBatch = 1,
            nSeqMax = 1
        ),
        plugin_id = "llama_cpp"
    ))
    .build()
    .getOrThrow()
```

### LLM Text Generation

```kotlin
// Generate text with LLM
llm.generateStreamFlow(prompt, GenerationConfig(
    maxTokens = 128,
    stopWords = arrayOf("</s>", "<|im_end|>")
)).collect { result ->
    when (result) {
        is LlmStreamResult.Token -> {
            // Handle generated token
            appendText(result.text)
        }
        is LlmStreamResult.Completed -> {
            // Generation completed
            Log.d("LLM", "Generation completed")
        }
        is LlmStreamResult.Error -> {
            // Handle error
            Log.e("LLM", "Generation error", result.throwable)
        }
    }
}
```

### VLM Visual Question Answering

```kotlin
// Create VLM chat message with image
val vlmMessage = VlmChatMessage(
    role = "user",
    contents = listOf(
        VlmContent(type = "text", text = question),
        VlmContent(type = "image", text = imagePath)
    )
)

// Generate response with VLM
vlm.generateStreamFlow(formattedPrompt, GenerationConfig(
    maxTokens = 32
)).collect { result ->
    when (result) {
        is LlmStreamResult.Token -> {
            appendText(result.text)
        }
        is LlmStreamResult.Completed -> {
            Log.d("VLM", "Generation completed")
        }
        is LlmStreamResult.Error -> {
            Log.e("VLM", "Generation error", result.throwable)
        }
    }
}
```

### Model Download

```kotlin
// Download model files using OkDownload
val downloadTask = DownloadTask.Builder(modelUrl, downloadDir)
    .setFilename(filename)
    .setPassIfAlreadyCompleted(true)
    .build()

downloadTask.enqueue(listener)
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
GenerationConfig(
    maxTokens = 128,                    // Maximum generation tokens
    stopWords = arrayOf("</s>"),        // Stop words
    samplerConfig = SamplerConfig(
        temperature = 0.7f,             // Temperature parameter
        topP = 0.9f,                    // Top-p sampling
        repetitionPenalty = 1.1f       // Repetition penalty
    )
)
```

## Best Practices

### 1. Memory Management

```kotlin
// Release model resources promptly
try {
    val llm = LlmWrapper.builder()...
    // Use model...
} finally {
    llm?.close()
}
```

### 2. Error Handling

```kotlin
// Use Result for initialization errors
val result = LlmWrapper.builder()
    .llmCreateInput(input)
    .build()

result.fold(
    onSuccess = { llm ->
        // Initialization successful
        Log.d("LLM", "Model loaded successfully")
    },
    onFailure = { error ->
        // Handle initialization failure
        Log.e("LLM", "Failed to load model", error)
    }
)
```

### 3. Async Operations

```kotlin
// Perform model operations on background thread
lifecycleScope.launch(Dispatchers.IO) {
    val result = llm.generateStreamFlow(prompt, config)
        .collect { streamResult ->
            // Switch to main thread for UI updates
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
    verbose = true,
    // Other parameters...
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

- [Nexa AI SDK Documentation](./android/README.md)
- [Project Source Code](https://github.com/nfl-nexa/nexa-sdk)
- [Issue Tracker](https://github.com/nfl-nexa/nexa-sdk/issues)