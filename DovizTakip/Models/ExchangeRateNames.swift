//
//  ExchangeRateNames.swift
//  DovizTakip
//
//  Created by Sezer on 6.03.2024.
//

import Foundation

struct ExchangeRateNames {

    static func getByCode(_ code: String) -> String? {
        var exchangeRate = ""
        
        switch code {
        case "AUD":
            exchangeRate = "Avustralya Doları"
        case "CAD":
            exchangeRate = "Kanada Doları"
        case "CHF":
            exchangeRate = "İsviçre Frangı"
        case "DKK":
            exchangeRate = "Danimarka Kronu"
        case "EUR":
            exchangeRate = "Euro"
        case "GBP":
            exchangeRate = "İngiliz Sterlini"
        case "QAR":
            exchangeRate = "Katar Riyali"
        case "NOK":
            exchangeRate = "Norveç Kronu"
        case "SEK":
            exchangeRate = "İsveç Kronu"
        case "USD":
            exchangeRate = "Amerikan Doları"
        case "XAU":
            exchangeRate = "Gram Altın"
        default:
            exchangeRate = ""
        }
        return exchangeRate
    }
}
    
   
    
