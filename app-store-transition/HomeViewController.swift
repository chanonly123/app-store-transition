//
//  ViewController.swift
//  app-store-transition
//
//  Created by Chandan Karmakar on 20/04/21.
//

import UIKit

class HomeViewController: UIViewController, HomeController {
    @IBOutlet weak var tableView: UITableView!
    
    var items = ["ic_image1.jpg", "ic_image2.jpg", "ic_image3.jpg", "ic_image4.jpg", "ic_image5.jpg", "ic_image6.jpg"]
    
    var presenter: Presenter!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = UITableView.automaticDimension
        tableView.separatorStyle = .none
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    var sharedView: UIView!
    var linkView: UIView { sharedView }
}

extension HomeViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TableCell") as! TableCell
        cell.ivLogo.image = UIImage(named: items[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TableCell
        sharedView = cell.cardView
        let viewc = storyboard?.instantiateViewController(identifier: "DetailViewController") as! DetailViewController
        viewc.inputImage = cell.ivLogo.image
        presenter = Presenter(params: .init(from: self, to: viewc))
        viewc.presenter = presenter
        presenter.present()
    }
}

class TableCell: UITableViewCell {
    @IBOutlet weak var cardView: UIView!
    @IBOutlet weak var ivLogo: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        selectionStyle = .none
        contentView.backgroundColor = .clear
        contentView.layer.shadowColor = UIColor.darkGray.cgColor
        contentView.layer.shadowRadius = 5
        contentView.layer.shadowOpacity = 0.4
        
        cardView.clipsToBounds = true
        cardView.layer.cornerRadius = 16
        cardView.enableTouchFeedback(enable: true) { (down, view) in
            UIView.animate(withDuration: 0.6, delay: 0.0, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.0, options: [], animations: {
                view.transform = down ? CGAffineTransform.init(scaleX: 0.95, y: 0.95) : CGAffineTransform.identity
            }, completion: nil)
        }
        
        ivLogo.contentMode = .scaleAspectFill
    }
}
