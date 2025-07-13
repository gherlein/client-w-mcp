# API Comparison: Anthropic vs OpenAI

A comprehensive comparison of the Anthropic Claude API and OpenAI API, covering differences in structure, capabilities, and implementation approaches.

## Executive Summary

While both APIs provide access to large language models through HTTP endpoints, they differ significantly in design philosophy, parameter handling, and response formats. OpenAI follows a more traditional chat completion approach, while Anthropic emphasizes message-based conversations with explicit role management and enhanced safety features.

## API Architecture Comparison

### Base URLs and Endpoints

#### OpenAI API
- **Base URL**: `https://api.openai.com/v1/`
- **Primary Endpoint**: `/chat/completions`
- **Authentication**: Bearer token in Authorization header

#### Anthropic API
- **Base URL**: `https://api.anthropic.com/v1/`
- **Primary Endpoint**: `/messages`
- **Authentication**: API key in `x-api-key` header
- **Additional Headers**: `anthropic-version` (required)

### Authentication Differences

```http
# OpenAI Authentication
Authorization: Bearer sk-...
Content-Type: application/json

# Anthropic Authentication
x-api-key: sk-ant-...
anthropic-version: 2023-06-01
Content-Type: application/json
```

## Request Format Comparison

### OpenAI Chat Completions Request

```json
{
  "model": "gpt-4",
  "messages": [
    {"role": "system", "content": "You are a helpful assistant."},
    {"role": "user", "content": "Hello!"}
  ],
  "temperature": 0.7,
  "max_tokens": 1000,
  "top_p": 0.9,
  "frequency_penalty": 0.0,
  "presence_penalty": 0.0,
  "stream": false
}
```

### Anthropic Messages Request

```json
{
  "model": "claude-3-5-sonnet-20241022",
  "max_tokens": 1000,
  "temperature": 0.7,
  "top_p": 0.9,
  "messages": [
    {"role": "user", "content": "Hello!"}
  ],
  "system": "You are a helpful assistant."
}
```

## Key Structural Differences

### 1. System Message Handling

| Aspect | OpenAI | Anthropic |
|--------|--------|-----------|
| **System Message** | Part of messages array | Separate `system` parameter |
| **Placement** | First message with role "system" | Top-level field |
| **Multiple System Messages** | Supported | Single system message only |

### 2. Message Structure

#### OpenAI Messages
```json
{
  "role": "user|assistant|system|function|tool",
  "content": "text content",
  "name": "optional function name",
  "function_call": {}, // deprecated
  "tool_calls": []
}
```

#### Anthropic Messages
```json
{
  "role": "user|assistant",
  "content": [
    {
      "type": "text",
      "text": "text content"
    },
    {
      "type": "image",
      "source": {
        "type": "base64",
        "media_type": "image/jpeg",
        "data": "base64_data"
      }
    }
  ]
}
```

### 3. Content Types

| Feature | OpenAI | Anthropic |
|---------|--------|-----------|
| **Text Content** | String or array of content objects | Array of content blocks |
| **Image Support** | Via content array (GPT-4V) | Native content block type |
| **File Attachments** | Limited support | Not supported |
| **Structured Content** | Tool calls | Content blocks |

## Parameter Differences

### Common Parameters

| Parameter | OpenAI | Anthropic | Notes |
|-----------|--------|-----------|-------|
| **model** | ✅ | ✅ | Different model names |
| **temperature** | ✅ | ✅ | Same range (0-2 OpenAI, 0-1 Anthropic) |
| **max_tokens** | ✅ | ✅ | Same concept, different limits |
| **top_p** | ✅ | ✅ | Same concept and range |
| **stream** | ✅ | ✅ | Both support streaming |

### OpenAI-Specific Parameters

```json
{
  "frequency_penalty": 0.0,     // Reduce repetition based on frequency
  "presence_penalty": 0.0,      // Encourage new topics
  "logit_bias": {},            // Modify likelihood of tokens
  "user": "user_id",           // User identifier for monitoring
  "seed": 42,                  // Deterministic outputs
  "response_format": {"type": "json_object"}, // Force JSON output
  "tool_choice": "auto",       // Control tool usage
  "tools": []                  // Available tools/functions
}
```

### Anthropic-Specific Parameters

```json
{
  "stop_sequences": ["Human:", "Assistant:"], // Custom stop sequences
  "top_k": 40,                  // Top-k sampling
  "metadata": {                 // Request metadata
    "user_id": "user_123"
  }
}
```

## Response Format Comparison

### OpenAI Response Structure

```json
{
  "id": "chatcmpl-123",
  "object": "chat.completion",
  "created": 1677652288,
  "model": "gpt-3.5-turbo",
  "choices": [
    {
      "index": 0,
      "message": {
        "role": "assistant",
        "content": "Hello! How can I help you today?"
      },
      "finish_reason": "stop"
    }
  ],
  "usage": {
    "prompt_tokens": 9,
    "completion_tokens": 9,
    "total_tokens": 18
  }
}
```

### Anthropic Response Structure

```json
{
  "id": "msg_123",
  "type": "message",
  "role": "assistant",
  "content": [
    {
      "type": "text",
      "text": "Hello! How can I help you today?"
    }
  ],
  "model": "claude-3-5-sonnet-20241022",
  "stop_reason": "end_turn",
  "stop_sequence": null,
  "usage": {
    "input_tokens": 9,
    "output_tokens": 9
  }
}
```

## Streaming Response Differences

### OpenAI Streaming Format

```
data: {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1677652288,"model":"gpt-3.5-turbo","choices":[{"index":0,"delta":{"content":"Hello"},"finish_reason":null}]}

data: {"id":"chatcmpl-123","object":"chat.completion.chunk","created":1677652288,"model":"gpt-3.5-turbo","choices":[{"index":0,"delta":{},"finish_reason":"stop"}]}

data: [DONE]
```

### Anthropic Streaming Format

```
event: message_start
data: {"type":"message_start","message":{"id":"msg_123","type":"message","role":"assistant","content":[],"model":"claude-3-sonnet-20240229","stop_reason":null,"stop_sequence":null,"usage":{"input_tokens":9,"output_tokens":0}}}

event: content_block_start
data: {"type":"content_block_start","index":0,"content_block":{"type":"text","text":""}}

event: content_block_delta
data: {"type":"content_block_delta","index":0,"delta":{"type":"text_delta","text":"Hello"}}

event: content_block_stop
data: {"type":"content_block_stop","index":0}

event: message_stop
data: {"type":"message_stop"}
```

## Model Capabilities Comparison

### OpenAI Models

| Model | Context Window | Capabilities |
|-------|----------------|--------------|
| **GPT-4** | 8K/32K | Advanced reasoning, code, analysis |
| **GPT-4 Turbo** | 128K | Latest features, JSON mode, vision |
| **GPT-4o** | 128K | Multimodal, faster, cost-effective |
| **GPT-3.5 Turbo** | 16K | Fast, cost-effective |

### Anthropic Models

| Model | Context Window | Capabilities |
|-------|----------------|--------------|
| **Claude 3.5 Sonnet** | 200K | Enhanced reasoning, improved coding, latest generation |
| **Claude 3 Opus** | 200K | Highest intelligence, complex reasoning |
| **Claude 3 Sonnet** | 200K | Balanced performance and speed |
| **Claude 3 Haiku** | 200K | Fastest, most cost-effective |
| **Claude 2.1** | 200K | Previous generation (legacy) |

**Note**: As of 2024, Claude 4 models are not yet available. Claude 3.5 Sonnet represents the latest and most advanced model in Anthropic's lineup, offering significant improvements in reasoning, coding capabilities, and overall performance compared to Claude 3 models.

## Function/Tool Calling Differences

### OpenAI Function Calling

```json
{
  "tools": [
    {
      "type": "function",
      "function": {
        "name": "get_weather",
        "description": "Get current weather",
        "parameters": {
          "type": "object",
          "properties": {
            "location": {"type": "string"}
          },
          "required": ["location"]
        }
      }
    }
  ],
  "tool_choice": "auto"
}
```

### Anthropic Tool Use

```json
{
  "tools": [
    {
      "name": "get_weather",
      "description": "Get current weather",
      "input_schema": {
        "type": "object",
        "properties": {
          "location": {"type": "string"}
        },
        "required": ["location"]
      }
    }
  ]
}
```

**Key Differences:**
- OpenAI uses `parameters` schema, Anthropic uses `input_schema`
- OpenAI has `tool_choice` parameter for controlling tool usage
- Response formats differ significantly for tool calls

## Error Handling Comparison

### OpenAI Error Response

```json
{
  "error": {
    "message": "The model `gpt-4` does not exist or you do not have access to it.",
    "type": "invalid_request_error",
    "param": "model",
    "code": "model_not_found"
  }
}
```

### Anthropic Error Response

```json
{
  "type": "error",
  "error": {
    "type": "invalid_request_error",
    "message": "Invalid model specified"
  }
}
```

## Rate Limiting and Headers

### OpenAI Rate Limiting

```
x-ratelimit-limit-requests: 3000
x-ratelimit-limit-tokens: 250000
x-ratelimit-remaining-requests: 2999
x-ratelimit-remaining-tokens: 249950
x-ratelimit-reset-requests: 1677652400
x-ratelimit-reset-tokens: 1677652400
```

### Anthropic Rate Limiting

```
anthropic-ratelimit-requests-limit: 1000
anthropic-ratelimit-requests-remaining: 999
anthropic-ratelimit-requests-reset: 2024-01-01T00:00:00Z
anthropic-ratelimit-tokens-limit: 100000
anthropic-ratelimit-tokens-remaining: 99950
anthropic-ratelimit-tokens-reset: 2024-01-01T00:00:00Z
```

## Pricing Structure Differences

### OpenAI Pricing Model
- **Input Tokens**: Different rates per model
- **Output Tokens**: Typically higher rate than input
- **Image Processing**: Additional charges for vision models
- **Fine-tuning**: Separate pricing for training and inference

### Anthropic Pricing Model
- **Input Tokens**: Per-token pricing
- **Output Tokens**: Higher rate than input tokens
- **Consistent Pricing**: Same rate across Claude 3 model family tiers
- **No Image Charges**: Native image support included

## Context Window Management

### OpenAI Approach
- **Truncation**: Manual context management required
- **Token Counting**: Requires external libraries (tiktoken)
- **Sliding Window**: Not built-in

### Anthropic Approach
- **Large Context**: 200K tokens across all models
- **Better Management**: More forgiving with context overflow
- **Token Estimation**: Simpler character-to-token ratio

## Safety and Moderation

### OpenAI Safety Features
- **Content Moderation**: Separate moderation API
- **Safety Classifiers**: Built-in safety checks
- **User-ID Tracking**: For abuse monitoring

### Anthropic Safety Features
- **Constitutional AI**: Built-in harmlessness training
- **Automatic Safety**: Integrated safety without separate calls
- **Transparency**: Clear safety reasoning in responses

## Code Migration Considerations

### From OpenAI to Anthropic

```go
// OpenAI Request
type OpenAIRequest struct {
    Model       string    `json:"model"`
    Messages    []Message `json:"messages"`
    Temperature float64   `json:"temperature"`
    MaxTokens   int       `json:"max_tokens"`
    Stream      bool      `json:"stream"`
}

// Anthropic Request  
type AnthropicRequest struct {
    Model      string            `json:"model"`
    MaxTokens  int              `json:"max_tokens"`
    Messages   []AnthropicMessage `json:"messages"`
    System     string           `json:"system,omitempty"`
    Temperature float64         `json:"temperature"`
    Stream     bool             `json:"stream"`
}
```

### Key Migration Steps

1. **Headers**: Change authentication and add version header
2. **System Messages**: Move from messages array to system parameter
3. **Response Parsing**: Handle different response structure
4. **Content Format**: Convert between string and content blocks
5. **Streaming**: Handle different event formats

## Performance Characteristics

### OpenAI Performance
- **Latency**: Generally faster initial response
- **Throughput**: High throughput for shorter requests
- **Reliability**: Mature infrastructure with high uptime

### Anthropic Performance
- **Latency**: Slightly higher latency but improving
- **Quality**: Often higher quality responses for complex tasks
- **Context Handling**: Better performance with long contexts

## Use Case Recommendations

### Choose OpenAI When:
- **Cost Optimization**: Need the most cost-effective solution
- **Speed Priority**: Require fastest possible responses
- **Ecosystem**: Heavily invested in OpenAI tooling
- **Function Calling**: Need advanced function/tool calling features

### Choose Anthropic When:
- **Quality Focus**: Need highest quality reasoning and analysis
- **Long Context**: Working with large documents or conversations
- **Safety Critical**: Require built-in safety and harmlessness
- **Research/Analysis**: Complex reasoning and research tasks

## Conclusion

Both APIs offer powerful language model capabilities but with different strengths:

- **OpenAI** excels in speed, cost-effectiveness, and ecosystem maturity
- **Anthropic** leads in reasoning quality, safety, and context handling, with Claude 3.5 Sonnet offering significant improvements in coding and complex reasoning tasks

The choice depends on specific requirements around cost, quality, safety, and technical constraints. For applications requiring the highest quality output and safety, Anthropic's Claude models (especially Claude 3.5 Sonnet) are often preferred. For cost-sensitive applications requiring speed and broad compatibility, OpenAI remains a strong choice.

**Latest Update**: Claude 3.5 Sonnet represents a significant advancement over previous Claude models, with enhanced reasoning capabilities, improved coding assistance, and better performance on complex analytical tasks. While Claude 4 is not yet available, Claude 3.5 Sonnet currently offers state-of-the-art performance in many domains.

When migrating between APIs, the main considerations are authentication changes, message format differences, and response structure adaptations. Both APIs support streaming and offer comparable core functionality, making migration feasible with appropriate abstraction layers.