//
//  CurrencyDetailView.swift
//  DovizTakip
//
//  Created by Sezer on 23.02.2023.
//

import UIKit
import FirebaseDatabase

class CurrencyDetailView: UIViewController {

   
    @IBOutlet weak var lblSellRate: UILabel!
    @IBOutlet weak var lblBuyRate: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    
    private var weeklyRates: [WeeklyModel] = []
    var selectedCurrency = SelectedCurrency()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buyPrice = Double(selectedCurrency.BuyRate)
        let sellPrice = Double(selectedCurrency.SellRate)
        
        lblCode.text=selectedCurrency.Code
        lblBuyRate.text=String(format: "%.2f", buyPrice ?? 0) + " ₺"
        lblSellRate.text=String(format: "%.2f", sellPrice ?? 0) + " ₺"
        
        getWeeklyData()
    }
    
    func getWeeklyData(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        ref.child("WeeklyRates/"+selectedCurrency.Code).getData(completion:  { [self] error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            let value = snapshot?.value as? NSDictionary
          //  print(value)
            
            let keys = value?.keyEnumerator()
          
            

            while let key = keys?.nextObject() {
                let value = value?.object(forKey: key)
                let singleData = WeeklyModel()
                singleData.CurrencyDate=key as! String;
                singleData.Price=value as! String;
                   
                weeklyRates.append(singleData)
                print(singleData.CurrencyDate)
               // print("\(key)= \(value)")
            }
           // print(weeklyRates)
            
            
            /*let currencyArray = ["USD","EUR","CAD","GBP","AUD","CHF"]
            for currency in currencyArray{
                if let jsonResult = value?[currency] as? Dictionary<String, AnyObject> {
                    let singleData = RateDetail(
                        Code: jsonResult["Code"] as! String,
                        BuyRate: jsonResult["BuyRate"] as! String,
                        Name: jsonResult["Name"] as! String,
                        SellRate: jsonResult["SellRate"] as! String,
                        Flag: "")
                    self.weeklyRates.append(singleData)
                }
            }*/
        });
    }

}
