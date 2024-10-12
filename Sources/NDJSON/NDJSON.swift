import Foundation

public enum StreamError: Error {
  case unavailable(Error?)
  case noBytesAvailable
}

public class NDJSONEncoder {
  public typealias KeyEncodingStrategy = JSONEncoder.KeyEncodingStrategy
  public typealias DateEncodingStrategy = JSONEncoder.DateEncodingStrategy
  public typealias DataEncodingStrategy = JSONEncoder.DataEncodingStrategy
  public typealias NonConformingFloatEncodingStrategy = JSONEncoder.NonConformingFloatEncodingStrategy

  public var keyEncodingStrategy: KeyEncodingStrategy {
    get { encoder.keyEncodingStrategy }
    set { encoder.keyEncodingStrategy = newValue }
  }

  public var userInfo: [CodingUserInfoKey: Any] {
    get { encoder.userInfo }
    set { encoder.userInfo = newValue }
  }

  public var dateEncodingStrategy: DateEncodingStrategy {
    get { encoder.dateEncodingStrategy }
    set { encoder.dateEncodingStrategy = newValue }
  }

  public var dataEncodingStrategy: DataEncodingStrategy {
    get { encoder.dataEncodingStrategy }
    set { encoder.dataEncodingStrategy = newValue }
  }

  public var nonConformingFloatEncodingStrategy: NonConformingFloatEncodingStrategy {
    get { encoder.nonConformingFloatEncodingStrategy }
    set { encoder.nonConformingFloatEncodingStrategy = newValue }
  }

  private let encoder: JSONEncoder = .init()

  public init() {}

  public func encode<S>(_ sequence: S) throws -> Data where S: Sequence, S.Element: Encodable {
    .init(try sequence.map { try encoder.encode($0) }.joined(separator: [.newline]))
  }
}

public class NDJSONDecoder {
  public typealias KeyDecodingStrategy = JSONDecoder.KeyDecodingStrategy
  public typealias DateDecodingStrategy = JSONDecoder.DateDecodingStrategy
  public typealias DataDecodingStrategy = JSONDecoder.DataDecodingStrategy
  public typealias NonConformingFloatDecodingStrategy = JSONDecoder.NonConformingFloatDecodingStrategy

  public var keyDecodingStrategy: KeyDecodingStrategy {
    get { decoder.keyDecodingStrategy }
    set { decoder.keyDecodingStrategy = newValue }
  }

  public var userInfo: [CodingUserInfoKey: Any] {
    get { decoder.userInfo }
    set { decoder.userInfo = newValue }
  }

  public var dateDecodingStrategy: DateDecodingStrategy {
    get { decoder.dateDecodingStrategy }
    set { decoder.dateDecodingStrategy = newValue }
  }

  public var dataDecodingStrategy: DataDecodingStrategy {
    get { decoder.dataDecodingStrategy }
    set { decoder.dataDecodingStrategy = newValue }
  }

  public var nonConformingFloatDecodingStrategy: NonConformingFloatDecodingStrategy {
    get { decoder.nonConformingFloatDecodingStrategy }
    set { decoder.nonConformingFloatDecodingStrategy = newValue }
  }

  public var ignoreEmptyLines: Bool = false

  let readBufferSize: Int = 1024

  let whitespaces: Set<UInt8> = [
    .horizontalTab,
    .newline,
    .carriageReturn,
    .space,
  ]

  private let decoder: JSONDecoder = .init()

  public init() {}

  public func decode<T>(_ type: T.Type, from data: Data) throws -> [T] where T: Decodable {
    try data
      .split(separator: .newline, omittingEmptySubsequences: ignoreEmptyLines)
      .filter { data in !ignoreEmptyLines || !data.allSatisfy { whitespaces.contains($0) } }
      .map { try decoder.decode(type, from: $0) }
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0, *)
  public func stream<T>(_ type: T.Type, from stream: InputStream) -> AsyncThrowingStream<T, Error> where T: Decodable {
    .init { continuation in
      if stream.streamStatus == .notOpen {
        stream.open()
      }

      guard stream.streamStatus == .open else {
        continuation.finish(throwing: StreamError.unavailable(stream.streamError))
        return
      }

      continuation.onTermination = { _ in
        stream.close()
      }

      var data = Data()

      while !data.isEmpty || stream.hasBytesAvailable {
        if let index = data.firstIndex(of: .newline) {
          do {
            if !ignoreEmptyLines || !data[..<index].allSatisfy({ whitespaces.contains($0) }) {
              continuation.yield(try decoder.decode(type, from: data[..<index]))
            }
            data.removeSubrange(...index)
            continue
          } catch {
            continuation.finish(throwing: error)
            return
          }
        }

        if stream.hasBytesAvailable {
          let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: readBufferSize)
          let readSize = stream.read(buffer, maxLength: readBufferSize)
          if readSize > 0 {
            data.append(buffer, count: readSize)
            continue
          } else {
            continuation.finish(throwing: StreamError.noBytesAvailable)
            return
          }
        }

        break
      }

      do {
        if !ignoreEmptyLines || !data.allSatisfy({ whitespaces.contains($0) }) {
          continuation.yield(try decoder.decode(type, from: data))
        }
        data.removeAll()
      } catch {
        continuation.finish(throwing: error)
        return
      }

      continuation.finish()
    }
  }
}

extension UInt8 {
  static let horizontalTab: UInt8 = 0x09
  static let newline: UInt8 = 0x0A
  static let carriageReturn: UInt8 = 0x0D
  static let space: UInt8 = 0x20
}
