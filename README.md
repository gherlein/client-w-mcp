# GCHAI - Go Client for OpenAI API

A Go-based client for interacting with OpenAI's API, supporting model definitions, dynamic context loading, and performance metrics.

## Usage

GCHAI can be used in several modes, from interactive chat to automated performance testing.

### Command Line Options

```bash
./client [flags]

Flags:
  -model string     Path to model definition file (JSON format)
  -prompt string    Path to initial prompt file to start the conversation
  -url string       OpenAI API base URL (default: https://api.openai.com)
  -default-model    Default OpenAI model to use (default: gpt-4o-mini)
  -context, -c      Show prompts and context before sending to LLM
```

#### Flag Details

- **-model**: Specifies a JSON file containing model definition, parameters, and options.
  - Optional for interactive chat mode
  - See "Model Files" section for file format

- **-prompt**: Provides an initial prompt from a text file.
  - Optional for interactive chat mode
  - File should contain the prompt text to send to the model

- **-url**: OpenAI API base URL (default: <https://api.openai.com>)
  - Can be used to point to compatible API endpoints
  - Useful for testing or using alternative providers

- **-default-model**: Default OpenAI model to use (default: gpt-4o-mini)
  - Used when no model configuration file is specified
  - Should be a valid OpenAI model name

- **-context, -c**: Show prompts and context before sending to LLM
  - Displays the full context being sent to the model
  - Useful for debugging and understanding what the model sees

### Usage Modes

#### Interactive Chat Mode

```bash
# Basic interactive mode with default model
./client

# Using a custom model definition
./client -model mymodel.json

# Start with an initial prompt, then continue interactively
./client -model mymodel.json -prompt initial-prompt.txt
```

### Performance Metrics

Performance metrics are automatically displayed after each interaction:

```plaintext
[Performance: 123.45 tokens/sec, 150 total tokens, response time: 1.234s]
```

### Interactive Commands

While in interactive mode, the following commands are available:

- `/load <file>` - Load a file into context
- `/model <file>` - Load a model definition file
- `/template <file>` - Create a model definition template
- `/list` - List loaded files
- `/clear` - Clear context
- `/status` - Show current model and parameters

### Examples

Here are some common usage examples:

```bash
# Basic interactive chat
./client

# Using a custom model with specific parameters
./client -model qwen2.5-coder32b-basic.json

# Starting with an initial prompt
./client -model qwen2.5-coder32b-basic.json -prompt test-prompt.txt

# Show context before sending to model
./client -context -model model.json
```

### Environment Variables

The following environment variables can be used to configure the client:

- `OPENAI_API_KEY`: Your OpenAI API key (required)
- `OPENAI_ORG_ID`: Your OpenAI organization ID (optional)
- `OPENAI_BASE_URL`: Custom OpenAI API base URL (optional, default: <https://api.openai.com>)

## Model Files

Model configuration for OpenAI models is done via a "model definition file" in JSON format. The file supports OpenAI API parameters:

```json
{
  "name": "gpt-4o-mini",
  "parameters": {
    "temperature": 0.7,
    "top_p": 0.9,
    "max_tokens": 2048,
    "frequency_penalty": 0.1,
    "presence_penalty": 0.0,
    "seed": 42
  },
  "system": "You are a helpful assistant with expertise in software development.",
  "format": "markdown"
}
```

### Available OpenAI Models

- **gpt-4o-mini**: Fast, cost-effective model with 128k context window
- **gpt-4o**: Advanced model with enhanced capabilities and 128k context
- **gpt-4**: High-quality model with 8k context window
- **gpt-3.5-turbo**: Fast, efficient model with 16k context window

### OpenAI Parameters

The `parameters` section supports the following OpenAI API parameters:

- **temperature** (0.0-2.0): Controls randomness in responses
  - Lower values (0.1-0.3) make output more focused and deterministic
  - Higher values (0.7-1.0) make output more creative and varied
  - Default: 0.7

- **top_p** (0.0-1.0): Nucleus sampling parameter
  - Controls diversity by considering only top tokens whose probability mass sums to p
  - Default: 0.9

- **max_tokens**: Maximum number of tokens to generate
  - Controls the length of the response
  - Default varies by model

- **frequency_penalty** (-2.0 to 2.0): Reduces repetition based on frequency
  - Positive values discourage repetition
  - Default: 0.0

- **presence_penalty** (-2.0 to 2.0): Reduces repetition based on presence
  - Positive values encourage discussing new topics
  - Default: 0.0

- **seed**: Integer seed for deterministic outputs
  - Same seed with same parameters should produce similar outputs
  - Optional
}
```

### Configuration Fields

- `name`: The name of the model to use (required)
- `modelfile`: Optional Modelfile commands to customize the model
- `parameters`: Runtime parameters that control the model's behavior:
  - `temperature`: Controls randomness (0.0 to 1.0, default 0.8)
  - `top_p`: Nucleus sampling threshold (0.0 to 1.0, default 0.9)
  - `top_k`: Top-k sampling (1 to 100, default 40)
  - `repeat_penalty`: Penalty for repeated tokens (1.0 to 2.0, default 1.1)
  - `num_predict`: Maximum number of tokens to predict
  - And more (see Ollama docs for all parameters)
- `options`: Model-wide configuration options:
  - `num_ctx`: Size of the context window
  - `num_batch`: Batch size for prompt processing
  - `num_thread`: Number of CPU threads to use
  - `num_gpu`: Number of GPUs to use
- `template`: Template for formatting prompts
- `system`: System prompt to control model behavior
- `format`: Optional response format specification

### Ollama `options` Parameters

#### num_ctx (Context Window Size)

- Sets the maximum number of tokens the model can consider in a single prompt + response
- Higher values allow longer conversations or documents, but use more RAM/VRAM
- Must not exceed the model's maximum supported context length

#### num_batch (Batch Size)

- Controls how many tokens are processed in parallel during generation
- Larger values can improve throughput on powerful hardware
- Too high a value may cause out-of-memory errors

#### num_thread (CPU Threads)

- Sets how many CPU threads Ollama will use for model inference
- Increasing this can speed up generation on multi-core CPUs
- Best value depends on your CPU core count

#### num_gpu (GPU Usage)

- Specifies how many GPUs Ollama should use for inference
- Setting this to `1` means only one GPU will be used
- On multi-GPU systems, increasing this may improve performance

### Options Summary Table

| Option     | Purpose                           | Typical Impact/Usage                      |
|------------|-----------------------------------|------------------------------------------|
| num_ctx    | Context window (tokens)           | Longer memory, more RAM/VRAM needed       |
| num_batch  | Batch size for token processing   | Higher = faster, but more memory required |
| num_thread | Number of CPU threads             | Higher = faster (up to core count)        |
| num_gpu    | Number of GPUs to use             | Uses more GPUs if available              |

### References

## Getting Started

### Prerequisites

1. **OpenAI API Key**: Get your API key from <https://platform.openai.com/api-keys>
2. **Go 1.19+**: Required to build the client

### Setup

1. Set your OpenAI API key:

```bash
export OPENAI_API_KEY="sk-your-api-key-here"
```

2. Build the client:

```bash
cd client
go build -o client .
```

3. Run the client:

```bash
# Interactive mode with default model (gpt-4o-mini)
./client

# Using a specific model configuration
./client -model gpt-4o.json

# Starting with an initial prompt
./client -model gpt-4o-mini.json -prompt test-prompt.txt
```

### Example Model Files

The repository includes several pre-configured model files:

- `gpt-4o-mini.json`: Fast, cost-effective model
- `gpt-4o.json`: Advanced model with enhanced capabilities
- `gpt-4.json`: High-quality model for complex tasks

## API Usage and Costs

When using OpenAI's API, be aware of the following:

- **Token-based pricing**: You pay for both input and output tokens
- **Rate limits**: API requests are subject to rate limiting
- **Context window**: Larger contexts cost more but provide better continuity
- **Model differences**: Different models have different capabilities and costs

For current pricing information, visit <https://openai.com/pricing>

## References

For more information about OpenAI's API and models:

- [OpenAI API Documentation](https://platform.openai.com/docs)
- [Model Information](https://platform.openai.com/docs/models)
- [API Reference](https://platform.openai.com/docs/api-reference/chat)
