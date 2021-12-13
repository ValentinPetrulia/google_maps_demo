//
//  TabBarController.swift
//  GoogleMapsDemo
//
//  Created by Валентин Петруля on 05.12.2021.
//

import UIKit

final class TabBarController: UITabBarController {
    
    private let markersVC = MarkersVC()
    private let placesVC = UINavigationController(rootViewController: PlacesVC())

    override func viewDidLoad() {
        super.viewDidLoad()
        viewControllers = [markersVC, placesVC]
        markersVC.title = "Markers"
        placesVC.title = "Places"
        if let items = tabBar.items {
            items[0].image = UIImage(systemName: "mappin.and.ellipse")
            items[1].image = UIImage(systemName: "mappin.circle.fill")
        }
    }
    
}
