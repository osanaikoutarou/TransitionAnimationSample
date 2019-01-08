//
//  CustomPrecentDrivenInteractiveTransition.swift
//  TransitionAnimationSample
//
//  Created by osanai on 2019/01/07.
//  Copyright © 2019年 osanai. All rights reserved.
//

// 遷移アニメーションを定義する

import UIKit

class CustomPrecentDrivenInteractiveTransition: UIPercentDrivenInteractiveTransition {
    var shouldBeginGesture:((_ gesture:UIGestureRecognizer) -> Bool)?
    var popViewController:(() -> Void)?
    
    var isPop:Bool = false
    var percentageDriven:Bool = false
    var scale:CGFloat = 0

    var fromView:UIView?
    var toView:UIView?
    var fromVCProtocol:TransitioinAnimationTargetViewControllerProtocol?
    var toVCProtocol:TransitioinAnimationTargetViewControllerProtocol?
    
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
        
//        var percent = gesture.location(in: view).y / view.bounds.height / 1.5
//        percent = (percent < 1.0) ? percent : 0.99
        percentageDriven = true
        
        switch gesture.state {
        case .began:
            if let popViewController = self.popViewController {
                
                popViewController()
            }
        case .changed:
            // 適当なスケール
            let scale:CGFloat = (1000 - gesture.translation(in: view).y)/1000
            fromView?.transform = CGAffineTransform(translationX: gesture.translation(in: view).x, y: gesture.translation(in: view).y * 0.8)
            fromVCProtocol?.targetView.transform = CGAffineTransform(scaleX: scale, y: scale)
            
            // 遷移アニメーションを奪うためにこのようにおく
            // 感覚的には0やpercentとしたいが、transformが打ち消し方向に動く問題が生じたため0.999とする（より良い方法があるかもしれません）
            self.update(0.999)
        case .ended, .cancelled:
            
            if (gesture.translation(in: view).y < 100) {
                self.cancel()
            }
            else {
                // percentを0に戻してからfinish
                self.update(0)
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
        return 1.5 * 1
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }
        guard let fromVCProtocol = fromVC as? TransitioinAnimationTargetViewControllerProtocol else {
            return
        }
        guard let toVCProtocol = toVC as? TransitioinAnimationTargetViewControllerProtocol else {
            return
        }

        let toView:UIView! = toVC.view
        let fromView:UIView! = fromVC.view
        
        if isPop {
            // from :今の画面
            // to :戻った画面
            
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            fromView.frame = containerView.frame
            fromView.transform = CGAffineTransform.identity

            self.fromView = fromView
            self.toView = toView
            self.fromVCProtocol = fromVCProtocol
            self.toVCProtocol = toVCProtocol

            toView.frame = containerView.frame
            toView.transform = CGAffineTransform.identity
            
            let animationDuration = transitionDuration(using: transitionContext)
            
            UIView.animate(withDuration: animationDuration,
                           animations: {
                            
                            toView.transform = CGAffineTransform.identity
                            fromView.transform = self.calcTransform3(fromTargetView: fromVCProtocol.targetView,
                                                                     toTargetView: toVCProtocol.targetView,
                                                                     fromVCView: fromView,
                                                                     toVCView: toView)
                            
                            fromVCProtocol.targetView.transform = self.calcTransform2(fromTargetView: fromVCProtocol.targetView,
                                                                                      toTargetView: toVCProtocol.targetView,
                                                                                      fromVCView: fromView,
                                                                                      toVCView: toView)
                            
            }) { (finished) in
                
                toView.transform = CGAffineTransform.identity
                fromView.transform = CGAffineTransform.identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

            }

        }
        else {
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            
            toView.frame = containerView.frame
            toView.transform = CGAffineTransform(translationX: containerView.frame.height, y: 0)
            
            fromView.frame = containerView.frame
            fromView.transform = CGAffineTransform.identity
            
            let animationDuration = transitionDuration(using: transitionContext)

            UIView.animate(withDuration: animationDuration,
                           animations: {
                            toView.transform = CGAffineTransform.identity
                            fromView.transform = CGAffineTransform.identity
                            
            }) { (finished) in
                toView.transform = CGAffineTransform.identity
                fromView.transform = CGAffineTransform.identity
                
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
        }
        
    }
    
    func animationEnded(_ transitionCompleted: Bool) {
        print("🙂ENDED")
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
        
//        return CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: toTargetFrame.center.x - fromTargetFrame.center.x, ty: toTargetFrame.center.y - fromTargetFrame.center.y)
        return CGAffineTransform(a: scaleX,
                                 b: 0,
                                 c: 0,
                                 d: scaleY,
                                 tx: toTargetFrame.center.x - fromTargetFrameSaled.center.x,
                                 ty: toTargetFrame.center.y - fromTargetFrameSaled.center.y)
        
        
    }
    
    func calcTransform2(fromTargetView:UIView, toTargetView:UIView, fromVCView:UIView, toVCView:UIView) -> CGAffineTransform {
        // imageViewのframe
        let toTargetFrame   = toVCView.convert(toTargetView.frame, to: toVCView)
        let fromTargetFrame = fromVCView.convert(fromTargetView.frame, to: toVCView)
        
        // 縮小後のTargetのFrame
        // アンカーがcenterなので、(center + 差 * スケール)となる
        let scaleX = toTargetFrame.width/fromTargetFrame.width
        let scaleY = toTargetFrame.height/fromTargetFrame.height
//        let fromTargetFrameSaled = CGRect(x: fromVCView.center.x + (fromTargetFrame.origin.x - fromVCView.center.x) * scaleX,
//                                          y: fromVCView.center.y + (fromTargetFrame.origin.y - fromVCView.center.y) * scaleY,
//                                          width: toTargetFrame.width,
//                                          height: toTargetFrame.height)
        
        //        print("scaleX\(scaleX) scaleY\(scaleY)")
        //
        
        //        return CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: toTargetFrame.center.x - fromTargetFrame.center.x, ty: toTargetFrame.center.y - fromTargetFrame.center.y)
//        return CGAffineTransform(a: scaleX,
//                                 b: 0,
//                                 c: 0,
//                                 d: scaleY,
//                                 tx: toTargetFrame.center.x - fromTargetFrame.center.x,
//                                 ty: toTargetFrame.center.y - fromTargetFrame.center.y)
        return CGAffineTransform(a: scaleX,
                                 b: 0,
                                 c: 0,
                                 d: scaleY,
                                 tx: 0,
                                 ty: 0)

        
    }
    
    func calcTransform3(fromTargetView:UIView, toTargetView:UIView, fromVCView:UIView, toVCView:UIView) -> CGAffineTransform {
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
        
        //        return CGAffineTransform(a: 1, b: 0, c: 0, d: 1, tx: toTargetFrame.center.x - fromTargetFrame.center.x, ty: toTargetFrame.center.y - fromTargetFrame.center.y)
        return CGAffineTransform(a: 1,
                                 b: 0,
                                 c: 0,
                                 d: 1,
                                 tx: toTargetFrame.center.x - fromTargetFrame.center.x,
                                 ty: toTargetFrame.center.y - fromTargetFrame.center.y)
        
        
    }
    
}

protocol TransitioinAnimationTargetViewControllerProtocol {
    var targetView:UIView { get }
}

extension CGRect {
    var center:CGPoint {
        return CGPoint(x: origin.x + width/2.0, y: origin.y + height/2.0)
    }
}
