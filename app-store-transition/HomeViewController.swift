//
//  ViewController.swift
//  app-store-transition
//
//  Created by Chandan Karmakar on 20/04/21.
//

import UIKit

class HomeViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    
    var items = ["ic_image1.jpg", "ic_image2.jpg", "ic_image3.jpg", "ic_image4.jpg", "ic_image5.jpg", "ic_image6.jpg", "ic_image7.jpg"]
    
    var presenter: Presenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        items.shuffle()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        CardView.applyShadow(view: tableView)
    }
    
    override var prefersStatusBarHidden: Bool { false }
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation { .slide }
    
    var sharedView: UIView!
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        cell.cardView.ivLogo.image = UIImage(named: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableCell
        sharedView = cell.cardView
        let viewc = storyboard?.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
        viewc.inputImage = cell.cardView.ivLogo.image
        presenter = Presenter(params: .init(from: self, to: viewc))
        presenter.configTransitionContext = {
            CardView.applyShadow(view: $0)
        }
        viewc.presenter = presenter
        presenter.present()
    }
}

class TableCell: UITableViewCell {
    let cardView = CardView.loadXib()
    let gap: CGFloat = 25
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        backgroundColor = .clear
        contentView.backgroundColor = .clear
        
        contentView.addSubview(cardView)
        cardView.addPinConstraints(top: gap / 2, left: gap, bottom: gap / 2, right: gap)
        cardView.layer.cornerRadius = gap
        
        cardView.enableTouchFeedback(enable: true) { down, view in
            UIView.animate(withDuration: 0.7, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [.allowUserInteraction], animations: {
                view.transform = down ? CGAffineTransform(scaleX: 0.96, y: 0.96) : CGAffineTransform.identity
            }, completion: nil)
        }
    }
}

extension HomeViewController: HomeController {
    var linkView: UIView { sharedView }
    
    func willStartTransition() {}
    
    func willEndTransition() {}
    
    func didEndTransition() {}
}

public extension UIView {
    func addPinConstraints(top: CGFloat? = nil, left: CGFloat? = nil, bottom: CGFloat? = nil, right: CGFloat? = nil) {
        guard let parent = superview else { return }
        translatesAutoresizingMaskIntoConstraints = false
        if let left = left {
            leadingAnchor.constraint(equalTo: parent.leadingAnchor, constant: left).isActive = true
        }
        if let right = right {
            trailingAnchor.constraint(equalTo: parent.trailingAnchor, constant: -right).isActive = true
        }
        if let top = top {
            topAnchor.constraint(equalTo: parent.topAnchor, constant: top).isActive = true
        }
        if let bottom = bottom {
            bottomAnchor.constraint(equalTo: parent.bottomAnchor, constant: -bottom).isActive = true
        }
    }
    
    func addRatioConstraints(ratio: CGFloat) {
        widthAnchor.constraint(equalTo: heightAnchor, multiplier: ratio, constant: 0).isActive = true
    }
}
