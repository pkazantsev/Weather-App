//
//  Weather.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/14/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import Foundation
import Marshal

struct Weather {
    /// General weather conditions
    struct Conditions {
        /// Conditions ID
        let id: Int
        let group: String
        let description: String
        let iconId: String
    }

    struct Main {
        let temperature: Double
        let humidity: Double
        let pressure: Double
    }

    struct Wind {
        let speed: Double
        let direction: Double
    }

    struct Coordinates {
        let latitude: Double
        let longitude: Double
    }

    let cityName: String
    let countryName: String
    let coordinates: Coordinates
    let conditions: Conditions

    let main: Main
    let wind: Wind
//    let rain: ...
//    let clouds: ...
//    let snow: ...
}

extension Weather: Unmarshaling {
    init(object: MarshaledObject) throws {
        let weatherArray: [Conditions] = try object.value(for: "weather")
        conditions = weatherArray[0]
        cityName = try object.value(for: "name")
        countryName = try object.value(for: "sys.country")
        main = try object.value(for: "main")
        wind = try object.value(for: "wind")
        coordinates = try object.value(for: "coord")
    }
}

extension Weather.Conditions: Unmarshaling {
    init(object: MarshaledObject) throws {
        id = try object.value(for: "id")
        group = try object.value(for: "main")
        description = try object.value(for: "description")
        iconId = try object.value(for: "icon")
    }
}

extension Weather.Main: Unmarshaling {
    init(object: MarshaledObject) throws {
        temperature = try object.value(for: "temp")
        humidity = try object.value(for: "humidity")
        pressure = try object.value(for: "pressure")
    }
}

extension Weather.Wind: Unmarshaling {
    init(object: MarshaledObject) throws {
        speed = try object.value(for: "speed")
        direction = try object.value(for: "deg")
    }
}

extension Weather.Coordinates: Unmarshaling {
    init(object: MarshaledObject) throws {
        latitude = try object.value(for: "lat")
        longitude = try object.value(for: "lon")
    }
}

