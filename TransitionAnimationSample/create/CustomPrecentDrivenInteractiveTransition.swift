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

    var fromView:UIView?
    
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
            print(percent)
            if let fromView = fromView {
//                toView.transform.tx = gesture.translation(in: view).x
//                toView.transform.ty = gesture.translation(in: view).y

                let bairitu = (1000 - gesture.translation(in: view).y)/1000
//                print("😍 \(toView.transform.a) \(toView.transform.b) \(toView.transform.c) \(toView.transform.d) \(toView.transform.tx) \(toView.transform.ty) ")
                fromView.transform = CGAffineTransform(a: bairitu, b: 0, c: 0, d: bairitu, tx: gesture.translation(in: view).x, ty: gesture.translation(in: view).y)//gesture.translation(in: view).y)
//                print("🐚 \(toView.transform.a) \(toView.transform.b) \(toView.transform.c) \(toView.transform.d) \(toView.transform.tx) \(toView.transform.ty) ")
                //CGAffineTransform(translationX: gesture.translation(in: view).x, y: gesture.translation(in: view).y)
                
//                print("\(gesture.translation(in: view).x)  \(gesture.translation(in: view).y)")
            }
//            self.update(percent)
            self.update(0.999)
        case .ended, .cancelled:
            
            self.update(0)
//            if (gesture.velocity(in: view).y < 0) {
//                self.cancel()   // cancelInteractiveTransition
//            }
//            else {
//                self.finish()   // finishInteractiveTransition
//            }
            if (gesture.translation(in: view).y < 10) {
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
        return 4.0
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        guard let fromHogeProtocol = fromVC as? HogeProtocol else {
            return
        }
        guard let toHogeProtocol = toVC as? HogeProtocol else {
            return
        }

        let toView:UIView! = toVC.view
        let fromView:UIView! = fromVC.view
        let offset = containerView.frame.height

        print("🤩 frt\(fromHogeProtocol.targetImageView.frame) tot\(toHogeProtocol.targetImageView.frame)")
        
        if isPop {
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            fromView.frame = containerView.frame
            toView.transform = CGAffineTransform.identity
            self.fromView = fromView
            
            print("💪  \(containerView.frame)")
            print("💪  \(toVC.view.frame)")

            toView.frame = containerView.frame
            toView.transform = CGAffineTransform(translationX: 1.0, y: 1.0)
            
            let animationDuration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: animationDuration,
                           animations: {
                            
                            toView.transform = CGAffineTransform.identity
                            let transform = self.calcTransform(fromTargetView: fromHogeProtocol.targetImageView,
                                                               toTargetView: toHogeProtocol.targetImageView,
                                                               fromVCView: fromView,
                                                               toVCView: toView)
                            fromView.transform = transform
                            
            }) { (finished) in
                toView.transform = CGAffineTransform.identity
                fromView.transform = CGAffineTransform.identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }

        }
        else {
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            
            toView.frame = containerView.frame
            toView.transform = CGAffineTransform(translationX: offset, y: 0)
            
            fromView.frame = containerView.frame
            fromView.transform = CGAffineTransform.identity
            
            let animationDuration = transitionDuration(using: transitionContext)

            UIView.animate(withDuration: animationDuration,
                           animations: {
                            toView.transform = CGAffineTransform.identity
                            fromView.transform = CGAffineTransform(translationX: 1.0, y: 1.0)
                            
            }) { (finished) in
                toView.transform = CGAffineTransform.identity
                fromView.transform = CGAffineTransform.identity
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
        
    }
    
    func calcTransform(fromTargetView:UIView, toTargetView:UIView, fromVCView:UIView, toVCView:UIView) -> CGAffineTransform {
        // imageViewのframe
        let toTargetFrame   = toVCView.convert(toTargetView.frame, to: toVCView)
        let fromTargetFrame = fromVCView.convert(fromTargetView.frame, to: fromVCView)
        
        // 縮小後のTargetのFrame
        // アンカーがcenterなので、(center + 差 * スケール)となる
        let scaleX = toTargetFrame.width/fromTargetFrame.width
        let scaleY = toTargetFrame.height/fromTargetFrame.height
        let fromTargetFrameSaled = CGRect(x: fromVCView.center.x + (fromTargetFrame.origin.x - fromVCView.center.x) * scaleX,
                                          y: fromVCView.center.y + (fromTargetFrame.origin.y - fromVCView.center.y) * scaleY,
                                          width: toTargetFrame.width,
                                          height: toTargetFrame.height)
        
//        print("scaleX\(scaleX) scaleY\(scaleY)")
//
        return CGAffineTransform(a: scaleX,
                                 b: 0,
                                 c: 0,
                                 d: scaleY,
                                 tx: toTargetFrame.center.x - fromTargetFrameSaled.center.x,
                                 ty: toTargetFrame.center.y - fromTargetFrameSaled.center.y)
        
    }
    
}

protocol HogeProtocol {
    var targetImageView:UIImageView { get }
}

extension CGRect {
    var center:CGPoint {
        return CGPoint(x: origin.x + width/2.0, y: origin.y + height/2.0)
    }
}
