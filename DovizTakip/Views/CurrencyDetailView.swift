//
//  CurrencyDetailView.swift
//  DovizTakip
//
//  Created by Sezer on 23.02.2023.
//

import UIKit

class CurrencyDetailView: UIViewController {

   
    @IBOutlet weak var lblCode: UILabel!
    var selectedCurrency = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        lblCode.text=selectedCurrency
    }

}
