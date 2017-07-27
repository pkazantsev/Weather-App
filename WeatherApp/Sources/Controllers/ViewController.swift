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

    private var searchHistoryViewController: SearchHistoryViewController?

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

        fetchForLastSearch()
    }

    private func locationDetected(_ location: UserLocation) {
        viewModel.userLocation = location
        mainView.currentLocationButton?.isEnabled = true
        locationDelectionToken = nil
        if userLocationEnabled {
            fetchViewModel(for: .currentLocation)
        }
    }

    private func fetchForLastSearch() {
        guard let lastSearch = searchHistoryViewController?.lastSearch else { return }

        fetchViewModel(for: .byCoordinates(latitude: lastSearch.coordinates.latitude, longitude: lastSearch.coordinates.longitude), fromHistory: true)
    }

    @IBAction func fetchForCurrentLocation(_ sender: UIButton) {
        fetchViewModel(for: .currentLocation)
    }

    fileprivate func fetchViewModel(for mode: WeatherSearchParameters, fromHistory: Bool = false) {
        viewModel.weatherViewModel(for: mode)
            .then { weatherViewModel -> Void in
                dlog("Weather fetched: \(weatherViewModel)")
                self.updateWith(viewModel: weatherViewModel, fromHistory: fromHistory)
            }.catch { error in
                dlog("Weather fetching error: \(error)")
                if let err = error as? WeatherAPIError, case .cityNotFound = err {
                    self.presentError(title: "City not found")
                }
            }
    }

    private func updateWith(viewModel vm: WeatherViewModel, fromHistory: Bool) {
        mainView.viewModel = vm
        viewModel.countryCode = vm.countryCode.lowercased()
        if !fromHistory {
            searchHistoryViewController?.addSearchHistoryRow(vm.locationDetails)
        }
    }

    private func presentError(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "OpenMapScreenIdentifier",
            let navVC = segue.destination as? UINavigationController,
            let mapVC = navVC.topViewController as? MapViewController {
            mapVC.userSelectedLocation = (searchHistoryViewController?.lastSearch ?? viewModel.userLocation)?.coordinates
        } else if segue.identifier == "EmbedSearchHistoryIdentifier",
            let searchVC = segue.destination as? SearchHistoryViewController {
            searchHistoryViewController = searchVC
            searchVC.onRowSelection = { [weak self] location in
                self?.fetchViewModel(for: .byCoordinates(latitude: location.coordinates.latitude, longitude: location.coordinates.longitude), fromHistory: true)
            }
        }

    }

    /// Close Map Screen without saving a selected location
    @IBAction func cancelMapScreen(_ sender: UIStoryboardSegue) { }
    /// Closing Map Screen with passing a selected location
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

        if let mode = MainViewModel.searchPatametersFromRequest(text) {
            fetchViewModel(for: mode)
        }
    }
}

