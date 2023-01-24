import Foundation

public enum StreamError: Error {
  case unavailable(Error?)
  case noBytesAvailable
}

public class NDJSONDecoder {
  let readBufferSize: Int = 1024

  public init() {}

  public func decode<T>(_ type: T.Type, from data: Data) throws -> [T] where T: Decodable {
    let decoder = JSONDecoder()

    return try data
      .split(separator: .newline)
      .map { try decoder.decode(type, from: $0) }
  }

  @available(iOS 13.0, macOS 10.15, tvOS 13.0, watchOS 6.0,*)
  public func stream<T>(_ type: T.Type, from stream: InputStream) -> AsyncThrowingStream<T, Error> where T: Decodable {
    let decoder = JSONDecoder()

    return AsyncThrowingStream { continuation in
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
            continuation.yield(try decoder.decode(type, from: data[..<index]))
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
        continuation.yield(try decoder.decode(type, from: data))
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
  static let newline: UInt8 = 0x0A
}
