//
//  WeeklyModel.swift
//  DovizTakip
//
//  Created by Sezer on 24.02.2023.
//

import Foundation

class WeeklyModel: Decodable {
    var CurrencyDate: String
    var Price: String
    
    init() {
        CurrencyDate = "";
        Price = "";
        }
}
