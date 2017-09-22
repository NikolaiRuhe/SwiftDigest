import SwiftDigest
import XCTest
import CommonCrypto


class MD5DigestPerformanceTests: XCTestCase {

    static var hugeTestData: Data {
        var data = "All work and no play makes Jack a dull boy\n".data(using: .utf8)!
        data.reserveCapacity(2_885_681_152) // ~ 2.6 GB
        for _ in 1...26 {
            data.append(data)
        }
        return data
    }

    func testMD5DigestSmallMessage() {
        let input = "The quick brown fox jumps over the lazy dog".data(using: .utf8)!

        self.measure {
            var digest: MD5Digest? = nil
            for _ in 1 ... 1000000 {
                digest = input.md5
            }
            XCTAssertEqual(
                digest,
                MD5Digest(rawValue: "9e107d9d372bb6826bd81d3542a419d6")
            )
        }

    }

    func testCommonCryptoSmallMessage() {
        let input = "The quick brown fox jumps over the lazy dog".data(using: .utf8)!

        self.measure {
            var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

            for _ in 1 ... 1000000 {
                digestData.resetBytes(in: 0..<Int(CC_MD5_DIGEST_LENGTH))
                digestData.withUnsafeMutableBytes { (digestBytes) -> Void in
                    input.withUnsafeBytes { (messageBytes) -> Void in
                        CC_MD5(messageBytes, CC_LONG(input.count), digestBytes)
                    }
                }
            }

            let md5Hex =  digestData.map { String(format: "%02hhx", $0) }.joined()

            XCTAssertEqual(
                md5Hex,
                "9e107d9d372bb6826bd81d3542a419d6"
            )
        }
    }

    func testMD5DigestShining() {
        let input = MD5DigestPerformanceTests.hugeTestData

        self.measure {
            let digest = input.md5
            XCTAssertEqual(
                digest,
                MD5Digest(rawValue: "91ad3b24f924e7999f10c1accd3cd510")
            )
        }

    }

    func testCommonCryptoShining() {
        let input = MD5DigestPerformanceTests.hugeTestData

        self.measure {
            var digestData = Data(count: Int(CC_MD5_DIGEST_LENGTH))

            digestData.withUnsafeMutableBytes { (digestBytes) -> Void in
                input.withUnsafeBytes { (messageBytes) -> Void in
                    CC_MD5(messageBytes, CC_LONG(input.count), digestBytes)
                }
            }

            let md5Hex =  digestData.map { String(format: "%02hhx", $0) }.joined()

            XCTAssertEqual(
                md5Hex,
                "91ad3b24f924e7999f10c1accd3cd510"
            )
        }
    }
}
