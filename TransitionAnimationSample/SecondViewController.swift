//
//  SecondViewController.swift
//  TransitionAnimationSample
//
//  Created by osanai on 2019/01/07.
//  Copyright © 2019年 osanai. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController {

    @IBOutlet weak var hogeImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

//        self.view.backgroundColor = UIColor(red: 0, green: 1, blue: 1, alpha: 0.5)
//        self.view.alpha = 0
        // Do any additional setup after loading the view.
    }
}

extension SecondViewController: TransitioinAnimationTargetViewControllerProtocol {
    func clearBack() {
        self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(0)
    }
    
    func resetBack() {
        self.view.backgroundColor = self.view.backgroundColor?.withAlphaComponent(1)
    }
    
    var targetView: UIView {
        return hogeImageView
    }
}
