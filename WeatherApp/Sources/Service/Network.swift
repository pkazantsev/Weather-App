//
//  Network.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/13/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import Foundation
import PromiseKit
import Marshal

protocol NetworkHelper {

    func fetchJson(from url: URL) -> Promise<JSONObject>

}

class NetworkHelperImpl: NetworkHelper {
    func fetchJson(from url: URL) -> Promise<JSONObject> {
        return Promise { (callback, failure) in
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let data = data {
                    callback(data)
                } else if let error = error {
                    failure(error)
                }
            })
        }.then(execute: { data -> JSONObject in
            return try JSONParser.JSONObjectWithData(data)
        })
    }
}
