//
//  AVPlayer+Observer.swift
//  AVCaches
//
//  Created by lee on 2022/4/28

import AVKit

let kAVPlayerItemStatus = "status"
let kAVPlayerItemDuration = "duration"
let kAVPlayerItemBufferEmpty = "playbackBufferEmpty"
let kAVPlayerItemBufferFull = "playbackBufferFull"
let kAVPlayerItemKeepUp = "playbackLikelyToKeepUp"
let kAVPlayerItemTimeRanges = "loadedTimeRanges"

let kAVPlayerRate = "rate"
let kAVPlayerError = "error"
let kAVPlayerTimeControl = "timeControlStatus"

private var kAVPlayerItemObserverKey = 23523456
private var kAVPlayerObserverKey = 42341234
private var kAVPlayerTimeObserverKey = 443456

public extension AVPlayerItem {
    private(set) var observer: NSObject? {
        set {
            objc_setAssociatedObject(self, &kAVPlayerItemObserverKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        } get {
            objc_getAssociatedObject(self, &kAVPlayerItemObserverKey) as? NSObject
        }
    }
    
    func setObserver(_ o: NSObject) {
        removeObserver()
        addObserver(o, forKeyPath: kAVPlayerItemStatus, options: .new, context: nil)
        addObserver(o, forKeyPath: kAVPlayerItemDuration, options: .new, context: nil)
        addObserver(o, forKeyPath: kAVPlayerItemBufferEmpty, options: .new, context: nil)
        addObserver(o, forKeyPath: kAVPlayerItemBufferFull, options: .new, context: nil)
        addObserver(o, forKeyPath: kAVPlayerItemKeepUp, options: .new, context: nil)
        addObserver(o, forKeyPath: kAVPlayerItemTimeRanges, options: .new, context: nil)
        observer = o
    }
    
    func removeObserver() {
        guard let _observer = observer else {
            return
        }
        removeObserver(_observer, forKeyPath: kAVPlayerItemStatus)
        removeObserver(_observer, forKeyPath: kAVPlayerItemDuration)
        removeObserver(_observer, forKeyPath: kAVPlayerItemBufferEmpty)
        removeObserver(_observer, forKeyPath: kAVPlayerItemBufferFull)
        removeObserver(_observer, forKeyPath: kAVPlayerItemKeepUp)
        removeObserver(_observer, forKeyPath: kAVPlayerItemTimeRanges)
        observer = nil
    }
}

public extension AVPlayer {
    private(set) var observer: NSObject? {
        set {
            objc_setAssociatedObject(self, &kAVPlayerObserverKey, newValue, .OBJC_ASSOCIATION_ASSIGN)
        } get {
            objc_getAssociatedObject(self, &kAVPlayerObserverKey) as? NSObject
        }
    }
    
    private(set) var timeObserver: Any? {
        set {
            objc_setAssociatedObject(self, &kAVPlayerTimeObserverKey, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        } get {
            objc_getAssociatedObject(self, &kAVPlayerTimeObserverKey)
        }
    }
 
    func setObserver(_ o: NSObject, timeChanged: @escaping (CMTime) -> Void) {
        removeObserver()
        addObserver(o, forKeyPath: kAVPlayerRate, options: .new, context: nil)
        addObserver(o, forKeyPath: kAVPlayerError, options: .new, context: nil)
        addObserver(o, forKeyPath: kAVPlayerTimeControl, options: .new, context: nil)
        timeObserver = addPeriodicTimeObserver(forInterval: .init(value: 1, timescale: .init(60.0)), queue: .main, using: timeChanged)
        observer = o
    }
    
    func removeObserver() {
        if let _observer = observer {
            removeObserver(_observer, forKeyPath: kAVPlayerRate)
            removeObserver(_observer, forKeyPath: kAVPlayerError)
            removeObserver(_observer, forKeyPath: kAVPlayerTimeControl)
        }
        if let _timeObserver = timeObserver {
            removeTimeObserver(_timeObserver)
        }
        observer = nil
        timeObserver = nil
    }
}
