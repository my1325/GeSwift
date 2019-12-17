//
//  Player.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/16.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit
import IJKMediaFramework

public final class IJKPlayer {
    
    /// 当前播放时间
    public var currentPlaybackTime: TimeInterval = 0
    
    /// 当前的缓存时间
    public var currentPlayableDuration: TimeInterval = 0
    
    /// 总的播放时间
    public var playableDuration: TimeInterval = 0
    
    public enum PlayerState {
        case idle
        case prepared
        case playing
        case seekingForward
        case seekingBackward
        case paused
        case stoped
        case failed
    }
    /// 播放状态
    public var playerState: PlayerState = .idle
    
    /// 播放速率，默认1.0
    public var rate: Float = 1.0
    
    public enum ScaleModel: Int {
        case none
        case scaleAspectFit
        case scaleAspectFill
        case scaleToFill
        
        var ijkValue: IJKMPMovieScalingMode {
            switch self {
            case .none:
                return .none
            case .scaleAspectFill:
                return .aspectFill
            case .scaleAspectFit:
                return .aspectFit
            case .scaleToFill:
                return .fill
            }
        }
    }
    /// scale model default is scaleAspectFit
    public var scaleMode: ScaleModel = .scaleAspectFit {
        didSet {
            if self.isPlayerPrepared {
                self.player!.scalingMode = self.scaleMode.ijkValue
            }
        }
    }
    
    /// 播放器音量，默认为0
    public var volume: Float = 0 {
        didSet {
            if self.isPlayerPrepared {
                self.player!.playbackVolume = self.volume
                self.isMuted = self.volume < 0.000001
            }
        }
    }
    
    /// 是否静音, 默认为true
    public var isMuted: Bool = true {
        didSet {
            if self.isPlayerPrepared {
                self.player!.playbackVolume = self.isMuted ? 0 : self.volume
            }
        }
    }
    
    /// seek time 
    public var timeToSeek: TimeInterval = 0 {
        didSet {
            if self.isPlayerPrepared {
                self.player!.currentPlaybackTime = self.timeToSeek
            }
        }
    }
    
    /// Private
    /// 播放地址
    public internal(set) var playURL: URL?
    
    /// ijk player
    public internal(set) var player: IJKFFMoviePlayerController?
    
    /// 是否准备好了播放器对象
    public internal(set) var isPlayerPrepared: Bool = false
}
