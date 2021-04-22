//
//  SharedView.swift
//  app-store-transition
//
//  Created by Chandan Karmakar on 22/04/21.
//

import UIKit

class CardView: UIView {
    @IBOutlet weak var ivLogo: UIImageView!
    @IBOutlet weak var lblText1: UILabel!
    @IBOutlet weak var lblText2: UILabel!
    @IBOutlet weak var lblText3: UILabel!
    
    @IBOutlet var labelContainerTopSafeArea: NSLayoutConstraint!
    @IBOutlet weak var ivLogoWidth: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        clipsToBounds = true
        ivLogoWidth.constant = UIScreen.main.bounds.width
        ivLogo.contentMode = .scaleAspectFill
        
        addRatioConstraints(ratio: 3/4)
    }
    
    static func loadXib() -> CardView {
        return Bundle.main.loadNibNamed(String(describing: self), owner: nil, options: nil)![0] as! Self
    }
    
    static func applyShadow(view: UIView) {
        view.layer.shadowColor = UIColor.darkGray.cgColor
        view.layer.shadowRadius = 15
        view.layer.shadowOpacity = 0.3
    }
}
