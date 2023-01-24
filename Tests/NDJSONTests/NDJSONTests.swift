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
}
