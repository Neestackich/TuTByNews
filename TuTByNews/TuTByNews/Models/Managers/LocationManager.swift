//
//  LocationManager.swift
//  TuTByNews
//
//  Created by Neestackich on 10/31/20.
//

import UIKit
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()
    
    override init() {
        super.init()
        
        locationManager.delegate = self
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = .greatestFiniteMagnitude
    }
    
    func getLocation() {
        let authorizationStatus = CLLocationManager.authorizationStatus()
        
        if authorizationStatus == .authorizedWhenInUse {
            locationManager.startUpdatingLocation()
            isValidLocation()
        } else {
            locationManager.requestWhenInUseAuthorization()
            
        }
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        getLocation()
    }
    
    func isValidLocation() {
        if let location = locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [] placeMark, error in
                guard let placeMark = placeMark?.first else {
                    return
                }
                
                if let countryCode = placeMark.isoCountryCode {
                    if countryCode == "RU" {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "true"), object: nil)
                    } else {
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "false"), object: nil)
                    }
                    
                    print(countryCode)
                }
            }
        }
    }
}
