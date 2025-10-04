//
// Created by luowei on 2019/11/4.
// Swift version
//

import UIKit
import WebKit

#if DEBUG
func WLLog(_ items: Any..., separator: String = " ", terminator: String = "\n\n\n") {
    let output = items.map { "\($0)" }.joined(separator: separator)
    print("\(#function) [Line \(#line)]\n\(output)\(terminator)")
}
#else
func WLLog(_ items: Any..., separator: String = " ", terminator: String = "\n\n\n") {}
#endif

// MARK: - Enums

public enum LWWebLoadMethod: UInt {
    case getData = 0
    case postData = 1
    case uploadData = 2
    case downloadFile = 3
    case downloadStream = 4
    case getClipboardText = 5
    case nativeLog = 6
}

public enum WLHanderBodyType: UInt {
    case error = 0
    case json = 1
    case plainText = 2
    case data = 3
    case streamStart = 4
    case streaming = 5
    case streamEnd = 6
    case other = 7
}

// MARK: - WLEvaluateBody

public class WLEvaluateBody {
    public var url: URL {
        get { _url ?? URL(string: "http://localhost")! }
        set { _url = newValue }
    }
    private var _url: URL?

    public var requestId: String?
    public var evalueteJSMethod: String?
    public var methodArguments: String?
    public var jsCode: String?
}

// MARK: - WLMessageBody

public class WLMessageBody {
    public var requestId: String = ""
    public var type: String = ""
    public var done: NSNumber = false
    public var chrunkOrder: NSNumber = 0
    public var total: NSNumber = 0
    public var received: NSNumber = 0
    public var value: String = ""

    public init(dictionary: [String: Any]) {
        requestId = dictionary["requestId"] as? String ?? ""
        type = dictionary["type"] as? String ?? ""
        value = dictionary["value"] as? String ?? ""
        done = dictionary["done"] as? NSNumber ?? false
        total = dictionary["total"] as? NSNumber ?? 0
        received = dictionary["received"] as? NSNumber ?? 0
        chrunkOrder = dictionary["chrunkOrder"] as? NSNumber ?? 0
    }
}

// MARK: - WLHanderBody

public class WLHanderBody {
    public var requestId: String?
    public var bodyType: WLHanderBodyType = .error
    public var handlerResult: Any?

    public static func body(withId rid: String, bodyType: WLHanderBodyType, handlerResult: Any?) -> WLHanderBody {
        let body = WLHanderBody()
        body.requestId = rid
        body.bodyType = bodyType
        body.handlerResult = handlerResult
        return body
    }
}

// MARK: - Dictionary Extension

extension Dictionary {
    func lwwl_jsonString(prettyPrint: Bool = false) -> String {
        guard let jsonData = try? JSONSerialization.data(
            withJSONObject: self,
            options: prettyPrint ? .prettyPrinted : []
        ) else {
            WLLog("Error converting dictionary to JSON")
            return "{}"
        }
        return String(data: jsonData, encoding: .utf8) ?? "{}"
    }
}

// MARK: - LWWLWKScriptMessageHandler

private class LWWLWKScriptMessageHandler: NSObject, WKScriptMessageHandler {
    var dataStream: OutputStream?
    var dataLoadCompletionHandler: ((Bool, WLHanderBody, Error?) -> Void)?
    var streamError: Error?

    var streamFilePath: String? {
        didSet {
            if let path = streamFilePath {
                _streamFilePath = path
            }
        }
    }
    private var _streamFilePath: String?

    static func messageHandler(
        evaluateBody: WLEvaluateBody,
        dataLoadCompletionHandler: @escaping (Bool, WLHanderBody, Error?) -> Void
    ) -> LWWLWKScriptMessageHandler {
        let handler = LWWLWKScriptMessageHandler()
        handler.dataLoadCompletionHandler = dataLoadCompletionHandler
        handler.streamFilePath(fileName: evaluateBody.requestId ?? UUID().uuidString)
        return handler
    }

    func streamFilePath(fileName: String) {
        _streamFilePath = NSTemporaryDirectory() + fileName
    }

    private func getStreamFilePath() -> String {
        if let path = _streamFilePath {
            return path
        }
        let path = NSTemporaryDirectory() + UUID().uuidString
        _streamFilePath = path
        return path
    }

    private func getDataStream() -> OutputStream {
        if let stream = dataStream {
            return stream
        }
        let stream = OutputStream(toFileAtPath: getStreamFilePath(), append: true)!
        dataStream = stream
        return stream
    }

    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        if message.name == "bridge" {
            guard let body = message.body as? [String: Any] else {
                if let handler = dataLoadCompletionHandler {
                    let errorBody = WLHanderBody.body(withId: "-1", bodyType: .error, handlerResult: nil)
                    handler(true, errorBody, NSError(domain: "数据格式错误", code: 0, userInfo: nil))
                }
                return
            }

            let messageBody = WLMessageBody(dictionary: body)

            switch messageBody.type {
            case "json":
                if let handler = dataLoadCompletionHandler {
                    let bod = WLHanderBody.body(withId: messageBody.requestId, bodyType: .json, handlerResult: messageBody.value)
                    handler(true, bod, nil)
                }

            case "plaintext":
                if let handler = dataLoadCompletionHandler {
                    let bod = WLHanderBody.body(withId: messageBody.requestId, bodyType: .plainText, handlerResult: messageBody.value)
                    handler(true, bod, nil)
                }

            case "b64text":
                if let data = Data(base64Encoded: messageBody.value) {
                    if let handler = dataLoadCompletionHandler {
                        let bod = WLHanderBody.body(withId: messageBody.requestId, bodyType: .data, handlerResult: data)
                        handler(true, bod, nil)
                    }
                }

            case "b64streamstart":
                WLLog("=====b64 streaming start !")
                getDataStream().open()
                if let handler = dataLoadCompletionHandler {
                    let bod = WLHanderBody.body(withId: messageBody.requestId, bodyType: .streamStart, handlerResult: messageBody.value)
                    handler(true, bod, nil)
                }

            case "b64streaming":
                let progress = messageBody.received.doubleValue / messageBody.total.doubleValue
                WLLog("=====b64 streaming \(String(format: "%.2f", progress))...")

                if let data = Data(base64Encoded: messageBody.value) {
                    let stream = getDataStream()
                    let dataLength = data.count
                    let writeLen = data.withUnsafeBytes { (buffer: UnsafeRawBufferPointer) -> Int in
                        guard let pointer = buffer.baseAddress?.assumingMemoryBound(to: UInt8.self) else {
                            return 0
                        }
                        return stream.write(pointer, maxLength: dataLength)
                    }

                    if dataLength > writeLen {
                        _streamFilePath = nil
                        streamError = stream.streamError
                        stream.close()
                        dataStream = nil
                        return
                    }
                }

                if let handler = dataLoadCompletionHandler {
                    let bod = WLHanderBody.body(withId: messageBody.requestId, bodyType: .streaming, handlerResult: progress)
                    handler(true, bod, nil)
                }

            case "b64streamend":
                WLLog("=====b64 streaming finish !")
                if let stream = dataStream, stream.streamStatus != .closed {
                    stream.close()
                    dataStream = nil
                }
                if let handler = dataLoadCompletionHandler {
                    let bod = WLHanderBody.body(withId: messageBody.requestId, bodyType: .streamEnd, handlerResult: getStreamFilePath())
                    handler(true, bod, streamError)
                }

            case "error":
                if let handler = dataLoadCompletionHandler {
                    let bod = WLHanderBody.body(withId: messageBody.requestId, bodyType: .error, handlerResult: messageBody.value)
                    handler(true, bod, nil)
                }

            default:
                break
            }

        } else if message.name == "nativelog" {
            WLLog("=====nativelog:\(message.body)")
        }
    }

    deinit {
        if let stream = dataStream {
            stream.close()
            dataStream = nil
        }
        WLLog("===========dealloc LWWLWKScriptMessageHandler ")
    }
}

// MARK: - WLWebView

public class WLWebView: WKWebView, WKNavigationDelegate {
    weak var webConfiguration: WKWebViewConfiguration?
    var evaluateBody: WLEvaluateBody?
    var didCommitNavigation = false
    var evaluateJSCompletionHandler: ((Any?, Error?) -> Void)?

    public override func load(_ request: URLRequest) -> WKNavigation? {
        WLLog("===========loadRequest")
        var headerFields = request.allHTTPHeaderFields ?? [:]
        headerFields["referrer"] = "http://app.wodedata.com"

        var mRequest = request
        mRequest.allHTTPHeaderFields = headerFields

        return super.load(request)
    }

    public static func buildWebView(
        evaluateBody: WLEvaluateBody,
        parentView: UIView,
        dataLoadCompletionHandler: @escaping (Bool, WLHanderBody, Error?) -> Void,
        jsCompletionHandler: @escaping (Any?, Error?) -> Void
    ) -> WLWebView {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.userContentController = WKUserContentController()
        webConfiguration.processPool = WKProcessPool()
        webConfiguration.applicationNameForUserAgent = ""

        let injectionJS = "function log(msg) {window.webkit.messageHandlers.nativelog.postMessage(msg);}"
        let userScript = WKUserScript(source: injectionJS, injectionTime: .atDocumentStart, forMainFrameOnly: true)
        webConfiguration.userContentController.addUserScript(userScript)

        let messageHandler = LWWLWKScriptMessageHandler.messageHandler(
            evaluateBody: evaluateBody,
            dataLoadCompletionHandler: dataLoadCompletionHandler
        )
        webConfiguration.userContentController.add(messageHandler, name: "bridge")
        webConfiguration.userContentController.add(messageHandler, name: "clipboard")
        webConfiguration.userContentController.add(messageHandler, name: "nativelog")

        let webView = WLWebView(frame: CGRect(x: 0, y: 0, width: 1, height: 1), configuration: webConfiguration)
        parentView.addSubview(webView)
        webView.navigationDelegate = webView
        webView.evaluateBody = evaluateBody
        webView.evaluateJSCompletionHandler = jsCompletionHandler
        return webView
    }

    // MARK: - WKNavigationDelegate

    public func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        WLLog("===========webview didStartProvisionalNavigation : \(webView.url?.absoluteString ?? "")")
    }

    public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        WLLog("===========webview didCommitNavigation : \(webView.url?.absoluteString ?? "")")
    }

    public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        WLLog("===========webview didFinishNavigation : \(webView.url?.absoluteString ?? "")")

        guard let jsCode = evaluateBody?.jsCode else { return }

        evaluateJavaScript(jsCode) { [weak self] result, error in
            self?.didCommitNavigation = true
            if let handler = self?.evaluateJSCompletionHandler {
                handler(result, error)
            }
        }

        showWebCachePath()
    }

    private func showWebCachePath() {
        guard let libraryDir = NSSearchPathForDirectoriesInDomains(.libraryDirectory, .userDomainMask, true).first,
              let bundleId = Bundle.main.infoDictionary?["CFBundleIdentifier"] as? String else {
            return
        }
        let webKitFolder = "\(libraryDir)/Caches/\(bundleId)/WebKit"
        WLLog("==========webkit folder: \(webKitFolder)")
    }

    deinit {
        WLLog("===========dealloc WLWebView ")
        if #available(iOS 11.0, *) {
            configuration.userContentController.removeAllContentRuleLists()
        }
        configuration.userContentController.removeAllUserScripts()
        configuration.userContentController.removeScriptMessageHandler(forName: "bridge")
        configuration.userContentController.removeScriptMessageHandler(forName: "clipboard")
        configuration.userContentController.removeScriptMessageHandler(forName: "nativelog")
    }
}

// MARK: - LWWebLoader

public class LWWebLoader {
    private weak var webview: WLWebView?

    private static let defaultUA = "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/78.0.3904.87 Safari/537.36"

    public static func webloader() -> LWWebLoader {
        return LWWebLoader()
    }

    public static func body(
        urlString: String?,
        method: LWWebLoadMethod,
        methodArguments: String?,
        userAgent: String?,
        contentType: String?,
        postData: [String: Any]?,
        uploadData: Data?
    ) -> WLEvaluateBody {

        let url = URL(string: urlString ?? "http://localhost") ?? URL(string: "http://localhost")!
        let requestId = UUID().uuidString

        var defaultHeaders: [String: String] = [
            "user-agent": defaultUA
        ]

        defaultHeaders["user-agent"] = userAgent ?? defaultHeaders["user-agent"]!
        if let contentType = contentType {
            defaultHeaders["content-type"] = contentType
        }

        var referrer = "\(url.scheme ?? "http")://\(url.host ?? "")"
        if let port = url.port, port != 0 && port != 80 {
            referrer += ":\(port)"
        }

        var evalueteJSMethod = "getData"
        var requestHeader: [String: Any] = [
            "method": "GET",
            "headers": defaultHeaders,
            "cache": "no-cache",
            "referrer": referrer
        ]

        switch method {
        case .postData:
            evalueteJSMethod = "postData"
            let bodyJson = postData?.lwwl_jsonString() ?? "{}"
            requestHeader = [
                "method": "POST",
                "body": bodyJson,
                "headers": defaultHeaders,
                "cache": "no-cache",
                "referrer": referrer
            ]

        case .uploadData:
            evalueteJSMethod = "uploadData"
            requestHeader = [
                "method": "POST",
                "headers": defaultHeaders,
                "cache": "no-cache",
                "referrer": referrer
            ]

        case .downloadFile:
            evalueteJSMethod = "downloadFile"
            defaultHeaders["requestId"] = requestId
            requestHeader = [
                "method": "GET",
                "headers": defaultHeaders,
                "cache": "no-cache",
                "referrer": referrer
            ]

        case .downloadStream:
            evalueteJSMethod = "downloadStream"
            defaultHeaders["requestId"] = requestId
            requestHeader = [
                "method": "GET",
                "headers": defaultHeaders,
                "cache": "no-cache",
                "referrer": referrer
            ]

        case .nativeLog:
            evalueteJSMethod = "log"

        case .getClipboardText:
            evalueteJSMethod = "getClipboardText"

        case .getData:
            break
        }

        WLLog("==========requestId:\(requestId)")

        let evaluateBody = WLEvaluateBody()
        evaluateBody._url = url
        evaluateBody.requestId = requestId
        evaluateBody.evalueteJSMethod = evalueteJSMethod

        if method == .getClipboardText {
            evaluateBody.jsCode = "\(evalueteJSMethod)('\(requestId)')"
            return evaluateBody
        } else if method == .nativeLog {
            evaluateBody.methodArguments = methodArguments
            evaluateBody.jsCode = "\(evalueteJSMethod)('\(methodArguments ?? "")')"
            return evaluateBody
        }

        let requestHeaderJson = requestHeader.lwwl_jsonString()

        var jsCode = "\(evalueteJSMethod)('\(requestId)','\(url.absoluteString)',\(requestHeaderJson))"
        if method == .uploadData {
            let postDataJson = postData?.lwwl_jsonString() ?? "{}"
            let uploadDataB64String = uploadData?.base64EncodedString() ?? ""
            jsCode = "\(evalueteJSMethod)('\(requestId)','\(url.absoluteString)',\(requestHeaderJson),\(postDataJson),'\(uploadDataB64String)')"
        }

        evaluateBody.jsCode = jsCode

        return evaluateBody
    }

    public func evaluate(
        body evaluateBody: WLEvaluateBody,
        parentView: UIView,
        dataLoadCompletionHandler: @escaping (Bool, WLHanderBody, Error?) -> Void
    ) {
        let isSameHost = webview?.url?.host == evaluateBody.url.host &&
                        webview?.url?.port == evaluateBody.url.port

        if webview == nil || webview?.didCommitNavigation == false || !isSameHost {
            webview = WLWebView.buildWebView(
                evaluateBody: evaluateBody,
                parentView: parentView,
                dataLoadCompletionHandler: { [weak self] finish, result, error in
                    dataLoadCompletionHandler(finish, result, error)
                    self?.webview?.removeFromSuperview()
                    self?.webview = nil
                },
                jsCompletionHandler: { result, error in
                    if let error = error {
                        WLLog("======error:\(error)")
                    } else {
                        WLLog("======evaluate js \(evaluateBody.evalueteJSMethod ?? "") ok")
                    }
                }
            )

            loadPage(baseURL: evaluateBody.url)

        } else {
            guard let jsCode = evaluateBody.jsCode else { return }
            webview?.evaluateJavaScript(jsCode) { [weak self] result, error in
                if let handler = self?.webview?.evaluateJSCompletionHandler {
                    handler(result, error)
                }
            }
        }
    }

    private func loadPage(baseURL: URL) {
        guard let bundle = Bundle(path: Bundle(for: type(of: self)).path(forResource: "LWWebLoader", ofType: "bundle") ?? "") ??
                          Bundle(path: Bundle.main.path(forResource: "WLWebLoader", ofType: "bundle") ?? "") ??
                          Bundle.main,
              let fileURL = bundle.url(forResource: "loader", withExtension: "html"),
              let data = try? Data(contentsOf: fileURL),
              let htmlString = String(data: data, encoding: .utf8) else {
            return
        }

        webview?.loadHTMLString(htmlString, baseURL: baseURL)
    }

    deinit {
        WLLog("======== dealloc LWWebLoader")
    }
}
