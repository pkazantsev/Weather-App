//
//  MainView.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/15/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit

class MainView: UIView {

    @IBOutlet weak var searchTextField: UITextField!

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsImageView: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!

    @IBOutlet weak var currentLocationButton: UIButton!

    var countrySelectButton: UIButton! {
        didSet {
            countrySelectButton?.setTitle("--", for: .normal)
            searchTextField.rightView = countrySelectButton
        }
    }

    var viewModel: WeatherViewModel? {
        didSet {
            if let vm = viewModel {
                populate(with: vm)
            } else {
                clear()
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        clear()
        searchTextField.rightViewMode = .always
        searchTextField.rightView = countrySelectButton
    }

    private func populate(with viewModel: WeatherViewModel) {
        temperatureLabel.text = viewModel.temperature
        windSpeedLabel.text = viewModel.windDirection + " " + viewModel.windSpeed
        locationLabel.text = viewModel.location
        countrySelectButton.setTitle(viewModel.countryCode, for: .normal)

        viewModel.loadConditionsImage { [weak self] image in
            // TODO: Check that the image still relevant
            self?.conditionsImageView.image = image
        }
    }

    private func clear() {
        temperatureLabel.text = " -- "
        conditionsImageView.image = nil
        windSpeedLabel.text = "--"
        locationLabel.text = ". . ."
        countrySelectButton?.setTitle("--", for: .normal)
    }

}
