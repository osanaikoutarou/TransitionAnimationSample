//
//  ViewController.swift
//  TransitionAnimationSample
//
//  Created by osanai on 2019/01/07.
//  Copyright © 2019年 osanai. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var tokeiImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ViewController: TransitioinAnimationTargetViewControllerProtocol {
    func clearBack() {
    }
    
    func resetBack() {
    }
    
    var targetView: UIView {
        return tokeiImageView
    }
}

