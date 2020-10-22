//
//  DetailInfoTableViewCell.swift
//  AppStoreSearchAppMVVM
//
//  Created by isens on 22/10/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit

enum EnumDetailInfoTableViewCellType {
    case str
    case image
    case arrow
}

class DetailInfoTableViewCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subTitleLabel: UILabel!
    @IBOutlet weak var subImageView: UIImageView!
    @IBOutlet weak var subTitleLabelTrailingConstraint: NSLayoutConstraint!
    
    var index: Int = 0 // cell index
    
    static var Identifier = "DetailInfoTableViewCell"
    
    override func awakeFromNib() {
        self.subImageView.isHidden = true
        self.subTitleLabel.isHidden = true
    }
    
    func setType(_ type: EnumDetailInfoTableViewCellType, index: Int, isExpanded: Bool = false) {
        self.index = index
        if type == .str {
            self.subTitleLabel.isHidden = false
            self.subImageView.isHidden = true
            self.subTitleLabelTrailingConstraint.constant = 0
        } else if type == .image {
            self.subTitleLabel.isHidden = true
            self.subImageView.isHidden = false
            self.subTitleLabelTrailingConstraint.constant = 0
        } else {
            self.subImageView.isHidden = true
            self.subTitleLabelTrailingConstraint.constant = 28
        }
    }
}

