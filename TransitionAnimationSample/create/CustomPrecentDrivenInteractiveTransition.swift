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
    var pushFromVCProtocol:TransitioinAnimationTargetPushFromViewControllerProtocol?
    var pushToVCProtocol:TransitioinAnimationTargetPushToViewControllerProtocol?
    var popFromVCProtocol:TransitioinAnimationTargetPopFromViewControllerProtocol?
    var popToVCProtocol:TransitioinAnimationTargetPopToViewControllerProtocol?
    
    var pan:Bool = false
    
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
        
        percentageDriven = true
        
        switch gesture.state {
        case .began:
            if let popViewController = self.popViewController {
                popViewController()
            }
            pan = true
        case .changed:
            guard let popFromVCProtocol = self.popFromVCProtocol else {
                return
            }
            guard let popToVCProtocol = self.popToVCProtocol else {
                return
            }

            // 適当なスケール
            let scaleW:CGFloat = popToVCProtocol.targetViewPopTo.frame.width / popFromVCProtocol.targetViewPopFrom.frame.width
            let scaleH:CGFloat = popToVCProtocol.targetViewPopTo.frame.height / popFromVCProtocol.targetViewPopFrom.frame.height
            let progress:CGFloat = min(1.0, (500 - (gesture.translation(in: view).y - 50) )/500)
            let progressRev:CGFloat = 1 - progress
            print("scale \(scaleW) \(scaleH)")
            print(progressRev)
                                       
            fromView?.transform = CGAffineTransform(translationX: gesture.translation(in: view).x, y: gesture.translation(in: view).y * 0.8)
            popFromVCProtocol.targetViewPopFrom.transform = CGAffineTransform(scaleX: 1 - (1 - scaleW) * progressRev, y: 1 - (1 - scaleH) * progressRev)
            
            fromView?.backgroundColor = fromView?.backgroundColor?.withAlphaComponent(1.0 - gesture.translation(in: view).y * 0.01)
            
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
            pan = false
            
        default:
            break
        }
    }
    
    func finish(doSomething:((_ withPanGesture:Bool) -> Void)) {
        doSomething(pan)
        finish()
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
        if isPop {
            return 0.4
        }
        else {
            return 0
        }
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let containerView = transitionContext.containerView

        guard let fromVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from) else {
            return
        }
        guard let toVC = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to) else {
            return
        }

        let toView:UIView! = toVC.view
        let fromView:UIView! = fromVC.view
        
        if isPop {
            // from :今の画面
            // to :戻った画面
            
            guard let popFromVCProtocol = fromVC as? TransitioinAnimationTargetPopFromViewControllerProtocol else {
                return
            }
            guard let popToVCProtocol = toVC as? TransitioinAnimationTargetPopToViewControllerProtocol else {
                return
            }
            
            popFromVCProtocol.animationStartInPopFrom()
            popToVCProtocol.animationStartInPopTo()
            
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            containerView.insertSubview(toVC.view, belowSubview: fromVC.view)
            
            fromView.frame = containerView.frame
            fromView.transform = CGAffineTransform.identity

            self.fromView = fromView
            self.toView = toView
            self.popFromVCProtocol = popFromVCProtocol
            self.popToVCProtocol = popToVCProtocol

            toView.frame = containerView.frame
            toView.transform = CGAffineTransform.identity
            
            let animationDuration = transitionDuration(using: transitionContext)

            if !pan {
                popFromVCProtocol.clearBack()
            }
            
            UIView.setAnimationCurve(.easeOut)
            
            UIView.animate(withDuration: animationDuration,
                           animations: {
                            
                            toView.transform = CGAffineTransform.identity
                            
                            // 画面自体を移動し、ターゲットViewを拡縮する
                            // （両方を画面に適用した場合、不本意な挙動をしたため）
                            fromView.transform = self.transformBackFromVC(fromTargetView: popFromVCProtocol.targetViewPopFrom,
                                                                          toTargetView: popToVCProtocol.targetViewPopTo,
                                                                          fromVCView: fromView,
                                                                          toVCView: toView)
                            popFromVCProtocol.targetViewPopFrom.transform = self.transformBackTargetView(fromTargetView: popFromVCProtocol.targetViewPopFrom,
                                                                                                         toTargetView: popToVCProtocol.targetViewPopTo)
                            
            }) { (finished) in
                
                toView.transform = CGAffineTransform.identity
                fromView.transform = CGAffineTransform.identity
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)

            }

        }
        else {
            // from :今の画面
            // to :進む画面
            
            guard let pushFromVCProtocol = fromVC as? TransitioinAnimationTargetPushFromViewControllerProtocol else {
                return
            }
            guard let pushToVCProtocol = toVC as? TransitioinAnimationTargetPushToViewControllerProtocol else {
                return
            }
            
            pushToVCProtocol.animationStartInPushTo()
            pushToVCProtocol.animationStartInPushTo()
            
            containerView.insertSubview(toVC.view, aboveSubview: fromVC.view)
            
            toView.frame = containerView.frame
            toView.transform = CGAffineTransform(translationX: containerView.frame.height, y: 0)
            
            fromView.frame = containerView.frame
            fromView.transform = CGAffineTransform.identity
            
            self.fromView = fromView
            self.toView = toView
            self.pushFromVCProtocol = pushFromVCProtocol
            self.pushToVCProtocol = pushToVCProtocol
            
            // 実際は0秒
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
        if isPop {
            self.popFromVCProtocol?.resetBack()
            self.popFromVCProtocol?.animationEndedInPopFrom()
            self.popToVCProtocol?.animationEndedInPopTo()
        }
        else {
            if let targetView = self.pushToVCProtocol?.targetViewPushTo {
                targetView.transform = self.transformForwaradTargetView(fromTargetView: self.pushFromVCProtocol!.targetViewPushFrom, toTargetView: self.pushToVCProtocol!.targetViewPushTo, fromVCView: fromView!, toVCView: toView!)
                
                UIView.setAnimationCurve(.easeOut)
                
                UIView.animate(withDuration: 0.3, animations: {
                    targetView.transform = CGAffineTransform.identity
                }, completion: { (finished) in
                    self.pushToVCProtocol?.animationEndedInPushTo()
                    self.pushFromVCProtocol?.animationEndedInPushFro()
                })
            }
        }
    }
    
    
}

// 進む遷移のときのtransform
extension CustomPrecentDrivenInteractiveTransition {
    // 拡大と移動 ターゲットView
    func transformForwaradTargetView(fromTargetView:UIView, toTargetView:UIView, fromVCView:UIView, toVCView:UIView) -> CGAffineTransform {
        let toTargetFrame = toVCView.convert(toTargetView.frame, to: toVCView)
        let fromTargetFrame = fromVCView.convert(fromTargetView.frame, to: toVCView)
        
        let scaleX = fromTargetFrame.width/toTargetFrame.width
        let scaleY = fromTargetFrame.height/toTargetFrame.height
        
        return CGAffineTransform(a: scaleX, b: 0, c: 0, d: scaleY, tx: fromTargetFrame.center.x - toTargetFrame.center.x, ty: fromTargetFrame.center.y - toTargetFrame.center.y)
    }
    
    
}
// 戻る遷移のときのtransform
extension CustomPrecentDrivenInteractiveTransition {
    // 拡大のみ ターゲットView
    func transformBackTargetView(fromTargetView:UIView, toTargetView:UIView) -> CGAffineTransform {
        return CGAffineTransform(scaleX: toTargetView.frame.width/fromTargetView.frame.width,
                                 y: toTargetView.frame.height/fromTargetView.frame.height)
    }
    // 移動のみ 画面
    func transformBackFromVC(fromTargetView:UIView, toTargetView:UIView, fromVCView:UIView, toVCView:UIView) -> CGAffineTransform {
        // imageViewのframe
        let toTargetFrame   = toVCView.convert(toTargetView.frame, to: toVCView)
        let fromTargetFrame = fromVCView.convert(fromTargetView.frame, to: toVCView)
        
        return CGAffineTransform(translationX: toTargetFrame.center.x - fromTargetFrame.center.x,
                                 y: toTargetFrame.center.y - fromTargetFrame.center.y)
    }
}

// 戻る,今の画面
protocol TransitioinAnimationTargetPopFromViewControllerProtocol {
    var targetViewPopFrom:UIView { get }
    func animationStartInPopFrom()
    func animationEndedInPopFrom()

    var shouldBeginGesture:Bool { get }
    func clearBack()
    func resetBack()
}
// 戻る,前の画面
protocol TransitioinAnimationTargetPopToViewControllerProtocol {
    var targetViewPopTo:UIView { get }
    func animationStartInPopTo()
    func animationEndedInPopTo()
}
// 進む,今の画面
protocol TransitioinAnimationTargetPushFromViewControllerProtocol {
    var targetViewPushFrom:UIView { get }
    func animationStartInPushFro()
    func animationEndedInPushFro()
}
// 進む,前の画面
protocol TransitioinAnimationTargetPushToViewControllerProtocol {
    var targetViewPushTo:UIView { get }
    func animationStartInPushTo()
    func animationEndedInPushTo()
}

extension CGRect {
    var center:CGPoint {
        return CGPoint(x: origin.x + width/2.0, y: origin.y + height/2.0)
    }
}


