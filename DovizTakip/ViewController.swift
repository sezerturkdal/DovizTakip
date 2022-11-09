//
//  ViewController.swift
//  DovizTakip
//
//  Created by Sezer on 6.11.2022.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tblList: UITableView!
    var spinner = UIActivityIndicatorView(style: .large)
    var loadingView: UIView = UIView()
    

    private var allRates: [RateDetail] = []
    private let refreshCtrl = UIRefreshControl()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblList.delegate=self
        tblList.dataSource=self
        setupRefreshControl()
        getData()
    }
    
    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            tblList.refreshControl = refreshCtrl
        } else {
            tblList.addSubview(refreshCtrl)
        }
        refreshCtrl.addTarget(self, action: #selector(getData), for: .valueChanged)
    }
    
    @objc func getData(){
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
                let singleData = RateDetail(
                    Code: jsonResult["Code"] as! String,
                    BuyRate: jsonResult["BuyRate"] as! String,
                    Name: jsonResult["Name"] as! String,
                    SellRate: jsonResult["SellRate"] as! String,
                    Flag: "")
                self.allRates.append(singleData)
            }
            if let jsonResult = value?["EUR"] as? Dictionary<String, AnyObject> {
                let singleData = RateDetail(
                    Code: jsonResult["Code"] as! String,
                    BuyRate: jsonResult["BuyRate"] as! String,
                    Name: jsonResult["Name"] as! String,
                    SellRate: jsonResult["SellRate"] as! String,
                    Flag: "")
                self.allRates.append(singleData)
            }
            tblList.reloadData()
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

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.allRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cellRate") as? RateCell else { return UITableViewCell() }
        if(allRates.isEmpty){
            return cell
        }
        let rateData = allRates[indexPath.row]
        cell.lbl_currencyName.text = rateData.Name
        cell.lbl_rate.text = String(rateData.SellRate)
        cell.img_flag.image = UIImage(named: "US")

        // UIImage(named: "\(rateData.Flag.lowercased())")
        return cell
        }

}

