//
//  CollectionViewCell.swift
//  Heart Rate Monitor
//
//  Created by Catalina on 30/05/20.
//  Copyright © 2020 LanetTeam. All rights reserved.
//

import UIKit

class CollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var bmpLabel: UILabel!
    @IBOutlet weak var viewHieght: NSLayoutConstraint!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var view: UIView!
    override func awakeFromNib() {
        super.awakeFromNib()
        view.layer.cornerRadius = 4
        // Initialization code
    }

}
