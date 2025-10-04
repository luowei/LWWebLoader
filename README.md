# LWWebLoader

[![CI Status](https://img.shields.io/travis/luowei/LWWebLoader.svg?style=flat)](https://travis-ci.org/luowei/LWWebLoader)
[![Version](https://img.shields.io/cocoapods/v/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)
[![License](https://img.shields.io/cocoapods/l/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)
[![Platform](https://img.shields.io/cocoapods/p/LWWebLoader.svg?style=flat)](https://cocoapods.org/pods/LWWebLoader)

[English](./README.md) | [中文版](./README_ZH.md) | [Swift Version](./README_SWIFT_VERSION.md)

---

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Requirements](#requirements)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage](#usage)
  - [HTTP Requests](#http-requests)
  - [WebSocket Communication](#websocket-communication)
- [API Reference](#api-reference)
- [Advanced Usage](#advanced-usage)
- [Architecture](#architecture)
- [Performance Optimization](#performance-optimization)
- [FAQ](#faq)
- [Example Project](#example-project)
- [Author](#author)
- [License](#license)

---

## Overview

LWWebLoader is a powerful iOS library that provides advanced web loading capabilities through WKWebView, including HTTP requests, file operations, and WebSocket communication with streaming support. It leverages WKWebView's independent network process to handle binary data downloads and uploads efficiently, offering an innovative networking solution for iOS applications through JavaScript-to-native bridging.

## Features

### Core Capabilities

- **Independent Network Process**: Utilizes WKWebView's separate network process to avoid impacting main application performance
- **Multiple Loading Methods**: Supports GET, POST, file upload, file download, and streaming downloads
- **Streaming Support**: Stream large files with real-time progress monitoring
- **WebSocket Integration**: Works seamlessly with LWWebSocket for bidirectional communication
- **Base64 Encoding**: Automatic binary data encoding and decoding
- **Asynchronous Callbacks**: Comprehensive asynchronous data processing handlers

### HTTP Features

- **HTTP Methods**: GET, POST requests with custom headers and content types
- **File Operations**: Both in-memory and streaming file downloads
- **File Upload**: Multipart/form-data file uploads with additional parameters
- **Response Handling**: Automatic JSON parsing and plain text processing
- **Custom Configuration**: Custom user agent strings and content types
- **Progress Tracking**: Real-time download/upload progress monitoring

### WebSocket Features

- **Bidirectional Communication**: Full-duplex communication between native and web
- **Message Types**: Support for string messages and binary data
- **Streaming Protocol**: Built-in streaming protocol for large file transfers
- **Connection Management**: Easy connection, disconnection, and reconnection handling
- **Event Callbacks**: Comprehensive event handling for all WebSocket states
- **Chunked Transfer**: Send and receive data in chunks efficiently

## Requirements

- iOS 10.0 or later
- Xcode 9.0 or later
- Objective-C
- WKWebView support

## Installation

### CocoaPods

LWWebLoader is available through [CocoaPods](https://cocoapods.org). To install it, add the following line to your Podfile:

```ruby
pod 'LWWebLoader'
```

Then run:

```bash
pod install
```

### Manual Installation

1. Download or clone this repository
2. Add files from `LWWebLoader/Classes` to your project
3. Add resources from `LWWebLoader/Assets` to your project

## Quick Start

Here's a simple example to get you started with LWWebLoader:

```Objective-C
// Import the library
#import <LWWebLoader/LWWebLoader.h>

// Create a loader instance
LWWebLoader *loader = LWWebLoader.webloader;

// Perform a GET request
NSString *urlString = @"https://api.example.com/data.json";
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:GetData
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:nil
                                                     postData:nil
                                                   uploadData:nil];

[loader evaluateWithBody:evaluateBody
              parentView:self.view
dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }

    if (body.bodyType == BodyType_Json) {
        NSDictionary *jsonData = body.handlerResult;
        NSLog(@"Received JSON: %@", jsonData);
    }
}];
```

## Example Project

To run the example project:

1. Clone the repository
2. Navigate to the Example directory
3. Run `pod install`
4. Open `LWWebLoader.xcworkspace`
5. Build and run the project

## Usage

### HTTP Requests

LWWebLoader leverages WKWebView to perform various HTTP operations with full feature support.

#### Initializing LWWebLoader

```Objective-C
@property (nonatomic, strong) LWWebLoader *webloader;

- (LWWebLoader *)webloader {
    if (!_webloader) {
        _webloader = LWWebLoader.webloader;
    }
    return _webloader;
}
```

#### Basic GET Request

Perform HTTP GET requests to fetch JSON, text, or binary data:

```Objective-C
NSString *urlString = @"https://api.example.com/data.json";
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:GetData
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:nil
                                                     postData:nil
                                                   uploadData:nil];

__weak typeof(self) weakSelf = self;
[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    [weakSelf handleResponseBody:body];
}];
```

#### POST Request

Send POST requests with JSON or form data:

```Objective-C
NSString *urlString = @"https://api.example.com/submit";
NSString *contentType = @"application/json";
NSDictionary *postData = @{@"name": @"John Doe", @"email": @"john@example.com"};

WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:PostData
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:contentType
                                                     postData:postData
                                                   uploadData:nil];

[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    if (error) {
        NSLog(@"POST Error: %@", error);
        return;
    }
    // Handle response
}];
```

#### File Upload

Upload files with additional form parameters:

```Objective-C
NSString *urlString = @"https://api.example.com/upload";
NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"document.pdf"];
NSData *uploadData = [NSData dataWithContentsOfFile:filePath];
NSDictionary *postData = @{
    @"filename": @"document.pdf",
    @"description": @"Important document"
};

WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:UploadData
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:nil
                                                     postData:postData
                                                   uploadData:uploadData];

[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    if (error) {
        NSLog(@"Upload Error: %@", error);
        return;
    }
    NSLog(@"Upload successful!");
}];
```

#### File Download (In-Memory)

Download files directly into memory (suitable for smaller files):

```Objective-C
NSString *urlString = @"https://example.com/files/document.pdf";
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:DownloadFile
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:nil
                                                     postData:nil
                                                   uploadData:nil];

[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    if (error) {
        NSLog(@"Download Error: %@", error);
        return;
    }

    if (body.bodyType == BodyType_Data) {
        NSData *fileData = body.handlerResult;
        // Save to file
        [self saveDataToFile:fileData];
    }
}];
```

#### File Download (Streaming)

Download large files with streaming support and progress tracking:

```Objective-C
NSString *urlString = @"https://example.com/files/large-video.mp4";
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:DownloadStream
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:nil
                                                     postData:nil
                                                   uploadData:nil];

[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    if (error) {
        NSLog(@"Stream Error: %@", error);
        return;
    }

    switch (body.bodyType) {
        case BodyType_StreamStart:
            NSLog(@"Download started: %@", body.handlerResult);
            break;
        case BodyType_Streaming: {
            double progress = [body.handlerResult doubleValue];
            NSLog(@"Download progress: %.2f%%", progress * 100);
            // Update UI progress bar
            break;
        }
        case BodyType_StreamEnd:
            NSLog(@"Download complete! File saved to: %@", body.handlerResult);
            break;
        default:
            break;
    }
}];
```

#### Handling Response Data

```Objective-C
- (void)handleResponseBody:(WLHanderBody *)body {
    switch (body.bodyType) {
        case BodyType_Error:
            NSLog(@"Error: %@", body.handlerResult);
            break;

        case BodyType_Json: {
            NSDictionary *jsonData = body.handlerResult;
            NSLog(@"JSON Response: %@", jsonData);
            break;
        }

        case BodyType_PlainText: {
            NSString *textData = body.handlerResult;
            NSLog(@"Text Response: %@", textData);
            break;
        }

        case BodyType_Data: {
            NSData *binaryData = body.handlerResult;
            [self saveDataToFile:binaryData];
            break;
        }

        case BodyType_StreamStart:
            NSLog(@"Stream starting: %@", body.handlerResult);
            break;

        case BodyType_Streaming: {
            double progress = [body.handlerResult doubleValue];
            NSLog(@"Progress: %.2f%%", progress * 100);
            break;
        }

        case BodyType_StreamEnd:
            NSLog(@"Stream complete: %@", body.handlerResult);
            break;

        default:
            break;
    }
}

- (void)saveDataToFile:(NSData *)data {
    NSString *filePath = [NSTemporaryDirectory() stringByAppendingPathComponent:@"downloaded_file.dat"];
    NSError *error;
    [data writeToFile:filePath options:NSDataWritingAtomic error:&error];

    if (error) {
        NSLog(@"Failed to save file: %@", error);
    } else {
        NSLog(@"File saved to: %@", filePath);
    }
}
```

### WebSocket Communication

LWWebLoader provides a powerful WebSocket implementation that supports real-time bidirectional communication, including streaming large files.

#### Initializing WebSocket WebLoader

```Objective-C
@property (nonatomic, strong) LWWebLoader *wsWebloader;

- (LWWebLoader *)wsWebloader {
    if (!_wsWebloader) {
        _wsWebloader = LWWebLoader.webloader;
    }
    return _wsWebloader;
}
```

#### Setting Up WebSocket Server

Start a WebSocket server on a specified port and handle incoming messages:

```Objective-C

- (void)startWebSocketServer {
    // Set WebSocket server working directory
    NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                            NSUserDomainMask,
                                                            YES).firstObject;

    // Start WebSocket server on port 11335
    [[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

    // Handle received text messages
    [WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
        switch (messageType) {
            case SocketMessageType_String:
                NSLog(@"Received text message: %@", message);
                break;
            default:
                break;
        }
    };

    // Handle received binary data
    [WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
        switch (messageType) {
            case SocketMessageType_StreamStart:
                NSLog(@"Stream started");
                break;

            case SocketMessageType_Streaming:
                NSLog(@"Streaming in progress...");
                break;

            case SocketMessageType_StreamEnd: {
                NSString *dataPath = [[NSString alloc] initWithData:data
                                                           encoding:NSUTF8StringEncoding];
                NSLog(@"Stream completed, file path: %@", dataPath);
                break;
            }

            case SocketMessageType_Data: {
                NSString *text = [[NSString alloc] initWithData:data
                                                       encoding:NSUTF8StringEncoding];
                NSLog(@"Received binary data: %@", text);
                break;
            }

            default:
                break;
        }
    };

    // Set up WebSocket data reception handler
    void (^receiveWSDataHandler)(WLHanderBody *, NSError *) = ^(WLHanderBody *body, NSError *error) {
        switch (body.bodyType) {
            case BodyType_Error:
                NSLog(@"WebSocket error: %@", body.handlerResult);
                break;

            case BodyType_PlainText:
                NSLog(@"WebSocket text: %@", body.handlerResult);
                break;

            case BodyType_Data: {
                NSString *dataString = [[NSString alloc] initWithData:body.handlerResult
                                                              encoding:NSUTF8StringEncoding];
                NSLog(@"WebSocket data: %@", dataString);
                break;
            }

            case BodyType_StreamStart:
                NSLog(@"WebSocket stream started: %@", body.handlerResult);
                break;

            case BodyType_Streaming:
                NSLog(@"WebSocket streaming...");
                break;

            case BodyType_StreamEnd:
                NSLog(@"WebSocket stream completed, file path: %@", body.handlerResult);
                break;

            case BodyType_WSOpened:
                NSLog(@"WebSocket connection opened");
                break;

            case BodyType_WSClosed:
                NSLog(@"WebSocket connection closed");
                break;

            default:
                break;
        }
    };

    // Start WebSocket WebView
    [self.wsWebloader startWSWebViewWithParentView:self.view
                             receiveWSDataHandler:receiveWSDataHandler];
}
```

#### Connecting to WebSocket

```Objective-C
- (void)connectWebSocket {
    [self.wsWebloader wsConnect];
}
```

#### Sending Messages and Data

**Send Text Message:**

```Objective-C
- (void)sendTextMessage {
    NSString *message = @"Hello WebSocket!";
    [self.wsWebloader wsSendString:message];
}
```

**Send Binary Data:**

```Objective-C
- (void)sendBinaryData {
    NSData *data = [@"binary content" dataUsingEncoding:NSUTF8StringEncoding];
    [self.wsWebloader wsSendData:data];
}
```

#### Streaming Files via WebSocket

Send large files using the streaming protocol:

```Objective-C
- (void)sendFileStream {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"document"
                                              withExtension:@"pdf"];

    // Start streaming
    [self.wsWebloader wsSendStreamStart];

    NSError *error;
    NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL
                                                                    error:&error];
    if (error) {
        NSLog(@"Error opening file: %@", error.localizedDescription);
        return;
    }

    // Send file in chunks
    NSData *data = nil;
    while ((data = [fileHandle readDataOfLength:10240])) {
        if (data.length > 0) {
            [self.wsWebloader wsSendStreaming:data];
        } else {
            break;
        }
    }

    // End streaming
    [self.wsWebloader wsSendStreamEnd];
}
```

#### Sending Files via Native WebSocket

```Objective-C
- (void)sendFileViaNative {
    NSURL *fileURL = [[NSBundle mainBundle] URLForResource:@"document"
                                              withExtension:@"pdf"];

    // Send file directly through WebSocketManager
    [[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];
}
```

#### Stopping WebSocket Server

```Objective-C
- (void)stopWebSocketServer {
    [[WebSocketManager sharedManager] stopServer];
    [self.wsWebloader removeWSWebView];
    self.wsWebloader = nil;
}

```

#### WebSocket Message Types

The library supports a streaming protocol for efficiently transferring large files:

| Message Type | Description |
|-------------|-------------|
| `SocketMessageType_String` | Text message communication |
| `SocketMessageType_Data` | Binary data communication |
| `SocketMessageType_StreamStart` | Indicates the beginning of a stream |
| `SocketMessageType_Streaming` | Continuous data chunks being transferred |
| `SocketMessageType_StreamEnd` | Stream completed, includes final file path |

### Response Body Types

LWWebLoader automatically identifies and parses response types:

| Body Type | Result Type | Description |
|-----------|-------------|-------------|
| `BodyType_Json` | NSDictionary/NSArray | Parsed JSON data |
| `BodyType_PlainText` | NSString | Plain text content |
| `BodyType_Data` | NSData | Binary data |
| `BodyType_StreamStart` | NSString | Stream initialization message |
| `BodyType_Streaming` | NSNumber | Download progress (0.0-1.0) |
| `BodyType_StreamEnd` | NSString | File path where stream was saved |
| `BodyType_Error` | NSString | Error message |
| `BodyType_WSOpened` | NSString | WebSocket connection opened |
| `BodyType_WSClosed` | NSString | WebSocket connection closed |

## API Reference

### LWWebLoader Class

The main class providing web loading and WebSocket functionality.

#### Class Methods

##### Creating WebLoader Instance

```Objective-C
+ (LWWebLoader *)webloader;
```

Creates and returns a new LWWebLoader instance.

**Returns:** A new `LWWebLoader` instance.

**Example:**
```Objective-C
LWWebLoader *loader = LWWebLoader.webloader;
```

##### Creating Request Body

```Objective-C
+ (WLEvaluateBody *)bodyWithURLString:(NSString *)urlString
                               method:(LWWebLoadMethod)method
                      methodArguments:(NSString *)methodArguments
                            userAgent:(NSString *)userAgent
                          contentType:(NSString *)contentType
                             postData:(NSDictionary *)postData
                           uploadData:(NSData *)uploadData;
```

Creates a request body object for HTTP operations.

**Parameters:**
- `urlString`: The URL string for the request
- `method`: The HTTP method type (see `LWWebLoadMethod`)
- `methodArguments`: Optional additional method arguments
- `userAgent`: Optional custom user agent string
- `contentType`: Optional content type (e.g., "application/json")
- `postData`: Optional dictionary for POST data
- `uploadData`: Optional binary data for file uploads

**Returns:** A configured `WLEvaluateBody` instance.

**Example:**
```Objective-C
WLEvaluateBody *body = [LWWebLoader bodyWithURLString:@"https://api.example.com/data"
                                               method:GetData
                                      methodArguments:nil
                                            userAgent:@"MyApp/1.0"
                                          contentType:nil
                                             postData:nil
                                           uploadData:nil];
```

#### Instance Methods - HTTP Operations

##### Execute Request

```Objective-C
- (void)evaluateWithBody:(WLEvaluateBody *)evaluateBody
              parentView:(UIView *)parentView
dataLoadCompletionHandler:(void (^)(WLHanderBody *body, NSError *error))handler;
```

Executes an HTTP request with the specified body configuration.

**Parameters:**
- `evaluateBody`: The request configuration
- `parentView`: The parent view to attach the hidden WKWebView
- `handler`: Completion block called when data is loaded or an error occurs

**Handler Parameters:**
- `body`: The response body containing result and type information
- `error`: An error object if the request failed

**Example:**
```Objective-C
[loader evaluateWithBody:evaluateBody
              parentView:self.view
dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    if (error) {
        NSLog(@"Error: %@", error);
        return;
    }
    // Process response based on body.bodyType
}];
```

#### Instance Methods - WebSocket Operations

##### Start WebSocket WebView

```Objective-C
- (void)startWSWebViewWithParentView:(UIView *)parentView
              receiveWSDataHandler:(void (^)(WLHanderBody *data, NSError *error))handler;
```

Initializes and starts a WebSocket-enabled WKWebView.

**Parameters:**
- `parentView`: The parent view to attach the WebSocket WebView
- `handler`: Completion block called when WebSocket data is received

**Example:**
```Objective-C
[wsLoader startWSWebViewWithParentView:self.view
                receiveWSDataHandler:^(WLHanderBody *body, NSError *error) {
    if (body.bodyType == BodyType_WSOpened) {
        NSLog(@"WebSocket connected");
    }
}];
```

##### Connect WebSocket

```Objective-C
- (void)wsConnect;
```

Establishes a WebSocket connection. Must be called after `startWSWebViewWithParentView:receiveWSDataHandler:`.

**Example:**
```Objective-C
[wsLoader wsConnect];
```

##### Send String Message

```Objective-C
- (void)wsSendString:(NSString *)string;
```

Sends a text message through the WebSocket connection.

**Parameters:**
- `string`: The text message to send

**Example:**
```Objective-C
[wsLoader wsSendString:@"Hello WebSocket!"];
```

##### Send Binary Data

```Objective-C
- (void)wsSendData:(NSData *)data;
```

Sends binary data through the WebSocket connection.

**Parameters:**
- `data`: The binary data to send

**Example:**
```Objective-C
NSData *binaryData = [@"binary content" dataUsingEncoding:NSUTF8StringEncoding];
[wsLoader wsSendData:binaryData];
```

##### Start File Stream

```Objective-C
- (void)wsSendStreamStart;
```

Initiates a file streaming session over WebSocket. Call this before sending file chunks.

**Example:**
```Objective-C
[wsLoader wsSendStreamStart];
```

##### Send Stream Chunk

```Objective-C
- (void)wsSendStreaming:(NSData *)data;
```

Sends a chunk of streaming data. Must be called between `wsSendStreamStart` and `wsSendStreamEnd`.

**Parameters:**
- `data`: A chunk of file data

**Example:**
```Objective-C
NSData *chunk = [fileHandle readDataOfLength:10240];
[wsLoader wsSendStreaming:chunk];
```

##### End File Stream

```Objective-C
- (void)wsSendStreamEnd;
```

Finalizes the file streaming session. Call this after all chunks have been sent.

**Example:**
```Objective-C
[wsLoader wsSendStreamEnd];
```

##### Remove WebSocket WebView

```Objective-C
- (void)removeWSWebView;
```

Removes and cleans up the WebSocket WebView.

**Example:**
```Objective-C
[wsLoader removeWSWebView];
wsLoader = nil;
```

### Enumerations

#### LWWebLoadMethod

Defines the HTTP method types for web loading operations.

```Objective-C
typedef NS_OPTIONS(NSUInteger, LWWebLoadMethod) {
    GetData = 0,           // HTTP GET request
    PostData = 1,          // HTTP POST request
    UploadData = 2,        // File upload with multipart/form-data
    DownloadFile = 3,      // Download file to memory
    DownloadStream = 4,    // Download file with streaming
    GetClipboardText = 5,  // Get clipboard text (internal use)
    NativeLog = 6,         // Native logging (internal use)
};
```

#### WLHanderBodyType

Defines the response body types.

```Objective-C
typedef NS_OPTIONS(NSUInteger, WLHanderBodyType) {
    BodyType_Error = 0,        // Error occurred
    BodyType_Json = 1,         // JSON response (NSDictionary/NSArray)
    BodyType_PlainText = 2,    // Plain text response (NSString)
    BodyType_Data = 3,         // Binary data response (NSData)
    BodyType_StreamStart = 4,  // Stream initialization
    BodyType_Streaming = 5,    // Stream in progress (NSNumber progress)
    BodyType_StreamEnd = 6,    // Stream completed (NSString file path)
    BodyType_WSOpened = 7,     // WebSocket connection opened
    BodyType_WSClosed = 8,     // WebSocket connection closed
};
```

### Data Classes

#### WLEvaluateBody

Request body configuration object.

**Properties:**
- `url` (NSURL): The request URL
- `requestId` (NSString): Unique identifier for the request
- `evalueteJSMethod` (NSString): JavaScript method to execute
- `methodArguments` (NSString): Arguments for the method
- `jsCode` (NSString): JavaScript code to evaluate

#### WLHanderBody

Response body object containing result data.

**Properties:**
- `requestId` (NSString): Request identifier matching the request
- `bodyType` (WLHanderBodyType): Type of the response body
- `handlerResult` (id): The actual result data (type varies by bodyType)

**Class Method:**
```Objective-C
+ (instancetype)bodyWithId:(NSString *)rid
                  bodyType:(WLHanderBodyType)bodyType
             handlerResult:(id)handlerResult;
```

**Result Types by Body Type:**
| Body Type | Result Type | Description |
|-----------|-------------|-------------|
| BodyType_Json | NSDictionary/NSArray | Parsed JSON data |
| BodyType_PlainText | NSString | Plain text content |
| BodyType_Data | NSData | Binary data |
| BodyType_StreamStart | NSString | Stream start message |
| BodyType_Streaming | NSNumber | Download progress (0.0-1.0) |
| BodyType_StreamEnd | NSString | File path where stream was saved |
| BodyType_Error | NSString | Error message |
| BodyType_WSOpened | NSString | Connection confirmation |
| BodyType_WSClosed | NSString | Disconnection message |

#### WLMessageBody

Internal message body used for JavaScript bridge communication.

**Properties:**
- `requestId` (NSString): Request identifier
- `type` (NSString): Message type
- `done` (NSNumber): Completion status
- `chrunkOrder` (NSNumber): Chunk order number
- `total` (NSNumber): Total bytes for streaming
- `received` (NSNumber): Received bytes for streaming
- `value` (NSString): Message value

### WebSocket Integration

#### WebSocketManager

For native WebSocket server functionality (requires LWWebSocket dependency).

**Key Methods:**
```Objective-C
// Start WebSocket server on specified port
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

// Send message from native side
[[WebSocketManager sharedManager] sendMessage:@"Hello"];

// Send data from native side
[[WebSocketManager sharedManager] sendData:binaryData];

// Send file from native side
[[WebSocketManager sharedManager] sendDataWithFileURL:fileURL];

// Stop server
[[WebSocketManager sharedManager] stopServer];
```

**Callbacks:**
```Objective-C
// Handle received text messages
[WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t messageType, NSString *message) {
    // Process message
};

// Handle received binary data
[WebSocketManager sharedManager].handleReceiveData = ^(uint32_t messageType, NSData *data) {
    // Process data
};
```

#### Socket Message Types

```Objective-C
typedef enum {
    SocketMessageType_String,      // Text message
    SocketMessageType_Data,        // Binary data
    SocketMessageType_StreamStart, // Stream initiation
    SocketMessageType_Streaming,   // Stream chunk
    SocketMessageType_StreamEnd,   // Stream completion
} SocketMessageType;
```

## Advanced Usage

### Custom Headers and User Agent

Configure custom user agent strings for your requests:

```Objective-C
NSString *userAgent = @"MyApp/1.0 (iOS; iPhone; Build 123)";
WLEvaluateBody *body = [LWWebLoader bodyWithURLString:urlString
                                               method:GetData
                                      methodArguments:nil
                                            userAgent:userAgent
                                          contentType:nil
                                             postData:nil
                                           uploadData:nil];
```

### Custom Content-Type

Set specific content types for POST requests:

```Objective-C
NSString *contentType = @"application/x-www-form-urlencoded";
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:PostData
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:contentType
                                                     postData:postData
                                                   uploadData:nil];
```

### Progress Tracking for Streaming Downloads

Monitor real-time progress during large file downloads:

```Objective-C
[loader evaluateWithBody:evaluateBody
              parentView:self.view
dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    switch (body.bodyType) {
        case BodyType_StreamStart:
            // Initialize progress UI
            [self showProgressBar];
            break;

        case BodyType_Streaming: {
            double progress = [body.handlerResult doubleValue];
            NSLog(@"Download progress: %.2f%%", progress * 100);
            // Update progress UI
            [self updateProgressBar:progress];
            break;
        }

        case BodyType_StreamEnd:
            NSLog(@"Download complete: %@", body.handlerResult);
            // Show completion UI
            [self hideProgressBar];
            break;

        default:
            break;
    }
}];
```

### Concurrent Requests

LWWebLoader supports concurrent requests by creating multiple instances:

```Objective-C
// Create multiple loader instances
LWWebLoader *loader1 = LWWebLoader.webloader;
LWWebLoader *loader2 = LWWebLoader.webloader;

// Execute requests concurrently
[loader1 evaluateWithBody:body1
               parentView:self.view
dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    // Handle first request
    NSLog(@"Request 1 completed");
}];

[loader2 evaluateWithBody:body2
               parentView:self.view
dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    // Handle second request
    NSLog(@"Request 2 completed");
}];
```

### Complete WebSocket Communication Flow

Here's a complete example of WebSocket setup and usage:

```Objective-C
// 1. Initialize WebSocket loader
LWWebLoader *wsLoader = LWWebLoader.webloader;

// 2. Start WebSocket server (native side)
NSString *webPath = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,
                                                         NSUserDomainMask,
                                                         YES).firstObject;
[[WebSocketManager sharedManager] startServerWithPort:11335 webPath:webPath];

// 3. Set up native side message callbacks
[WebSocketManager sharedManager].handleReceiveMessage = ^(uint32_t type, NSString *msg) {
    NSLog(@"Received from WebView: %@", msg);
};

// 4. Start WebSocket WebView
[wsLoader startWSWebViewWithParentView:self.view
                receiveWSDataHandler:^(WLHanderBody *body, NSError *error) {
    if (body.bodyType == BodyType_WSOpened) {
        NSLog(@"WebSocket connected successfully!");
    }
}];

// 5. Connect WebSocket
[wsLoader wsConnect];

// 6. Send text messages
[wsLoader wsSendString:@"Hello from iOS!"];

// 7. Stream a file
[wsLoader wsSendStreamStart];
NSError *error;
NSFileHandle *fileHandle = [NSFileHandle fileHandleForReadingFromURL:fileURL error:&error];
NSData *chunk;
while ((chunk = [fileHandle readDataOfLength:10240])) {
    if (chunk.length > 0) {
        [wsLoader wsSendStreaming:chunk];
    }
}
[wsLoader wsSendStreamEnd];

// 8. Clean up when done
[[WebSocketManager sharedManager] stopServer];
[wsLoader removeWSWebView];
wsLoader = nil;
```

### Error Handling Best Practices

Implement comprehensive error handling:

```Objective-C
[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    // Handle NSError (network errors, timeouts, etc.)
    if (error) {
        NSLog(@"Request failed with error: %@", error.localizedDescription);
        [self showErrorAlert:error.localizedDescription];
        return;
    }

    // Handle business/application errors
    if (body.bodyType == BodyType_Error) {
        NSLog(@"Business error: %@", body.handlerResult);
        [self showErrorAlert:body.handlerResult];
        return;
    }

    // Process successful response
    [self handleSuccessfulResponse:body];
}];
```

## Architecture

### Design Overview

LWWebLoader employs an innovative architecture that leverages WKWebView's capabilities:

**Core Components:**

1. **LWWebLoader**: Main controller managing WebView instances and coordinating data transfer
2. **WLWebView**: Custom WKWebView handling page navigation and JavaScript execution
3. **LWWLWKScriptMessageHandler**: Script message handler managing JavaScript-to-native communication
4. **loader.html**: Embedded HTML page containing JavaScript implementation for data loading

### How It Works

#### Data Loading Workflow

1. **Request Creation**: Create `WLEvaluateBody` using `bodyWithURLString:method:...`
2. **WebView Initialization**: Create WLWebView instance and load loader.html
3. **Script Injection**: Inject JavaScript code via WKUserScript
4. **Request Execution**: Execute JavaScript fetch request in WebView
5. **Data Transfer**: JavaScript sends data back via `window.webkit.messageHandlers`
6. **Data Processing**: Native code receives and processes data (Base64 decode if needed)
7. **Callback Notification**: Return results via completion handler

#### Streaming Download Workflow

Optimized for large files:

1. **Start Download**: Send `b64streamstart` message
2. **Chunked Transfer**: JavaScript reads Response Stream, sends `b64streaming` chunks
3. **File Writing**: Native code uses NSOutputStream to write chunks to temp file
4. **Progress Updates**: Real-time progress calculation and callbacks
5. **Completion**: Send `b64streamend` message with final file path

### Key Technical Features

#### JavaScript Bridge Communication

Uses WKWebView's Script Message Handler for bidirectional communication:

```javascript
// JavaScript sends to native
window.webkit.messageHandlers.bridge.postMessage({
    requestId: requestId,
    type: 'json',
    value: data
});
```

```objective-c
// Native registers message handler
[webConfiguration.userContentController addScriptMessageHandler:messageHandler
                                                           name:@"bridge"];
```

#### Base64 Encoding for Binary Data

Binary data is Base64 encoded during JavaScript-to-native transfer:

```javascript
// JavaScript encodes binary data
function arrayBufferToBase64(buffer) {
    let binary = '';
    let bytes = new Uint8Array(buffer);
    for (let i = 0; i < bytes.byteLength; i++) {
        binary += String.fromCharCode(bytes[i]);
    }
    return window.btoa(binary);
}
```

```objective-c
// Objective-C decodes
NSData *data = [[NSData alloc] initWithBase64EncodedString:body.value options:0];
```

#### WebView Lifecycle Management

Smart WebView lifecycle management:

- **Reuse Mechanism**: Reuses existing WebView instances for same-host requests
- **Auto-Release**: Automatically cleans up WebView after request completion
- **Delegate Management**: Properly handles WKNavigationDelegate and WKScriptMessageHandler registration/deregistration

## Performance Optimization

### WebView Reuse

For frequent requests to the same domain, LWWebLoader automatically reuses WebView instances:

```objective-c
// Check if WebView can be reused
BOOL isSameHost = [self.webview.URL.host isEqualToString:evaluateBody.url.host]
                   && self.webview.URL.port.integerValue == evaluateBody.url.port.integerValue;

if (!self.webview || !self.webview.didCommitNavigation || !isSameHost) {
    // Create new WebView
} else {
    // Reuse existing WebView
}
```

### Choosing the Right Download Method

- **Small Files (< 10MB)**: Use `DownloadFile` for one-time memory loading
- **Large Files (> 10MB)**: Use `DownloadStream` for streaming to disk, saving memory

### Memory Management Best Practices

- Release unused WebLoader instances promptly
- Framework automatically manages NSOutputStream lifecycle for streaming
- Use `__weak` in completion handlers to avoid retain cycles

```objective-c
__weak typeof(self) weakSelf = self;
[self.webloader evaluateWithBody:evaluateBody
                      parentView:self.view
       dataLoadCompletionHandler:^(WLHanderBody *body, NSError *error) {
    [weakSelf handleResponse:body];
}];
```

### WebView Limitations

iOS limits the number of WKWebView instances. Avoid creating too many simultaneously.

## FAQ

### Why use WKWebView for data loading?

**Advantages:**
- Independent network process doesn't block main thread
- Leverages browser caching mechanisms
- Supports standard Web APIs (Fetch, WebSocket)
- Can bypass certain network restrictions
- Handles SSL/TLS automatically

### What's the difference between streaming and regular downloads?

- **Regular Download (`DownloadFile`)**: Loads entire file into memory, suitable for small files
- **Streaming Download (`DownloadStream`)**: Downloads while writing to disk with real-time progress, suitable for large files

### Does it support HTTPS certificate validation?

Yes, WKWebView automatically handles HTTPS certificate validation. For custom validation logic, implement WKNavigationDelegate methods.

### Does it support upload progress monitoring?

No, the current version doesn't support upload progress monitoring as JavaScript Fetch API's upload progress features aren't widely supported yet.

### Does WebSocket functionality require additional dependencies?

Yes, WebSocket functionality requires the `LWWebSocket` library:

```ruby
pod 'LWWebSocket', :source => 'https://gitee.com/lw_ios_project/mylibrepo.git'
```

### How to handle large file downloads without memory issues?

Use the `DownloadStream` method for streaming downloads:

```objective-c
WLEvaluateBody *evaluateBody = [LWWebLoader bodyWithURLString:urlString
                                                       method:DownloadStream
                                              methodArguments:nil
                                                    userAgent:nil
                                                  contentType:nil
                                                     postData:nil
                                                   uploadData:nil];
```

### Does it support resumable downloads?

Not directly, but you can implement it by setting the Range header in HTTP requests.

### How to configure App Transport Security (ATS) for HTTP access?

Add to your Info.plist:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

### Is it thread-safe?

All LWWebLoader APIs should be called from the main thread.

## Key Advantages

- **No External Dependencies**: Built entirely on WKWebView, no third-party networking libraries required
- **Unified API**: Single interface for HTTP requests, file operations, and WebSocket communication
- **Streaming Support**: Efficient handling of large files without memory overhead
- **Progress Tracking**: Real-time progress updates for downloads and uploads
- **Type Safety**: Automatic response type detection and parsing
- **Error Handling**: Comprehensive error handling with detailed error messages
- **Independent Network Process**: Utilizes WKWebView's separate process for better performance

## Author

**luowei**
Email: [luowei@wodedata.com](mailto:luowei@wodedata.com)

## Contributing

Contributions are welcome! Please feel free to submit issues and pull requests.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## Related Projects

- [LWWebSocket](https://gitee.com/lw_ios_project/mylibrepo) - WebSocket support library for LWWebLoader

## Acknowledgments

Thanks to all contributors who have helped improve this project.

## License

LWWebLoader is available under the MIT license. See the [LICENSE](LICENSE) file for more info.

```
Copyright (c) 2019 luowei <luowei@wodedata.com>

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
```

---

**If you have any questions or suggestions, please contact us through [GitHub Issues](https://github.com/luowei/LWWebLoader/issues).**
