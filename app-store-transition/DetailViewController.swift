//
//  DetailViewController.swift
//  app-store-transition
//
//  Created by Chandan Karmakar on 20/04/21.
//

import UIKit

class DetailViewController: UIViewController {
    
    @IBOutlet weak var btnDismiss: UIButton!
    @IBOutlet weak var ivLogoMain: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var inputImage: UIImage?
    var presenter: Presenter?
            
    override func viewDidLoad() {
        super.viewDidLoad()
        
        presenter?.scrollView = scrollView
        scrollView.delegate = self
        
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
    var linkView: UIView { ivLogoMain }
    
    func didEndTransition() {}
    
    func willStartDismiss(duration: Double) {
        UIView.animate(withDuration: duration * 0.5) {
            self.btnDismiss.alpha = 0
            self.scrollView.contentOffset.y = 0
        }
    }
}
