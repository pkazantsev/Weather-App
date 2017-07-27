//
//  MainViewModel_Tests.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/17/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import Foundation
import XCTest
import Hamcrest
@testable import WeatherApp

class MainViewModel_Tests: XCTestCase {

    func testSearchParametersFromRequestLetters() {
        let request = "New York"
        if let params = MainViewModel.searchPatametersFromRequest(request) {
            if case .byZipCode(_) = params {
                XCTFail("'\(request)' is not a zip code")
            } else if case let .byCityName(cityName) = params {
                assertThat(cityName, equalTo("\(request)"))
            }
        } else {
            XCTFail("'\(request)' is not recognized as a serch parameter")
        }
    }
    func testSearchParametersFromRequestAlphanums() {
        let request = "11724,qa"
        if let params = MainViewModel.searchPatametersFromRequest(request) {
            if case .byZipCode(_) = params {
                XCTFail("'\(request)' is not a zip code")
            } else if case let .byCityName(cityName) = params {
                assertThat(cityName, equalTo("\(request)"))
            }
        } else {
            XCTFail("'\(request)' is not recognized as a serch parameter")
        }
    }
    func testSearchParametersFromRequestNumbers() {
        let request = "11724"
        if let params = MainViewModel.searchPatametersFromRequest(request) {
            if case let .byZipCode(zipCode) = params {
                assertThat(zipCode, equalTo(Int(request)!))
            } else if case .byCityName(_) = params {
                XCTFail("'\(request)' is not a city name code")
            }
        } else {
            XCTFail("'\(request)' is not recognized as a serch parameter")
        }
    }

}
