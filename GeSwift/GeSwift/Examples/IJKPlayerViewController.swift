//
//  IJKPlayerViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/17.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

internal final class IJKPlayerViewController: BaseViewController {

    let player = IJKPlayer()
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.player.useDefaultOptions()
        self.player.isMuted = true
        self.player.play(url: URL(string: "http://tb-video.bdstatic.com/tieba-smallvideo-transcode/3612804_e50cb68f52adb3c4c3f6135c0edcc7b0_3.mp4")!, inView: self.view)
    }
}
