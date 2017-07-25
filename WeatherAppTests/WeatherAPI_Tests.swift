//
//  WeatherAppTests.swift
//  WeatherAppTests
//
//  Created by Pavel Kazantsev on 7/13/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import XCTest
import PromiseKit
import Hamcrest
@testable import WeatherApp

private let units = "&units=metric"

private let mainSrv = "http://api.openweathermap.org"
private let fetchByCityNameUrl = mainSrv + "/data/2.5/weather?q={query}" + units
private let fetchByZipCodeUrl = mainSrv + "/data/2.5/weather?zip={zip}" + units
private let fetchByCoordinatesUrl = mainSrv + "/data/2.5/weather?lat={lat}&lon={lon}" + units
private let testApiKey = "12345"

class WeatherAPI_Tests: XCTestCase {

    func testFetchWeatherByCityNameWithCountryName() throws {
        let url = URL(string: fetchByCityNameUrl.replacingOccurrences(of: "{query}", with: "New%20York,us"))!
        let testNetwork = TestsNetworkHelper(withFileName: "weather_name_NewYork", targetUrl: url, apiKey: testApiKey)
        let api = WeatherAPI(network: testNetwork, apiKey: testApiKey)

        let exp = self.expectation(description: "Weather fetched by city name")

        api.fetch(byCityName: "New York", countryCode: "us").then { weather -> Void in
            try assert(weather, [
                "cityName": "New York",
                "countryName": "US",
                "conditions": ["id": 500, "group": "Rain", "description": "light rain", "iconId": "10d"],
                "main": ["temperature" : 19.21, "humidity": 88.0, "pressure": 1018.0],
                "wind": ["speed": 1.96, "direction": 64.5027],
                "coordinates": ["latitude": 40.71, "longitude": -74.01]])
        }.catch { error in
            XCTFail("fetching error: \(error)")
        }.always {
            exp.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testFetchWeatherByZipCodeAndCountry() throws {
        let url = URL(string: fetchByZipCodeUrl.replacingOccurrences(of: "{zip}", with: "9016,nz"))!
        let testNetwork = TestsNetworkHelper(withFileName: "weather_zip_9016nz", targetUrl: url, apiKey: testApiKey)
        let api = WeatherAPI(network: testNetwork, apiKey: testApiKey)

        let exp = self.expectation(description: "Weather fetched by zip code and country")

        api.fetch(byZipCode: 9016, countryCode: "nz").then { weather -> Void in
            try assert(weather, [
                "cityName": "Waverley",
                "countryName": "NZ",
                "conditions": ["id": 803, "group": "Clouds", "description": "broken clouds", "iconId": "04n"],
                "main": ["temperature" : -1.03, "humidity": 95, "pressure": 995.4],
                "wind": ["speed": 1.71, "direction": 334.003],
                "coordinates": ["latitude": -45.87, "longitude": 170.51]])
        }.catch { error in
            XCTFail("fetching error: \(error)")
        }.always {
            exp.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

    func testFetchWeatherByCoordinates() throws {
        let url = URL(string: fetchByCoordinatesUrl.replacingOccurrences(of: "{lat}", with: "-54.8").replacingOccurrences(of: "{lon}", with: "-68.3"))!
        let testNetwork = TestsNetworkHelper(withFileName: "weather_coordinates_-54.8,-68.3", targetUrl: url, apiKey: testApiKey)
        let api = WeatherAPI(network: testNetwork, apiKey: testApiKey)

        let exp = self.expectation(description: "Weather fetched by zip code and country")

        api.fetch(byLatitute: -54.8, longitue: -68.3).then { weather -> Void in
            try assert(weather, [
                "cityName": "Ushuaia",
                "countryName": "AR",
                "conditions": ["id": 600, "group": "Snow", "description": "light snow", "iconId": "13n"],
                "main": ["temperature" : 0.0, "humidity": 100.0, "pressure": 986.0],
                "wind": ["speed": 13.9, "direction": 230.0],
                "coordinates": ["latitude": -54.8, "longitude": -68.3]])
            }.catch { error in
                XCTFail("fetching error: \(error)")
            }.always {
                exp.fulfill()
        }

        waitForExpectations(timeout: 3.0)
    }

}
