# SwiftDigest

Copyright (c) 2017 Nikolai Ruhe.

SwiftDigest is released under the MIT License.

## Contents

This is a pure Swift implementation of the MD5 algorithm. I might add more algorithms in the future. Or not.

The main purpose is to provide hashing through a pure Swift framework without dependencies other than
Swift Foundation. Currently no effort has been taken to optimze the performance. When hashing more than a
couple of kilo bytes it might be better to use Apple's CommonCrypto implementation.

## Examples

Hash some `Data`:

    let data = Data()
    let digest = data.md5
    print("md5: \(digest)")

    // prints: "md5: d41d8cd98f00b204e9800998ecf8427e"

Hash `String` contents:

    let input = "The quick brown fox jumps over the lazy dog"
    let digest = input.utf8.md5
    print("md5: \(digest)")

    // prints: "md5: 9e107d9d372bb6826bd81d3542a419d6"

Hash the main executable:

    let appID = try! Data(contentsOf: Bundle.main.executableURL!).md5
    // can be used to send a unique id of the app version to a server or so.

## Features

The `MD5Digest` type is ...

- `Hashable`, so it can be used as a key in dictionaries
- `RawRepresentable` to convert to and from string representations
- `CustomStringConvertible` to make printing easy
- `Codable` to enable JSON and Plist coding of types containing a digest property

## Interface

    /// Represents a 16 byte digest value, created from hashing arbitrary data.
    public struct MD5Digest : Hashable, RawRepresentable, CustomStringConvertible, Codable {

        /// Perform hashing of the supplied data.
        public init(from input: Data)

        /// Create a digest from reading a hex representation from the supplied string.
        public init?(rawValue: String)

        /// The 32 digit hex representation.
        public var rawValue: String { get }

        /// The 32 digit hex representation.
        public var description: String { get }

        /// The raw bytes of the digest value, always exactly 16 bytes.
        public var data: Data { get }

        /// The raw bytes of the digest value as a tuple.
        public var bytes: (UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8, UInt8) { get }
    }


    public extension Data {

        /// Computes md5 digest value of the contained bytes.
        public var md5: MD5Digest { get }
    }

    public extension String.UTF8View {

        /// Computes md5 digest value of the string's UTF-8 representation.
        public var md5: MD5Digest { get }
    }
