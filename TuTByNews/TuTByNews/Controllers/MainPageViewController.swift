//
//  MainPageViewController.swift
//  TuTByNews
//
//  Created by Neestackich on 10/29/20.
//

import UIKit
import CoreData
import UPCarouselFlowLayout

class MainPageViewController: UIViewController, NSFetchedResultsControllerDelegate, UICollectionViewDataSource, UICollectionViewDelegate, MainPageDelegate {

    
    // MARK: -Properties
    
    @IBOutlet weak var tryGetLocationButton: UIButton!
    @IBOutlet weak var noFeedLoadedWarningLabel: UILabel!
    @IBOutlet weak var warningMessageLabel: UILabel!
    @IBOutlet weak var loadingActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var updateFeed: UIButton!
    @IBOutlet weak var feedView: UIView!
    @IBOutlet weak var itemTitleText: UITextView!
    @IBOutlet weak var itemPubDateLabel: UILabel!
    @IBOutlet weak var itemDescriptionText: UITextView!
    @IBOutlet weak var tutByLogo: UIImageView!
    @IBOutlet weak var feedCollectionView: UICollectionView!
    private var rssItems: [RSSItem]?
    private let url: String = "https://news.tut.by/rss/index.rss"
    
    private var currentItem: Int = 0 {
        didSet {
            self.itemTitleText.text = DatabaseManager.shared.fetchetResultController.fetchedObjects?[currentItem].itemTitle
            self.itemDescriptionText.text = DatabaseManager.shared.fetchetResultController.fetchedObjects?[currentItem].itemDescription
            self.itemPubDateLabel.text = DatabaseManager.shared.fetchetResultController.fetchedObjects?[currentItem].itemPubDate
            
            if currentItem != 0 {
                let cell = self.feedCollectionView.cellForItem(at: IndexPath(row: currentItem, section: 0)) as! FeedItemCollectionViewCell
                if cell.imageUrl != DatabaseManager.shared.fetchetResultController.fetchedObjects?[currentItem].imageUrl {
                    cell.setup(itemNumber: currentItem)
                }
            }
        }
    }
    
    private var pageSize: CGSize {
        let layout = self.feedCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        var pageSize = layout.itemSize
        
        if layout.scrollDirection == .horizontal {
            pageSize.width += layout.minimumLineSpacing
        } else {
            pageSize.height += layout.minimumLineSpacing
        }
        
        return pageSize
    }
    
    
    // MARK: -Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
       
        setup()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func setup() {
        let flowLayout = UPCarouselFlowLayout()
        flowLayout.itemSize = CGSize(width: UIScreen.main.bounds.size.width, height: UIScreen.main.bounds.size.height)
        flowLayout.itemSize = CGSize(width: 315, height: 440)
        flowLayout.scrollDirection = .horizontal
        flowLayout.sideItemScale = 0.9
        flowLayout.sideItemAlpha = 1
        flowLayout.spacingMode = .fixed(spacing: 8)
        
        feedCollectionView.delegate = self
        feedCollectionView.dataSource = self
        feedCollectionView.collectionViewLayout = flowLayout
        
        NotificationCenter.default.addObserver(self, selector: #selector(getFeed), name: NSNotification.Name("true"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(showWarningMessage), name: NSNotification.Name("false"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateInterface), name: NSNotification.Name("dataLoaded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(getOldData), name: NSNotification.Name("impossible"), object: nil)

        hideScrollView()
        showLoadingProcess()
        hideNoFeedLoadedWarning()
        deactivateWarningMessage()
        
        LocationManager.shared.getLocation()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let layout = self.feedCollectionView.collectionViewLayout as! UPCarouselFlowLayout
        let pageSide = (layout.scrollDirection == .horizontal) ? self.pageSize.width : self.pageSize.height
        let offset = (layout.scrollDirection == .horizontal) ? scrollView.contentOffset.x : scrollView.contentOffset.y
        currentItem = Int(floor((offset - pageSide / 2) / pageSide) + 1)
    }
    
    @IBAction func updateConnectionStatusClick(_ sender: Any) {
        LocationManager.shared.getLocation()
    }
    
    @IBAction func tryGetLocationClick(_ sender: Any) {
        hideNoFeedLoadedWarning()
        showLoadingProcess()
        LocationManager.shared.getLocation()
    }
    
    func updateCollectionView() {
        feedCollectionView.reloadData()
    }
    
    func showLoadingProcess() {
        loadingActivityIndicator.startAnimating()
        loadingActivityIndicator.isHidden = false
    }
    
    func hideLoadingProcess() {
        loadingActivityIndicator.stopAnimating()
        loadingActivityIndicator.isHidden = true
    }
    
    func showScrollView() {
        scrollView.isHidden = false
    }
    
    func hideScrollView() {
        scrollView.isHidden = true
    }
    
    func activateWarningMessage() {
        warningMessageLabel.isHidden = false
    }
    
    func deactivateWarningMessage() {
        warningMessageLabel.isHidden = true
    }
    
    func hideNoFeedLoadedWarning() {
        noFeedLoadedWarningLabel.isHidden = true
        tryGetLocationButton.isHidden = true
    }
    
    func showNoFeedLoadedWarning() {
        noFeedLoadedWarningLabel.isHidden = false
        tryGetLocationButton.isHidden = false
    }
    
    
    // MARK: -CollerctionView protocols
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if DatabaseManager.shared.fetchetResultController != nil {
            return DatabaseManager.shared.fetchetResultController.fetchedObjects?.count ?? 0
        }
        
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let itemCell = feedCollectionView.dequeueReusableCell(withReuseIdentifier: "FeedItemCollectionViewCell", for: indexPath) as! FeedItemCollectionViewCell
        
        if DatabaseManager.shared.fetchetResultController != nil {
            itemCell.setup(itemNumber: indexPath.row)
            
            if currentItem == 0 {
                currentItem = 0
            }
        }
        
        return itemCell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let fullArticleVC = storyboard?.instantiateViewController(withIdentifier: "FullArticlePageViewController") as! FullArticlePageViewController
        fullArticleVC.itemNumber = indexPath.row
        fullArticleVC.modalPresentationStyle = .fullScreen
        fullArticleVC.delegate = self
        
        present(fullArticleVC, animated: true, completion: nil)
    }
    
    
    // MARK: -completion handlers
    
    @objc func getFeed() {
        print("VALID COUNTRY")
        
        NewsManager.shared.getFeed(url: url) { feedInXml in
            XMLParseManager.shared.parseXml(data: feedInXml, completion: nil)
        }
    }
    
    @objc func showWarningMessage() {
       print("INVALID COUNTRY")
        
        DispatchQueue.main.async {
            self.scrollView.isHidden = true
            self.hideLoadingProcess()
            self.activateWarningMessage()
        }
    }
    
    @objc func updateInterface() {
        DispatchQueue.main.async {
            self.hideLoadingProcess()
            self.feedCollectionView.reloadData()
            self.showScrollView()
        }
    }
    
    @objc func getOldData() {
        print("IMPOSSIBLE TO CHECKOUT LOCATION\nLOADING OLD DATA")
        
        DatabaseManager.shared.getFetchetResultController()
        
        if DatabaseManager.shared.fetchetResultController.fetchedObjects?.count == 0 {
            DispatchQueue.main.async {
                self.hideLoadingProcess()
                self.hideScrollView()
                self.showNoFeedLoadedWarning()
            }
        }
    }
}
