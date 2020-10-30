//
//  XMLParseManager.swift
//  TuTByNews
//
//  Created by Neestackich on 10/29/20.
//

import UIKit

class XMLParseManager: NSObject, XMLParserDelegate {
    
    
    // MARK: -Properties
    
    static let shared = XMLParseManager()
    private var rssItems: [RSSItem] = []
    private var currentItem: String = ""
    private var itemTitle: String = ""
    private var itemDescription: String = "" {
        didSet {
            itemDescription = cleanDescription(string: itemDescription)
            print(itemDescription)
        }
    }
    private var itemPubDate: String = ""
    private var descriptionImages: [String] = []
    private var mediaImages: [String] = []
    private var parseCompletionHandler: (([RSSItem]) -> Void)?
    

    // MARK: -Methods
    
    func cleanDescription(string: String) -> String {
        let cleanedDescription = string.trimmingCharacters(in: .whitespacesAndNewlines).replacingOccurrences(of: "<[^>]+>", with: "", options: String.CompareOptions.regularExpression, range: nil)
        
        return cleanedDescription
    }
    
    func parseXml(data: Data, completion: (([RSSItem]) -> Void)?) {
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
            descriptionImages.removeAll()
            mediaImages.removeAll()
        } else if elementName == "enclosure" {
            if let url = attributeDict["url"] {
                descriptionImages.append(url)
            }
        } else if elementName == "media:content" {
            if let url = attributeDict["url"] {
                mediaImages.append(url)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "item" {
           rssItems.append(RSSItem(title: itemTitle, description: itemDescription, pubDate: itemPubDate, descriptionImages: descriptionImages, mediaImages: mediaImages))
        }
    }
    
    func parserDidEndDocument(_ parser: XMLParser) {
        if let parseCompletionHandler = parseCompletionHandler {
            parseCompletionHandler(rssItems)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        switch currentItem {
        case "title":
            itemTitle += string
        case "description":
            itemDescription += string
        case "pubDate":
            itemPubDate += string
        case "media:content":
            break
        default:
            break
        }
    }
    
    func parser(_ parser: XMLParser, parseErrorOccurred parseError: Error) {
        print(parseError.localizedDescription)
    }
}
