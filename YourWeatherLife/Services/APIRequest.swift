//
//  APIRequest.swift
//  YourDay
//
//  Created by David Barkman on 6/18/22.
//

import Foundation

struct APIRequest {
  static func getAPIRequest(url: URL) -> URLRequest {
    let apiKey = APISettings.fetchAPISettings().apiKey
    let secretKey = APISettings.fetchAPISettings().secretKey
    let signature = CryptoUtilities.signRequest(input: apiKey, secretKey: secretKey)
    var urlRequest = URLRequest(url: url)
    
    urlRequest.setValue(apiKey, forHTTPHeaderField: "apiKey")
    urlRequest.setValue(signature, forHTTPHeaderField: "signature")
    
    return urlRequest
  }
}
