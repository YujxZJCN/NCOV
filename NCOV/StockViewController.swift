//
//  StockViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/13.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit

class StockViewController: UIViewController {

    @IBOutlet var topView: UIView! {
        didSet {
            self.topView.clipsToBounds = true
            self.topView.layer.cornerRadius = 28.0
        }
    }
    @IBOutlet var collectionView: UICollectionView!
    private var collectionViewLayout = UICollectionViewFlowLayout()
    
    var stocks = [Stock]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.collectionViewLayout = collectionViewLayout
        collectionViewLayout.minimumLineSpacing = 0
        collectionViewLayout.scrollDirection = .vertical
        configureCollectionViewLayout()
        
        stocks = [Stock(name: "Mask1", time: "3 hours ago", image: UIImage(named: "Mask1"), message: "I have 2 new KF94 masks!\nContact me if you need."),
                  Stock(name: "Mask2", time: "5 hours ago", image: UIImage(named: "Mask2"), message: "I have 10 new N95 masks!\nContact me if you need."),
                  Stock(name: "Medical gloves", time: "7 hours ago", image: UIImage(named: "Medical gloves"), message: "I have 100 new Medical gloves!\nContact me if you need."),
                  Stock(name: "Hand soap", time: "2020-04-01", image: UIImage(named: "Hand soap"), message: "I have 45 new Hand soaps!\nContact me if you need."),
                  Stock(name: "Hand soap2", time: "2020-03-30", image: UIImage(named: "Hand soap2"), message: "I have 25 new Hand soaps!\nContact me if you need."),
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.hidesBarsOnSwipe = false
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

extension StockViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let sectionController = self.storyboard?.instantiateViewController(withIdentifier: "StockDetailVC") as! StockDetailViewController
        sectionController.modalPresentationStyle = .fullScreen
        sectionController.stock = stocks[indexPath.row]
        self.navigationController?.pushViewController(sectionController, animated: true)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return stocks.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "collectionViewCell", for: indexPath) as? StockCollectionViewCell else {
            fatalError()
        }
        cell.itemImageView.image = stocks[indexPath.row].image
        cell.itemNameLabel.text = stocks[indexPath.row].name
        return cell
    }
    
    private func configureCollectionViewLayout() {
        collectionViewLayout.itemSize = CGSize(width: (self.view.frame.width - 50) / 2, height: self.view.frame.width / 2 + 25)
        
        collectionViewLayout.sectionInset = UIEdgeInsets(top: 32, left: 16, bottom: 16, right: 16)
        collectionViewLayout.collectionView?.reloadData()
    }
}
