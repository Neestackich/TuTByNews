//
//  XMLParseManager.swift
//  TuTByNews
//
//  Created by Neestackich on 10/29/20.
//

import UIKit
import CoreData

class XMLParseManager: NSObject, XMLParserDelegate {
    
    
    // MARK: -Properties
    
    static let shared = XMLParseManager()
    private var rssItems: [RSSItem] = []
    private var currentItem: String = ""
    private var itemTitle: String = ""
    private var itemPubDate: String = ""
    private var descriptionImage: String = ""
    private var mediaImages: [String] = []
    private var parseCompletionHandler: (() -> Void)?
    private var itemDescription: String = "" {
        didSet {
            itemDescription = cleanDescription(string: itemDescription)
        }
    }
    

    // MARK: -Methods
    
    func cleanDescription(string: String) -> String {
        let cleanedDescription = string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
        
        return cleanedDescription
    }
    
    func parseXml(data: Data, completion: (() -> Void)?) {
        let xmlParser = XMLParser(data: data)
        xmlParser.delegate = self
        parseCompletionHandler = completion
        xmlParser.parse()
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        currentItem = elementName
        
        if currentItem == "item" {
            itemTitle = ""
            itemDescription = ""
            itemPubDate = ""
            descriptionImage = ""
            mediaImages.removeAll()
        } else if elementName == "enclosure" {
            if let url = attributeDict["url"] {
                descriptionImage = url
            }
        } else if elementName == "media:content" {
            if let url = attributeDict["url"] {
                mediaImages.append(url)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
            DatabaseManager.shared.addItem(itemTitle: itemTitle, itemDescription: itemDescription, itemPubDate: itemPubDate, imageUrl: descriptionImage)
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        DatabaseManager.shared.getFetchetResultController()
        
        if let parseCompletionHandler = parseCompletionHandler {
            parseCompletionHandler()
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentItem {
        case "title":
            itemTitle += string
        case "description":
            itemDescription += string
        case "pubDate":
            itemPubDate += getDate(dateString: string)
        case "media:content":
            break
        default:
            break
        }
    }
    
    func getDate(dateString: String) -> String {
        let date = Date()
        let parsedDate = date.getFormattedDate(dateToParse: dateString)
        
        return parsedDate
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
