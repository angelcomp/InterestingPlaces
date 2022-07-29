/**
 * Copyright (c) 2018 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN  AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import CoreLocation

class ViewController: UIViewController{
    
    @IBOutlet weak var placeName: UILabel!
    @IBOutlet weak var locationDistance: UILabel!
    @IBOutlet weak var placeImage: UIImageView!
    @IBOutlet weak var address: UILabel!
    
    
    var placesViewController: PlaceScrollViewController?
    var locationManager: CLLocationManager?
    var currentLocation: CLLocation?
    var places: [InterestingPlaces] = []
    var selectedPlace: InterestingPlaces? = nil
    lazy var geocoder = CLGeocoder()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let childViewController = children.first as? PlaceScrollViewController {
            placesViewController = childViewController
        }
        loadPlaces()
        locationManager = CLLocationManager()
        locationManager?.delegate = self
        locationManager?.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager?.allowsBackgroundLocationUpdates = true
        selectedPlace = places.first
        updateUI()
        placesViewController?.addPlaces(places: places)
        placesViewController?.delegate = self
        printAddress()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func selectPlace() {
        print("place selected")
    }
    
    @IBAction func startLocationService(_ sender: UIButton) {
        if CLLocationManager.authorizationStatus() == .authorizedAlways ||
            CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            activateLocationServices()
        } else {
            locationManager?.requestAlwaysAuthorization()
        }
    }
    
    private func activateLocationServices() {
        locationManager?.startUpdatingLocation()
    }
    
    func loadPlaces() {
        
        guard let entries = loadPlist() else { fatalError("Unable to load data") }
        
        for property in entries {
            guard let name = property["Name"] as? String,
                  let latitude = property["Latitude"] as? NSNumber,
                  let longitude = property["Longitude"] as? NSNumber,
                  let image = property["Image"] as? String else { fatalError("Error reading data") }
            let place = InterestingPlaces(latitude: Double(truncating: latitude), longitude: Double(truncating: longitude), name: name, imageName: image)
            places.append(place)
        }
    }
    
    private func updateUI() {
        placeName.text = selectedPlace?.name
        guard let imageName = selectedPlace?.imageName, let image = UIImage(named: imageName) else { return }
        placeImage.image = image
        
        guard let currentLocation = currentLocation,
              let distanceInMeters = selectedPlace?.location.distance(from: currentLocation) else { return }
        let distance = Measurement(value: distanceInMeters, unit: UnitLength.meters)
        let miles = distance.converted(to: .miles)
        locationDistance.text = "\(miles)"
    }
    
    private func loadPlist() -> [[String: Any]]? {
        guard let plistUrl = Bundle.main.url(forResource: "Places", withExtension: "plist"),
              let plistData = try? Data(contentsOf: plistUrl) else { return nil }
        var placedEntries: [[String: Any]]? = nil
        
        do {
            placedEntries = try PropertyListSerialization.propertyList(from: plistData, options: [], format: nil) as? [[String: Any]]
        } catch {
            print("error reading plist")
        }
        return placedEntries
    }
    
    private func printAddress() {
        guard let selectedPlace = selectedPlace else { return }
        geocoder.reverseGeocodeLocation(selectedPlace.location) { [weak self] placeMarks, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            
            guard let placeMark = placeMarks?.first else { return }
            if let streetNumber = placeMark.subThoroughfare,
               let street = placeMark.thoroughfare,
               let city = placeMark.locality,
               let state = placeMark.administrativeArea {
                self?.address.text = "\(streetNumber) \(street) \(city) \(state)"
                
            }
            
        }
    }
}

extension ViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways || status == .authorizedWhenInUse {
            activateLocationServices()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        
        currentLocation = locations.first
        
//        if currentLocation == nil {
//            currentLocation = locations.first
//        } else {
//            guard let latest = locations.first else { return }
//            let distanceInMeters = currentLocation?.distance(from: latest) ?? 0
//            print("distance in meters: \(distanceInMeters)")
//            currentLocation = latest
//        }
    }
}

extension ViewController: PlaceScrollViewControllerDelegate {
    func selectedPlaceViewController(_ controller: PlaceScrollViewController, didSelectPlace place: InterestingPlaces) {
        selectedPlace = place
        updateUI()
    }
}
