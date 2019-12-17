//
//  Player+Play.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/16.
//  Copyright © 2019 my. All rights reserved.
//

import Foundation
import IJKMediaFramework


fileprivate var ijkPlayerProperties = "com.ijk.player.extionsion.properties"
public extension IJKPlayer {
    
    private var properties: ExtensionIJKPlayerProperties {
        get {
            var properties = objc_getAssociatedObject(self, &ijkPlayerProperties) as? ExtensionIJKPlayerProperties
            if properties == nil {
                properties = ExtensionIJKPlayerProperties()
                objc_setAssociatedObject(self, &ijkPlayerProperties, properties, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
            }
            return properties!
        } set {
            objc_setAssociatedObject(self, &ijkPlayerProperties, newValue, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
    
    private struct ExtensionIJKPlayerProperties {
        
        var timer: Timer?
        
        var queue: DispatchQueue = DispatchQueue(label: "com.ge.ijk.player.loop.queue")
        
        var superView: UIView?
    }
    
    /// 播放
    func play(url: URL, inView superView: UIView) {
        /// 如果在当前页面重播，则重置到0秒开始，不再重新加载URL
        if self.playURL == url, self.properties.superView == superView {
            self.isPlayerPrepared = true
            self.timeToSeek = 0
            self.player?.play()
        } else {
            /// 如果播放器不处于空闲状态，则先停止当前的播放器行为
            if self.playerState != .idle {
                self.stop()
            }
            self.properties.superView = superView
            self.playURL = url
            self.prepareToPlay()
        }
    }
    
    /// 暂停
    func paused() {
        self.player?.pause()
        self.playerState = .paused
    }
    
    /// 停止
    func stop() {
        self.playerState = .stoped
        self.removePlayerNotifications()
        self.player!.shutdown()
        self.player!.view.removeFromSuperview()
        self.currentPlaybackTime = 0
        self.currentPlayableDuration = 0
        self.playableDuration = 0
        self.playURL = nil
        self.player = nil
        self.playerState = .idle
        self.isPlayerPrepared = false
    }
}

extension IJKPlayer {
    
    private func prepareToPlay() {
        guard let url = self.playURL else { return }
        
        self.player = IJKFFMoviePlayerController(contentURL: url, with: self.options)
        self.player?.shouldAutoplay = true
        self.player?.prepareToPlay()
        self.player?.scalingMode = self.scaleMode.ijkValue
        self.player?.play()
        self.player?.playbackRate = self.rate
        self.properties.superView!.addSubview(self.player!.view)
        self.player!.view.frame = self.properties.superView!.bounds
        self.player!.view.backgroundColor = UIColor.clear
        self.player!.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addPlayerNotifications()
        self.isPlayerPrepared = true
    }
    
    private func scheduleTimer() {
        self.invalidateTimer()
        self.properties.queue.async { [weak self] in
            guard let self = self else { return }
            self.properties.timer = Timer.scheduledTimer(timeInterval: 1,
                                                         target: WeakTarget(target: self, selector: self.updateTimer),
                                                         selector: #selector(WeakTarget<Timer>.handleActionEvent(_:)),
                                                         userInfo: nil,
                                                         repeats: true)
            RunLoop.current.add(self.properties.timer!, forMode: .common)
            RunLoop.current.run()
        }
    }
    
    private func invalidateTimer() {
        self.properties.timer?.invalidate()
        self.properties.timer = nil
    }
    
    private func updateTimer(_ timer: Timer) {
        self.currentPlaybackTime = max(0, self.player?.currentPlaybackTime ?? 0)
        self.playableDuration = self.player?.duration ?? 0
        self.currentPlayableDuration = self.player?.playableDuration ?? 0
    }
}

@objc
extension IJKPlayer {
    
    fileprivate func addPlayerNotifications() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(loadStateDidChange(_:)),
                                               name: .IJKMPMoviePlayerLoadStateDidChange,
                                               object: self.player!)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moviePlayBackFinish(_:)),
                                               name: .IJKMPMoviePlayerPlaybackDidFinish,
                                               object: self.player!)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(mediaIsPreparedToPlayDidChange(_:)),
                                               name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange,
                                               object: self.player!)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(moviePlayBackStateDidChange(_:)),
                                               name: .IJKMPMoviePlayerPlaybackStateDidChange,
                                               object: self.player!)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(sizeAvailableChange(_:)),
                                               name: .IJKMPMovieNaturalSizeAvailable,
                                               object: self.player!)
    }
    
    fileprivate func removePlayerNotifications() {
        NotificationCenter.default.removeObserver(self,
                                               name: .IJKMPMoviePlayerLoadStateDidChange,
                                               object: self.player!)
        NotificationCenter.default.removeObserver(self,
                                               name: .IJKMPMoviePlayerPlaybackDidFinish,
                                               object: self.player!)
        NotificationCenter.default.removeObserver(self,
                                               name: .IJKMPMediaPlaybackIsPreparedToPlayDidChange,
                                               object: self.player!)
        NotificationCenter.default.removeObserver(self,
                                               name: .IJKMPMoviePlayerPlaybackStateDidChange,
                                               object: self.player!)
        NotificationCenter.default.removeObserver(self,
                                               name: .IJKMPMovieNaturalSizeAvailable,
                                               object: self.player!)
    }
    
    /// 准备播放
    func loadStateDidChange(_ notification: Notification) {
        guard let loadState = self.player?.loadState else { return }
        switch loadState {
        case .playable:
            /// 加载状态变成了缓存数据足够开始播放，但是视频并没有缓存完全
            if self.currentPlaybackTime > 0 {
                self.playerState = .playing
            }
        case .playthroughOK:
            /// 加载完成，即将播放，停止加载的动画，并将其移除
            /// 加载状态变成了已经缓存完成，如果设置了自动播放, 会自动播放
            self.playerState = .prepared
        case .stalled:
            /// 可能由于网速不好等因素导致了暂停，重新添加加载的动画, 网速不好等因素导致了暂停
            self.playerState = .idle
        default:
            self.playerState = .idle
        }
    }
    
    /// 播放完成或者用户退出
    func moviePlayBackFinish(_ notification: Notification) {
        if let reason = notification.userInfo?[IJKMPMoviePlayerPlaybackDidFinishReasonUserInfoKey] as? Int {
            switch reason {
            case IJKMPMovieFinishReason.playbackEnded.rawValue:
                /// 播放完毕
                self.playerState = .stoped
            case IJKMPMovieFinishReason.userExited.rawValue:
                /// 用户退出播放
                self.playerState = .stoped
            case IJKMPMovieFinishReason.playbackError.rawValue:
                /// 播放出错
                self.playerState = .failed
            default:
                break
            }
        }
    }
    
    /// 准备开始播放了
    func mediaIsPreparedToPlayDidChange(_ notification: Notification) {
        /// 加载状态变成了已经缓存完成，如果设置了自动播放, 会自动播放
        self.playerState = .playing
        self.scheduleTimer()
        if self.timeToSeek > 0.00001 {
            self.player!.currentPlaybackTime = self.timeToSeek
        }
        self.player?.playbackVolume = self.isMuted ? 0 : self.volume
    }
    
    /// 播放状态改变了
    func moviePlayBackStateDidChange(_ notification: Notification) {
        guard let playState = self.player?.playbackState else { return }
        switch playState {
        case .stopped:
            self.playerState = .stoped
        case .playing:
            self.playerState = .playing
        case .paused:
            self.playerState = .paused
        case .interrupted:
            self.playerState = .paused
        case .seekingBackward:
            self.playerState = .seekingBackward
        case .seekingForward:
            self.playerState = .seekingForward
        default:
            break
        }
    }
    
    /// 视频的尺寸变化了
    func sizeAvailableChange(_ notification: Notification) {
        /// 尺寸变化
    }
}
