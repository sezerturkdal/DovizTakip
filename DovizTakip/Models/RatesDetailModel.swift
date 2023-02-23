//
//  RatesDetailModel.swift
//  DovizTakip
//
//  Created by Sezer on 9.11.2022.
//

import Foundation

struct RatesDetailModel: Decodable {
    let base: String
    var date: String
    var rates: [RateDetail]
}

struct RateDetail: Decodable {
    let Code: String
    let BuyRate: String
    let Name: String
    let SellRate: String
    let Flag: String
}

class SelectedCurrency: Decodable {
    var Code: String
    var BuyRate: String
    var Name: String
    var SellRate: String
    var Flag: String
    
    init() {
        Code = "";
        BuyRate="";
        Name="";
        SellRate="";
        Flag="";
        }
}

