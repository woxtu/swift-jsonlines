# swift-jsonlines

[![Swift Package Manager](https://img.shields.io/badge/Swift%20Package%20Manager-compatible-brightgreen.svg?style=flat-square)](https://github.com/apple/swift-package-manager)

A Swift implementation of [JSON Lines](https://jsonlines.org/) encoding/decoding.

```swift
import JSONLines

// Encode
try JSONLinesEncoder().encode(sequence)

// Decode
try JSONLinesDecoder().decode(Value.self, from: data)

// Decode asynchronously
for try await value in JSONLinesDecoder().stream(Value.self, from: inputStream) {
  ...
}
```

## Installation

### Swift Package Manager

```swift
.package(url: "https://github.com/woxtu/swift-jsonlines.git", from: "1.0.0")
```

## License

Licensed under the MIT license.
