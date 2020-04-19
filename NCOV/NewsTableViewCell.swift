//
//  NewsTableViewCell.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/13.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit

class NewsTableViewCell: UITableViewCell {

    @IBOutlet var backgroundContainerView: UIView! {
        didSet {
            self.backgroundContainerView.clipsToBounds = true
            self.backgroundContainerView.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet var newsImageView: UIImageView! {
        didSet {
            self.newsImageView.clipsToBounds = true
            self.newsImageView.layer.cornerRadius = 8.0
        }
    }
    @IBOutlet var newsTitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
