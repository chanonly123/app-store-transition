//
//  DetailViewController.swift
//  app-store-transition
//
//  Created by Chandan Karmakar on 20/04/21.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var ivLogoMain: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    @IBOutlet weak var ivLogoFloating: UIImageView!
    var inputImage: UIImage?
    var presenter: Presenter?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.scrollView = scrollView
        scrollView.delegate = self
        
        ivLogoFloating.contentMode = .scaleAspectFill
        ivLogoFloating.image = inputImage
        
        ivLogoMain.contentMode = .scaleAspectFill
        ivLogoMain.image = inputImage
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.contentInset.bottom = view.safeAreaInsets.bottom
    }
    
    @IBAction func actionDismiss() {
        dismiss(animated: true, completion: nil)
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
    var linkView: UIView { ivLogoFloating }
    
    func didEndTransition() {
        ivLogoFloating.isHidden = true
    }
    
    func willStartDismiss(duration: Double) {
        UIView.animate(withDuration: duration * 0.5) {
            self.scrollView.contentOffset.y = 0
        }
    }
}
