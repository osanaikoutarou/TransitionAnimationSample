//
//  CustomPrecentDrivenInteractiveTransition.swift
//  TransitionAnimationSample
//
//  Created by osanai on 2019/01/07.
//  Copyright © 2019年 osanai. All rights reserved.
//

import UIKit

class CustomPrecentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var shouldBeginGesture:((_ gesture:UIGestureRecognizer) -> Bool)?
    var popViewController:(() -> Void)?
    
    var isPop:Bool = false
    var percentageDriven:Bool = false
    var scale:CGFloat = 0
    
    init(view:UIView) {
        super.init()
        setup(view: view)
    }
    
    func setup(view:UIView) {
        let gesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        gesture.delegate = self
        view.addGestureRecognizer(gesture)
        
        isPop = false
    }
    
    @objc
    func handlePanGesture(gesture:UIPanGestureRecognizer) {
        guard let view = gesture.view else {
            return
        }
        
        var percent = gesture.location(in: view).y / view.bounds.height / 1.5
        percent = (percent < 1.0) ? percent : 0.99
        percentageDriven = true
        
        switch gesture.state {
        case .began:
            if let popViewController = self.popViewController {
                popViewController()
            }
        case .changed:
            self.update(percent)
        case .ended, .cancelled:
            
//            if (gesture.velocity(in: view).y < 0) {
//                self.cancel()   // cancelInteractiveTransition
//            }
//            else {
//                self.finish()   // finishInteractiveTransition
//            }
            if (gesture.translation(in: view).y < 100) {
                self.cancel()
            }
            else {
                self.finish()
            }
            
            percentageDriven = false
        default:
            break
        }
    }
    
    
}

extension CustomPrecentDrivenInteractiveTransition: UIGestureRecognizerDelegate {
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let shouldBeginGesture = shouldBeginGesture {
            return shouldBeginGesture(gestureRecognizer)
        }
        return true
    }
}

extension CustomPrecentDrivenInteractiveTransition: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController,
                              animationControllerFor operation: UINavigationController.Operation,
                              from fromVC: UIViewController,
                              to toVC: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        
        isPop = (operation == UINavigationController.Operation.pop)
        return self
    }
    
    func navigationController(_ navigationController: UINavigationController,
                              interactionControllerFor animationController: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return percentageDriven ? self : nil
    }
}

extension CustomPrecentDrivenInteractiveTransition: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        // アニメーション時間
        return 0.3
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        
        let toView:UIView! = isPop ? fromVC.view : toVC.view
        let fromView:UIView! = isPop ? toVC.view : fromVC.view
        let offset = containerView.frame.height
        
        containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
        if isPop {
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
        }
        
        toView.frame = containerView.frame
        toView.transform = isPop ? CGAffineTransform.identity : CGAffineTransform(translationX: offset, y: 0)
        
        fromView.frame = containerView.frame
        fromView.transform = isPop ? CGAffineTransform(translationX: 0.95, y: 0.95) : CGAffineTransform.identity
        
        let animationDuration = transitionDuration(using: transitionContext)
        
        UIView.animate(withDuration: animationDuration,
                       animations: {
                        toView.transform = self.isPop ? CGAffineTransform(translationX: 0, y: offset) : CGAffineTransform.identity
                        fromView.transform = self.isPop ? CGAffineTransform.identity : CGAffineTransform(translationX: 0.95, y: 0.95)
                        
        }) { (finished) in
            toView.transform = CGAffineTransform.identity
            fromView.transform = CGAffineTransform.identity
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}
