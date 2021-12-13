//
//  ViewController.swift
//  GoogleMapsDemo
//
//  Created by Валентин Петруля on 02.12.2021.
//

import UIKit
import GoogleMaps

final class PlacesVC: UIViewController {
    private let searchVC = UISearchController(searchResultsController: ResultsVC())
    private var mapView: GMSMapView!
    private let locationManager = CLLocationManager()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Places"
        searchVC.searchResultsUpdater = self
        navigationItem.searchController = searchVC
        setupMapView()
        locationManager.startUpdatingLocation()
        locationManager.delegate = self
    }

    private func setupMapView() {
        let camera = GMSCameraPosition.camera(withLatitude: 47.5, longitude: -122.3, zoom: 6.0)
        mapView = GMSMapView.map(withFrame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        mapView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(mapView)
        mapView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        mapView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        mapView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        mapView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
    }
}

extension PlacesVC: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        guard let query = searchController.searchBar.text,
              let resultsVC = searchController.searchResultsController as? ResultsVC,
              query.trimmingCharacters(in: .whitespaces).isEmpty == false else {
                  return
              }
        
        resultsVC.delegate = self
        
        GooglePlacesManager.shared.findPlaces(query: query) { result in
            switch result {
            case .success(let places):
                DispatchQueue.main.async {
                    resultsVC.update(with: places)
                }
            case .failure(let error):
                print(error)
            }
        }
    }
}

extension PlacesVC: ResultsViewControllerDelegate {
    func didTapPlace(with coordinates: CLLocationCoordinate2D, placeName: String) {
        searchVC.searchBar.resignFirstResponder()
        searchVC.searchBar.text = placeName
        searchVC.dismiss(animated: true)
        mapView.clear()
        let marker = GMSMarker()
        marker.position = coordinates
        let value: Double = 100000
        let roundedLatitude = Double(round(value * coordinates.latitude) / value)
        let roundedLongitude = Double(round(value * coordinates.longitude) / value)
        marker.title = "Latitude: \(roundedLatitude)"
        marker.snippet = "Longitude: \(roundedLongitude)"
        marker.map = mapView
        mapView.animate(toLocation: coordinates)
    }
}

extension PlacesVC: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location = locations.last
        let camera = GMSCameraPosition.camera(withLatitude: (location?.coordinate.latitude)!, longitude: (location?.coordinate.longitude)!, zoom: 10.0)
        mapView.animate(to: camera)
        locationManager.stopUpdatingLocation()
    }
}
