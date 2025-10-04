//
// LWWebLoaderSwiftUI.swift
// SwiftUI wrapper for LWWebLoader
//
// Created by luowei on 2019/11/4.
// Swift version
//

import SwiftUI
import Combine

// MARK: - WebLoadRequest

@available(iOS 13.0, *)
public struct WebLoadRequest {
    public let urlString: String
    public let method: LWWebLoadMethod
    public let methodArguments: String?
    public let userAgent: String?
    public let contentType: String?
    public let postData: [String: Any]?
    public let uploadData: Data?

    public init(
        urlString: String,
        method: LWWebLoadMethod = .getData,
        methodArguments: String? = nil,
        userAgent: String? = nil,
        contentType: String? = nil,
        postData: [String: Any]? = nil,
        uploadData: Data? = nil
    ) {
        self.urlString = urlString
        self.method = method
        self.methodArguments = methodArguments
        self.userAgent = userAgent
        self.contentType = contentType
        self.postData = postData
        self.uploadData = uploadData
    }
}

// MARK: - WebLoadResponse

@available(iOS 13.0, *)
public struct WebLoadResponse {
    public let requestId: String?
    public let bodyType: WLHanderBodyType
    public let result: Any?
    public let error: Error?

    public var isSuccess: Bool {
        return error == nil && bodyType != .error
    }

    public var jsonString: String? {
        guard bodyType == .json, let resultString = result as? String else {
            return nil
        }
        return resultString
    }

    public var plainText: String? {
        guard bodyType == .plainText, let resultString = result as? String else {
            return nil
        }
        return resultString
    }

    public var data: Data? {
        guard bodyType == .data, let resultData = result as? Data else {
            return nil
        }
        return resultData
    }

    public var streamProgress: Double? {
        guard bodyType == .streaming, let progress = result as? Double else {
            return nil
        }
        return progress
    }

    public var streamFilePath: String? {
        guard bodyType == .streamEnd, let path = result as? String else {
            return nil
        }
        return path
    }
}

// MARK: - LWWebLoaderViewModel

@available(iOS 13.0, *)
public class LWWebLoaderViewModel: ObservableObject {
    @Published public var isLoading = false
    @Published public var response: WebLoadResponse?
    @Published public var streamProgress: Double = 0.0

    private let webLoader = LWWebLoader.webloader()
    private var cancellables = Set<AnyCancellable>()

    public init() {}

    public func load(
        request: WebLoadRequest,
        parentView: UIView,
        onProgress: ((Double) -> Void)? = nil,
        completion: ((WebLoadResponse) -> Void)? = nil
    ) {
        isLoading = true
        streamProgress = 0.0

        let evaluateBody = LWWebLoader.body(
            urlString: request.urlString,
            method: request.method,
            methodArguments: request.methodArguments,
            userAgent: request.userAgent,
            contentType: request.contentType,
            postData: request.postData,
            uploadData: request.uploadData
        )

        webLoader.evaluate(
            body: evaluateBody,
            parentView: parentView
        ) { [weak self] finished, handlerBody, error in
            guard let self = self else { return }

            let response = WebLoadResponse(
                requestId: handlerBody.requestId,
                bodyType: handlerBody.bodyType,
                result: handlerBody.handlerResult,
                error: error
            )

            DispatchQueue.main.async {
                // Update progress for streaming
                if handlerBody.bodyType == .streaming,
                   let progress = handlerBody.handlerResult as? Double {
                    self.streamProgress = progress
                    onProgress?(progress)
                } else if finished {
                    self.isLoading = false
                    self.response = response
                    completion?(response)
                }
            }
        }
    }

    public func loadAsync(
        request: WebLoadRequest,
        parentView: UIView
    ) async throws -> WebLoadResponse {
        return try await withCheckedThrowingContinuation { continuation in
            load(request: request, parentView: parentView) { response in
                if let error = response.error {
                    continuation.resume(throwing: error)
                } else {
                    continuation.resume(returning: response)
                }
            }
        }
    }
}

// MARK: - WebLoaderView (SwiftUI View)

@available(iOS 13.0, *)
public struct WebLoaderView: View {
    @StateObject private var viewModel = LWWebLoaderViewModel()
    let request: WebLoadRequest
    let onCompletion: (WebLoadResponse) -> Void

    public init(
        request: WebLoadRequest,
        onCompletion: @escaping (WebLoadResponse) -> Void
    ) {
        self.request = request
        self.onCompletion = onCompletion
    }

    public var body: some View {
        GeometryReader { geometry in
            Color.clear
                .frame(width: 1, height: 1)
                .background(
                    WebLoaderViewRepresentable(
                        viewModel: viewModel,
                        request: request,
                        onCompletion: onCompletion
                    )
                )
        }
        .frame(width: 1, height: 1)
    }
}

// MARK: - WebLoaderViewRepresentable

@available(iOS 13.0, *)
private struct WebLoaderViewRepresentable: UIViewRepresentable {
    let viewModel: LWWebLoaderViewModel
    let request: WebLoadRequest
    let onCompletion: (WebLoadResponse) -> Void

    func makeUIView(context: Context) -> UIView {
        let view = UIView(frame: CGRect(x: 0, y: 0, width: 1, height: 1))
        view.backgroundColor = .clear

        DispatchQueue.main.async {
            viewModel.load(
                request: request,
                parentView: view,
                completion: onCompletion
            )
        }

        return view
    }

    func updateUIView(_ uiView: UIView, context: Context) {
        // No updates needed
    }
}

// MARK: - Convenience Extensions

@available(iOS 13.0, *)
public extension LWWebLoaderViewModel {
    /// Load JSON data from a URL
    func loadJSON(
        from urlString: String,
        parentView: UIView,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = WebLoadRequest(urlString: urlString, method: .getData)
        load(request: request, parentView: parentView) { response in
            if let error = response.error {
                completion(.failure(error))
            } else if let jsonString = response.jsonString {
                completion(.success(jsonString))
            } else {
                completion(.failure(NSError(domain: "LWWebLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response type"])))
            }
        }
    }

    /// Upload data to a URL
    func upload(
        data: Data,
        to urlString: String,
        postData: [String: Any]? = nil,
        parentView: UIView,
        completion: @escaping (Result<WebLoadResponse, Error>) -> Void
    ) {
        let request = WebLoadRequest(
            urlString: urlString,
            method: .uploadData,
            uploadData: data
        )
        load(request: request, parentView: parentView) { response in
            if let error = response.error {
                completion(.failure(error))
            } else {
                completion(.success(response))
            }
        }
    }

    /// Download file with progress tracking
    func downloadFile(
        from urlString: String,
        parentView: UIView,
        onProgress: @escaping (Double) -> Void,
        completion: @escaping (Result<Data, Error>) -> Void
    ) {
        let request = WebLoadRequest(urlString: urlString, method: .downloadFile)
        load(request: request, parentView: parentView, onProgress: onProgress) { response in
            if let error = response.error {
                completion(.failure(error))
            } else if let data = response.data {
                completion(.success(data))
            } else {
                completion(.failure(NSError(domain: "LWWebLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "No data received"])))
            }
        }
    }

    /// Download file as stream with progress tracking
    func downloadStream(
        from urlString: String,
        parentView: UIView,
        onProgress: @escaping (Double) -> Void,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        let request = WebLoadRequest(urlString: urlString, method: .downloadStream)
        load(request: request, parentView: parentView, onProgress: onProgress) { response in
            if let error = response.error {
                completion(.failure(error))
            } else if let filePath = response.streamFilePath {
                completion(.success(filePath))
            } else {
                completion(.failure(NSError(domain: "LWWebLoader", code: -1, userInfo: [NSLocalizedDescriptionKey: "No file path received"])))
            }
        }
    }
}

// MARK: - Example Usage in SwiftUI

#if DEBUG
@available(iOS 13.0, *)
struct WebLoaderExampleView: View {
    @StateObject private var viewModel = LWWebLoaderViewModel()
    @State private var downloadProgress: Double = 0.0
    @State private var result: String = "No result yet"

    var body: some View {
        VStack(spacing: 20) {
            Text("LWWebLoader SwiftUI Example")
                .font(.headline)

            if viewModel.isLoading {
                ProgressView("Loading...")
                if viewModel.streamProgress > 0 {
                    ProgressView(value: viewModel.streamProgress)
                        .padding()
                }
            }

            Text(result)
                .font(.caption)
                .multilineTextAlignment(.center)
                .padding()

            Button("Load JSON Data") {
                loadJSONExample()
            }

            Button("Download File") {
                downloadFileExample()
            }
        }
        .padding()
    }

    private func loadJSONExample() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let parentView = window.rootViewController?.view else {
            return
        }

        let request = WebLoadRequest(
            urlString: "https://api.example.com/data.json",
            method: .getData
        )

        viewModel.load(request: request, parentView: parentView) { response in
            if response.isSuccess {
                result = "Success: \(response.jsonString ?? "No data")"
            } else {
                result = "Error: \(response.error?.localizedDescription ?? "Unknown error")"
            }
        }
    }

    private func downloadFileExample() {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let parentView = window.rootViewController?.view else {
            return
        }

        viewModel.downloadStream(
            from: "https://example.com/largefile.zip",
            parentView: parentView,
            onProgress: { progress in
                downloadProgress = progress
            },
            completion: { result in
                switch result {
                case .success(let filePath):
                    self.result = "Downloaded to: \(filePath)"
                case .failure(let error):
                    self.result = "Error: \(error.localizedDescription)"
                }
            }
        )
    }
}

@available(iOS 13.0, *)
struct WebLoaderExampleView_Previews: PreviewProvider {
    static var previews: some View {
        WebLoaderExampleView()
    }
}
#endif
