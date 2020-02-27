import XCTest
@testable import Request


let key = ""
final class RequestTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
    }
    
    func testGet() {
        XCTAssertFalse(key.isEmpty, "need juhe key")
        
        guard let result = Request.get("http://apis.juhe.cn/xzqh/query?fid=0&key=\(key)") else {
            XCTFail("result is nil")
            return
        }
        
        switch result {
        case .failure(let error):
            print(error)
        case .success(let response):
            XCTAssert(response.text! + "\n" == readJson("0"))
        }
    }
    
    func testPost() {
        XCTAssertFalse(key.isEmpty, "need juhe key")

        guard let result = Request.post("http://apis.juhe.cn/xzqh/query?fid=320000&key=\(key)") else {
            XCTFail("result is nil")
            return
        }
        
        switch result {
        case .failure(let error):
            print(error)
        case .success(let response):
            XCTAssert(response.text! + "\n" == readJson("320000"))
        }
    }
    
    func testUrlEncoding() {
        let resultURLString = "https://www.baidu.com/s?wd=%E5%93%88%E5%93%8832%E5%9C%A8"
        let urlString = "https://www.baidu.com/s?wd=哈哈32在".urlEncoding
        XCTAssert(urlString == resultURLString)
    }
    
    
    
    func readJson(_ name: String) -> String? {
        let path = URL(fileURLWithPath: #file).deletingLastPathComponent().path
        let filePath = path + "/JSON/" + name + ".json"
        
        guard let data = FileManager.default.contents(atPath: filePath) else { fatalError("read failed" )}
        return String(data: data, encoding: .utf8) ?? ""
    }
}
