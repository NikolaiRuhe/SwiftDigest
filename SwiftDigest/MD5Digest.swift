// SwiftDigest | MD5Digest
// Copyright (c) 2017 Nikolai Ruhe
// SwiftDigest is released under the MIT License

import Foundation


/// Pure Swift implementation of the MD5 algorithm.
///
/// Copyright (c) 2017 Nikolai Ruhe.
/// This MD5 implementation is roughly based on https://en.wikipedia.org/wiki/MD5

public struct MD5Digest : Hashable, RawRepresentable, CustomStringConvertible, Codable {

    private let _digest: (UInt64, UInt64)

    /// Perform hashing of the supplied data.
    public init(from input: Data) {
        _digest = MD5State(input).digest
    }

    /// Create a digest from reading a hex representation from the supplied string.
    ///
    /// The string _must_ consist of exactly 32 hex digits. Otherwise the initializer
    /// returns `nil`.
    public init?(rawValue: String) {
        let input = rawValue as NSString
        guard input.length == 32 else { return nil }
        guard let high = UInt64(input.substring(to: 16), radix: 16) else { return nil }
        guard let low  = UInt64(input.substring(from: 16), radix: 16) else { return nil }
        _digest = (high.byteSwapped, low.byteSwapped)
    }

    public var rawValue: String { return self.description }

    public var description: String {
        return String(format: "%016lx%016lx",
                      _digest.0.byteSwapped,
                      _digest.1.byteSwapped)
    }

    public var hashValue: Int {
        return Int(_digest.0 ^ _digest.1)
    }

    public static func ==(lhs: MD5Digest, rhs: MD5Digest) -> Bool {
        return lhs._digest.0 == rhs._digest.0 && lhs._digest.1 == rhs._digest.1
    }

    public var data: Data {
        var v = self
        return withUnsafeBytes(of: &v) {
            return Data(bytes: $0.baseAddress!, count: $0.count)
        }
    }

    public var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) {
        var v = self
        return withUnsafeBytes(of: &v) {
            (ptr: UnsafeRawBufferPointer) -> (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) in
            return (ptr[0], ptr[1], ptr[2], ptr[3], ptr[4], ptr[5], ptr[6], ptr[7],
                    ptr[8], ptr[9], ptr[10], ptr[11], ptr[12], ptr[13], ptr[14], ptr[15])
        }
    }
}


public extension Data {
    var md5: MD5Digest {
        return MD5Digest(from: self)
    }
}


public extension String.UTF8View {
    var md5: MD5Digest {
        return MD5Digest(from: Data(self))
    }
}


fileprivate struct MD5State {

    var a = UInt32(0x67452301)
    var b = UInt32(0xefcdab89)
    var c = UInt32(0x98badcfe)
    var d = UInt32(0x10325476)

    init(_ input: Data) {

        // NOTE: A static assert for little endian platform would be great here.
        // Not sure how to do this in Swift, though.
        assert(1.littleEndian == 1 && 2.bigEndian != 2)

        var start = input.startIndex
        while start + 64 < input.endIndex {
            defer { start += 64 }
            self.feed(chunk: input[start ..< start + 64])
        }

        var remaining = Data(input[start...])
        remaining.append(0x80)

        while remaining.count % 64 != 56 {
            remaining.append(0)
        }

        let len = UInt64(input.count) << 3
        for i in 0 ..< 8 {
            remaining.append(UInt8(truncatingIfNeeded: len >> UInt64(i * 8)))
        }

        switch remaining.count {
        case 128:
            self.feed(chunk: remaining[..<64])
            self.feed(chunk: remaining[64...])

        case 64:
            self.feed(chunk: remaining)

        default:
            preconditionFailure("unexpected remaining bytes count")
        }
    }

    var digest: (UInt64, UInt64) {
        let high = UInt64(a) | UInt64(b) << 32
        let low  = UInt64(c) | UInt64(d) << 32
        return (high, low)
    }

    mutating func feed(chunk data: Data) {
        precondition(data.count == 64)

        data.withUnsafeBytes {
            (ptr: UnsafePointer<UInt32>) in
            feed(chunkPtr: ptr)
        }
    }

    private mutating func feed(chunkPtr: UnsafePointer<UInt32>) {

        let old = self

        feed(f0, chunkPtr[00], 0xd76aa478, 07); feed(f0, chunkPtr[01], 0xe8c7b756, 12)
        feed(f0, chunkPtr[02], 0x242070db, 17); feed(f0, chunkPtr[03], 0xc1bdceee, 22)
        feed(f0, chunkPtr[04], 0xf57c0faf, 07); feed(f0, chunkPtr[05], 0x4787c62a, 12)
        feed(f0, chunkPtr[06], 0xa8304613, 17); feed(f0, chunkPtr[07], 0xfd469501, 22)
        feed(f0, chunkPtr[08], 0x698098d8, 07); feed(f0, chunkPtr[09], 0x8b44f7af, 12)
        feed(f0, chunkPtr[10], 0xffff5bb1, 17); feed(f0, chunkPtr[11], 0x895cd7be, 22)
        feed(f0, chunkPtr[12], 0x6b901122, 07); feed(f0, chunkPtr[13], 0xfd987193, 12)
        feed(f0, chunkPtr[14], 0xa679438e, 17); feed(f0, chunkPtr[15], 0x49b40821, 22)

        feed(f1, chunkPtr[01], 0xf61e2562, 05); feed(f1, chunkPtr[06], 0xc040b340, 09)
        feed(f1, chunkPtr[11], 0x265e5a51, 14); feed(f1, chunkPtr[00], 0xe9b6c7aa, 20)
        feed(f1, chunkPtr[05], 0xd62f105d, 05); feed(f1, chunkPtr[10], 0x02441453, 09)
        feed(f1, chunkPtr[15], 0xd8a1e681, 14); feed(f1, chunkPtr[04], 0xe7d3fbc8, 20)
        feed(f1, chunkPtr[09], 0x21e1cde6, 05); feed(f1, chunkPtr[14], 0xc33707d6, 09)
        feed(f1, chunkPtr[03], 0xf4d50d87, 14); feed(f1, chunkPtr[08], 0x455a14ed, 20)
        feed(f1, chunkPtr[13], 0xa9e3e905, 05); feed(f1, chunkPtr[02], 0xfcefa3f8, 09)
        feed(f1, chunkPtr[07], 0x676f02d9, 14); feed(f1, chunkPtr[12], 0x8d2a4c8a, 20)

        feed(f2, chunkPtr[05], 0xfffa3942, 04); feed(f2, chunkPtr[08], 0x8771f681, 11)
        feed(f2, chunkPtr[11], 0x6d9d6122, 16); feed(f2, chunkPtr[14], 0xfde5380c, 23)
        feed(f2, chunkPtr[01], 0xa4beea44, 04); feed(f2, chunkPtr[04], 0x4bdecfa9, 11)
        feed(f2, chunkPtr[07], 0xf6bb4b60, 16); feed(f2, chunkPtr[10], 0xbebfbc70, 23)
        feed(f2, chunkPtr[13], 0x289b7ec6, 04); feed(f2, chunkPtr[00], 0xeaa127fa, 11)
        feed(f2, chunkPtr[03], 0xd4ef3085, 16); feed(f2, chunkPtr[06], 0x04881d05, 23)
        feed(f2, chunkPtr[09], 0xd9d4d039, 04); feed(f2, chunkPtr[12], 0xe6db99e5, 11)
        feed(f2, chunkPtr[15], 0x1fa27cf8, 16); feed(f2, chunkPtr[02], 0xc4ac5665, 23)

        feed(f3, chunkPtr[00], 0xf4292244, 06); feed(f3, chunkPtr[07], 0x432aff97, 10)
        feed(f3, chunkPtr[14], 0xab9423a7, 15); feed(f3, chunkPtr[05], 0xfc93a039, 21)
        feed(f3, chunkPtr[12], 0x655b59c3, 06); feed(f3, chunkPtr[03], 0x8f0ccc92, 10)
        feed(f3, chunkPtr[10], 0xffeff47d, 15); feed(f3, chunkPtr[01], 0x85845dd1, 21)
        feed(f3, chunkPtr[08], 0x6fa87e4f, 06); feed(f3, chunkPtr[15], 0xfe2ce6e0, 10)
        feed(f3, chunkPtr[06], 0xa3014314, 15); feed(f3, chunkPtr[13], 0x4e0811a1, 21)
        feed(f3, chunkPtr[04], 0xf7537e82, 06); feed(f3, chunkPtr[11], 0xbd3af235, 10)
        feed(f3, chunkPtr[02], 0x2ad7d2bb, 15); feed(f3, chunkPtr[09], 0xeb86d391, 21)

        (a, b, c, d) = (a &+ old.a, b &+ old.b, c &+ old.c, d &+ old.d)
    }

    private var f0: UInt32 { return (b & c) | (~b & d) }
    private var f1: UInt32 { return (d & b) | (~d & c) }
    private var f2: UInt32 { return b ^ c ^ d }
    private var f3: UInt32 { return c ^ (b | ~d) }

    @inline(__always)
    private mutating func feed(_ f: UInt32, _ input: UInt32, _ magic: UInt32, _ shift: Int) {
        let s = a &+ input &+ magic &+ f
        let r = (s << shift) | (s >> (32 - shift))
        (a, b, c, d) = (d, b &+ r, b, c)
    }
}
