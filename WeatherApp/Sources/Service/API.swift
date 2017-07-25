//
//  API.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/13/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit
import PromiseKit

typealias WeatherApiKey = String

private let openWeatherMapSrv = URL(string: "http://api.openweathermap.org")!
private let weatherPath = "/data/2.5/weather"

private enum Endpoints {
    case byCityName(cityName: String, countryCode: String?)
    case byCityId(cityId: Int)
    case byCoordinates(latitude: Double, longitude: Double)
    case byZipCode(zip: Int, countryCode: String?)

    func asUrl(withApiKey apiKey: WeatherApiKey) -> URL {
        var components = URLComponents(url: openWeatherMapSrv, resolvingAgainstBaseURL: false)!
        components.path = weatherPath
        var queryItems: [URLQueryItem] = []
        switch self {
        case let .byCityName(cityName, countryCode):
            var params = cityName
            if let country = countryCode {
                params += "," + country
            }
            queryItems.append(URLQueryItem(name: "q", value: params))
        case let .byCityId(cityId):
            queryItems.append(URLQueryItem(name: "id", value: "\(cityId)"))
        case let .byCoordinates(latitude, longitude):
            queryItems.append(URLQueryItem(name: "lat", value: "\(latitude)"))
            queryItems.append(URLQueryItem(name: "lon", value: "\(longitude)"))
        case let .byZipCode(zipCode, countryCode):
            var params = "\(zipCode)"
            if let country = countryCode {
                params += "," + country
            }
            queryItems.append(URLQueryItem(name: "zip", value: params))
        }
        queryItems.append(URLQueryItem(name: "units", value: "metric"))
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        components.queryItems = queryItems
        return components.url!
    }
}

final class WeatherAPI {

    private let network: NetworkHelper
    private let apiKey: WeatherApiKey

    init(network: NetworkHelper, apiKey: WeatherApiKey) {
        self.network = network
        self.apiKey = apiKey
    }

    func fetch(byCityName cityName: String, countryCode: String) -> Promise<Weather> {
        let url = Endpoints.byCityName(cityName: cityName, countryCode: countryCode).asUrl(withApiKey: apiKey)
        return network
            .fetchJson(from: url)
            .then { try Weather(object: $0) }
    }

    func fetch(byLatitute latitude: Double, longitue: Double) -> Promise<Weather> {
        let url = Endpoints.byCoordinates(latitude: latitude, longitude: longitue).asUrl(withApiKey: apiKey)
        return network
            .fetchJson(from: url)
            .then { try Weather(object: $0) }
    }

    func fetch(byZipCode zipCode: Int, countryCode: String) -> Promise<Weather> {
        let url = Endpoints.byZipCode(zip: zipCode, countryCode: countryCode).asUrl(withApiKey: apiKey)
        return network
            .fetchJson(from: url)
            .then { try Weather(object: $0) }
    }

}
