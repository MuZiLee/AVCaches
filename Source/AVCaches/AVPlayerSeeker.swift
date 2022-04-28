//
//  AVPlayerSeeker.swift
//  AVCaches
//
//  Created by lee on 2022/4/28

import AVKit

public class AVPlayerSeeker {
    
    private var isSeeking = false
    
    private var targetTime = CMTime.zero
    
    public weak var player: AVPlayer?
    
    public init(player: AVPlayer) {
        self.player = player
    }

    public func seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        targetTime = time
        guard !isSeeking else {
            return
        }
        isSeeking = true
        _seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
    }
    
    private func _seek(to time: CMTime, toleranceBefore: CMTime, toleranceAfter: CMTime, completionHandler: @escaping (Bool) -> Void) {
        player?.seek(to: time, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: { [weak self] success in
            guard let _self = self else {
                completionHandler(success)
                return
            }
            if _self.targetTime == time {
                _self.isSeeking = false
                completionHandler(success)
            } else {
                _self._seek(to: _self.targetTime, toleranceBefore: toleranceBefore, toleranceAfter: toleranceAfter, completionHandler: completionHandler)
            }
        })
    }
}
