//
//  AVCacheProvider.swift
//  AVCaches
//
//  Created by lee on 2022/4/28
//

import UIKit
import CommonCrypto

public class AVCacheProvider: NSObject {
    public static let shared = AVCacheProvider()
    
    private lazy var cacheFolder = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first! + "/\(Bundle.main.bundleIdentifier ?? "camera.youpi.thoughtsapp.avcaches")"
    
    private lazy var locker = NSLock()
    
    private lazy var cacheDic = NSMapTable<NSURL, AVCache>(keyOptions: .strongMemory, valueOptions: .weakMemory)
    
    private override init() {
        super.init()
    }
    
    public func cache(url: URL) -> AVCache {
        locker.lock()
        defer {
            locker.unlock()
        }
        if let result = cacheDic.object(forKey: url as NSURL) {
            cachePath(url)//检查并创建文件
            return result
        } else {
            let result = AVCache(url: url, cachePath: cachePath(url))
            cacheDic.setObject(result, forKey: url as NSURL)
            return result
        }
    }
}

public extension AVCacheProvider {
    func cleanCache(_ url: URL? = nil, completion: @escaping (Bool) -> Void) {
        DispatchQueue.global().async {
            AVPreloader.shared.cancel(url: url)
            var result = true
            let path: String
            let name: String?
            if let _url = url {
                path = self.cachePath(_url)
                name = self.cacheName(_url)
            } else {
                path = self.cacheFolder
                name = nil
            }
            do {
                try FileManager.default.removeItem(atPath: path)
            } catch {
                result = false
            }
            AVProperty<Int>.removeAll(contains: name)
            DispatchQueue.global().async {
                completion(result)
            }
        }
    }
    
    func cacheSize(completion: @escaping (UInt64) -> Void) {
        DispatchQueue.global().async {
            var result: UInt64 = 0
            let files = (try? FileManager.default.contentsOfDirectory(atPath: self.cacheFolder)) ?? []
            for f in files {
                if let size = (try? FileManager.default.attributesOfItem(atPath: self.cacheFolder + "/" + f))?[.size] as? UInt64 {
                    result += size
                }
            }
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    @discardableResult func cachePath(_ url: URL) -> String {
        return cachePath(cacheName(url))
    }
    
    func cachePath(_ cacheName: String) -> String {
        var path = cacheFolder
        path += "/\(cacheName)"
        if !FileManager.default.fileExists(atPath: cacheFolder) {
            try? FileManager.default.createDirectory(atPath: cacheFolder, withIntermediateDirectories: false, attributes: nil)
        }
        if !FileManager.default.fileExists(atPath: path) {
            FileManager.default.createFile(atPath: path, contents: nil, attributes: nil)
        }
        return path
    }
    
    func cacheName(_ url: URL) -> String {
        return "cache" + url.absoluteString.md5 + "cache"
    }
}

private extension String {
    var md5: String {
        guard let str = self.cString(using: .utf8) else {
            return ""
        }
        let strLen = CC_LONG(self.lengthOfBytes(using: String.Encoding.utf8))
        let digestLen = Int(CC_MD5_DIGEST_LENGTH)
        let pointer = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: digestLen)
        
        CC_MD5(str, strLen, pointer)
        
        var result = String()
        for i in 0 ..< digestLen {
            result.append(.init(format: "%02x", pointer[i]))
        }
        pointer.deallocate()
        return result
    }
}
