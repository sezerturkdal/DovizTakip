//
//  Currency.swift
//  DovizTakip
//
//  Created by Sezer on 6.11.2022.
//

import Foundation

class Currency{
    var BuyRate:String
    var Code:String
    var Id=Int()
    var Name:String
    var SellRate:String
    var Time:String
    
    init(buyRate:String, code:String, id:Int, name:String, sellRate:String, time:String){
        BuyRate = buyRate
        Code = code
        Id=id
        Name=name
        SellRate=sellRate
        Time=time
    }
}
