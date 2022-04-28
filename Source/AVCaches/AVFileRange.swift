//
//  AVFileRange.swift
//  AVCaches
//
//  Created by lee on 2022/4/28
//

import UIKit

open class AVFileRange {

    private lazy var cache = AVProperty(key: "AVProperty.\(id).cache", default: [String]())
    
    public lazy var ranges = decode()
    
    public let id: String
    
    public init(id: String) {
        self.id = id
        NotificationCenter.default.addObserver(self, selector: #selector(encode), name: UIApplication.willTerminateNotification, object: nil)
    }
    
    deinit {
        encode()
    }
    
    public func clean() {
        ranges = []
        cache.value = []
    }
    
    @objc private func encode() {
        guard ranges.count > 0 else {
            cache.value = []
            return
        }
        var result = [String]()
        let encoder = JSONEncoder()
        for r in ranges {
            if !r.isInvalid, let data = try? encoder.encode(r) {
                if let str = String(data: data, encoding: .utf8) {
                    result.append(str)
                }
            }
        }
        cache.value = result
    }
    
    private func decode() -> [FileRange] {
        guard cache.value.count > 0 else {
            return []
        }
        var result = [FileRange]()
        let decoder = JSONDecoder()
        for str in cache.value {
            if let data = str.data(using: .utf8) {
                if let r = try? decoder.decode(FileRange.self, from: data) {
                    result.append(r)
                }
            }
        }
        return result
    }
    
    public func add(_ range: FileRange) {
        ranges.append(range)
        #if DEBUG
        encode()
        #endif
    }
    
    public func deduct(_ other: FileRange) {
        for uncache in ranges {
            if uncache.isInvalid {
                continue
            }
            if let breaked = uncache.deduct(other) {
                ranges.append(breaked)
            }
        }
        #if DEBUG
        encode()
        #endif
    }
    
    public func exclude(_ source: FileRange) {
        for r in ranges {
            source.deduct(r)
        }
    }
}

open class FileRange: NSObject, Codable {
    private(set) var start: Int64
    
    private(set) var end: Int64
    ///区间已无效
    private(set) var isInvalid = false
    
    public init?(start: Int64, end: Int64) {
        guard start >= 0, start < end else {
            return nil
        }
        self.start = start
        self.end = end
    }
    
    ///区间不相交部分
    public func notIntersect(_ other: FileRange) -> [(Int64, Int64)] {
        if start < other.start {
            if end < other.end {
                if end > other.start {//右相交
                    return [(start, other.start)]
                } else {//右不相交
                    return [(start, end)]
                }
            } else {//包含other
                return [(start, other.start), (other.end, end)]
            }
        } else {
            if end > other.end {
                if start < other.end {//左相交
                    return [(other.end, end)]
                } else {//左不相交
                    return [(start, end)]
                }
            } else {//被other包含
                return []
            }
        }
    }
    
    ///区间相交部分
    public func intersect(_ other: FileRange) -> (Int64, Int64)? {
        if start < other.start {
            if end < other.end {//右相交
                if end > other.start {//右相交
                    return (other.start, end)
                } else {//右不相交
                    return nil
                }
            } else {//包含other
                return (other.start, other.end)
            }
        } else {
            if end > other.end {
                if start < other.end {//左相交
                    return (start, other.end)
                } else {//左不相交
                    return nil
                }
            } else {//被other包含
                return (start, end)
            }
        }
    }
}

private extension FileRange {
    @discardableResult func deduct(_ other: FileRange) -> FileRange? {
        guard !isInvalid else {
            return nil
        }
        var result: FileRange?
        let temp = notIntersect(other)
        if temp.count == 2 {
            let first = temp[0]
            let second = temp[1]
            start = first.0
            end = first.1
            result = FileRange(start: second.0, end: second.1)
        } else if temp.count == 1 {
            let first = temp[0]
            start = first.0
            end = first.1
        } else if temp.count == 0 {
            isInvalid = true
        }
        return result
    }
    
    func include(_ other: FileRange) -> FileRange? {
        if let temp = intersect(other) {
            return FileRange(start: temp.0, end: temp.1)
        } else {
            return nil
        }
    }
}
