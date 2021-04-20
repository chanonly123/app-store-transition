//
//  DismissBehaviour.swift
//  AppStoreInteractiveTransition
//
//  Created by Chandan Karmakar on 20/04/21.
//  Copyright © 2021 Wirawit Rueopas. All rights reserved.
//

import Foundation
import UIKit

public class DismissBehaviour: NSObject, UIGestureRecognizerDelegate {
    var draggingDownToDismiss = false

    final class DismissalPanGesture: UIPanGestureRecognizer {}
    final class DismissalScreenEdgePanGesture: UIScreenEdgePanGestureRecognizer {}

    lazy var dismissalPanGesture: DismissalPanGesture = {
        let pan = DismissalPanGesture()
        pan.maximumNumberOfTouches = 1
        return pan
    }()

    lazy var dismissalScreenEdgePanGesture: DismissalScreenEdgePanGesture = {
        let pan = DismissalScreenEdgePanGesture()
        pan.edges = .left
        return pan
    }()

    weak var presenter: Presenter?
    
    init(presenter: Presenter) {
        self.presenter = presenter
    }

    public func setup() {
        dismissalPanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalPanGesture.delegate = self

        dismissalScreenEdgePanGesture.addTarget(self, action: #selector(handleDismissalPan(gesture:)))
        dismissalScreenEdgePanGesture.delegate = self

        // Make drag down/scroll pan gesture waits til screen edge pan to fail first to begin
        dismissalPanGesture.require(toFail: dismissalScreenEdgePanGesture)

        presenter?.params.to?.view.addGestureRecognizer(dismissalPanGesture)
        presenter?.params.to?.view.addGestureRecognizer(dismissalScreenEdgePanGesture)
    }

    var interactiveStartingPoint: CGPoint?

    @objc func handleDismissalPan(gesture: UIPanGestureRecognizer) {
        let isScreenEdgePan = gesture.isKind(of: DismissalScreenEdgePanGesture.self)
        let canStartDragDownToDismissPan = !isScreenEdgePan && !draggingDownToDismiss

        // Don't do anything when it's not in the drag down mode
        if canStartDragDownToDismissPan { return }

        let targetAnimatedView = gesture.view!
        let startingPoint: CGPoint

        if let p = interactiveStartingPoint {
            startingPoint = p
        } else {
            // Initial location
            startingPoint = gesture.location(in: nil)
            interactiveStartingPoint = startingPoint
        }

        let currentLocation = gesture.location(in: nil)
        let progress = isScreenEdgePan ? (gesture.translation(in: targetAnimatedView).x / 100) : (currentLocation.y - startingPoint.y) / 100
//        print("\(gesture.state.name)", currentLocation, progress)

        switch gesture.state {
        case .began:
            presenter?.createDismissAnimator()
            presenter?.dismissAnimator.fractionComplete = 0
        case .changed:
            let actualProgress = progress
            let isDismissalSuccess = actualProgress >= 1.0
            
            presenter?.createDismissAnimator()
            presenter?.dismissAnimator.fractionComplete = actualProgress

            if isDismissalSuccess {
                presenter?.dismissAnimator.stopAnimation(false)
                presenter?.dismissAnimator.addCompletion { [unowned self] pos in
                    switch pos {
                    case .end:
                        self.didSuccessfullyDragDownToDismiss()
                    default:
                        fatalError("Must finish dismissal at end!")
                    }
                }
                presenter?.dismissAnimator.finishAnimation(at: .end)
                gesture.isEnabled = false
            }
        case .ended, .cancelled:
            // Ended, Animate back to start
            presenter?.dismissAnimator.pauseAnimation()
            presenter?.dismissAnimator.isReversed = true

            // Disable gesture until reverse closing animation finishes.
            gesture.isEnabled = false
            presenter?.dismissAnimator.addCompletion { [unowned self] pos in
                self.didCancelDismissalTransition()
                gesture.isEnabled = true
            }
            presenter?.dismissAnimator.startAnimation()
        default:
            fatalError("Impossible gesture state? \(gesture.state.rawValue)")
        }
    }

    func didSuccessfullyDragDownToDismiss() {
        presenter?.params.to.dismiss(animated: true, completion: nil)
    }

    func didCancelDismissalTransition() {
        presenter?.setBigVersion()
        presenter?.dismissAnimator = nil
        interactiveStartingPoint = nil
        draggingDownToDismiss = false
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if draggingDownToDismiss || (scrollView.isTracking && scrollView.contentOffset.y < 0) {
            draggingDownToDismiss = true
            scrollView.contentOffset = .zero
        }
        scrollView.showsVerticalScrollIndicator = !draggingDownToDismiss
    }

    public func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        if velocity.y > 0, scrollView.contentOffset.y <= 0 {
            scrollView.contentOffset = .zero
        }
    }

    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension UIGestureRecognizer.State {
    var name: String {
        switch self {
        case .began: return "began"
        case .possible: return "possible"
        case .changed: return "changed"
        case .ended: return "ended"
        case .cancelled: return "cancelled"
        case .failed: return "failed"
        @unknown default: return "unknown"
        }
    }
}
