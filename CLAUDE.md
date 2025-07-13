# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a Go-based demonstration project showing OpenAI API client integration with a Model Context Protocol (MCP) server. The project consists of two main components:

1. **Client** (`/client`): Interactive CLI for OpenAI API with model configuration, context management, and performance metrics
2. **Server** (`/server`): HTTP-based MCP server providing tools (currently a time tool)

## Build and Run Commands

### Client Commands
```bash
cd client
make build          # Build the client binary
make run            # Build and run client
make clean          # Remove binary and temp files
make flush          # Clean Go module cache
```

### Server Commands  
```bash
cd server
make build          # Build the server binary
make run            # Build and run server on port 8081
make clean          # Remove binary and temp files
make flush          # Clean Go module cache
```

### Manual Build/Run
```bash
# Client
cd client && go build -o client . && ./client

# Server  
cd server && go build -o server . && ./server
```

## Architecture Overview

### Client Architecture
- **Interactive CLI**: Uses readline for command history and completion
- **OpenAI Integration**: Supports multiple OpenAI models (GPT-4o, GPT-4o-mini, GPT-4, GPT-3.5-turbo)
- **Model Configuration**: JSON-based model definitions with parameters
- **Context Management**: File loading with intelligent token counting and context window management
- **Performance Metrics**: Real-time tokens/sec, response time, and context usage tracking
- **Conversation History**: Persistent conversation state with automatic trimming

### Server Architecture
- **MCP Protocol**: HTTP-based server implementing Model Context Protocol
- **Stateless Design**: Each request processed independently
- **Tool System**: Extensible tool registration (currently includes time tool)
- **JSON Schema**: Automatic parameter validation for tools

## Key Features and Commands

### Client Interactive Commands
- `/load <file>` - Load source files into context
- `/model <file>` - Switch model configuration  
- `/status` - Show current model, context usage, token counts
- `/history` - Display conversation history
- `/clear` - Clear conversation history
- `/dump` - Export context to file
- `exit` - Quit application

### Client Command Line Flags
- `-model <file>` - Specify model definition JSON file
- `-prompt <file>` - Initial prompt from text file
- `-url <url>` - OpenAI API base URL (default: https://api.openai.com)
- `-default-model <name>` - Default model when no config specified (default: gpt-4o-mini)
- `-context, -c` - Show full context before sending to LLM

## Configuration

### Environment Variables
- `OPENAI_API_KEY` - Required for client operation
- `OPENAI_ORG_ID` - Optional OpenAI organization ID
- `OPENAI_BASE_URL` - Optional custom API base URL

### Model Configuration Files
JSON files defining model parameters. Example structure:
```json
{
  "name": "gpt-4o-mini",
  "parameters": {
    "temperature": 0.7,
    "top_p": 0.9,
    "max_tokens": 2048,
    "seed": 42
  },
  "system": "You are a helpful assistant with expertise in software development.",
  "format": "markdown"
}
```

### Context Window Management
- **GPT-4o/GPT-4o-mini**: 128k tokens
- **GPT-4**: 8k tokens  
- **GPT-3.5-turbo**: 16k tokens
- **Default**: 4k tokens

Automatic context trimming maintains system prompt and user/assistant message pairs.

## Dependencies

### Client Dependencies
- `github.com/chzyer/readline v1.5.1` - Interactive CLI with history
- `golang.org/x/text v0.26.0` - Text processing utilities

### Server Dependencies  
- `github.com/metoro-io/mcp-golang v0.13.0` - Core MCP implementation
- Uses Gin HTTP framework (indirect dependency)

## Development Workflow

1. **Set up environment**: Export OPENAI_API_KEY
2. **Build components**: Use make commands in respective directories
3. **Test client**: Run client with different model configurations
4. **Test server**: Verify MCP server responds on localhost:8081/mcp
5. **Add new tools**: Extend server by registering additional tool handlers

## Code Organization

### Client Structure (`/client`)
- `main.go` - Main application with OpenAI client, conversation management, and CLI
- Model definitions in JSON files (gpt-4o.json, gpt-4o-mini.json, etc.)
- Makefile for build automation

### Server Structure (`/server`)  
- `main.go` - MCP server with tool registration and HTTP transport
- TimeArgs struct for tool parameter validation
- Makefile for build automation

## Common Development Tasks

### Adding New Client Features
- Model parameter handling in ModelDefinition struct
- Interactive commands in main command processing loop
- Context management in file loading logic

### Adding New Server Tools
1. Define argument struct with JSON schema tags
2. Implement handler function returning *mcp_golang.ToolResponse
3. Register tool with server.RegisterTool()

### Performance Monitoring
Client automatically displays metrics after each interaction:
```
[Performance: 123.45 tokens/sec, 150 total tokens, response time: 1.234s]
```

## Testing and Validation

Currently no automated tests. Manual testing approach:
1. **Client testing**: Verify interactive commands, model switching, file loading
2. **Server testing**: Test MCP tool calls via HTTP requests
3. **Integration testing**: Use client to interact with external APIs

For production use, add unit tests for core functions, integration tests for API communication, and end-to-end workflow tests.