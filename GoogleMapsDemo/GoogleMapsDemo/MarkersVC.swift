//
//  MarkersVC.swift
//  GoogleMapsDemo
//
//  Created by Валентин Петруля on 05.12.2021.
//

import UIKit
import CoreLocation
import GoogleMaps
import GoogleMapsUtils

final class MarkersVC: UIViewController {
    
    private let mapView = GMSMapView()
    private var clusterManager: GMUClusterManager!
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupMapView()
        setupClusterManager()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }
    
    private func setupMapView() {
        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        
        view.addSubview(mapView)
        mapView.translatesAutoresizingMaskIntoConstraints = false
        mapView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
    
    private func setupClusterManager() {
        let iconGenerator = GMUDefaultClusterIconGenerator()
        let algorithm = GMUNonHierarchicalDistanceBasedAlgorithm()
        let renderer = GMUDefaultClusterRenderer(
            mapView: mapView, clusterIconGenerator: iconGenerator
        )
        clusterManager = GMUClusterManager(
            map: mapView, algorithm: algorithm, renderer: renderer
        )
        clusterManager.setMapDelegate(self)
        clusterManager.cluster()
    }
}

extension MarkersVC: GMSMapViewDelegate {
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        let marker = GMSMarker()
        let latitude = coordinate.latitude
        let longitude = coordinate.longitude
        let position = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        marker.position = position
        let value: Double = 100000
        let roundedLatitude = Double(round(value * latitude) / value)
        let roundedLongitude = Double(round(value * longitude) / value)
        marker.title = "Latitude: \(roundedLatitude)"
        marker.snippet = "Longitude: \(roundedLongitude)"
        marker.map = mapView
        clusterManager.add(marker)
    }
}

extension MarkersVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 13.0)
        mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
}
