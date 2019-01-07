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
            return self.viewControllers.count > 1
        }
        animator!.popViewController = {
            self.popViewController(animated: true)
        }
        
        self.delegate = animator

        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
