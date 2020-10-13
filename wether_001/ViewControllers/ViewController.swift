//
//  ViewController.swift
//  wether_001
//
//  Created by Fredia Wiley on 9/17/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import UIKit

protocol DataDelegate: class {
    func updateViewController(city: String, weathers: [Weather])
}

enum UDKeys: String {
    case cityName = "City"
    case cityID = "CityID"
}

class ViewController: UIViewController, DataDelegate {
    
    // MARK: - Outlets
    @IBOutlet weak var currentCityLabel: UILabel!
    @IBOutlet weak var currentTempLabel: UILabel!
    @IBOutlet weak var weatherImageView: UIImageView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var descriptionWeatherLabel: UILabel!
    @IBOutlet weak var selectCityButton: UIButton!
    
    
    // MARK: - Properties
    private let weatherServises = WeatherServises.shared
    private var weathers: [Weather] = []
    private var cityName: String? {
        get { return UserDefaults.standard.string(forKey: UDKeys.cityName.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UDKeys.cityName.rawValue) }
    }
    private var cityID: Int? {
        get { return UserDefaults.standard.integer(forKey: UDKeys.cityID.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UDKeys.cityID.rawValue) }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle { .lightContent }
    
    
    // MARK: - Live cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTableView()
        configureViewController()
        loadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        if self.cityName == nil {
            self.showCityListViewController()
        }
    }
    
    private func configureTableView() {
        self.tableView.delegate = self
        self.tableView.dataSource = self
    }
    
    private func configureViewController() {
        selectCityButton.layer.cornerRadius = selectCityButton.bounds.height / 2
    }
    
    private func loadData() {
        guard let city = self.cityName, let cityID = self.cityID else {
            self.resetData()
            return
        }
        
        weatherServises.loadWeatherData(cityID: cityID) { weather in
            guard let weather = weather else {
                self.resetData()
                return
            }
            self.updateViewController(city: city, weathers: weather)
        }
    }
    
    
    // MARK: - Data
    func updateViewController(city: String, weathers: [Weather]) {
        self.weathers = weathers
        
        guard let currentWeather = weathers.first else {
            return
        }
        
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.currentCityLabel.text = city
            self.currentTempLabel.text = currentWeather.tempFormat
            self.weatherImageView.image = self.getIcon(for: currentWeather)
            self.descriptionWeatherLabel.text = currentWeather.weatherDescription.capitalized
        }
    }
    
    func resetData() {
        DispatchQueue.main.async {
            self.currentCityLabel.text = ""
            self.currentTempLabel.text = ""
            self.weatherImageView.image = nil
            self.descriptionWeatherLabel.text = "Problems with the Internet"
            self.weathers = []
            self.tableView.reloadData()
        }
    }
        
    
    // MARK: - Action
    @IBAction func selectCityButtonTapped(_ sender: UIButton) {
        showCityListViewController()
    }
    
    private func showCityListViewController() {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        guard let nextVC = storyboard.instantiateViewController(identifier: "CityViewController") as? CityViewController else {
            return
        }
        
        nextVC.delegate = self
        show(nextVC, sender: nil)
    }
    
}


//MARK: - UITableViewDelegate, UITableViewDataSource
extension ViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return weathers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as? WeatherTableViewCell else {
            return UITableViewCell()
        }
        let weather = self.weathers[indexPath.row]
        let date = weather.time
        let hour = Calendar.current.component(.hour, from: date)
        
        cell.temp.text = weather.tempFormat
        cell.tempMinLabrel.text = weather.tempMinFormat
        cell.weatherImageView.image = getIcon(for: weather)
        cell.weakDayLabel.text = getWeakDay(for: date)
        cell.timeLabel.text = "\(hour):00"
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    
    private func getIcon(for weather: Weather?) -> UIImage? {
        guard let weather = weather else {
            return nil
        }
        
        let iconID = weather.iconID
        
        var dayInterval: String {
            let hour = Calendar.current.component(.hour, from: weather.time)
            if hour > 7 && hour < 21 {
                return "sun"
            } else {
                return "moon"
            }
        }
        
        var imageName: String
        
        switch iconID {
        case 200...202, 230...232:
            imageName = "cloud.bolt.rain"
        case 210...212, 221:
            imageName = "cloud.\(dayInterval).bolt"
        case 300...302:
            imageName = "cloud.drizzle"
        case 310...314:
            imageName = "cloud.rain"
        case 500...501:
            imageName = "cloud.\(dayInterval).rain"
        case 502...504, 520...522:
            imageName = "cloud.heavyrain"
        case 511:
            imageName = "cloud.sleet"
        case 600...699:
            imageName = "cloud.snow"
        case 700...799:
            imageName = "wind"
        case 800: do {
            if dayInterval == "sun" {
                imageName = "sun.max"
            } else {
                imageName = "moon.stars"
            }
        }
        case 801...804:
            imageName = "cloud.\(dayInterval)"
        default:
            imageName = ""
        }
        return UIImage(systemName: imageName)
    }
    
    private func getWeakDay(for date: Date) -> String {
        let calenar = Calendar.current
        
        if calenar.isDateInToday(date) {
            return "Today"
        }
        else if calenar.isDateInTomorrow(date) {
            return "Tommorow"
        }
        else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            let weakDay = formatter.string(from: date).capitalized
            return weakDay
        }
    }
}
