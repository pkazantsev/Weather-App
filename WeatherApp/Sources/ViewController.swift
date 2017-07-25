//
//  ViewController.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/24/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet private var mainView: MainView!

    var viewModel: MainViewModel!
    var userLocationEnabled = true

    private var locationDelectionToken: UserLocationDetectionToken?

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // TODO: Replace with Result
        // In case wee need to request permission
        locationDelectionToken = viewModel.detectUserLocation(locationDetectedCallback: { [weak self] location in
            print("Location detected: \(location)")
            guard let vc = self else { return }

            vc.viewModel.userLocation = location
            vc.locationDelectionToken = nil
            if vc.userLocationEnabled {
                vc.viewModel.weatherViewModel(for: .currentLocation).then(execute: { weatherViewModel -> Void in
                    print("Weather fetched: \(weatherViewModel)")
                    vc.mainView.viewModel = weatherViewModel
                }).catch(execute: { (error) in
                    print("Weather fetching error: \(error)")
                })
            }
        }) { [weak self] error in
            print("Location detection error: \(error)")
            // Present the error to ther user
            self?.locationDelectionToken = nil
        }
    }


}

