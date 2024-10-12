import XCTest

@testable import JSONLines

final class JSONLinesEncoderTests: XCTestCase {
  func testEncodeValues() throws {
    let encoder = JSONLinesEncoder()
    XCTAssertEqual(
      try encoder.encode([0, 1, 2]),
      """
      0
      1
      2
      """.data(using: .utf8)!
    )
  }
}

final class JSONLinesDecoderTests: XCTestCase {
  func testDecodeValues() throws {
    let decoder = JSONLinesDecoder()
    let data = """
        0
        1
        2
      """.data(using: .utf8)!
    XCTAssertEqual(
      try decoder.decode(Int.self, from: data),
      [0, 1, 2]
    )
  }

  func testDecodeValuesContainingEmptyLines() throws {
    var decoder = JSONLinesDecoder()
    decoder.ignoreEmptyLines = true
    let data = """

        0

        1
        \r\t
        2

      """.data(using: .utf8)!
    XCTAssertEqual(
      try decoder.decode(Int.self, from: data),
      [0, 1, 2]
    )
  }

  func testDecodeValuesAsynchronously() async throws {
    let decoder = JSONLinesDecoder()
    let data = """
        0
        1
        2
      """.data(using: .utf8)!
    let result = try await decoder.stream(Int.self, from: InputStream(data: data)).reduce(into: []) { $0.append($1) }
    XCTAssertEqual(result, [0, 1, 2])
  }

  func testDecodeValuesContainingEmptyLinesAsynchronously() async throws {
    var decoder = JSONLinesDecoder()
    decoder.ignoreEmptyLines = true
    let data = """

        0

        1
        \r\t
        2

      """.data(using: .utf8)!
    let result = try await decoder.stream(Int.self, from: InputStream(data: data)).reduce(into: []) { $0.append($1) }
    XCTAssertEqual(result, [0, 1, 2])
  }
}
