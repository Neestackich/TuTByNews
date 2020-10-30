//
//  MainPageViewController.swift
//  TuTByNews
//
//  Created by Neestackich on 10/29/20.
//

import UIKit

class MainPageViewController: UIViewController {

    
    // MARK: -Properties
    
    private var rssItems: [RSSItem]?
    private let url: String = "https://news.tut.by/rss/index.rss"
    
    
    // MARK: -Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
    }
    
    func reloadData() {
        for item in rssItems! {
//            print(item.title)
//            print(item.description)
//            print(item.descriptionImages)
//            print(item.mediaImages)

        }
    }
    
    private func setup() {
        NewsManager.shared.getFeed(url: url) { feedInXml in
            XMLParseManager.shared.parseXml(data: feedInXml) { rssItems in
                self.rssItems = rssItems
                
                // что-то обновляем
                for item in (self.rssItems)! {
//                    print(item.title)
//                    print(item.description)
//                    print(item.descriptionImages)
//                    print(item.mediaImages)
                    
                    
                    // pltcь добавление в кордату
                    
                    self.reloadData()
                }
            }
        }
    }
}
