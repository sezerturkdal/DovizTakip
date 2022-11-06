//
//  ViewController.swift
//  DovizTakip
//
//  Created by Sezer on 6.11.2022.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
    }
    
    func getData(){
        var ref: DatabaseReference!
        ref = Database.database().reference()

        ref.child("CurrentRates").getData(completion:  { [self] error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            
            let value = snapshot?.value as? NSDictionary
        
            if let jsonResult = value?["USD"] as? Dictionary<String, AnyObject> {
                print(jsonResult)
            }
            if let jsonResult = value?["EUR"] as? Dictionary<String, AnyObject> {
                print(jsonResult["BuyRate"])
            }
            
        });
    }


}

