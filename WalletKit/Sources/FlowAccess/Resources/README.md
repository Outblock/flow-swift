#  Generating client code using the protocol buffer compiler.

## Overview
Generating client code depends on the gRPC Swift API and code generator. gRPC is intended for use with Apple's SwiftProtobuf support for Protocol Buffers. Both gRPC and SwiftProtobuf contain code generation plugins for protoc, Google's Protocol Buffer compiler, and both contain libraries of supporting code that is needed to build and run the generated code.

## Generating Code
### Step 1
Before generating code, make sure gRPC Swift and SwiftProtobuf are properly installed and configured: 
- gRPC: https://github.com/grpc/grpc-swift
- SwiftProtobuf: https://github.com/apple/swift-protobuf 

### Step 2
Download the Flow Protocol Buffer Source Files from https://github.com/onflow/flow

### Step 3 
Generate the code using the following commands:

```console
$ cd flow-master && mkdir flow-pb && mkdir flow-grpc 

$ cd protobuf 

$ protoc --swift_out=../flow-pb --swift_opt=Visibility=Public flow/**/*.proto && protoc --grpc-swift_out=../flow-grpc --grpc-swift_opt=Visibility=Public flow/**/*.proto
```

### Step 4
Import the gRPC  and SwiftProtobuf files (*.grpc.swift and *.pb.swift, respectively) into Xcode. Note: Importing the legacy folder might cause issues with filenames clashing.
