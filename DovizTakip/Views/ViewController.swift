//
//  ViewController.swift
//  DovizTakip
//
//  Created by Sezer on 6.11.2022.
//

import UIKit
import FirebaseDatabase
import Network

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, NetworkCheckObserver {
    
   
    @IBOutlet weak var tblList: UITableView!
    var spinner = UIActivityIndicatorView(style: .large)
    var loadingView: UIView = UIView()

    private var allRates: [RateDetail] = []
    private let refreshCtrl = UIRefreshControl()
    private var chosenCurrenyCode = ""
    var networkCheck = NetworkCheck.sharedInstance()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tblList.delegate=self
        tblList.dataSource=self
        setupRefreshControl()
        getData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        networkCheck.addObserver(observer: self)
        if networkCheck.currentStatus == .unsatisfied{
            noInternetConnectionAlert()
        }
    }
    
    func setupRefreshControl() {
        if #available(iOS 10.0, *) {
            self.tblList.refreshControl = refreshCtrl
        } else {
            tblList.addSubview(refreshCtrl)
        }
        refreshCtrl.addTarget(self, action: #selector(self.getData), for: UIControl.Event.valueChanged)
    }
    
    @objc func getData(){
        allRates=[]
        tblList.reloadData()
        
        if networkCheck.currentStatus == .unsatisfied{
            noInternetConnectionAlert()
            refreshCtrl.endRefreshing()
            hideActivityIndicator()
            return;
        }
        var ref: DatabaseReference!
        ref = Database.database().reference()
        showActivityIndicator()
        ref.child("CurrentRates").getData(completion:  { [self] error, snapshot in
          guard error == nil else {
            print(error!.localizedDescription)
            return;
          }
            let value = snapshot?.value as? NSDictionary
            
            let currencyArray = ["USD","EUR","CAD","GBP","AUD","CHF"]
            for currency in currencyArray{
                if let jsonResult = value?[currency] as? Dictionary<String, AnyObject> {
                    let singleData = RateDetail(
                        Code: jsonResult["Code"] as! String,
                        BuyRate: jsonResult["BuyRate"] as! String,
                        Name: jsonResult["Name"] as! String,
                        SellRate: jsonResult["SellRate"] as! String,
                        Flag: "")
                    self.allRates.append(singleData)
                }
            }
            tblList.reloadData()
        });
        refreshCtrl.endRefreshing()
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
        
        let buyPrice = Double(rateData.BuyRate)
        
        cell.lbl_currencyName.text = rateData.Name
        cell.lbl_rate.text = String(format: "%.2f", buyPrice ?? 0) + " ₺"
        
        let flag  = UIImage(named: rateData.Name)
        
        let size = CGSize(width: 100, height: 100)
        cell.img_flag.image =  resizeImage(image: flag!, targetSize: size)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        chosenCurrenyCode = allRates[indexPath.row].Code 
        performSegue(withIdentifier: "toDetailsVC", sender: nil)
    }
    
    func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage {
        let size = image.size

        let widthRatio  = targetSize.width  / image.size.width
        let heightRatio = targetSize.height / image.size.height

        // Figure out what our orientation is, and use that to form the rectangle
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }

        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height)

        // Actually do the resizing to the rect using the ImageContext stuff
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()

        return newImage!
    }
    
    func noInternetConnectionAlert(){
        let alert=UIAlertController(title: "Warning", message: "No internet connection!", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
    }
    
    func statusDidChange(status: NWPath.Status) {
        if status == .satisfied{
            getData()
        }else{
            noInternetConnectionAlert()
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
            if segue.identifier=="toDetailsVC"
            {
                let destinationVC=segue.destination as!CurrencyDetailView
                destinationVC.selectedCurrency = chosenCurrenyCode
            }
    }

}

