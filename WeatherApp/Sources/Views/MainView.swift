//
//  MainView.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/15/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit

class MainView: UIView {

    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var temperatureLabel: UILabel!
    @IBOutlet weak var conditionsImageView: UIImageView!
    @IBOutlet weak var windSpeedLabel: UILabel!

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
    }

    private func populate(with viewModel: WeatherViewModel) {
        self.temperatureLabel.text = viewModel.temperature
        self.windSpeedLabel.text = viewModel.windDirection + " " + viewModel.windSpeed
        self.locationLabel.text = viewModel.location

        viewModel.loadConditionsImage { [weak self] image in
            // TODO: Check that the image still relevant
            self?.conditionsImageView.image = image
        }
    }

    private func clear() {
        temperatureLabel.text = " -- "
        conditionsImageView.image = nil
        windSpeedLabel.text = "--"
    }

}
