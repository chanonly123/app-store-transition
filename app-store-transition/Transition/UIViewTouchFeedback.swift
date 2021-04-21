//
//  UIView.swift
//  eezylife-sample
//
//  Created by Chandan Karmakar on 14/03/20.
//  Copyright © 2020 chanonly123. All rights reserved.
//

import UIKit

extension UIView {
    // MARK: touch feedback

    func enableTouchFeedback(enable: Bool, touchHandler: ((Bool, UIView) -> Void)?) {
        if !enable {
            savedTouchHandlers.removeObject(forKey: self)
            gestureRecognizers?.removeAll(where: { $0 is TouchGestureRecognizer })
            return
        }
        savedTouchHandlers.setObject(touchHandler as AnyObject, forKey: self)
        if gestureRecognizers?.first(where: { $0 is TouchGestureRecognizer }) == nil {
            let touch = TouchGestureRecognizer(target: self, action: #selector(onTouch(gesture:)))
            touch.cancelsTouchesInView = false
            addGestureRecognizer(touch)
        }
    }

    @objc func onTouch(gesture: UIGestureRecognizer) {
        let down = gesture.state == .began || gesture.state == .changed
        if let handler = savedTouchHandlers.object(forKey: self) as? ((Bool, UIView) -> Void) {
            handler(down, self)
        } else {
            let transform = down ? CGAffineTransform(scaleX: 0.97, y: 0.97) : .identity
            if down {
                UIView.animate(withDuration: 0.8, delay: 0.0, usingSpringWithDamping: 0.4, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
                    self.transform = transform
                }, completion: nil)
            } else {
                UIView.animate(withDuration: 0.25, delay: 0.0, options: [.allowUserInteraction, .curveEaseOut], animations: {
                    self.transform = transform
                })
            }
        }
    }

    func setAlpha(_ alpha: CGFloat, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) {
                self.alpha = alpha
            } completion: { _ in
                self.isUserInteractionEnabled = alpha == 1
            }
        } else {
            self.alpha = alpha
            isUserInteractionEnabled = alpha == 1
        }
    }

    func setHidden(_ hidden: Bool, animated: Bool = true, duration: Double = 0.3, layout: UIView? = nil, comp: (() -> Void)? = nil) {
        if !animated {
            isHidden = hidden
            alpha = 1
            comp?()
            return
        }
        if self.isHidden == hidden {
            comp?()
            return
        }
        if UIApplication.shared.applicationState == .background {
            self.isHidden = hidden
            self.alpha = hidden ? 0 : 1
            comp?()
            return
        }
        let parent = layout ?? superview
        if hidden {
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
                self.alpha = 0
            }, completion: { _ in
                self.isHidden = true
                self.alpha = 1
                UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
                    parent?.layoutIfNeeded()
                }, completion: { _ in
                    comp?()
                })
            })
        } else {
            isHidden = false
            self.alpha = 0
            UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
                parent?.layoutIfNeeded()
            }, completion: { _ in
                UIView.animate(withDuration: duration, delay: 0.0, options: [.curveEaseInOut], animations: {
                    self.alpha = 1
                }, completion: { _ in
                    self.alpha = 1
                    comp?()
                })
            })
        }
    }
}

private var savedTouchHandlers = NSMapTable<UIView, AnyObject>(keyOptions: .weakMemory, valueOptions: .strongMemory)

private class TouchGestureRecognizer: UIGestureRecognizer, UIGestureRecognizerDelegate {
    override init(target: Any?, action: Selector?) {
        super.init(target: target, action: action)
        delegate = self
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .began
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .changed
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .ended
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }

    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return !(otherGestureRecognizer is TouchGestureRecognizer)
    }
}
