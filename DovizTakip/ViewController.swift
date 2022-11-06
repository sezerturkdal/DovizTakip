//
//  ViewController.swift
//  DovizTakip
//
//  Created by Sezer on 6.11.2022.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    
    var spinner = UIActivityIndicatorView(style: .large)
    var loadingView: UIView = UIView()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        getData()
    }
    
    func getData(){
        var ref: DatabaseReference!
        ref = Database.database().reference()
        showActivityIndicator()
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
        hideActivityIndicator()
    }
    
    func showActivityIndicator() {
            self.loadingView = UIView()
            self.loadingView.frame = CGRect(x: 0.0, y: 0.0, width: 100.0, height: 100.0)
            self.loadingView.center = self.view.center
            self.loadingView.backgroundColor = UIColor.white
            self.loadingView.alpha = 0.7
            self.loadingView.clipsToBounds = true
            self.loadingView.layer.cornerRadius = 10

            self.spinner = UIActivityIndicatorView(style: .large)
            self.spinner.frame = CGRect(x: 0.0, y: 0.0, width: 80.0, height: 80.0)
            self.spinner.color = UIColor.blue
            self.spinner.center = CGPoint(x:self.loadingView.bounds.size.width / 2, y:self.loadingView.bounds.size.height / 2)

            self.loadingView.addSubview(self.spinner)
            self.view.addSubview(self.loadingView)
            self.spinner.startAnimating()
    }

    func hideActivityIndicator() {
            self.spinner.stopAnimating()
            self.loadingView.removeFromSuperview()
    }


}

