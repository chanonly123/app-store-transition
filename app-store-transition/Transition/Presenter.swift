//
//  Presenter.swift
//  app-store-transition
//
//  Created by Chandan Karmakar on 20/04/21.
//

import UIKit

public protocol HomeController: UIViewController {
    var linkView: UIView { get }
    func willStartTransition()
    func willEndTransition()
    func didEndTransition()
}

public extension HomeController {
    func willStartTransition() {}
    func willEndTransition() {}
    func didEndTransition() {}
}

public protocol DetailController: UIViewController {
    func willStartDismiss(duration: Double)
    func didEndTransition()
}

public extension DetailController {
    func willStartDismiss(duration: Double) {}
    func didEndTransition() {}
}

public class Presenter: NSObject, UIViewControllerAnimatedTransitioning, UIViewControllerTransitioningDelegate {
    public struct Params {
        weak var from: HomeController!
        weak var to: DetailController!
        
        public init(from: HomeController, to: DetailController) {
            self.from = from
            self.to = to
        }
    }
    
    var targetFrame = CGRect.zero
    let duration: Double = 0.9
    let params: Params
    var isPresenting = true
    
    var leading: NSLayoutConstraint?
    var trailing: NSLayoutConstraint?
    var bottom: NSLayoutConstraint?
    var top: NSLayoutConstraint?
    var blurView = UIVisualEffectView(effect: UIBlurEffect(style: .regular))
    public var configTransitionContext: ((UIView) -> Void)?
    
    public lazy var behaviour = DismissBehaviour(presenter: self)
    
    weak var container: UIView?
    public weak var scrollView: UIScrollView? {
        didSet {
            scrollView?.panGestureRecognizer.require(toFail: behaviour.dismissalScreenEdgePanGesture)
        }
    }
    
    public init(params: Params) {
        self.params = params
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        duration
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        if params.from == nil || params.to == nil {
            assertionFailure("from/to controllers nil")
            return
        }
        let container = transitionContext.containerView
        configTransitionContext?(container)
        self.container = container
        if isPresenting {
            params.from.linkView.alpha = 0
            
            targetFrame = params.from.linkView.frame
            targetFrame.origin = params.from.linkView.superview!.convert(params.from.linkView.frame.origin, to: UIApplication.shared.windows.first!)
            
//            print("targetFrame", targetFrame)
            
            container.addSubview(params.to.view)
            params.to.view.translatesAutoresizingMaskIntoConstraints = false
            params.to.view.clipsToBounds = true
            params.to.view.layer.cornerRadius = params.from.linkView.layer.cornerRadius
            
            leading = params.to.view.leadingAnchor.constraint(equalTo: params.to.view.superview!.leadingAnchor, constant: 0)
            trailing = params.to.view.superview!.trailingAnchor.constraint(equalTo: params.to.view.trailingAnchor, constant: 0)
            top = params.to.view.topAnchor.constraint(equalTo: params.to.view.superview!.topAnchor, constant: 0)
            bottom = params.to.view.superview!.bottomAnchor.constraint(equalTo: params.to.view.bottomAnchor, constant: 0)
            
            [leading, trailing, top, bottom].forEach { $0?.isActive = true }
            
            setSmallVersion()
            
            container.setNeedsLayout()
            container.layoutIfNeeded()
                
            [leading, trailing, top, bottom].forEach { $0?.constant = 0 }
            
            self.params.from.willStartTransition()
            
            UIView.animate(withDuration: duration * 0.5, delay: duration * 0.5, options: [], animations: {
                self.params.to.view.layer.cornerRadius = 0
            }, completion: nil)

            let dur = duration - Double(targetFrame.origin.y / container.bounds.height) * 0.2
            let damping = 0.55 + targetFrame.origin.y * 0.0002
            print(dur, damping)
            UIView.animate(withDuration: dur, delay: 0.0, usingSpringWithDamping: damping, initialSpringVelocity: 0.0, options: []) {
                container.layoutIfNeeded()
            } completion: { _ in
                container.addSubview(self.blurView)
                self.blurView.frame = container.bounds
                container.sendSubviewToBack(self.blurView)
                
                transitionContext.completeTransition(true)
                self.params.to.didEndTransition()
            }
        } else {
            self.params.to.willStartDismiss(duration: duration)
            self.params.from.willEndTransition()
            setSmallVersion()
            
            UIView.animate(withDuration: duration * 0.3, animations: {
                self.params.to.view.transform = .identity
                self.params.to.view.layer.cornerRadius = self.params.from.linkView.layer.cornerRadius
            }, completion: nil)
            UIView.animate(withDuration: duration * 0.8, delay: 0.0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: []) {
                container.layoutIfNeeded()
                self.blurView.alpha = 0
            } completion: { _ in
                self.params.from.linkView.alpha = 1
                self.params.to.view.removeFromSuperview()
                transitionContext.completeTransition(true)
                self.params.from.didEndTransition()
            }
        }
    }
    
    func createDismissAnimator() {
        if dismissAnimator != nil { return }
        let animator = UIViewPropertyAnimator(duration: 0, curve: .linear, animations: { [weak self] in
            self?.params.to.view.transform = .init(scaleX: 0.9, y: 0.9)
            self?.params.to.view.layer.cornerRadius = self!.params.from.linkView.layer.cornerRadius
        })
        animator.isReversed = false
        animator.pauseAnimation()
        animator.fractionComplete = 0
        dismissAnimator = animator
    }
    
    var dismissAnimator: UIViewPropertyAnimator!
    
    func setBigVersion() {
        [leading, trailing, top, bottom].forEach { $0?.constant = 0 }
        params.to.view.layer.cornerRadius = 0
    }
    
    func setSmallVersion() {
        guard let container = self.container else { return }
        leading?.constant = targetFrame.origin.x
        trailing?.constant = container.bounds.width - targetFrame.origin.x - targetFrame.width

        top?.constant = targetFrame.origin.y
        bottom?.constant = container.bounds.height - targetFrame.origin.y - targetFrame.height
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = true
        return self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        isPresenting = false
        return self
    }
    
    public func present() {
        params.to.transitioningDelegate = self
        params.to.modalPresentationStyle = .overCurrentContext
        params.from.present(params.to, animated: true, completion: {
            self.behaviour.setup()
        })
    }
    
    deinit {
        print("DEINIT", NSStringFromClass(Self.self))
    }
}
