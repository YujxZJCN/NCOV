//
//  News.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/17.
//  Copyright © 2020 yjx. All rights reserved.
//

import Foundation

struct News: Equatable, Comparable {
    static func < (lhs: News, rhs: News) -> Bool {
        return lhs.newsID < rhs.newsID
    }

    var newsID: Int
    var title: String
    var tags: [String]?
    var publishedTime: String
    var previewImageURL: String?
}
