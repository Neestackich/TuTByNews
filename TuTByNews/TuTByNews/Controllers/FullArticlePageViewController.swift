//
//  FullArticlePageViewController.swift
//  TuTByNews
//
//  Created by Neestackich on 10/30/20.
//

import UIKit

class FullArticlePageViewController: UIViewController, UIGestureRecognizerDelegate {
    
    
    // MARK: -Properties
    
    @IBOutlet weak var articleView: UIView!
    @IBOutlet weak var itemDescriptionImage: UIImageView!
    @IBOutlet weak var itemPubDateLabel: UILabel!
    @IBOutlet weak var itemTitleText: UITextView!
    @IBOutlet weak var itemDescriptionText: UITextView!
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var downloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var itemNumber: Int!
    var initialTouchPoint: CGPoint = CGPoint(x: 0, y: 0)
    var delegate: MainPageDelegate!
    
    
    // MARK: -Methods
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setup()
    }
    
    func setup() {
        showDownloadProcess()
        
        itemDescriptionImage.layer.cornerRadius = 10
        itemDescriptionImage.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        
        if let tagged = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].tagged, tagged == true {
            fillBookMark()
        } else {
            cleanBookMark()
        }
        
        if let image = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].titleImage {
            let image = UIImage(data: image)
            
            if let image = image {
                if image.size.width > image.size.height {
                    itemDescriptionImage.contentMode = .scaleAspectFill
                } else {
                    itemDescriptionImage.contentMode = .scaleAspectFill
                }
                
                itemDescriptionImage.image = image
                hideDownloadProcess()
            }
        } else {
            downloadImage()
        }
        
        itemTitleText.text = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].itemTitle
        itemDescriptionText.text = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].itemDescription
        itemPubDateLabel.text = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].itemPubDate
        
        let panGesturerecognizer = UIPanGestureRecognizer(target: self, action: #selector(swipeGestureRecognized))
        panGesturerecognizer.delegate = self
        
        scrollView.addGestureRecognizer(panGesturerecognizer)
    }
    
    func downloadImage() {
        if let imageUrl = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].imageUrl {
            guard let imageUrl = URL(string: imageUrl) else {
                return
            }
            
            let imageDownloadTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                if let data = data {
                    DispatchQueue.main.async {
                        print("Downloaded!")
                        let image = UIImage(data: data)
                        if let image = image {
                            if image.size.width > image.size.height {
                                self!.itemDescriptionImage.contentMode = .scaleAspectFill
                            } else {
                                self!.itemDescriptionImage.contentMode = .scaleAspectFill
                            }
                            
                            DatabaseManager.shared.fetchetResultController.fetchedObjects?[self!.itemNumber].titleImage = data
                            DatabaseManager.shared.saveContext()
                            
                            
                            self!.itemDescriptionImage.image = image
                            self?.hideDownloadProcess()
                        }
                    }
                }
            }
            
            imageDownloadTask.resume()
        }
    }
    
    @IBAction func saveButtonClick(_ sender: Any) {
        if let tagged = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].tagged {
            if tagged {
                DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].tagged = false
                DatabaseManager.shared.saveContext()
                cleanBookMark()
            } else {
                DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].tagged = true
                DatabaseManager.shared.saveContext()
                fillBookMark()
            }
        }
    }
    
    func showDownloadProcess() {
        downloadActivityIndicator.startAnimating()
        downloadActivityIndicator.isHidden = false
    }
    
    func hideDownloadProcess() {
        downloadActivityIndicator.stopAnimating()
        downloadActivityIndicator.isHidden = true
    }
    
    func fillBookMark() {
        saveButton.setImage(UIImage(systemName: "bookmark.fill"), for: .normal)
        saveButton.tintColor = .yellow
    }
    
    func cleanBookMark() {
        saveButton.setImage(UIImage(systemName: "bookmark"), for: .normal)
        saveButton.tintColor = .white
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @objc func swipeGestureRecognized(_ sender: UIPanGestureRecognizer) {
        let touchPoint = sender.location(in: view.window)
        
        switch sender.state {
        case .began:
            initialTouchPoint = touchPoint
        case .changed:
            if touchPoint.x - initialTouchPoint.x > 0 {
                view.frame = CGRect(x: touchPoint.x - initialTouchPoint.x, y: 0, width: view.frame.size.width, height: view.frame.size.height)
            }
        case .ended, .cancelled:
            if touchPoint.x - initialTouchPoint.x > 50 {
                dismiss(animated: true, completion: nil)
            } else {
                UIView.animate(withDuration: 0.3) {
                    self.view.frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
                }
            }
        default:
            break
        }
    }
}
