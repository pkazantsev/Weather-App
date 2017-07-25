//
//  ViewController.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/13/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit
import PromiseKit

class ViewController: UIViewController {

    @IBOutlet private var mainView: MainView!
    @IBOutlet var countrySelectButton: UIButton!

    var viewModel: MainViewModel!
    var userLocationEnabled = false

    private var locationDelectionToken: UserLocationDetectionToken?

    override func viewDidLoad() {
        super.viewDidLoad()

        mainView.countrySelectButton = countrySelectButton
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // In case we need to request permission
        locationDelectionToken = viewModel.detectUserLocation(locationDetectedCallback: { [weak self] location in
            print("Location detected: \(location)")
            self?.locationDetected(location)


        }) { [weak self] error in
            dlog("Location detection error: \(error)")
            // Present the error to ther user
            self?.locationDelectionToken = nil
        }
    }

    private func locationDetected(_ location: UserLocation) {
        viewModel.userLocation = location
        mainView.currentLocationButton?.isEnabled = true
        locationDelectionToken = nil
        if userLocationEnabled {
            fetchViewModel(for: .currentLocation)
        }
    }

    @IBAction func fetchForCurrentLocation(_ sender: UIButton) {
        fetchViewModel(for: .currentLocation)
    }

    fileprivate func fetchViewModel(for mode: WeatherSearchParameters) {
        viewModel.weatherViewModel(for: mode)
            .then { weatherViewModel -> Void in
                dlog("Weather fetched: \(weatherViewModel)")
                self.updateWith(viewModel: weatherViewModel)
            }.catch { error in
                dlog("Weather fetching error: \(error)")
                if let err = error as? WeatherAPIError, case .cityNotFound = err {
                    self.showError(title: "City not found")
                }
            }
    }

    private func updateWith(viewModel vm: WeatherViewModel) {
        mainView.viewModel = vm
        viewModel.countryCode = vm.countryCode.lowercased()
        viewModel.lastSearchedLocation = vm.locationDetails
    }

    private func showError(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: "Error", message: "City not found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenMapScreenIdentifier",
            let navVC = segue.destination as? UINavigationController,
            let mapVC = navVC.topViewController as? MapViewController {
            mapVC.userSelectedLocation = (viewModel.lastSearchedLocation ?? viewModel.userLocation)?.coordinates
        }
    }

    @IBAction func cancelMapScreen(_ sender: UIStoryboardSegue) { }
    @IBAction func fetchFromMapScreen(_ sender: UIStoryboardSegue) {
        guard let mapVC = sender.source as? MapViewController else { return }

        if let location = mapVC.userSelectedLocation {
            fetchViewModel(for: .byCoordinates(latitude: location.latitude, longitude: location.longitude))
        }
    }
}

extension ViewController: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(false)
        return true
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        guard let text = textField.text, text.characters.count > 0 else {
            return
        }
        var searchMode: WeatherSearchParameters? = nil
        // parse the text
        if let _ = text.rangeOfCharacter(from: .letters) {
            searchMode = .byCityName(cityName: text)
        } else if let zipCode = Int(text) {
            searchMode = .byZipCode(zipCode: zipCode)
        }

        if let mode = searchMode {
            fetchViewModel(for: mode)
        }
    }
}

