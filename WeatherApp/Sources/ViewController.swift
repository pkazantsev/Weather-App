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
            guard let vc = self else { return }

            vc.viewModel.userLocation = location
            vc.mainView.currentLocationButton?.isEnabled = true
            vc.locationDelectionToken = nil
            if vc.userLocationEnabled {
                vc.fetchViewModel(for: .currentLocation)
            }
        }) { [weak self] error in
            dlog("Location detection error: \(error)")
            // Present the error to ther user
            self?.locationDelectionToken = nil
        }
    }

    @IBAction func fetchForCurrentLocation(_ sender: UIButton) {
        fetchViewModel(for: .currentLocation)
    }

    fileprivate func fetchViewModel(for mode: WeatherSearchParameters) {
        viewModel.weatherViewModel(for: mode)
            .then { weatherViewModel -> Void in
                dlog("Weather fetched: \(weatherViewModel)")
                self.mainView.viewModel = weatherViewModel
                self.viewModel.countryCode = weatherViewModel.countryCode.lowercased()
            }.catch { error in
                dlog("Weather fetching error: \(error)")
                if let err = error as? WeatherAPIError, case .cityNotFound = err {
                    self.showError(title: "City not found")
                }
            }
    }

    private func showError(title: String? = nil, message: String? = nil) {
        let alert = UIAlertController(title: "Error", message: "City not found", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
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
        // TODO: Implement support for inline country code detection
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

