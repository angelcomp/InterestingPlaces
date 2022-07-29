//
//  InterestingPlaces.swift
//  InterestingPlaces
//
//  Created by Angelica dos Santos on 29/07/22.
//  Copyright © 2022 Razeware LLC. All rights reserved.
//

import Foundation
import CoreLocation

class InterestingPlaces {
    
    let location: CLLocation
    let name: String
    let imageName: String
    
    init(latitude: Double, longitude: Double, name: String, imageName: String) {
        self.location = CLLocation(latitude: latitude, longitude: longitude)
        self.name = name
        self.imageName = imageName
    }
}
