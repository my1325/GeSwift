//
//  Player+Configuration.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/16.
//  Copyright © 2019 my. All rights reserved.
//

import Foundation
import IJKMediaFramework


fileprivate var ijkOptions = "com.ge.ijk.options.associate.key"

public extension IJKPlayer {
    /// 使用默认的播放器设置参数
    func useDefaultOptions() {
        self.setSupportHttp()
        self.setAnalyzeMaxDuration()
        self.setProbesize()
        self.setFlushPackets()
        self.setPacketBuffering()
        self.setFrameDrop()
    }
}

/// 此处播放之后，将在下一次播放生效
public extension IJKPlayer {
    
    var options: IJKFFOptions {
        var option = objc_getAssociatedObject(self, &ijkOptions) as? IJKFFOptions
        if option == nil {
            option = IJKFFOptions.byDefault()
            objc_setAssociatedObject(self, &ijkOptions, option, .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
        return option!
    }
    
    /// 如果遇到http不能播放的情况，可以调用这个方法试一下
    func setSupportHttp() {
        self.options.setFormatOptionIntValue(1, forKey: "dns_cache_clear")
    }
    
    /// 设置播放前的最大探测时间
    func setAnalyzeMaxDuration(_ duration: Int64 = 100) {
        self.options.setFormatOptionIntValue(duration, forKey: "analyzemaxduration")
    }
    
    /// 播放前的探测Size，默认是1M, 改小一点会出画面更快
    func setProbesize(_ probesize: Int64 = 1024 * 10) {
        self.options.setFormatOptionIntValue(probesize, forKey: "probesize")
    }
    
    /// 每处理一个packet之后刷新io上下文
    func setFlushPackets(_ flushPackets: Int64 = 1) {
        self.options.setFormatOptionIntValue(flushPackets, forKey: "flush_packets")
    }
    
    /// 是否开启预缓冲，一般直播项目会开启，达到秒开的效果，不过带来了播放丢帧卡顿的体验
    ///    mediaPlayer.setOption(4, "packet-buffering", 0L);
    func setPacketBuffering(_ packetBuffering: Bool = false) {
        self.options.setPlayerOptionIntValue(packetBuffering ? 1 : 0, forKey: "flush_packets")
    }
    
    /// 跳帧处理, 当CPU处理较慢时，进行跳帧处理，保证播放流程，画面和声音同步
    func setFrameDrop(_ frameDrop: Int64 = 1) {
        self.options.setPlayerOptionIntValue(frameDrop, forKey: "framedrop")
    }
    
    /// 设置播放前的探测时间 1,达到首屏秒开效果
    func setAnalyzeDuration(_ duration: Int64) {
        self.options.setFormatOptionIntValue(duration, forKey: "analyzeduration")
    }
    
    /// 是否开启变调
    func setIsModifyTone(_ isModifyTone: Bool) {
        self.options.setPlayerOptionIntValue(isModifyTone ? 0 : 1, forKey: "soundtouch")
    }

    /// 是否开启环路过滤(开启质量高，解码开销大， 不开启质量差，解码开销小)
    func setIsSkipLookFilter(_ isSkipLookFilter: Bool) {
        self.options.setCodecOptionIntValue(isSkipLookFilter ? 0 : 48, forKey: "skip_loop_filter")
    }
    
    /// 播放重连次数
    func setReconnectTimes(_ reconnect: Int64) {
        self.options.setPlayerOptionIntValue(reconnect, forKey: "reconnect")
    }
    
    /// 设置缓存大小，单位kb
    func setMaxBufferSize(_ size: Int64) {
        self.options.setPlayerOptionIntValue(size, forKey: "max-buffer-size")
    }
    
    /// 最大FPS
    func setMaxFPS(_ fps: Int64) {
        self.options.setPlayerOptionIntValue(fps, forKey: "max-fps")
    }
    
    /// 解码方式(0, 为软解，1，为硬解，默认是0)
    func setDecodeMethod( _ method: Int64) {
        self.options.setPlayerOptionIntValue(method, forKey: "videotoolbox")
    }
    
    /// 设置seek能快速定位到位置并播放, 解决m3u8文件拖动问题 比如:一个3个多少小时的音频文件，开始播放几秒中，然后拖动到2小时左右的时间，要loading 10分钟
    func setFastSeek() {
        self.options.setFormatOptionValue("fastseek", forKey: "fflags")
    }
    
    /// SeekTo设置优化某些视频在SeekTo的时候，会跳回到拖动前的位置，
    /// 这是因为视频的关键帧的问题，通俗一点就是FFMPEG不兼容，视频压缩过于厉害，seek只支持关键帧，出现这个情况就是原始的视频文件中i 帧比较少
    func setAccurateSeek() {
        self.options.setPlayerOptionIntValue(1, forKey: "enable-accurate-seek")
    }
}

/// 问题： 设置之后，高码率m3u8的播放卡顿，声音画面不同步，或者只有画面，没有声音，或者声音画面不同步
///mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_PLAYER, "enable-accurate-seek", 1);
///mediaPlayer.setOption(IjkMediaPlayer.OPT_CATEGORY_FORMAT, "probesize", 1024 * 10);
