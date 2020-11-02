//
//  FeedItemCollectionViewCell.swift
//  TuTByNews
//
//  Created by Neestackich on 10/31/20.
//

import UIKit

class FeedItemCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var downloadActivityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var itemDescriptionImage: UIImageView!
    var imageUrl: String?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        itemDescriptionImage.layer.cornerRadius = 10
    }
    
    func setup(itemNumber: Int) {
        itemDescriptionImage.image = nil
        self.imageUrl = DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].imageUrl
        
        showDownloadProcess()
        
        if DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].titleImage == nil {
            downloadImage(itemNumber: itemNumber)
        } else {
            let image = UIImage(data: (DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].titleImage)!)
            
            if let image = image { 
                if image.size.width > image.size.height {
                    itemDescriptionImage.contentMode = .scaleAspectFill
                } else {
                    itemDescriptionImage.contentMode = .scaleAspectFill
                }
                
                itemDescriptionImage.image = image
                hideDownloadProcess()
                
                print("fetched from database")
            }
        }
    }
    
    func downloadImage(itemNumber: Int) {
        if let imageUrl = imageUrl {
            let imageUrl = URL(string: imageUrl)
            
            if let imageUrl = imageUrl {
                let imageDownloadTask = URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                    if let data = data {
                        DispatchQueue.main.async {
                            print("Downloaded!")
                            let image = UIImage(data: data)
                            if let image = image {
                                if image.size.width > image.size.height {
                                    self?.itemDescriptionImage.contentMode = .scaleAspectFill
                                } else {
                                    self?.itemDescriptionImage.contentMode = .scaleAspectFill
                                }
                                
                                DatabaseManager.shared.fetchetResultController.fetchedObjects?[itemNumber].titleImage = data
                                DatabaseManager.shared.saveContext()
                                
                                
                                self?.itemDescriptionImage.image = image
                                self?.hideDownloadProcess()
                            }
                        }
                    }
                }
                
                imageDownloadTask.resume()
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
}
