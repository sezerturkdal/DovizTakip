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
        
       // getChart()
        getWeeklyData()
    }
    
    func getChart(){
        //lineChartView.noDataText = "Veri bulunamadı"
                
        // X ekseninin etiketlerini belirle (örneğin günler)
        let days = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
                
        // Y eksenindeki verileri belirle (örneğin döviz kuru değerleri)
        let values: [ChartDataEntry] = [
            ChartDataEntry(x: 0.0, y: 5.0),
            ChartDataEntry(x: 1.0, y: 8.0),
            ChartDataEntry(x: 2.0, y: 6.0),
            ChartDataEntry(x: 3.0, y: 10.0),
            ChartDataEntry(x: 4.0, y: 7.0),
            ChartDataEntry(x: 5.0, y: 9.0),
            ChartDataEntry(x: 6.0, y: 5.0)
        ]
                
        // Grafik veri setini oluştur
        let dataSet = LineChartDataSet(entries: values, label: "Döviz Kuru")
        dataSet.colors = [NSUIColor.blue] // Çizgi rengi
                
        // Grafiği güncelle
        let data = LineChartData(dataSet: dataSet)
        lineChartView.data = data
                
        // X eksenini ayarla
        lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: days)
        lineChartView.xAxis.granularity = 1
                
        // Animasyon ekle
        lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
    }
    
    func getNameOfDay(dt : String) -> String{
        let fullDateArr = dt.split(separator: "-" )
        var components = DateComponents()
        components.year = Int(fullDateArr[0])
        components.month = Int(fullDateArr[1])
        components.day = Int(fullDateArr[2])
        
        let calendar = Calendar.current
        let date = calendar.date(from: components)
        
        var nameOfDay = ""
        
        if #available(iOS 15.0, *) {
            let fff = date?.formatted(Date.FormatStyle().weekday(.abbreviated))
            print(fff)
            nameOfDay = fff ?? ""
        }
        return nameOfDay
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
                let value = value?.object(forKey: key)
                let singleData = WeeklyModel()
                singleData.CurrencyDate=key as! String;
                singleData.Price=value as! String;
                
                singleData.CurrencyDate = getNameOfDay(dt : singleData.CurrencyDate)
                   
                weeklyRates.append(singleData)
                print(singleData.CurrencyDate)
               // print("\(key)= \(value)")
            }
           // print(weeklyRates)
            let screen = UIScreen.main.bounds
            let screenWidth = screen.size.width
            let screenHeight = screen.size.height
            
            weeklyRates.forEach { item in
                currencyDates.append(item.CurrencyDate)
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
            let dataSet = LineChartDataSet(entries: data, label: "Döviz Kuru")
            dataSet.colors = [NSUIColor.blue] // Çizgi rengi
                    
            // Grafiği güncelle
            let data1 = LineChartData(dataSet: dataSet)
            lineChartView.data = data1
                    
            // X eksenini ayarla
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: currencyDates)
            lineChartView.xAxis.granularity = 1
                    
            // Animasyon ekle
            lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
            
            /*
            let chart = Chart(frame: CGRect(x: 20, y: 450, width: screenWidth-50, height: screenHeight/3))
            // Create a new series specifying x and y values
            //chart.backgroundColor = ChartColors.orangeColor()
            chart.axesColor = ChartColors.greenColor()
            chart.gridColor = ChartColors.darkGreenColor()
            chart.labelColor = ChartColors.redColor()
            /*
            let data = [
                (x: currencyDates[0], y: currencyPrices[0]),
                (x: currencyDates[1], y: currencyPrices[1]),
                (x: currencyDates[2], y: currencyPrices[2]),
                (x: currencyDates[3], y: currencyPrices[3]),
                (x: currencyDates[4], y: currencyPrices[4]),
                (x: currencyDates[5], y: currencyPrices[5]),
                (x: currencyDates[6], y: currencyPrices[6])
            ]*/
            
            let data = [
                (x: 0, y: currencyPrices[0]),
                (x: 1, y: currencyPrices[1]),
                (x: 2, y: currencyPrices[2]),
                (x: 3, y: currencyPrices[3]),
                (x: 4, y: currencyPrices[4]),
                (x: 5, y: currencyPrices[5]),
                (x: 6, y: currencyPrices[6])
            ]
        
            let series = ChartSeries(data: data)
            series.area = true
            
            chart.xLabelsSkipLast = false
            
            var minVal = (currencyPrices.min() ?? 5)
            var maxVal = (currencyPrices.max() ?? 5)
            
            chart.minY = minVal - (maxVal-minVal)
            chart.maxY = maxVal + (maxVal-minVal)
            
            print((currencyPrices.min() ?? 5))
            print((currencyPrices.max() ?? 5))
            print("min:\(currencyPrices[0])")
            // Use `xLabels` to add more labels, even if empty
           // chart.xLabels =  [0, 1, 2, 3]

            // Format the labels with a unit
           // chart.xLabelsFormatter = { String(Int(round($1))) + "h" }

            chart.add(series)
            view.addSubview(chart)
            */
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


