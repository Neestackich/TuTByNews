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
        var authorizationStatus = CLLocationManager.authorizationStatus()
        
        switch authorizationStatus {
        case .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
            isValidLocation()
        case .authorizedAlways:
            locationManager.startUpdatingLocation()
            isValidLocation()
        case .denied:
            locationManager.requestWhenInUseAuthorization()
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: "false"), object: nil)
            
        default:
            locationManager.requestWhenInUseAuthorization()
        }
    }
    
    func requestAuthorization() {
        locationManager.requestWhenInUseAuthorization()
    }
    
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        getLocation()
    }
    
    func isValidLocation() {
        if let location = locationManager.location {
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) { [] placeMark, error in
                
                if let error = error {
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "impossible"), object: nil)
                } else {
                    guard let placeMark = placeMark?.first else {
                        return
                    }
                    
                    if let countryCode = placeMark.isoCountryCode {
                        if countryCode == "BLR" {
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
}
