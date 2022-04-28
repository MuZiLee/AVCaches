//
//  AVDataTaskManager.swift
//  AVCaches
//
//  Created by lee on 2022/4/28

import UIKit
import AVKit
import MobileCoreServices

open class AVDataTasker: NSObject {
    private let locker = NSLock()
    
    private var taskQueue = [String: (AVDataTask, AVAssetResourceLoadingRequest?)]()
    
    public let cache: AVCache
    
    public init(url: URL) {
        cache = AVCacheProvider.shared.cache(url: url)
        super.init()
    }
    
    deinit {
        locker.lock()
        taskQueue.removeAll()
        locker.unlock()
    }
    
    private func add(task: AVDataTask, loadingRequest: AVAssetResourceLoadingRequest? = nil) {
        locker.lock()
        taskQueue[task.id] = (task, loadingRequest)
        locker.unlock()
    }
    
    private func remove(task: AVDataTask?) {
        guard let _task = task else {
            return
        }
        locker.lock()
        taskQueue.removeValue(forKey: _task.id)
        locker.unlock()
    }
}

public extension AVDataTasker {
    func startTask(request: AVAssetResourceLoadingRequest) {
        var offset = request.dataRequest?.requestedOffset ?? 0
        let length = request.currentLength
        
        setup(info: cache.contentInfo(), request: request)
        setup(data: cache.data(offset: offset, length: length), request: request)

        guard request.isContinued else {
            return
        }
        offset = request.dataRequest?.currentOffset ?? offset
        let task = AVDataTask(url: cache.url, offset: offset)
        add(task: task, loadingRequest: request)
        task.start { [weak self] info in
            self?.setup(info: info, request: request, cache: self?.cache)
            
        } didLoadData: { [weak self] data in
            self?.setup(data: data, request: request, cache: self?.cache)
            
        } finished: { [weak self, weak task] error in
            self?.remove(task: task)
            request.finishLoadingIfNeeded(with: error)
        }
    }
    
    func cancel(request: AVAssetResourceLoadingRequest) {
        locker.lock()
        let task = taskQueue.first { $0.value.1 == request }
        taskQueue.removeValue(forKey: task?.key ?? "v")
        locker.unlock()
        task?.value.0.cancel()
    }
}

public extension AVDataTasker {
    func setup(info: ContentInfo?, request: AVAssetResourceLoadingRequest, cache: AVCache? = nil) {
        guard let _info = info else {
            return
        }
        cache?.cache(info: _info)

        let type = UTTypeCreatePreferredIdentifierForTag(kUTTagClassMIMEType, _info.type as CFString, nil)?.takeRetainedValue() as String?
        request.contentInformationRequest?.contentType = type
        request.contentInformationRequest?.contentLength = _info.length
        request.contentInformationRequest?.isByteRangeAccessSupported = true
    }
    
    func setup(data: Data, request: AVAssetResourceLoadingRequest, cache: AVCache? = nil) {
        guard data.count > 0 else {
            return
        }
        guard request.isContinued, let _dataRequest = request.dataRequest else {
            return
        }
        let targetOffset = _dataRequest.requestedOffset + request.currentLength
        let newOffset = _dataRequest.currentOffset + Int64(data.count)
        let diff = targetOffset - newOffset
        
        let _data = diff >= 0 ? data : data.subdata(in: Range(0 ... data.count + Int(diff) - 1))
        cache?.cache(data: _data, offset: _dataRequest.currentOffset)
        _dataRequest.respond(with: _data)
        
        if _dataRequest.currentOffset >= targetOffset {
            request.finishLoadingIfNeeded()
        }
    }
}

private extension AVAssetResourceLoadingRequest {
    var currentLength: Int64 {
        let requestAll = dataRequest?.requestsAllDataToEndOfResource ?? false
        if requestAll, let contentLength = contentInformationRequest?.contentLength {
            return contentLength
        } else {
            return Int64(dataRequest?.requestedLength ?? 0)
        }
    }
    
    var isContinued: Bool {
        if isFinished || isCancelled {
            return false
        } else {
            return true
        }
    }
    
    func finishLoadingIfNeeded(with error: Error? = nil) {
        guard isContinued else {
            return
        }
        if let _error = error {
            finishLoading(with: _error)
        } else {
            finishLoading()
        }
    }
}
