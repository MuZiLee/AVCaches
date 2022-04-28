//
//  AVPreloader.swift
//  AVCaches
//
//  Created by lee on 2022/4/28
//

import Foundation

///预加载器
open class AVPreloader: NSObject {
    public static let shared = AVPreloader()
    
    private let locker = NSLock()
    
    private lazy var taskDic = [URL: Task]()
    
    private override init() {
        super.init()
    }
    
    private func add(task: Task, url: URL) {
        locker.lock()
        taskDic[url] = task
        locker.unlock()
    }
    
    private func remove(task url: URL) {
        locker.lock()
        taskDic.removeValue(forKey: url)
        locker.unlock()
    }
}

public extension AVPreloader {
    func preload(urls: [(URL, Int64)]) {
        for node in urls {
            preload(url: node.0, length: node.1)
        }
    }
    
    func preload(urls: [URL], length: Int64 = 1024 * 1024 * 3) {
        for url in urls {
            preload(url: url, length: length)
        }
    }
    
    func preload(url: URL, length: Int64, completion: ((Error?) -> Void)? = nil) {
        let task = Task(url: url)
        add(task: task, url: url)
        task.preload(length: length) { [weak self] error in
            self?.remove(task: url)
            completion?(error)
        }
    }
    
    func cancel(url: URL? = nil) {
        locker.lock()
        if let _url = url {
            taskDic[_url]?.cancel()
            taskDic.removeValue(forKey: _url)
        } else {
            for t in taskDic {
                t.value.cancel()
            }
            taskDic.removeAll()
        }
        locker.unlock()
    }
}

private extension AVPreloader {
    class Task {
        private(set) var task: AVDataTask?
        
        private lazy var cache: AVCache? = AVCacheProvider.shared.cache(url: url)
        
        private var currentOffset: Int64 = 0

        let url: URL
        
        init(url: URL) {
            self.url = url
        }

        func preload(length: Int64, completion: ((Error?) -> Void)? = nil) {
            let temp = cache?.data(offset: 0, length: length) ?? Data()
            guard temp.count < length else {//已经有缓存数据了
                DispatchQueue.main.async {
                    completion?(nil)
                }
                return
            }
            let offset = Int64(temp.count)
            task = AVDataTask(url: url, offset: offset, end: length)
            currentOffset = offset
            task?.start { [weak self] info in
                if let _self = self {
                    _self.cache?.cache(info: info)
                }
            } didLoadData: { [weak self] data in
                if let _self = self {
                    _self.cache?.cache(data: data, offset: _self.currentOffset)
                    _self.currentOffset += Int64(data.count)
                }
            } finished: { [weak self] error in
                if let _self = self {
                    _self.task = nil
                }
                DispatchQueue.main.async {
                    completion?(error)
                }
            }
        }
        
        func cancel() {
            cache = nil
            task?.cancel()
        }
    }
}
