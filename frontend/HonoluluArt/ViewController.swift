/// Copyright (c) 2020 Razeware LLC
/// 
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
/// 
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
/// 
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
/// 
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import UIKit
import MapKit
import CoreLocation
import Foundation

struct User: Codable, Identifiable {
    let id = UUID()
    let username: String
    let name: String
}

class ViewController: UIViewController {
  @IBOutlet private var mapView: MKMapView!
  private var artworks: [Artwork] = []
  let locationManager = CLLocationManager()
  var hasBeenCentered = false
  @IBOutlet weak var searchBar: UISearchBar!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    /*
    searchBar.barTintColor = UIColor.clear
    searchBar.backgroundColor = UIColor.clear
    searchBar.isTranslucent = true
    searchBar.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
    */
 
    // Set initial location in Honolulu
    /*
    let initialLocation = CLLocation(latitude: 21.282778, longitude: -157.829444)
    mapView.centerToLocation(initialLocation)
    
    let oahuCenter = CLLocation(latitude: 21.4765, longitude: -157.9647)
    let region = MKCoordinateRegion(
      center: oahuCenter.coordinate,
      latitudinalMeters: 50000,
      longitudinalMeters: 60000)
    mapView.setCameraBoundary(
      MKMapView.CameraBoundary(coordinateRegion: region),
      animated: true)
    
    let zoomRange = MKMapView.CameraZoomRange(maxCenterCoordinateDistance: 200000)
    mapView.setCameraZoomRange(zoomRange, animated: true)
    */
    
    // new
    mapView.showsUserLocation = true
    
    mapView.delegate = self
    
    
    self.locationManager.requestAlwaysAuthorization()
    // For use in foreground
    self.locationManager.requestWhenInUseAuthorization()

    if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }

    // mapView.delegate = self
    mapView.mapType = .hybrid
    mapView.isZoomEnabled = true
    mapView.isScrollEnabled = true
    // mapView.showsScale = true
    // mapView.showsTraffic = true
    // mapView.showsCompass = true

    /*
    if let coor = mapView.userLocation.location?.coordinate{
        mapView.setCenter(coor, animated: true)
      print("user location = ")
      print(mapView.userLocation.location)
    }
    */
    
    mapView.register(
      ArtworkView.self,
      forAnnotationViewWithReuseIdentifier: MKMapViewDefaultAnnotationViewReuseIdentifier)
    
    // http://98.10.206.222:8080
    
    loadInitialData()
    // fetchData()
    // mapView.addAnnotations(artworks)
  }
  
  func addArtworks(_ artworks: [Artwork]) {
    // self.mapView.removeAnnotations(self.artworks)
    self.mapView.addAnnotations(artworks)
    self.artworks.append(contentsOf: artworks)
  }
  
  private func loadInitialData() {
    // 1
    
    /*
    guard
      // let fileName = Bundle.main.url(forResource: "PublicArt", withExtension: "geojson"),
      let fileName: URL = Bundle.main.url(forResource: "Sample", withExtension: "geojson"),
      let artworkData: Data = try? Data(contentsOf: fileName)
      else {
        print("Error: Unable to get data")
        return
    } 
 */
    
    
    var fileName: URL? = nil
    var artworkData: Data? = nil
    do {
      fileName = Bundle.main.url(forResource: "Sample", withExtension: "geojson")
      print("able to load file")
      artworkData = try! Data(contentsOf: fileName!)
      print(artworkData)
    } catch {
      print("Ope unexpected error: \(error).")
      return
    }
 
    
    
    do {
      // 2
      let features = try MKGeoJSONDecoder()
        .decode(artworkData!)
        .compactMap { $0 as? MKGeoJSONFeature }
      // 3
      let validWorks = features.compactMap(Artwork.init)
      // 4
      // artworks.append(contentsOf: validWorks)
      self.addArtworks(validWorks)
    } catch {
      // 5
      print("Unexpected error: \(error).")
    }
  }
  
  private func fetchData(latitude: Double = 43.1029381, longitude: Double = -77.57511, radius: Double = 2.0) {
    let formatStr = "%.5f"
    // let urlStr = "http://98.10.206.222:8080/get_locations?coords=43.1029381,-77.57511&radius=2"
    // let urlStr = "http://98.10.206.222:8080/get_locations?coords=" + "43.1029381" + "," + "-77.57511" + "&radius=" + "2"
    let urlStr = "http://98.10.206.222:8080/get_locations?coords=" + String(format: formatStr, latitude) + "," + String(format: formatStr, longitude) + "&radius=" + String(format: formatStr, radius)
    // guard let url = URL(string: "https://jsonplaceholder.typicode.com/users") else { return }
    print(urlStr)
    guard let url = URL(string: urlStr) else { return }
    URLSession.shared.dataTask(with: url) { (data, _, _) in
      /*
      print(data)
      let users = try! JSONDecoder().decode([User].self, from: data!)
      print(users)

      DispatchQueue.main.async {
        // completion(users)  
        // print(users)
      }
      */
      let artworkData = data
      do {
        // 2
        let features = try MKGeoJSONDecoder()
          .decode(artworkData!)
          .compactMap { $0 as? MKGeoJSONFeature }
        // 3
        let validWorks = features.compactMap(Artwork.init)
        // 4
        // self.artworks.append(contentsOf: validWorks)
        // self.mapView.addAnnotations(self.artworks) // make sure you don't accidentally add annotations twice
        self.addArtworks(validWorks)
      } catch {
        // 5
        print("Unexpected error: \(error).")
      }
    }
    .resume()
    
    /*
    var fileName: URL? = nil
    var artworkData: Data? = nil
    do {
      fileName = Bundle.main.url(forResource: "EndpointSample", withExtension: "geojson")
      artworkData = try! Data(contentsOf: fileName!)
    } catch {
      print("Unexpected error: \(error).")
      return
    }
 
    
    
    do {
      // 2
      let features = try MKGeoJSONDecoder()
        .decode(artworkData!)
        .compactMap { $0 as? MKGeoJSONFeature }
      // 3
      let validWorks = features.compactMap(Artwork.init)
      // 4
      // artworks.append(contentsOf: validWorks)
    } catch {
      // 5
      print("Unexpected error: \(error).")
    }
    */
  }
 
}

private extension MKMapView {
  func centerToLocation(_ location: CLLocation, regionRadius: CLLocationDistance = 1000) {
    let coordinateRegion = MKCoordinateRegion(
      center: location.coordinate,
      latitudinalMeters: regionRadius,
      longitudinalMeters: regionRadius)
    setRegion(coordinateRegion, animated: true)
  }
}

extension ViewController: MKMapViewDelegate {
  func mapView(
    _ mapView: MKMapView,
    annotationView view: MKAnnotationView,
    calloutAccessoryControlTapped control: UIControl
  ) {
    guard let artwork = view.annotation as? Artwork else {
      return
    }
    
    let launchOptions = [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving]
    artwork.mapItem?.openInMaps(launchOptions: launchOptions)
  }
}

extension ViewController: CLLocationManagerDelegate {
  func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
    let locValue:CLLocationCoordinate2D = manager.location!.coordinate

    // mapView.mapType = MKMapType.satellite

    // this also shouldn't exist bc it moves the map whenever your location updates / you move
    // just set it once
    /*
    let span = MKCoordinateSpan(latitudeDelta: 1.15, longitudeDelta: 1.15)
    let region = MKCoordinateRegion(center: locValue, span: span)
    mapView.setRegion(region, animated: true)
    */

    /*
    // pretty sure this shouldn't exist; maybe be making the current location marker look bad
    let annotation = MKPointAnnotation()
    annotation.coordinate = locValue
    annotation.title = "Your Current Location"
    annotation.subtitle = "current location"
    mapView.addAnnotation(annotation)
    */

    if (!hasBeenCentered) {
      //centerMap(locValue)
      // mapView.setCenter(locValue, animated: true)
      let latitude = locValue.latitude
      let longitude = locValue.longitude
      let radius = 30.0
      let location = CLLocation(latitude: latitude, longitude: longitude)
      mapView.centerToLocation(location, regionRadius: 10000)
      // later fetch for data whenever the location updates (and ignore data that has been fetched before)
      fetchData(latitude: latitude, longitude: longitude, radius: radius)
      print(locValue)
      hasBeenCentered = true
    }
  }
}
