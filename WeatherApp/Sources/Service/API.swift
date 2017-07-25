//
//  API.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/13/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit
import Marshal
import PromiseKit

typealias WeatherApiKey = String

private let openWeatherMapSrv = URL(string: "http://api.openweathermap.org")!
private let weatherPath = "/data/2.5/weather"
private let conditionImageUrl = "http://openweathermap.org/img/w/{imageCode}.png"

enum WeatherAPIError: Error {
    case incorrectWeatherImageCode
    case cityNotFound
    case unknownApiError
    case other(Error)
}

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
        return fetch(fromURL: url)
    }

    func fetch(byLatitute latitude: Double, longitue: Double) -> Promise<Weather> {
        let url = Endpoints.byCoordinates(latitude: latitude, longitude: longitue).asUrl(withApiKey: apiKey)
        return fetch(fromURL: url)
    }

    func fetch(byZipCode zipCode: Int, countryCode: String) -> Promise<Weather> {
        let url = Endpoints.byZipCode(zip: zipCode, countryCode: countryCode).asUrl(withApiKey: apiKey)
        return fetch(fromURL: url)
    }

    func loadConditionsImage(withName imageName: String) -> Promise<UIImage> {
        guard let url = URL(string: conditionImageUrl.replacingOccurrences(of: "{imageCode}", with: imageName)) else {
            return Promise(error: WeatherAPIError.incorrectWeatherImageCode)
        }
        return network
            .loadImage(from: url)
    }

    private func fetch(fromURL url: URL) -> Promise<Weather> {
        return network
            .fetchJson(from: url)
            .then { obj -> JSONObject in
                let statusCode: Int
                if let code: String = try? obj.value(for: "cod") {
                    // In case of error it is String
                    statusCode = Int(code)!
                } else {
                    // In normal case it is Int
                    statusCode = try obj.value(for: "cod")
                }
                if statusCode == 404 {
                    throw WeatherAPIError.cityNotFound
                } else if statusCode != 200 {
                    throw WeatherAPIError.unknownApiError
                }
                return obj
            }
            .then { try Weather(object: $0) }
    }

}
