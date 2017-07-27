//
//  WeatherViewModel_Tests.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/16/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import XCTest
import PromiseKit
import Hamcrest
@testable import WeatherApp

///
/// http://climate.umn.edu/snow_fence/components/winddirectionanddegreeswithouttable3.htm
///
class WeatherViewModel_Tests: XCTestCase {

    func testWindDirectionCodeNorth() {
        let direction1 = 348.87
        let dirCode1 = WeatherViewModel.windDirectionCode(from: direction1)
        assertThat(dirCode1, equalTo("N"))

        let direction2 = 359.95
        let dirCode2 = WeatherViewModel.windDirectionCode(from: direction2)
        assertThat(dirCode2, equalTo("N"))

        let direction3 = 11.24
        let dirCode3 = WeatherViewModel.windDirectionCode(from: direction3)
        assertThat(dirCode3, equalTo("N"))
    }

    func testWindDirectionCodeNorthWest() {
        let direction1 = 303.751
        let dirCode1 = WeatherViewModel.windDirectionCode(from: direction1)
        assertThat(dirCode1, equalTo("NW"))

        let direction2 = 312.7
        let dirCode2 = WeatherViewModel.windDirectionCode(from: direction2)
        assertThat(dirCode2, equalTo("NW"))

        let direction3 = 326.249
        let dirCode3 = WeatherViewModel.windDirectionCode(from: direction3)
        assertThat(dirCode3, equalTo("NW"))
    }

    func testWindDirectionCodeNorthNorthWest() {
        let direction1 = 326.251
        let dirCode1 = WeatherViewModel.windDirectionCode(from: direction1)
        assertThat(dirCode1, equalTo("NNW"))

        let direction2 = 338.005
        let dirCode2 = WeatherViewModel.windDirectionCode(from: direction2)
        assertThat(dirCode2, equalTo("NNW"))

        let direction3 = 348.749
        let dirCode3 = WeatherViewModel.windDirectionCode(from: direction3)
        assertThat(dirCode3, equalTo("NNW"))
    }

    func testTemperature() {
        let api = stubApi()

        var weather = makeWeather(temperature: -23.17)
        var model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.temperature, equalTo("-23.2°"))

        weather = makeWeather(temperature: -7.0)
        model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.temperature, equalTo("-7°"))

        weather = makeWeather(temperature: 2.33)
        model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.temperature, equalTo("2.3°"))

        weather = makeWeather(temperature: 28.79)
        model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.temperature, equalTo("28.8°"))
    }

    func testWindSpeed() {
        let api = stubApi()

        var weather = makeWeather(windSpeed: 3.21)
        var model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.windSpeed, equalTo("3.2 m/s"))

        weather = makeWeather(windSpeed: 7.0)
        model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.windSpeed, equalTo("7 m/s"))
    }

    func testLocation() {
        let api = stubApi()

        var weather = makeWeather(cityName: "Kiyv", countryName: "UA")
        var model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.location, equalTo("Kiyv, UA"))

        weather = makeWeather(cityName: "Gdynia", countryName: "PL")
        model = WeatherViewModel(api: api, weather: weather)
        assertThat(model.location, equalTo("Gdynia, PL"))
    }

    func testLoadConditionsImageSuccess() {
        let api = stubApi(imageName: "10n")
        let exp = expectation(description: "Icon should be loaded")

        let weather = makeWeather(iconId: "10n")
        let model = WeatherViewModel(api: api, weather: weather)
        model.loadConditionsImage { image in
            exp.fulfill()
            XCTAssert(image == UIImage(named: "10n", in: Bundle(for: WeatherViewModel_Tests.self), compatibleWith: nil))
        }
        waitForExpectations(timeout: 3.0)
    }

    func testLoadConditionsImageFailure() {
        let api = stubApi()
        let exp = expectation(description: "Icon should be loaded")

        let weather = makeWeather(iconId: "0k")
        let model = WeatherViewModel(api: api, weather: weather)
        model.loadConditionsImage { image in
            exp.fulfill()
            XCTAssert(image == UIImage(named: "NoWeatherIcon", in: Bundle(for: WeatherAPI.self), compatibleWith: nil))
        }
        waitForExpectations(timeout: 3.0)
    }

}

func makeWeather(cityName: String = "City", countryName: String = "Country", latitude: Double = -1, longitude: Double = -1, conditionsId: Int = 1, group: String = "Rain", description: String = "rain", iconId: String = "10d", temperature: Double = 17.23, humidity: Double = 78.2, pressure: Double = 789.6, windSpeed: Double = 3.45, direction: Double = 307.2) -> Weather {
    return Weather(cityName: cityName,
                   countryName: countryName,
                   coordinates: .init(latitude: latitude, longitude: longitude),
                   conditions: .init(id: conditionsId, group: group, description: description, iconId: iconId),
                   main: .init(temperature: temperature, humidity: humidity, pressure: pressure),
                   wind: .init(speed: windSpeed, direction: direction))
}

