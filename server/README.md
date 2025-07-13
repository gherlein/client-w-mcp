# MCP Server

A Model Context Protocol (MCP) server providing extensible tool capabilities through HTTP-based API. Built using Go and the mcp-golang library for standards-compliant MCP implementation.

## Overview

This server implements the Model Context Protocol specification, providing a stateless HTTP service that exposes tools and capabilities to MCP clients. The architecture is designed for easy extensibility and horizontal scaling.

## Features

### 🎯 Core Capabilities
- **HTTP-based MCP Implementation**: RESTful server compliant with MCP specification
- **Tool System**: Extensible architecture for adding custom tools and capabilities
- **Stateless Design**: Horizontally scalable with minimal resource footprint
- **JSON Schema Validation**: Automatic parameter validation for tool inputs
- **Standards Compliant**: Built on official mcp-golang library

### 🛠️ Available Tools
- **time**: Returns current time in specified format

### 🏗️ Architecture Benefits
- **Modular Design**: Easy to add new tools
- **Stateless**: No session state, scales horizontally
- **Fast Startup**: Quick server initialization
- **Concurrent**: Handles multiple requests simultaneously

## Quick Start

### Prerequisites
- Go 1.19+

### Setup and Run
```bash
# Build and run
make run

# Or manually
go build -o server . && ./server
```

Server starts on port 8081 at endpoint `/mcp`.

## Usage

### Server Information
- **Endpoint**: `http://localhost:8081/mcp`
- **Protocol**: HTTP with JSON payloads
- **Method**: POST for tool calls

### Testing the Server

Test the time tool using curl:
```bash
curl -X POST http://localhost:8081/mcp \
  -H "Content-Type: application/json" \
  -d '{
    "method": "tools/call",
    "params": {
      "name": "time",
      "arguments": {
        "format": "2006-01-02 15:04:05"
      }
    }
  }'
```

### Response Format
```json
{
  "result": {
    "content": [
      {
        "type": "text",
        "text": "2025-01-15 14:30:25"
      }
    ]
  }
}
```

## Adding New Tools

### 1. Define Argument Structure
Create a struct with JSON schema tags:
```go
type CalculatorArgs struct {
    Operation string  `json:"operation" jsonschema:"description=Math operation (add, subtract, multiply, divide)"`
    A         float64 `json:"a" jsonschema:"description=First number"`
    B         float64 `json:"b" jsonschema:"description=Second number"`
}
```

### 2. Implement Handler Function
```go
func calculatorHandler(args CalculatorArgs) (*mcp_golang.ToolResponse, error) {
    var result float64
    
    switch args.Operation {
    case "add":
        result = args.A + args.B
    case "subtract":
        result = args.A - args.B
    case "multiply":
        result = args.A * args.B
    case "divide":
        if args.B == 0 {
            return nil, fmt.Errorf("division by zero")
        }
        result = args.A / args.B
    default:
        return nil, fmt.Errorf("unsupported operation: %s", args.Operation)
    }
    
    return mcp_golang.NewToolResponse(
        mcp_golang.NewTextContent(fmt.Sprintf("%.2f", result))
    ), nil
}
```

### 3. Register the Tool
```go
err := server.RegisterTool("calculator", "Performs basic math operations", calculatorHandler)
if err != nil {
    panic(err)
}
```

## Architecture Overview

The server uses the mcp-golang library for standards-compliant MCP implementation:

### System Architecture

```mermaid
block-beta
  columns 3
  Client["MCP Client"] space:1 HTTPTransport["HTTP Transport<br/>:8081/mcp"]
  space:1 arrow1<["HTTP Requests"]>(down) space:1
  space:1 MCPServer["MCP Server<br/>mcp-golang"] space:1
  space:1 arrow2<["Tool Registration"]>(down) space:1
  space:1 TimeTools["Time Tool<br/>Handler"] space:1

  style Client fill:#e1f5fe
  style HTTPTransport fill:#f3e5f5
  style MCPServer fill:#e8f5e8
  style TimeTools fill:#fff3e0
```

### Component Breakdown

#### 1. HTTP Transport Layer
- **Location**: Port 8081, endpoint `/mcp`
- **Purpose**: Handles incoming HTTP requests and routes them to the MCP server
- **Implementation**: Uses the `http.NewHTTPTransport()` from the mcp-golang library

#### 2. MCP Server Core
- **Name**: "mcp-golang-stateless-http-example"
- **Version**: "0.0.1"
- **Description**: "A simple example of a stateless HTTP server using mcp-golang"
- **Purpose**: Manages tool registration and request processing

#### 3. Tool Implementation
- **Current Tools**: Single "time" tool
- **Handler Function**: Returns current time in specified format
- **Input**: Format string parameter
- **Output**: Formatted time string

## Code Analysis

### Main Function Flow

```mermaid
sequenceDiagram
    participant M as main()
    participant T as HTTPTransport
    participant S as MCPServer
    participant H as TimeHandler

    M->>T: NewHTTPTransport("/mcp", ":8081")
    M->>S: NewServer(transport, config...)
    M->>S: RegisterTool("time", handler)
    S->>H: Store handler function
    M->>S: Serve()
    Note over S: Server starts listening
    
    loop Client Requests
        Note over T: HTTP Request to /mcp
        T->>S: Route request
        S->>H: Execute tool("time", args)
        H->>S: Return formatted time
        S->>T: MCP Response
        T->>T: HTTP Response
    end
```

### Data Structures

#### TimeArgs Structure
```go
type TimeArgs struct {
    Format string `json:"format" jsonschema:"description=The time format to use"`
}
```

**Purpose**: Defines the input parameters for the time tool
**Fields**:
- `Format`: String specifying the Go time format layout
- **JSON Schema**: Includes description for API documentation

### Tool Registration Process

```mermaid
sequenceDiagram
    participant Server as MCP Server
    participant Registry as Tool Registry
    participant Handler as Tool Handler

    Server->>Registry: RegisterTool("time", description, handler)
    Registry->>Registry: Validate tool name uniqueness
    Registry->>Registry: Store tool metadata
    Registry->>Handler: Associate handler function
    Registry->>Server: Confirm registration
    
    Note over Registry: Tool available for client calls
```

## Dependencies Analysis

### Core Dependencies

Based on the `go.mod` file, the server relies on several key libraries:

#### Primary Dependencies
- **`github.com/metoro-io/mcp-golang v0.13.0`**: Core MCP implementation
- **`github.com/gin-gonic/gin v1.8.1`**: HTTP web framework (indirect)

#### Supporting Libraries
- **JSON Processing**: Multiple JSON libraries for request/response handling
  - `github.com/goccy/go-json v0.9.7`
  - `github.com/json-iterator/go v1.1.12`
  - `github.com/buger/jsonparser v1.1.1`

- **Validation**: 
  - `github.com/go-playground/validator/v10 v10.10.0`
  - `github.com/invopop/jsonschema v0.12.0`

- **HTTP Framework Components**:
  - `github.com/gin-contrib/sse v0.1.0` (Server-Sent Events)
  - Various encoding/decoding utilities

### Dependency Graph

```mermaid
block-beta
  columns 3
  
  Server["server/main.go"] space:1 MCPLib["mcp-golang<br/>v0.13.0"]
  space:1 arrow1<["imports"]>(down) space:1
  space:1 HTTPLib["HTTP Transport<br/>gin-gonic"] space:1
  space:1 arrow2<["uses"]>(down) space:1
  ValidationLib["Validation<br/>validator/v10"] JSONLib["JSON Processing<br/>multiple libs"] SchemaLib["JSON Schema<br/>invopop"]

  style Server fill:#e3f2fd
  style MCPLib fill:#e8f5e8
  style HTTPLib fill:#fff3e0
  style ValidationLib fill:#fce4ec
  style JSONLib fill:#f1f8e9
  style SchemaLib fill:#e0f2f1
```

## Runtime Behavior

### Server Startup Sequence

1. **Transport Initialization**: Creates HTTP transport on port 8081 with `/mcp` endpoint
2. **Server Creation**: Instantiates MCP server with metadata (name, version, instructions)
3. **Tool Registration**: Registers the "time" tool with its handler function
4. **Service Start**: Begins listening for HTTP requests

### Request Processing Flow

```mermaid
sequenceDiagram
    participant C as Client
    participant H as HTTP Layer
    participant M as MCP Server
    participant T as Time Tool

    C->>H: POST /mcp (tool request)
    H->>M: Parse MCP request
    M->>M: Validate request format
    M->>M: Route to tool handler
    M->>T: Execute time tool
    T->>T: Parse format argument
    T->>T: Generate current time
    T->>M: Return formatted time
    M->>H: Wrap in MCP response
    H->>C: HTTP response with result
```

### Error Handling

The server implements basic error handling:
- **Tool Registration Errors**: Panics if tool registration fails
- **Runtime Errors**: Tool handlers can return errors that are propagated to clients
- **HTTP Layer**: Underlying gin framework handles HTTP-level errors

## Configuration

### Server Configuration
- **Name**: "mcp-golang-stateless-http-example"
- **Instructions**: "A simple example of a stateless HTTP server using mcp-golang"
- **Version**: "0.0.1"

### Network Configuration
- **Port**: 8081
- **Endpoint**: `/mcp`
- **Protocol**: HTTP

### Tool Configuration
- **Tool Name**: "time"
- **Description**: "Returns the current time in the specified format"
- **Input Schema**: Accepts format string parameter

## Build System

### Makefile Analysis

```bash
build:          # Builds the server binary
    go mod tidy     # Clean up dependencies
    go build -o server ./...   # Compile to 'server' binary

clean:          # Cleanup build artifacts
    rm -f server    # Remove binary
    rm *~           # Remove backup files
    rm *.log        # Remove log files

run: build      # Build and run server
    ./server

flush:          # Clean module cache
    go clean -modcache
```

### Build Process Flow

```mermaid
block-beta
  columns 3
  
  Make["make build"] space:1 ModTidy["go mod tidy"]
  space:1 arrow1<["executes"]>(down) space:1
  space:1 GoBuild["go build -o server"] space:1
  space:1 arrow2<["produces"]>(down) space:1
  space:1 Binary["server executable"] space:1

  style Make fill:#e3f2fd
  style ModTidy fill:#e8f5e8
  style GoBuild fill:#fff3e0
  style Binary fill:#e1f5fe
```

## Extensibility and Future Enhancements

### Adding New Tools

The architecture supports easy addition of new tools:

1. **Define Arguments Structure**: Create a struct with JSON tags
2. **Implement Handler Function**: Function that takes args and returns `*mcp_golang.ToolResponse`
3. **Register Tool**: Call `server.RegisterTool()` with name, description, and handler

### Example Extension

```go
type CalculatorArgs struct {
    Operation string  `json:"operation"`
    A         float64 `json:"a"`
    B         float64 `json:"b"`
}

func calculatorHandler(args CalculatorArgs) (*mcp_golang.ToolResponse, error) {
    // Implementation here
}

// Register during server setup
server.RegisterTool("calculator", "Performs basic math operations", calculatorHandler)
```

## Security Considerations

### Current Security Posture
- **No Authentication**: Server accepts requests from any client
- **No Authorization**: All registered tools are accessible to all clients
- **No Input Validation**: Beyond JSON schema validation
- **No Rate Limiting**: Server can be overwhelmed by requests

### Recommended Security Enhancements
1. **Authentication**: Implement API key or token-based auth
2. **Input Sanitization**: Validate and sanitize all tool inputs
3. **Rate Limiting**: Implement request rate limiting
4. **HTTPS**: Use TLS for encrypted communication
5. **Access Control**: Role-based access to different tools

## Performance Characteristics

### Strengths
- **Stateless Design**: Easy to scale horizontally
- **Lightweight**: Minimal memory footprint
- **Fast Startup**: Quick server initialization
- **Concurrent**: Go's goroutine model handles concurrent requests well

### Potential Bottlenecks
- **Single Process**: No built-in clustering
- **Time Tool**: Simple implementation, low latency
- **JSON Processing**: Multiple JSON libraries may add overhead
- **No Caching**: Each request processed independently

## Testing and Validation

### Current Testing Status
- **No Unit Tests**: No test files present in the codebase
- **No Integration Tests**: No automated testing of the HTTP endpoints
- **Manual Testing Required**: Server must be tested manually

### Recommended Testing Strategy
1. **Unit Tests**: Test tool handlers in isolation
2. **Integration Tests**: Test full HTTP request/response cycle
3. **Load Testing**: Verify performance under load
4. **Schema Validation Tests**: Ensure JSON schemas work correctly

## Monitoring and Observability

### Current Monitoring
- **Basic Logging**: Uses Go's standard log package
- **Startup Message**: Logs server start on port 8081
- **No Metrics**: No performance or usage metrics
- **No Health Checks**: No endpoint for health monitoring

### Recommended Monitoring Enhancements
1. **Structured Logging**: Use structured logging library
2. **Metrics**: Add Prometheus metrics for requests, latency, errors
3. **Health Endpoints**: Add `/health` and `/ready` endpoints
4. **Distributed Tracing**: Add OpenTelemetry tracing
5. **Error Tracking**: Implement error tracking and alerting

## Conclusion

The MCP server implementation is a well-structured, minimal example of how to build an MCP-compliant server using Go. The architecture is clean and extensible, making it easy to add new tools and capabilities. However, the current implementation is primarily suitable for development and demonstration purposes.

For production use, significant enhancements would be needed in areas of security, monitoring, testing, and error handling. The stateless design and use of proven libraries (gin, mcp-golang) provide a solid foundation for building a more robust production server.

### Key Strengths
- Clean, readable code structure
- Proper use of MCP library patterns
- Easy tool registration mechanism
- Stateless design for scalability

### Areas for Improvement
- Add comprehensive testing
- Implement security measures
- Add monitoring and observability
- Enhance error handling and validation
- Add configuration management

This server serves as an excellent starting point for understanding MCP server implementation and can be evolved into a production-ready service with the recommended enhancements.
