//
//  ViewController.swift
//  ExchangeRates
//
//  Created by Yoshua Elmaryono on 26/09/18.
//  Copyright © 2018 Yoshua Elmaryono. All rights reserved.
//

import UIKit

typealias ExchangeRate = (ticker: String, rate: String)
extension Double {
    
    func toString(decimal: Int = 9) -> String {
        let value = decimal < 0 ? 0 : decimal
        var string = String(format: "%.\(value)f", self)
        
        while string.last == "0" || string.last == "." {
            if string.last == "." { string = String(string.dropLast()); break}
            string = String(string.dropLast())
        }
        return string
    }
}

class ViewController: UIViewController {
    private weak var tableView: UITableView? = nil
    private weak var pickerView: UIPickerView? = nil
    
    private var currencies = ["IDR","USD","EUR","JPY"]
    private var exchangeRates: [ExchangeRate] = [(ticker: "XXX", rate: "100"), (ticker: "XXY", rate: "200")]
    
    private func getExchangeRates(for baseRate: String){
        let session = URLSession(configuration: .default)
        let url = URL(string: "https://api.exchangeratesapi.io/latest?base=\(baseRate)")!
        let dataTask = session.dataTask(with: url) { (data, resp, err) in
            if let unwrappedError = err {
                print("Error",unwrappedError.localizedDescription)
            }else if let unwrappedData = data {
                do {
                    let json = try JSONSerialization.jsonObject(with: unwrappedData, options: [])
                    guard let dict = json as? [String:Any] else { return }
                    guard let rates = dict["rates"] as? [String:Any] else { return }
                    
                    self.exchangeRates = rates.map { arg -> ExchangeRate in
                        let rate = arg.value as! Double
                        return (ticker: arg.key, rate: rate.toString())
                    }
                    DispatchQueue.main.async {
                        self.tableView?.reloadData()
                    }
                } catch {
                    print(error.localizedDescription)
                }
            }
        }
        
        dataTask.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        setupPicker()
        setupTableView()
        getExchangeRates(for: currencies[0])
    }
    private func setupPicker(){
        let currencyPicker = UIPickerView()
        currencyPicker.dataSource = self
        currencyPicker.delegate = self
        view.addSubview(currencyPicker)
        
        currencyPicker.backgroundColor = .cyan
        
        currencyPicker.translatesAutoresizingMaskIntoConstraints = false
        currencyPicker.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        currencyPicker.heightAnchor.constraint(lessThanOrEqualToConstant: 100).isActive = true
        currencyPicker.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        currencyPicker.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        
        self.pickerView = currencyPicker
    }
    private func setupTableView(){
        let tableView = UITableView()
        view.addSubview(tableView)
        
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 100).isActive = true
        tableView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        self.tableView = tableView
    }
}

extension ViewController: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return currencies.count
    }
}
extension ViewController: UIPickerViewDelegate {
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return currencies[row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        getExchangeRates(for: currencies[row])
    }
}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return exchangeRates.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: "User Cell")
        let index = indexPath.row
        let currency = exchangeRates[index]
        cell.textLabel?.text = "\(currency.ticker): \(currency.rate)"
        return cell
    }
}
extension ViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
}
