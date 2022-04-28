//
//  AVDataTask.swift
//  AVCaches
//
//  Created by lee on 2022/4/28
//

import UIKit
import AVKit

public typealias ContentInfo = (type: String, length: Int64)

open class AVDataTask: NSObject {

    public private(set) lazy var config: URLSessionConfiguration = {
        let result = URLSessionConfiguration.ephemeral//.default会导致内存泄漏而ephemeral不会，很奇怪
        result.networkServiceType = .video
        return result
    }()
    
    public private(set) lazy var session = URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue())
    
    public private(set) lazy var request: URLRequest = {
        let end = requestedEnd != nil ? "\(requestedEnd!)" : ""
        var result = URLRequest(url: url, cachePolicy: .reloadIgnoringCacheData, timeoutInterval: 30)
        result.setValue("bytes=\(requestedOffset)-\(end)", forHTTPHeaderField: "Range")
        result.setValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        return result
    }()
    
    public private(set) lazy var task = session.dataTask(with: request)

    public let requestedOffset: Int64
    
    public let requestedEnd: Int64?

    private var infoCallback: ((ContentInfo) -> Void)?
    
    private var dataCallback: ((Data) -> Void)?
    
    private var finishedCallback: ((Error?) -> Void)?

    public let id = UUID().uuidString
    
    public let url: URL

    public init(url u: URL, offset: Int64? = nil, end: Int64? = nil) {
        url = u
        requestedOffset = offset ?? 0
        requestedEnd = end
        super.init()
    }
    
    deinit {
        cancel()
    }
}

public extension AVDataTask {
    func start(didLoadInfo: @escaping (ContentInfo) -> Void, didLoadData: @escaping (Data) -> Void, finished: @escaping (Error?) -> Void) {
        infoCallback = didLoadInfo
        dataCallback = didLoadData
        finishedCallback = finished
        task.resume()
    }
    
    func cancel() {
        infoCallback = nil
        dataCallback = nil
        finishedCallback = nil
        task.cancel()
        session.invalidateAndCancel()
    }
}

extension AVDataTask: URLSessionDelegate, URLSessionDataDelegate, URLSessionTaskDelegate { 
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive response: URLResponse, completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        if let _info = response.info() {
            infoCallback?(_info)
        }
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        guard data.count > 0 else {
            return
        }
        dataCallback?(data)
    }
    
    public func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        if (error as NSError?)?.code == NSURLErrorCancelled {
            finishedCallback?(nil)
        } else {
            finishedCallback?(error)
        }
    }
}

private extension URLResponse {
    func info() -> ContentInfo? {
        guard let header = (self as? HTTPURLResponse)?.allHeaderFields else {
            return nil
        }
        guard let type = header["Content-Type"] as? String else {
            return nil
        }
        guard let range = header["Content-Range"] as? String, let _length = range.split(separator: "/").last else {
            return nil
        }
        guard let length = Int64(_length) else {
            return nil
        }
        return (type, length)
    }
}
