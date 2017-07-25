//
//  Network.swift
//  WeatherApp
//
//  Created by Pavel Kazantsev on 7/13/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import UIKit
import PromiseKit
import Marshal

protocol NetworkHelper {

    func fetchJson(from url: URL) -> Promise<JSONObject>
    func loadImage(from url: URL) -> Promise<UIImage>

}

enum NetworkHelperError: Error, CustomStringConvertible {
    case imageNotLoaded(Error?)
    case imageFileIsCorrupted

    var description: String {
        switch self {
        case .imageNotLoaded(let error):
            return "Image not loaded: \(error ?? GenericError("Unknown error"))"
        case .imageFileIsCorrupted:
            return "Image file is corrupted"
        }
    }
}

class NetworkHelperImpl: NetworkHelper {

    func fetchJson(from url: URL) -> Promise<JSONObject> {
        dlog("Loading from '\(url)'")
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        return Promise { (callback, failure) in
            URLSession.shared.dataTask(with: url, completionHandler: { (data, response, error) in
                if let data = data {
                    callback(data)
                } else if let error = error {
                    failure(error)
                }
            }).resume()
        }.always {
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
        }.then(execute: { data -> JSONObject in
            return try JSONParser.JSONObjectWithData(data)
        })
    }

    func loadImage(from url: URL) -> Promise<UIImage> {
        return Promise { (callback, failure) in
            URLSession.shared.downloadTask(with: url, completionHandler: { (fileUrl, resp, error) in
                guard let imageFileUrl = fileUrl else {
                    failure(NetworkHelperError.imageNotLoaded(error))
                    return
                }
                do {
                    let fileHandle = try FileHandle(forReadingFrom: imageFileUrl)
                    defer {
                        fileHandle.closeFile()
                    }

                    let data = fileHandle.readDataToEndOfFile()
                    callback(data)
                } catch {
                    failure(NetworkHelperError.imageNotLoaded(error))
                }
            }).resume()
        }.then(execute: { (data: Data) -> UIImage in
            if let image = UIImage(data: data) {
                return image
            } else {
                throw NetworkHelperError.imageFileIsCorrupted
            }
        })
    }
}
