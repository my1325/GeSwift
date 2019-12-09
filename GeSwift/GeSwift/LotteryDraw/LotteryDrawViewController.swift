//
//  LotteryDrawViewController.swift
//  GeSwift
//
//  Created by 超神—mayong on 2019/12/9.
//  Copyright © 2019 my. All rights reserved.
//

import UIKit

class LotteryDrawViewController: BaseViewController {

    @IBOutlet weak var lotteryDrawView: LotteryDraw!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        self.lotteryDrawView.run()
        DispatchQueue.main.asyncAfter(deadline: .now() + 3.17) {
            self.lotteryDrawView.stopAtIndex(18)
        }
    }

}
