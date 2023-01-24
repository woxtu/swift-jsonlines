@testable import NDJSON
import XCTest

final class NDJSONDecoderTests: XCTestCase {
  func testDecodeValues() throws {
    let decoder = NDJSONDecoder()
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

  func testDecodeValuesAsynchronously() async throws {
    let decoder = NDJSONDecoder()
    let data = """
      0
      1
      2
    """.data(using: .utf8)!
    let result = try await decoder.stream(Int.self, from: InputStream(data: data)).reduce(into: []) { $0.append($1) }
    XCTAssertEqual(result, [0, 1, 2])
  }
}
