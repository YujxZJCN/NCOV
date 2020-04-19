//
//  StockCollectionViewCell.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/14.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit

class StockCollectionViewCell: UICollectionViewCell {
    @IBOutlet var itemImageView: UIImageView! {
        didSet {
            self.itemImageView.clipsToBounds = true
            self.itemImageView.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet var itemNameLabel: UILabel!
    
}
