# SwiftDigest

Copyright (c) 2017 Nikolai Ruhe.

SwiftDigest is released under the MIT License.

## Contents

SwiftDigest currently contains only a single hashing algorithm: MD5. I'll add more in the future. Or not.

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
