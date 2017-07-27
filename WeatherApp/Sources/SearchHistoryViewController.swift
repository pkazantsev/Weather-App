//
//  SearchHistoryViewController.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/26/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit

private let historyFileName = "search_history.plist"
private let historySizeLimit = 10

class SearchHistoryViewController: UITableViewController {

    private(set) var searchHistory: [UserLocation] = []

    var lastSearch: UserLocation? {
        return searchHistory.first
    }

    var onRowSelection: ((UserLocation) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        populateHistory()
    }

    func addSearchHistoryRow(_ location: UserLocation) {
        guard !searchHistory.contains(location) else {
            return
        }
        if searchHistory.count >= historySizeLimit {
            removeLastRow()
        }
        searchHistory.insert(location, at: 0)
        tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .bottom)
        saveHistory()
    }

    private func removeLastRow() {
        let indexPath = IndexPath(row: searchHistory.count - 1, section: 0)
        removeRow(at: indexPath)
    }

    private func removeRow(at indexPath: IndexPath) {
        tableView.beginUpdates()
        searchHistory.remove(at: indexPath.row)
        tableView.deleteRows(at: [indexPath], with: .top)
        tableView.endUpdates()
    }

    private func populateHistory() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let historyFileUrl = docs.appendingPathComponent(historyFileName)
        guard FileManager.default.fileExists(atPath: historyFileUrl.path) else { return }

        if let history = NSArray(contentsOf: historyFileUrl) as? Array<[String: Any]> {
            searchHistory = history.map { dict -> UserLocation in
                return UserLocation(cityName: dict["city_name"] as! String,
                                    countryName: dict["country_name"] as! String,
                                    countryCode: dict["country_code"] as! String,
                                    coordinates: Coordinates(latitude: dict["latitude"] as! Double,
                                                             longitude: dict["longitude"] as! Double))
            }
        }
    }
    private func saveHistory() {
        let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let historyFileUrl = docs.appendingPathComponent(historyFileName)

        if searchHistory.isEmpty {
            try? FileManager.default.removeItem(at: historyFileUrl)
        }

        let dataToSave = searchHistory.map { location -> [String: AnyObject] in
            return ["city_name": location.cityName as NSString,
                    "country_name": location.countryName as NSString,
                    "country_code": location.countryCode as NSString,
                    "latitude": location.coordinates.latitude as NSNumber,
                    "longitude": location.coordinates.longitude as NSNumber] as[ String: AnyObject]
        }

        let result = (dataToSave as NSArray).write(to: historyFileUrl, atomically: true)
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return searchHistory.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let location = searchHistory[indexPath.row]
        cell.textLabel?.text = "\(location.cityName), \(location.countryName)"

        return cell
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let location = searchHistory[indexPath.row]
        onRowSelection?(location)
        tableView.deselectRow(at: indexPath, animated: true)
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            removeRow(at: indexPath)
            saveHistory()
        }
    }

}
