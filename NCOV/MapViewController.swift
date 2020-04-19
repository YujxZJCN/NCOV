//
//  MapViewController.swift
//  NCOV
//
//  Created by 俞佳兴 on 2020/4/13.
//  Copyright © 2020 yjx. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController {
    
    @IBOutlet var topView: UIView! {
        didSet {
            self.topView.clipsToBounds = true
            self.topView.layer.cornerRadius = 28.0
        }
    }
    @IBOutlet var mapView: MKMapView!
    
    let locationManager = CLLocationManager()
    
    var latitude = [Double]()
    var longitude = [Double]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        mapView.delegate = self
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 5
        locationManager.requestWhenInUseAuthorization()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let status = CLLocationManager.authorizationStatus()
        checkLocationService()
        if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways {
            mapView.showsUserLocation = true
            // mapView.userTrackingMode = .follow
            locationManager.startUpdatingLocation()
            mapView.userTrackingMode = .follow
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}

extension MapViewController: MKMapViewDelegate, CLLocationManagerDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            
            let identifier = "myMarker"
            
            if annotation.isKind(of: MKUserLocation.self) {
                return nil
            }
            
            // Reuse the annotation if possible
            var annotationView: MKMarkerAnnotationView? = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
            
            if annotationView == nil {
                annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            }
            
    //        annotationView?.glyphText = "🚲"
            annotationView?.markerTintColor = .orange
            
            return annotationView
        }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let userLocation = mapView.userLocation
        let currentCoordinate = userLocation.coordinate
        
        latitude.append(currentCoordinate.latitude + 0.001 * Double(Int(10).arc4random))
        longitude.append(currentCoordinate.longitude - 0.001 * Double(Int(10).arc4random))
        
        latitude.append(currentCoordinate.latitude - 0.001 * Double(Int(10).arc4random))
        longitude.append(currentCoordinate.longitude + 0.001 * Double(Int(10).arc4random))
        mapView.removeAnnotations(mapView.annotations)
        for i in 0 ..< latitude.count {
            let annotation = MKPointAnnotation()
            let coordinate = CLLocationCoordinate2D(latitude: latitude[i], longitude: longitude[i])
            
            annotation.coordinate = coordinate
            
            mapView.showAnnotations([annotation], animated: true)
        }
        
        mapView.setRegion(MKCoordinateRegion(center: userLocation.coordinate, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
    }
    
    func checkLocationService() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                sendMessage(title: "定位权限未知", details: "请进入系统设置>隐私>定位服务中打开开关,并允许软件使用定位服务", turnOnSetting: true)
            case .denied:
                sendMessage(title: "定位权限/定位已关闭", details: "请进入系统设置>隐私>定位服务中打开开关,并允许软件使用定位服务", turnOnSetting: true)
            case .restricted:
                sendMessage(title: "定位权限已关闭", details: "请点击“前往设置”，并允许软件使用定位服务", turnOnSetting: true)
            case .authorizedAlways, .authorizedWhenInUse:
                return
            default:
                fatalError()
            }
        } else {
            sendMessage(title: "位置状态未知", details: "建议重启手机", turnOnSetting: false)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
            if status == CLAuthorizationStatus.authorizedWhenInUse || status == CLAuthorizationStatus.authorizedAlways {
                mapView.showsUserLocation = true
    //            mapView.userTrackingMode = .follow
                locationManager.startUpdatingLocation()
            }
        }
    
    func sendMessage(title: String, details: String, turnOnSetting: Bool) {
        let alertMessage = UIAlertController(title: title, message: details, preferredStyle: .alert)
        
        if turnOnSetting {
            let settingButton = UIAlertAction(title: NSLocalizedString("Go to settings", comment: "Go to settings"), style: .default) { ACTION in
                guard let settingURL = URL(string: UIApplication.openSettingsURLString) else {
                    // Handling errors that should not happen here
                    fatalError("Error!")
                }
                let app = UIApplication.shared
                app.open(settingURL)
                
                self.dismiss(animated: true, completion: nil)
            }
            alertMessage.addAction(settingButton)
            alertMessage.preferredAction = settingButton
        }
        
        let OKButton = UIAlertAction(title: NSLocalizedString("OK", comment: "OK"), style: .default) { ACTION in
            self.dismiss(animated: true, completion: nil)
        }
        alertMessage.addAction(OKButton)
        
        if !turnOnSetting { alertMessage.preferredAction = OKButton }
        
        present(alertMessage, animated: true)
    }
}

extension Int {
    var arc4random: Int {
        if self > 0 {
            return Int(arc4random_uniform(UInt32(self)))
        } else if self < 0 {
            return -Int(arc4random_uniform(UInt32(abs(self))))
        } else {
            return 0
        }
    }
}
