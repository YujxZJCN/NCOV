//
//  MainPageViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/13.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import Kanna
import AlamofireImage

var TABBARHIDDEN = false
var newsImageDic = [Int : UIImage]() {
    didSet {
        let queue = DispatchQueue(label: "com.YJX.fetchNewsImageLocal", qos: .userInteractive, attributes: .concurrent)
        queue.async {
            newsImageDic.forEach { (arg0) in
                let (key, value) = arg0
                if let data = value.pngData(), UserDefaults.standard.data(forKey: String(key)) == nil {
                    UserDefaults.standard.set(data, forKey: String(key))
                }
            }
        }
    }
}

class MainPageViewController: UIViewController {
    @IBOutlet var tagTableView: UITableView!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var menuButton: UIButton!
    @IBOutlet var menuView: UIView!
    @IBOutlet var tagView: UIView! {
        didSet {
            self.tagView.clipsToBounds = true
            self.tagView.layer.cornerRadius = 23.0
        }
    }
    
    var blurView: UIView!
    let transformLeft = CGAffineTransform(translationX: -200, y: 0)
    var fetchNewsURL = "http://www.newnan.city:2020/api/news/pull"
    var news = [News]() {
        didSet {
            if showingTag == "All" {
                showingNews = news
            } else {
                showingNews.removeAll()
                news.forEach { (news) in
                    if let tags = news.tags {
                        if tags.contains(showingTag) {
                            showingNews.append(news)
                        }
                    }
                }
            }
            
//            let queue = DispatchQueue(label: "com.YJX.fetchNewsImageLocally", qos: .userInteractive, attributes: .concurrent)
//            queue.async {
//                self.news.forEach { (news) in
//                    if let data = UserDefaults.standard.data(forKey: String(news.newsID)) {
//                        newsImageDic[news.newsID] = UIImage(data: data)
//                    }
//                }
//            }
            
        }
    }
    
    var showingNews = [News]() {
        didSet {
            self.tableView.reloadData()
        }
    }
    
    var showingTag = "All" {
        didSet {
            if showingTag == "All" {
                showingNews = news
            } else {
                showingNews.removeAll()
                news.forEach { (news) in
                    if let tags = news.tags {
                        if tags.contains(showingTag) {
                            showingNews.append(news)
                        }
                    }
                }
            }
        }
    }
    
    var count = 20
    
    var newsTags = [String]() {
        didSet {
            self.tagTableView.reloadData()
        }
    }
    
    @IBAction func showTagButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.view.addSubview(self.blurView)
            self.view.bringSubviewToFront(self.tagView)
            self.tagView.alpha = 1.0
            self.blurView.alpha = 1.0
            self.setTabBarHidden(true)
            TABBARHIDDEN = true
        }) { (completed) in
        }
    }
    
    @IBAction func menuButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.menuView.transform = .identity
            self.setTabBarHidden(true)
            TABBARHIDDEN = true
            self.view.addSubview(self.blurView)
            self.view.bringSubviewToFront(self.menuView)
            self.blurView.alpha = 1.0
        }) { (completed) in
        }
        
    }
    
    @IBAction func logoutButtonTapped(_ sender: UIButton) {
        UserDefaults.standard.set(0, forKey: "LOGIN")
        LOGIN = false
        UIView.animate(withDuration: 0.4, animations: {
            self.setTabBarHidden(false)
            TABBARHIDDEN = false
            self.blurView.alpha = 0.0
            self.menuView.transform = self.transformLeft
        }) { (completed) in
            self.blurView.removeFromSuperview()
        }
        let sectionController = self.storyboard?.instantiateViewController(withIdentifier: "loginPageVC") as! LoginViewController
        sectionController.modalPresentationStyle = .fullScreen
        self.present(sectionController, animated: true)
    }
    
    @IBAction func detailInfoButtonTapped(_ sender: UIButton) {
        UIView.animate(withDuration: 0.4, animations: {
            self.setTabBarHidden(false)
            TABBARHIDDEN = false
            self.blurView.alpha = 0.0
            self.menuView.transform = self.transformLeft
        }) { (completed) in
            self.blurView.removeFromSuperview()
        }
        let sectionController = self.storyboard?.instantiateViewController(withIdentifier: "DetailVC") as! DetailViewController
        sectionController.modalPresentationStyle = .fullScreen
        self.present(sectionController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        self.tagTableView.delegate = self
        self.tagTableView.dataSource = self
        self.tagTableView.separatorStyle = .none
        
        self.view.bringSubviewToFront(menuButton)
        
        if UserDefaults.standard.integer(forKey: "LOGIN") == 0 {
            LOGIN = false
        } else {
            LOGIN = true
        }
        
        blurView = UIView(frame: self.view.frame)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = blurView.bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        blurView.addSubview(blurEffectView)
        
        self.blurView.alpha = 0.0
        
        newsTags.append("All")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        
        menuView.transform = transformLeft
        
        fetchNews(count: count)
        
        if TABBARHIDDEN {
            self.setTabBarHidden(false)
            TABBARHIDDEN = false
        }
        
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.hidesBarsOnSwipe = false
        
        self.tagView.alpha = 0.0
        self.view.bringSubviewToFront(tableView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        if !LOGIN {
            let sectionController = self.storyboard?.instantiateViewController(withIdentifier: "loginPageVC") as! LoginViewController
            sectionController.modalPresentationStyle = .fullScreen
            self.present(sectionController, animated: true)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if TABBARHIDDEN {
            UIView.animate(withDuration: 0.4, animations: {
                self.setTabBarHidden(false)
                TABBARHIDDEN = false
                self.blurView.alpha = 0.0
                self.menuView.transform = self.transformLeft
                self.tagView.alpha = 0.0
            }) { (completed) in
                self.blurView.removeFromSuperview()
                self.view.bringSubviewToFront(self.tableView)
            }
        }
    }
    
    func fetchImage(with url: String, for newsID: Int) {
        if newsImageDic.keys.contains(newsID) { return }
        Alamofire.request(url).responseImage { response in
            if let image = response.result.value {
                // Handle error
                DispatchQueue.main.async {
                    print("Fetch: \(newsID)")
                    newsImageDic[newsID] = image
                    self.tableView.reloadData()
                }
            }
        }
//        let queue = DispatchQueue(label: "com.YJX.fetchNewsImage", qos: .userInteractive, attributes: .concurrent)
//        queue.async {
//
//        }
    }
    
    func fetchNews(count: Int) {
        let parameters: Parameters = ["from_time" : "",
                                      "to_time" : "",
                                      "count" : count,
                                      "tags" : ""
        ]
        Alamofire.request(self.fetchNewsURL, method: .get, parameters: parameters).responseData { (response) in
            if let data = response.data {
                let newsJSON = JSON(data)
                let newsList = newsJSON["news_list"]
                print(newsList.count)
                for i in 0..<newsList.count {
                    let news = newsList[i]
                    let previewImage = news["preview_image"].stringValue
                    let title = news["title"].stringValue
                    let newsID = news["news_id"].intValue
                    let publishedTime = news["published_time"].stringValue
                    let tags = news["tags"].array
                    var stringTags = [String]()
                    tags?.forEach({ (tag) in
                        stringTags.append(tag.stringValue)
                        if !self.newsTags.contains(tag.stringValue) {
                            self.newsTags.append(tag.stringValue)
                        }
                    })
                    let newNews = News(newsID: newsID, title: title, tags: stringTags, publishedTime: publishedTime, previewImageURL: previewImage)
                    DispatchQueue.main.async {
                        if !self.news.contains(newNews) {
                            self.news.append(newNews)
                            self.tableView.reloadData()
                        }
                    }
                    self.fetchImage(with: previewImage, for: newsID)
                }
            }
        }
//        let queue = DispatchQueue(label: "com.YJX.fetchNews", qos: .userInteractive, attributes: .concurrent)
//        queue.async {
//
//        }
    }
    
}

extension MainPageViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if tableView === self.tableView {
            let sectionController = self.storyboard?.instantiateViewController(withIdentifier: "NewsDetailVC") as! NewsDetailViewController
                    sectionController.modalPresentationStyle = .fullScreen
                    sectionController.news = showingNews[indexPath.row]
                    sectionController.newsImage = newsImageDic[showingNews[indexPath.row].newsID]
                    self.setTabBarHidden(true)
                    TABBARHIDDEN = true
                    self.navigationController?.pushViewController(sectionController, animated: true)
            //        self.present(sectionController, animated: true)
        } else {
            if let cell = tagTableView.cellForRow(at: indexPath), let text = cell.textLabel?.text {
                print("Selected")
                showingTag = text
                if TABBARHIDDEN {
                    UIView.animate(withDuration: 0.4, animations: {
                        self.setTabBarHidden(false)
                        TABBARHIDDEN = false
                        self.blurView.alpha = 0.0
                        self.menuView.transform = self.transformLeft
                        self.tagView.alpha = 0.0
                    }) { (completed) in
                        self.blurView.removeFromSuperview()
                        self.view.bringSubviewToFront(self.tableView)
                    }
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if tableView === self.tableView {
            return 120.0
        } else {
            return 43.5
        }
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if tableView === self.tableView {
            return showingNews.count
        } else {
            return newsTags.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if tableView === self.tableView {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "NewsTableViewCell", for: indexPath) as? NewsTableViewCell else {
                fatalError()
            }
            cell.newsTitleLabel.text = showingNews[indexPath.row].title
            if let image = newsImageDic[showingNews[indexPath.row].newsID] {
                cell.newsImageView.image = image
            } else {
                cell.newsImageView.image = UIImage(named: "image-slash")
            }
            cell.selectionStyle = .none
            return cell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "tagTableViewCell", for: indexPath) as? UITableViewCell else {
                fatalError()
            }
            cell.textLabel?.text = newsTags[indexPath.row]
            cell.textLabel?.font = UIFont(name: "Avenir", size: 18)
            cell.selectionStyle = .none
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if tableView === self.tableView {
            let lastElement = news.count - 1
            if indexPath.row == lastElement {
                count += 20
                fetchNews(count: count)
            }
        }
    }
    
}

extension UIViewController {
    
    func setTabBarHidden(_ hidden: Bool, animated: Bool = true, duration: TimeInterval = 0.3) {
        if animated {
            if let frame = self.tabBarController?.tabBar.frame {
                let factor: CGFloat = hidden ? 1 : -1
                let y = frame.origin.y + (frame.size.height * factor)
                UIView.animate(withDuration: duration, animations: {
                    self.tabBarController?.tabBar.frame = CGRect(x: frame.origin.x, y: y, width: frame.width, height: frame.height)
                })
                return
            }
        }
        self.tabBarController?.tabBar.isHidden = hidden
    }
    
}
