//
//  StockDetailViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/19.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit

class StockDetailViewController: UIViewController {
    
    @IBOutlet var topView: UIView! {
        didSet {
            self.topView.clipsToBounds = true
            self.topView.layer.cornerRadius = 28.0
        }
    }
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var stockImageView: UIImageView! {
        didSet {
            self.stockImageView.clipsToBounds = true
            self.stockImageView.layer.cornerRadius = 18.0
        }
    }
    @IBOutlet var messageLabel: UILabel!
    
    var stock: Stock!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        nameLabel.text = stock.name
        timeLabel.text = stock.time
        stockImageView.image = stock.image
        messageLabel.text = stock.message
        self.navigationController?.navigationBar.tintColor = UIColor.white
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
