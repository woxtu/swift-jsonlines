import Foundation

public class NDJSONDecoder {
  public init() {}

  public func decode<T>(_ type: T.Type, from data: Data) throws -> [T] where T: Decodable {
    let decoder = JSONDecoder()

    return try data
      .split(separator: .newline)
      .map { try decoder.decode(type, from: $0) }
  }
}

extension UInt8 {
  static let newline: UInt8 = 0x0A
}
