//
//  DateExtension.swift
//  TuTByNews
//
//  Created by Neestackich on 11/2/20.
//

import UIKit

extension Date {
    func getFormattedDate(dateToParse: String) -> String {
        let dateFormatterGet = DateFormatter()
        dateFormatterGet.dateFormat = "E, d MMM yyyy HH:mm:ss Z"
        dateFormatterGet.locale = Locale(identifier: "en_GB")
        
        let dateFormatterPrint = DateFormatter()
        dateFormatterPrint.dateFormat = "dd/MM/yyyy"
        
        let date = dateFormatterGet.date(from: dateToParse)
        
        if let date = date {
            return dateFormatterPrint.string(from: date)
        } else {
            return dateToParse
        }
    }
}
