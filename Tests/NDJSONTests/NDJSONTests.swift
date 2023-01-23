@testable import NDJSON
import XCTest

final class NDJSONTests: XCTestCase {
  func testExample() throws {
    XCTAssertEqual(NDJSON().text, "Hello, World!")
  }
}
