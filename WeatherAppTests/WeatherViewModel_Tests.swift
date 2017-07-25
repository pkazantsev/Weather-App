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
}
