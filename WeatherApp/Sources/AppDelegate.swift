//
//  AppDelegate.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/24/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit

private let openWeatherMapKey = "7527cc5c5007edd969f935e4363be1b5"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var api: WeatherAPI!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        api = WeatherAPI(network: NetworkHelperImpl(), apiKey: openWeatherMapKey)

        if let rootVc = window?.rootViewController as? ViewController {
            let viewModel = MainViewModel(api: api)
            rootVc.viewModel = viewModel
        }

        return true
    }


}

