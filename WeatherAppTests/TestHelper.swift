//
//  TestHelper.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/14/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import Foundation
import XCTest
import Hamcrest
import PromiseKit
import Marshal
@testable import WeatherApp

func parseJsonFile(withName fileName: String) throws -> [String: Any] {
    let fileUrl = Bundle(for: WeatherAPI_Tests.self).url(forResource: fileName, withExtension: "json")!
    return try JSONParser.JSONObjectWithData(Data(contentsOf: fileUrl))
}

extension String: Error {}

func AssertNotNilAndUnwrap<T>(_ variable: T?, message: String = "Unexpected nil variable", file: StaticString = #file, line: UInt = #line) throws -> T {
    guard let variable = variable else {
        XCTFail(message, file: file, line: line)
        throw message
    }
    return variable
}

func applyMatcher<T>(_ matcher: Matcher<T>, label: String, toValue value: T, _ file: StaticString = #file, _ line: UInt = #line) {
    if case let .mismatch(mismatchDescription) = matcher.matches(value) {
        XCTFail(label + " " + describeMismatch(value, matcher.description, mismatchDescription), file: file, line: line)
    }
}

// MARK: Model comparators

func assert(_ actual: Weather.Conditions, _ expected: [String: Any], _ file: StaticString = #file, _ line: UInt = #line) throws {
    assertThat(expected.count, equalTo(4), file:file, line:line)

    assertThat(actual.id, equalTo(expected["id"] as! Int), file:file, line:line)
    assertThat(actual.description, equalTo(expected["description"] as! String), file:file, line:line)
    assertThat(actual.group, equalTo(expected["group"] as! String), file:file, line:line)
    assertThat(actual.iconId, equalTo(expected["iconId"] as! String), file:file, line:line)
}
func assert(_ actual: Weather.Main, _ expected: [String: Any], _ file: StaticString = #file, _ line: UInt = #line) throws {
    assertThat(expected.count, equalTo(3), file:file, line:line)

    assertThat(actual.temperature, equalTo(expected["temperature"] as! Double), file:file, line:line)
    assertThat(actual.pressure, equalTo(expected["pressure"] as! Double), file:file, line:line)
    assertThat(actual.humidity, equalTo(expected["humidity"] as! Double), file:file, line:line)
}
func assert(_ actual: Weather.Wind, _ expected: [String: Any], _ file: StaticString = #file, _ line: UInt = #line) throws {
    assertThat(expected.count, equalTo(2), file:file, line:line)

    assertThat(actual.speed, equalTo(expected["speed"] as! Double), file:file, line:line)
    assertThat(actual.direction, equalTo(expected["direction"] as! Double), file:file, line:line)
}

func assert(_ actual: Weather, _ expected: [String: Any], _ file: StaticString = #file, _ line: UInt = #line) throws {
    assertThat(expected.count, equalTo(6), file:file, line:line)

    assertThat(actual.cityName, equalTo(expected["cityName"] as! String), file:file, line:line)
    assertThat(actual.countryName, equalTo(expected["countryName"] as! String), file:file, line:line)
    if let coordinates = expected["coordinates"] as? [String: Double] {
        assertThat(actual.coordinates.latitude, equalTo(coordinates["latitude"]!), file:file, line:line)
        assertThat(actual.coordinates.longitude, equalTo(coordinates["longitude"]!), file:file, line:line)
    } else {
        XCTFail("No 'coordinates' or not a [String: Double]")
    }

    try assert(actual.conditions, expected["conditions"] as! [String: Any], file, line)
    try assert(actual.wind, expected["wind"] as! [String: Any], file, line)
    try assert(actual.main, expected["main"] as! [String: Any], file, line)
}

// MARK: Mocks

class TestsNetworkHelper: NetworkHelper {
    let testFileName: String
    let targetUrl: URL

    init(withFileName fileName: String, targetUrl: URL, apiKey: String) {
        testFileName = fileName
        var comp = URLComponents(url: targetUrl, resolvingAgainstBaseURL: false)!
        var queryItems: [URLQueryItem] = []
        if let items = comp.queryItems {
            queryItems = items
        }
        queryItems.append(URLQueryItem(name: "appid", value: apiKey))
        comp.queryItems = queryItems
        self.targetUrl = comp.url!
    }

    func fetchJson(from url: URL) -> Promise<JSONObject> {
        if url != targetUrl {
            return Promise(error: "URL should be '\(targetUrl)', but was '\(url)'")
        }
        return Promise { (callback, failure) in
            let data = try parseJsonFile(withName: testFileName)
            callback(data)
        }
    }
}
