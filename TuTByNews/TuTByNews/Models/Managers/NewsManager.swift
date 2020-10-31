//
//  NewsManager.swift
//  TuTByNews
//
//  Created by Neestackich on 10/30/20.
//

import Foundation

class NewsManager: NSObject {
        
    
    // MARK: -Properties
    
    static let shared = NewsManager()
    
    
    // MARK: -Methods
    
    func getFeed(url: String, completion: ((Data) -> Void)?) {
        guard let url = URL(string: url) else {
            return
        }
        
        let getXMLTask = URLSession.shared.dataTask(with: URLRequest(url: url)) { (feedInXml, response, error) in
            if let error = error {
                print(error)
            } else {
                guard let feedInXml = feedInXml else {
                    return
                }
                
                DatabaseManager.shared.cleanUpDatabase()
                
                if let completion = completion {
                    completion(feedInXml)
                }
            }
        }
        
        getXMLTask.resume()
    }
}
