//
//  NewsDetailViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/16.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import Alamofire
import Kanna

class NewsDetailViewController: UIViewController {
    
    @IBOutlet var headerView: UIView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var timeAndAuthorLabel: UILabel!
    @IBOutlet var newsImageView: UIImageView! {
        didSet {
            self.newsImageView.clipsToBounds = true
            self.newsImageView.layer.cornerRadius = 18.0
        }
    }
    
    var news: News?
    var newsImage: UIImage?
    var fetchNewsDetailURL = "http://www.newnan.city:2020/api/news/"
    var newsDetails = [String]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    @IBAction func dismissButtonTapped(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        tableView.delegate = self
        tableView.dataSource = self
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        if let news = news {
            self.titleLabel.text = news.title
            self.timeAndAuthorLabel.text = news.publishedTime
            if let newsImage = newsImage {
                self.newsImageView.image = newsImage
            } else {
                if let url = news.previewImageURL {
                    fetchImage(with: url)
                }
            }
            fetchNewsDetails(with: news.newsID)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        self.navigationController?.hidesBarsOnSwipe = true
    }
    
    func fetchImage(with url: String) {
        let queue = DispatchQueue(label: "com.YJX.fetchNewsImage\(url)", qos: .userInteractive, attributes: .concurrent)
        queue.async {
            Alamofire.request(url, method: .get).responseData { (response) in
                if let data = response.data {
                    DispatchQueue.main.async {
                        self.newsImageView.image = UIImage(data: data)
                        if let news = self.news {
                            newsImageDic[news.newsID] = UIImage(data: data)
                        }
                    }
                }
            }
        }
    }
    
    func fetchNewsDetails(with newsID: Int) {
        let queue = DispatchQueue(label: "com.YJX.fetchNewsDetail", qos: .userInteractive, attributes: .concurrent)
        queue.async {
            Alamofire.request(self.fetchNewsDetailURL + String(newsID), method: .get).responseData { (response) in
                if let html = response.result.value, let doc = try? HTML(html: html, encoding: .utf8) {
                    if let content = doc.content {
                        DispatchQueue.main.async {
                            self.newsDetails = content.components(separatedBy: "\n")
                        }
                    }
                }
            }
        }
    }
    
    func imageWithColor(_ color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width: 5.0, height: 5.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return image!
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

extension NewsDetailViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return newsDetails.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsDetailTableViewCell", for: indexPath) as? NewsDetailTableViewCell else {
            fatalError()
        }
        cell.detailLabel.text = newsDetails[indexPath.row]
        cell.selectionStyle = .none
        return cell
    }
    
    private func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let identifier = "NewsDetailTableViewCell"
        let hsCell = tableView.dequeueReusableCell(withIdentifier: identifier) as? NewsDetailTableViewCell
        var tempCell: NewsDetailTableViewCell
        hsCell != nil ? (tempCell = hsCell!) : (tempCell = NewsDetailTableViewCell())
        tempCell.detailLabel.text = newsDetails[indexPath.row]
        tempCell.frame = CGRect(x: 0, y: 0, width: tableView.bounds.width, height: tableView.bounds.height)
        tempCell.layoutIfNeeded()
        tempCell.selectionStyle = .none
        return tempCell.contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height + 1
    }
    
}


