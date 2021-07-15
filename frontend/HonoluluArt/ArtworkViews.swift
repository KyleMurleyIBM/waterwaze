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

import Foundation
import MapKit
import Cosmos

class ArtworkMarkerView: MKMarkerAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      // 1
      guard let artwork = newValue as? Artwork else {
        return
      }
      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      rightCalloutAccessoryView = UIButton(type: .detailDisclosure)

      // 2
      markerTintColor = artwork.markerTintColor
      glyphImage = artwork.image
    }
  }
}

class ArtworkView: MKAnnotationView {
  override var annotation: MKAnnotation? {
    willSet {
      guard let artwork = newValue as? Artwork else {
        return
      }

      canShowCallout = true
      calloutOffset = CGPoint(x: -5, y: 5)
      let mapsButton = UIButton(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 48, height: 48)))
      mapsButton.setBackgroundImage(#imageLiteral(resourceName: "Map"), for: .normal)
      rightCalloutAccessoryView = mapsButton

      image = artwork.image
      
      let detailLabel = UILabel()
      detailLabel.numberOfLines = 0
      detailLabel.font = detailLabel.font.withSize(12)
      detailLabel.text = artwork.subtitle
      // detailCalloutAccessoryView = detailLabel
      // detailCalloutAccessoryView = mapsButton
      
      let ratingControls = CosmosView()
      ratingControls.settings.fillMode = .precise
      let starColor = UIColor.systemBlue // orange
      ratingControls.settings.filledColor = starColor
      ratingControls.settings.emptyBorderColor = starColor
      ratingControls.settings.filledBorderColor = starColor
      ratingControls.rating = artwork.rating ?? 0.0
      ratingControls.text = String(artwork.numRatings ?? 0)
      // ratingControls.settings.textColor = starColor
      ratingControls.settings.textFont = detailLabel.font.withSize(12)
      
      
      ratingControls.didFinishTouchingCosmos = { rating in 
        self.submitRating(source: artwork, rating: rating)
      }
      
      detailCalloutAccessoryView = ratingControls
    }
  }
  
  func submitRating(source: Artwork, rating: Double) {
    let locationId = source.locationId
    if (locationId == nil) {
      return
    }
    print(rating)
    
    let formatStr = "%.5f"
    // let urlStr = "http://98.10.206.222:8080/rate_location?location_id=" + locationId! + "&rating=" + String(format: formatStr, rating)
    let urlStr = "http://98.10.206.222:8080/rate_location?location_id=" + locationId! + "&rating=" + String(Int(rating))
    print(urlStr)
    /*
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
      let response = data
      do {
        print(response)
      } catch {
        // 5
        print("Unexpected error: \(error).")
      }
    }
    .resume()
 */
  }
}
