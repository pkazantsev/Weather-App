//
//  MainViewModel.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/15/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit
import PromiseKit
import CoreLocation

enum WeatherSearchParameters {
    case byCityName(cityName: String)
    case byZipCode(zipCode: Int)
    case byCoordinates(latitude: Double, longitude: Double)
    case currentLocation
}

enum WeatherViewModelFetchError: Error {
    case countryCodeUnknown
    case userLocationUnawailable
}
enum LocationDetectionError: Error, CustomStringConvertible {
    case notEnoughData
    case locationAccessDenied
    case locationAccessRestricted
    case otherError(Error)

    var description: String {
        switch self {
        case .notEnoughData:
            return "Can't detect a city or country name."
        case .locationAccessDenied:
            return "Location access denied. You can enable it in Settings."
        case .locationAccessRestricted:
            return "Location detection is unavailable."
        case .otherError(_):
            return "Can't detect user's location."
        }
    }
}

struct UserLocation {
    let cityName: String
    let countryName: String
    let countryCode: String
    let coordinates: Coordinates
}

class UserLocationDetectionToken {
    fileprivate let locationDelegate: MainViewModelLocationDelegate
    fileprivate let locationManager: CLLocationManager

    fileprivate init(locationDelegate: MainViewModelLocationDelegate, locationManager: CLLocationManager) {
        self.locationDelegate = locationDelegate
        self.locationManager = locationManager
    }
}

struct MainViewModel {

    private let api: WeatherAPI

    /// Automatically detected user location
    var userLocation: UserLocation?

    /// Country set by user
    var countryCode: String?

    private var fetchCountryCode: String? {
        return countryCode ?? userLocation?.countryCode
    }

    init(api: WeatherAPI) {
        self.api = api
    }

    /// Detect user location.
    /// - parameters:
    ///   - locationDetectedCallback: Called when location is detected
    ///   - locationDetectionFailed: Called if there's a location detection error
    ///
    /// - returns: a token which you should keep until you get a location or an error.
    func detectUserLocation(locationDetectedCallback: @escaping (UserLocation) -> Void, locationDetectionFailed: @escaping (LocationDetectionError) -> Void) -> UserLocationDetectionToken {
        let locationDelegate = MainViewModelLocationDelegate(locationCallback: { location in
            locationDetectedCallback(location)
        }, failureCallback: { error in
            locationDetectionFailed(error)
        })
        let token = UserLocationDetectionToken(locationDelegate: locationDelegate, locationManager: CLLocationManager())
        token.locationManager.delegate = locationDelegate
        token.locationManager.requestLocation()

        return token
    }

    func weatherViewModel(for searchParams: WeatherSearchParameters) -> Promise<WeatherViewModel> {
        let fetchPromise: Promise<Weather>
        switch searchParams {
        case let .byCityName(cityName):
            if let countryCode = fetchCountryCode {
                fetchPromise = api.fetch(byCityName: cityName, countryCode: countryCode)
            } else {
                return Promise(error: WeatherViewModelFetchError.countryCodeUnknown)
            }
        case let .byZipCode(zipCode):
            if let countryCode = fetchCountryCode {
                fetchPromise = api.fetch(byZipCode: zipCode, countryCode: countryCode)
            } else {
                return Promise(error: WeatherViewModelFetchError.countryCodeUnknown)
            }
        case let .byCoordinates(latitude, longitude):
            fetchPromise = api.fetch(byLatitute: latitude, longitue: longitude)
        case .currentLocation:
            if let location = userLocation?.coordinates {
                fetchPromise = api.fetch(byLatitute: location.latitude, longitue: location.longitude)
            } else {
                return Promise(error: WeatherViewModelFetchError.userLocationUnawailable)
            }
        }
        return fetchPromise.then {
            return WeatherViewModel(api: self.api, weather: $0)
        }
    }

}

/// A CLLocationManagerDelegate implementation that requests user's coordinates,
/// then checks location details and calls a callback with UserLocation instance.
private class MainViewModelLocationDelegate: NSObject, CLLocationManagerDelegate {

    fileprivate let locationCallback: (UserLocation) -> Void
    fileprivate let failureCallback: (LocationDetectionError) -> Void

    private var geocoder = CLGeocoder()

    init(locationCallback: @escaping (UserLocation) -> Void, failureCallback: @escaping (LocationDetectionError) -> Void) {
        self.locationCallback = locationCallback
        self.failureCallback = failureCallback
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            fetchLocationDetails(for: location)
        }
    }
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .denied:
            dlog("Location Denied")
            failureCallback(LocationDetectionError.locationAccessDenied)
        case .restricted:
            dlog("Location Restricted")
            failureCallback(LocationDetectionError.locationAccessRestricted)
        case .notDetermined:
            dlog("Location Not Asked")
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            dlog("Location Allowed")
            manager.requestLocation()
        case .authorizedAlways:
            dlog("I Never Asked For This")
        }
    }
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        failureCallback(LocationDetectionError.otherError(error))
    }

    private func fetchLocationDetails(for loc: CLLocation) {
        geocoder.reverseGeocodeLocation(loc) { (placemark, error) in
            if let places = placemark, let place = places.first {
                guard let countryCode = place.isoCountryCode, let countryName = place.country, let cityName = place.locality else {
                    self.failureCallback(LocationDetectionError.notEnoughData)
                    return
                }

                let location = UserLocation(cityName: cityName, countryName: countryName, countryCode: countryCode, coordinates: Coordinates(latitude: loc.coordinate.latitude, longitude: loc.coordinate.longitude))
                self.locationCallback(location)
            }
            else if let err = error {
                self.failureCallback(LocationDetectionError.otherError(err))
            }
        }
    }
}

private let windDirectionsArray = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]

struct WeatherViewModel {

    private let api: WeatherAPI
    private let weather: Weather

    var temperature: String {
        return String(format: "%.0-1f°", weather.main.temperature)
    }
    var windSpeed: String {
        return String(format: "%.0-1f m/s", weather.wind.speed)
    }
    var windDirection: String {
        return WeatherViewModel.windDirectionCode(from: weather.wind.direction)
    }
    var location: String {
        return "\(weather.cityName), \(weather.countryName)"
    }
    var countryCode: String {
        return weather.countryName
    }

    init(api: WeatherAPI, weather: Weather) {
        self.api = api
        self.weather = weather
    }

    func loadConditionsImage(_ callback: @escaping (UIImage) -> Void) {
        api.loadConditionsImage(withName: weather.conditions.iconId).then {
            callback($0)
        }.recover { _ in
            callback(#imageLiteral(resourceName: "NoWeatherIcon"))
        }.always {}
    }

    static func windDirectionCode(from direction: Double) -> String {
        let directionIndex: Int
        if direction >= 348.75 {
            directionIndex = 0
        } else {
            directionIndex = Int((direction + 11.25) / 22.5)
            if directionIndex >= windDirectionsArray.count {
                return "UNK"
            }
        }
        return windDirectionsArray[directionIndex]
    }

}
