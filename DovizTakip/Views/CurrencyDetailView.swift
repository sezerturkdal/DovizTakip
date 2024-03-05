//
//  CurrencyDetailView.swift
//  DovizTakip
//
//  Created by Sezer on 23.02.2023.
//

import UIKit
import FirebaseDatabase
import SwiftChart
import Charts



class CurrencyDetailView: UIViewController {

    
    
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var lblSellRate: UILabel!
    @IBOutlet weak var lblBuyRate: UILabel!
    @IBOutlet weak var lblCode: UILabel!
    
    private var weeklyRates: [WeeklyModel] = []
    var selectedCurrency = SelectedCurrency()
    
    var currencyDates : [String] = []
    var currencyPrices : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let buyPrice = Double(selectedCurrency.BuyRate)
        let sellPrice = Double(selectedCurrency.SellRate)
        
        lblCode.text=selectedCurrency.Code
        lblBuyRate.text=String(format: "%.2f", buyPrice ?? 0) + " ₺"
        lblSellRate.text=String(format: "%.2f", sellPrice ?? 0) + " ₺"
        
        getWeeklyData()
    }
    
    func getNameOfDay(dt : String) -> String{
        let fullDateArr = dt.split(separator: "-" )
        var components = DateComponents()
        components.year = Int(fullDateArr[0])
        components.month = Int(fullDateArr[1])
        components.day = Int(fullDateArr[2])
        
        let calendar = Calendar.current
        let date = calendar.date(from: components)
        
        var currencyDate = ""
        
        if #available(iOS 15.0, *) {
            let fff = date?.formatted(date: .abbreviated, time: .omitted) //date?.formatted(Date.FormatStyle().weekday(.abbreviated))
            currencyDate = fff ?? ""
        }
        return currencyDate
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
            let values = value?.objectEnumerator()
           
          
            
            while let key = keys?.nextObject() {
                let price = value?.object(forKey: key)
                let singleData = WeeklyModel()
                singleData.CurrencyDate=key as! String;
                singleData.Price=price as! String;
                
                singleData.CurrencyDate = getNameOfDay(dt : singleData.CurrencyDate)
                   
                weeklyRates.append(singleData)
                print(singleData.CurrencyDate)
               // print("\(key)= \(value)")
            }
           // print(weeklyRates)
            let screen = UIScreen.main.bounds
            let screenWidth = screen.size.width
            let screenHeight = screen.size.height
            
            weeklyRates.sort { $0.CurrencyDate < $1.CurrencyDate }
            
            weeklyRates.forEach { item in
                let crr = String(item.CurrencyDate.dropLast(6))
                currencyDates.append(crr)
                currencyPrices.append(Double(item.Price) ?? 0)
            }
            
            let data: [ChartDataEntry] = [
                ChartDataEntry(x: 0.0, y: currencyPrices[0]),
                ChartDataEntry(x: 1.0, y: currencyPrices[1]),
                ChartDataEntry(x: 2.0, y: currencyPrices[2]),
                ChartDataEntry(x: 3.0, y: currencyPrices[3]),
                ChartDataEntry(x: 4.0, y: currencyPrices[4]),
                ChartDataEntry(x: 5.0, y: currencyPrices[5]),
                ChartDataEntry(x: 6.0, y: currencyPrices[6])
            ]
            
            // Grafik veri setini oluştur
            let dataSet = LineChartDataSet(entries: data, label: selectedCurrency.Code)
            dataSet.colors = [NSUIColor.blue] // Çizgi rengi
                    
            // Grafiği güncelle
            let data1 = LineChartData(dataSet: dataSet)
            lineChartView.data = data1
        
            // X eksenini ayarla
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: currencyDates)
            lineChartView.xAxis.granularity = 1
                    
            // Animasyon ekle
            lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        });
    }

}


