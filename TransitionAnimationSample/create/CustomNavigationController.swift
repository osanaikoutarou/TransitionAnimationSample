//
//  CustomViewController.swift
//  TransitionAnimationSample
//
//  Created by osanai on 2019/01/07.
//  Copyright © 2019年 osanai. All rights reserved.
//

import UIKit

class CustomNavigationController: UINavigationController {
    
    var animator:CustomPrecentDrivenInteractiveTransition?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        animator = CustomPrecentDrivenInteractiveTransition(view: self.view)
        animator!.shouldBeginGesture = { (gesture) in
            guard let delegate = self.delegate else {
                return false
            }
            if !(delegate is CustomPrecentDrivenInteractiveTransition) {
                return false
            }
            if (self.viewControllers.count <= 1) {
                return false
            }
            guard let lastVCprotocol = self.viewControllers.last as? TransitioinAnimationTargetPopFromViewControllerProtocol else {
                return false
            }
            return lastVCprotocol.shouldBeginGesture
        }
        animator!.popViewController = {
            self.popViewController(animated: true)
        }
        
        self.delegate = animator

        // Do any additional setup after loading the view.
    }
}
