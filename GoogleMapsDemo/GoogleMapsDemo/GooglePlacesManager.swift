//
//  GooglePlacesManager.swift
//  GoogleMapsDemo
//
//  Created by Валентин Петруля on 06.12.2021.
//

import Foundation
import GooglePlaces

struct Place {
    let name: String
    let identifier: String
}

final class GooglePlacesManager {
    static let shared = GooglePlacesManager()
    private let client = GMSPlacesClient.shared()
    private init() {}
    
    enum PlacesError: Error {
        case failedToFind, failedToGetCoordinates
    }
    
    func findPlaces(
        query: String,
        completion: @escaping (Result<[Place], PlacesError>) -> Void
    ) {
        let filter = GMSAutocompleteFilter()
        filter.type = .geocode
        client.findAutocompletePredictions(
            fromQuery: query,
            filter: filter,
            sessionToken: nil
        ) { results, error in
            guard let results = results, error == nil else {
                completion(.failure(.failedToFind))
                return
            }
            let places = results.compactMap {
                Place(name: $0.attributedFullText.string, identifier: $0.placeID)
            }
            completion(.success(places))
        }
    }
    
    func resolveLocation(
        for place: Place,
        completion: @escaping (Result<CLLocationCoordinate2D, PlacesError>) -> Void
    ) {
        client.fetchPlace(
            fromPlaceID: place.identifier,
            placeFields: .coordinate,
            sessionToken: nil
        ) { googlePlace, error in
            guard let googlePlace = googlePlace, error == nil else {
                completion(.failure(.failedToGetCoordinates))
                return
            }
            let coordinate = CLLocationCoordinate2D(
                latitude: googlePlace.coordinate.latitude,
                longitude: googlePlace.coordinate.longitude
            )
            completion(.success(coordinate))
        }
    }
}

