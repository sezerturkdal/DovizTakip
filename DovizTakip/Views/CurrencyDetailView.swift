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

    @IBOutlet weak var nvgBar: UINavigationItem!
    @IBOutlet weak var lineChartView: LineChartView!
    @IBOutlet weak var lblSellRate: UILabel!
    @IBOutlet weak var lblBuyRate: UILabel!
    @IBOutlet weak var imgFlag: UIImageView!
    @IBOutlet weak var lblCode: UILabel!
    @IBOutlet weak var lblMaxPrice: UILabel!
    @IBOutlet weak var lblMinPrice: UILabel!
    @IBOutlet weak var vwMaxPrice: UIView!
    @IBOutlet weak var vwMinPrice: UIView!
    @IBOutlet weak var vwHeader: UIView!
    
    private var weeklyRates: [WeeklyModel] = []
    var selectedCurrency = SelectedCurrency()
    
    var currencyDates : [String] = []
    var currencyPrices : [Double] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
        
        let backButton = UIBarButtonItem()
        backButton.title = "Geri"
        navigationController?.navigationBar.topItem?.backBarButtonItem = backButton
        
        vwMaxPrice.layer.borderColor = UIColor.lightGray.cgColor
        vwMinPrice.layer.borderColor = UIColor.lightGray.cgColor
        
        // Gradient renklerini tanımlayın
                let startColor = UIColorFromHex("#a2c7db").cgColor
                let endColor = UIColorFromHex("#d3dbdb").cgColor
                
                // Gradient layer'ı oluşturun
                let gradientLayer = CAGradientLayer()
                gradientLayer.frame = vwHeader.bounds
                gradientLayer.colors = [startColor, endColor]
                
                // Gradient'ı ekrana ekleyin
        vwHeader.layer.insertSublayer(gradientLayer, at: 0)
        
        //nvgBar.title = selectedCurrency.Code
        let buyPrice = Double(selectedCurrency.BuyRate)
        let sellPrice = Double(selectedCurrency.SellRate)
        
        
        lblCode.text = ExchangeRateNames.getByCode(selectedCurrency.Code) // selectedCurrency.Name
        lblBuyRate.text = String(format: "%.2f", buyPrice ?? 0) + " ₺"
        lblSellRate.text = String(format: "%.2f", sellPrice ?? 0) + " ₺"
        imgFlag.image = UIImage(named: selectedCurrency.Flag)
        
        getWeeklyData()
    }
    
    func UIColorFromHex(_ hex: String) -> UIColor {
        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
        
        var rgb: UInt64 = 0
        
        Scanner(string: hexSanitized).scanHexInt64(&rgb)
        
        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0
        
        return UIColor(red: red, green: green, blue: blue, alpha: 1.0)
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
            currencyDate = date?.formatted(date: .abbreviated, time: .omitted) ?? ""
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
            
            let keys = value?.keyEnumerator()
           
            while let key = keys?.nextObject() {
                let price = value?.object(forKey: key)
                let singleData = WeeklyModel()
                singleData.CurrencyDate=key as! String;
                singleData.Price=price as! String;
                
                singleData.CurrencyDate = getNameOfDay(dt : singleData.CurrencyDate)
                   
                weeklyRates.append(singleData)
                print(singleData.CurrencyDate)
            }
            let screen = UIScreen.main.bounds
            let screenWidth = screen.size.width
            let screenHeight = screen.size.height
            
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MMM d, yyyy"

            let sortedCurrencyRates = weeklyRates.sorted {
                guard let date1 = dateFormatter.date(from: $0.CurrencyDate),
                      let date2 = dateFormatter.date(from: $1.CurrencyDate) else {
                          return false
                }
                return date1 < date2
            }
            weeklyRates = sortedCurrencyRates
            
            weeklyRates.forEach { item in
                let crr = String(item.CurrencyDate.dropLast(6))
                currencyDates.append(crr)
                currencyPrices.append(Double(item.Price) ?? 0)
            }
            
            if let maxPrice = currencyPrices.max() {
                lblMaxPrice.text = "\(String(format: "%.2f", maxPrice)) ₺"
            } else {
                lblMaxPrice.text = "0.00 ₺"
            }
            
            if let minPrice = currencyPrices.min() {
                lblMinPrice.text = "\(String(format: "%.2f", minPrice)) ₺"
            } else {
                lblMinPrice.text = "0.00 ₺"
            }
            
            if currencyPrices.count >= 7 {
                
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
                
                dataSet.fillAlpha = 0.2
                dataSet.lineWidth = 2
                dataSet.drawCircleHoleEnabled = true
                dataSet.drawCirclesEnabled = true
                dataSet.drawValuesEnabled = true
                dataSet.highlightColor = .blue
                dataSet.circleRadius = CGFloat(8.0)
                dataSet.lineCapType = .round
                dataSet.mode = .cubicBezier
                dataSet.drawFilledEnabled = true
                dataSet.fillColor = .blue
                dataSet.axisDependency = .right
                
                // Grafiği güncelle
                let data1 = LineChartData(dataSet: dataSet)
                lineChartView.data = data1
            }
            // X eksenini ayarla
            lineChartView.xAxis.valueFormatter = IndexAxisValueFormatter(values: currencyDates)
            lineChartView.xAxis.granularity = 1
            lineChartView.xAxis.labelTextColor = .blue
            lineChartView.xAxis.labelPosition = .bottom
                    
            // Animasyon ekle
            lineChartView.animate(xAxisDuration: 2.0, yAxisDuration: 2.0)
        });
    }

}


