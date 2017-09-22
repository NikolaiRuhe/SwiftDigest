import SwiftDigest
import XCTest


class MD5Tests: XCTestCase {

    func testEmpty() {
        XCTAssertEqual(
            Data().md5,
            MD5Digest(rawValue: "d41d8cd98f00b204e9800998ecf8427e")
        )
    }

    func testData() {
        XCTAssertEqual(
            MD5Digest(rawValue: "d41d8cd98f00b204e9800998ecf8427e")?.data,
            Data([212, 29, 140, 217, 143, 0, 178, 4, 233, 128, 9, 152, 236, 248, 66, 126,])
        )
    }

    func testBytes() {
        XCTAssertEqual(
            "\(MD5Digest(rawValue: "d41d8cd98f00b204e9800998ecf8427e")!.bytes)",
            "(212, 29, 140, 217, 143, 0, 178, 4, 233, 128, 9, 152, 236, 248, 66, 126)"
        )
    }

    func testFox1() {
        let input = "The quick brown fox jumps over the lazy dog"
        XCTAssertEqual(
            input.utf8.md5,
            MD5Digest(rawValue: "9e107d9d372bb6826bd81d3542a419d6")
        )
    }

    func testFox2() {
        let input = "The quick brown fox jumps over the lazy dog."
        XCTAssertEqual(
            input.utf8.md5,
            MD5Digest(rawValue: "e4d909c290d0fb1ca068ffaddf22cbd0")
        )
    }

    func testTwoFooterChunks() {
        let input = Data(count: 57)
        XCTAssertEqual(
            input.md5,
            MD5Digest(rawValue: "ab9d8ef2ffa9145d6c325cefa41d5d4e")
        )
    }

    func test4KBytes() {
        var input = String(repeating: "The quick brown fox jumps over the lazy dog.", count: 100)
        XCTAssertEqual(
            input.utf8.md5,
            MD5Digest(rawValue: "7052292b1c02ae4b0b35fabca4fbd487")
        )
    }

    func test4MBytes() {
        var input = String(repeating: "The quick brown fox jumps over the lazy dog.", count: 100000)
        XCTAssertEqual(
            input.utf8.md5,
            MD5Digest(rawValue: "f8a4ffa8b1c902f072338caa1e4482ce")
        )
    }

    func testRecursive() {
        XCTAssertEqual(
            "".utf8.md5.description.utf8.md5.description.utf8.md5.description.utf8.md5,
            MD5Digest(rawValue: "5a8dccb220de5c6775c873ead6ff2e43")
        )
    }
}
