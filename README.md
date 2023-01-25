# swift-ndjson

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg?style=flat-square)](https://github.com/apple/swift-package-manager)

A Swift implementation of [NDJSON (Newline Delimited JSON)](http://ndjson.org/) encoding/decoding.

```swift
import NDJSON

// Encode
try NDJSONEncoder().encode(sequence)

// Decode
try NDJSONDecoder().decode(Value.self, from: data)

// Decode asynchronously
for try await value in NDJSONDecoder().stream(Value.self, from: inputStream) {
  ...
}
```

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/woxtu/swift-ndjson.git", from: "1.0.0")
```

## License

Licensed under the MIT license.
