//
//  DetailViewController.swift
//  app-store-transition
//
//  Created by Chandan Karmakar on 20/04/21.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var cardContainerView: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    let cardView = CardView.loadXib()
    
    var inputImage: UIImage?
    var presenter: Presenter?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.scrollView = scrollView
        scrollView.delegate = self
        cardContainerView.addSubview(cardView)
        cardView.addPinConstraints(top: 0, left: 0, bottom: 0, right: 0)
        
        cardView.ivLogo.image = inputImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
    }
    
    @IBAction func actionDismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool { true }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }

    deinit {
        print("DEINIT", NSStringFromClass(Self.self))
    }
}

extension DetailViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        presenter?.behaviour.scrollViewDidScroll(scrollView)
    }

    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        presenter?.behaviour.scrollViewWillEndDragging(scrollView, withVelocity: velocity, targetContentOffset: targetContentOffset)
    }
}

extension DetailViewController: DetailController {
    
    func didEndTransition() {}
    
    func willStartDismiss(duration: Double) {
        UIView.animate(withDuration: duration * 0.5) {
            self.btnDismiss.alpha = 0
            self.scrollView.contentOffset.y = 0
            self.cardView.labelContainerTopSafeArea.isActive = false
        }
    }
}
