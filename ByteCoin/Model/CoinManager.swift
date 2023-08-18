//
//  CoinManager.swift
//  ByteCoin
//
//  Created by Angela Yu on 11/09/2019.
//  Copyright © 2019 The App Brewery. All rights reserved.
//

import Foundation

protocol CoinManagerDelegate {
    func didUpdateBitCoinRate(_ coinManager: CoinManager, price: String, currency: String)
    
    // _ coinManager: CoinManager is a reference. For Readability
    func didFailWithError(error: Error)
}

struct CoinManager {
    
    var delegate: CoinManagerDelegate?
    
    
    let baseURL = "https://rest.coinapi.io/v1/exchangerate/BTC"
    let apiKey = "APIKEY-0520432D-4CC8-465D-9B19-04C2D182E2B7"
    
    let currencyArray = ["AUD", "BRL", "CAD", "CNY", "EUR", "GBP", "HKD", "IDR", "ILS", "INR", "JPY", "MXN", "NOK", "NZD", "PLN", "RON", "RUB", "SEK", "SGD", "USD", "ZAR"]
    
    func getCoinPrice(for currency: String) {
        
        let urlString = "\(baseURL)/\(apiKey)/\(currency)"
        print(urlString)
        
        if let url = URL(string: urlString) {
            let session = URLSession(configuration: .default)
            let task = session.dataTask(with: url) { (data, response, error)
                in
                if error != nil {
                    self.delegate?.didFailWithError(error: error!)
                    print(error!)
                    return
                }
                if let safeData = data {
                    if let bitCoinRate = self.parseJSON(safeData){
                        let rateString = String(format: "%.2f", bitCoinRate)
                        self.delegate?.didUpdateBitCoinRate(self, price: rateString, currency: currency)
                    }
                    
                }
                
            }
            task.resume()
        }
        
    }
    
    func parseJSON(_ data: Data) -> Double? {
        let decoder = JSONDecoder()
        do {
            let decodedData = try decoder.decode(CoinData.self, from: data)
            let currentRate = decodedData.rate
            print(currentRate)
            return currentRate
        } catch {
            print(error)
            self.delegate?.didFailWithError(error: error)
            return nil
        }
        
    }
    
}
