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

extension ViewController: TransitioinAnimationTargetPushFromViewControllerProtocol {
    var targetViewPushFrom: UIView {
        return tokeiImageView
    }
    
    func animationStartInPushFro() {
        targetViewPushFrom.isHidden = true
    }
    
    func animationEndedInPushFro() {
        targetViewPushFrom.isHidden = false
    }
    
}

extension ViewController: TransitioinAnimationTargetPopToViewControllerProtocol {
    var targetViewPopTo: UIView {
        return tokeiImageView
    }
    
    func animationStartInPopTo() {
        targetViewPushFrom.isHidden = true
    }
    
    func animationEndedInPopTo() {
        targetViewPushFrom.isHidden = false
    }
}

