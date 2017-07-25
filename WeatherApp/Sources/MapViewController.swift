//
//  MapViewController.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/25/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

/// Presents a map view for user to select a point
class MapViewController: UIViewController {

    @IBOutlet weak var doneButton: UIBarButtonItem!
    @IBOutlet weak var mapView: MKMapView!

    var userSelectedLocation: Coordinates?
    var tappedMapAnnotation: MKAnnotation?

    override func viewDidLoad() {
        super.viewDidLoad()

        if let location = userSelectedLocation {
            setMapAnnotation(at: .init(latitude: location.latitude, longitude: location.longitude))
            doneButton.isEnabled = true
        }
    }
    @IBAction func mapTapped(_ sender: UITapGestureRecognizer) {
        let point = sender.location(in: mapView)
        let tappedMapPoint = mapView.convert(point, toCoordinateFrom: mapView)
        userSelectedLocation = Coordinates(latitude: tappedMapPoint.latitude, longitude: tappedMapPoint.longitude)

        setMapAnnotation(at: tappedMapPoint)

        doneButton.isEnabled = true
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if let location = userSelectedLocation {
            let coord = CLLocationCoordinate2D(latitude: location.latitude, longitude: location.longitude)
            mapView.centerCoordinate = coord
            mapView.region = MKCoordinateRegion(center: coord, span: .init(latitudeDelta: 1.4, longitudeDelta: 1.4))
        }
    }

    private func setMapAnnotation(at coordinates: CLLocationCoordinate2D) {
        if let existingAnnotation = tappedMapAnnotation {
            mapView.removeAnnotation(existingAnnotation)
        }

        let newAnnotation = MKPointAnnotation()
        newAnnotation.coordinate = coordinates
        mapView.addAnnotation(newAnnotation)
        tappedMapAnnotation = newAnnotation
    }

}
