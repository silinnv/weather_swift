//
//  CityViewController.swift
//  wether_001
//
//  Created by Fredia Wiley on 10/6/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import UIKit
import CoreData

class CityViewController: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var tableView: UITableView!
    
    
    // MARK: - Properties
    lazy var coreDataStack = CoreDataStack(modelName: "WeatherModel")
    var cities: [CityData] = []
    var filterCities: [CityData] = []
    
    let cityFileServises = CityFileServises()
    weak var delegate: DataDelegate?
    var searchController = UISearchController(searchResultsController: nil)
    
    private var city: String? {
        get { return UserDefaults.standard.string(forKey: UDKeys.cityName.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UDKeys.cityName.rawValue) }
    }
    private var cityID: Int? {
        get { return UserDefaults.standard.integer(forKey: UDKeys.cityID.rawValue) }
        set { UserDefaults.standard.set(newValue, forKey: UDKeys.cityID.rawValue) }
    }
    
    
    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
                
        configureTableView()
        loadFavoriteCities()
    }
    
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.tableHeaderView = searchController.searchBar
        
        searchController.searchResultsUpdater = self
        searchController.searchBar.sizeToFit()
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search City"
        searchController.searchBar.barStyle = .black
        searchController.searchBar.searchTextField.textColor = .white
        
        definesPresentationContext = true
    }
    
    private func loadFavoriteCities() {
        if isEmptyCoreData() {
            DispatchQueue.global(qos: .utility).async {
                self.parseCity()
            }
            return
        }
        
        let cityFavoriteFetch: NSFetchRequest<CityData> = CityData.fetchRequest()
        cityFavoriteFetch.predicate = NSPredicate(format: "%K == true", #keyPath(CityData.isFavorite))
        
        DispatchQueue.global(qos: .utility).async {
            do {
                let result = try self.coreDataStack.managedContex.fetch(cityFavoriteFetch)
                self.cities = result
                
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                }
            } catch let error as NSError {
                print("Fetch error: \(error) description: \(error.userInfo)")
            }
        }
    }
    
    private func isEmptyCoreData() -> Bool {
        let cityFetch: NSFetchRequest<CityData> = CityData.fetchRequest()
        cityFetch.fetchLimit = 1
        
        do {
            let results = try coreDataStack.managedContex.fetch(cityFetch)
            if results.isEmpty {
                return true
            }
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
        return false
    }
    
    private func parseCity() {
        self.cityFileServises.loadCity { cities in
            
            guard let cities = cities else {
                return
            }
            
            for city in cities {
                let cityData = CityData(context: self.coreDataStack.managedContex)
                
                cityData.name = city.name
                cityData.id = Int32(city.id)
                cityData.country = city.country
                cityData.isFavorite = false
                
                self.cities.append(cityData)
            }
            
            self.coreDataStack.saveContext()
        }
    }
    
}

// MARK: - UITableViewDelegate
extension CityViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let city: CityData
            
        if isFiltering {
            city = filterCities[indexPath.row]
        } else {
            city = cities[indexPath.row]
        }
        
        self.searchController.isActive = false
        city.isFavorite = true
        coreDataStack.saveContext()
        
        let weatherServises = WeatherServises.shared
        DispatchQueue.global(qos: .userInitiated).async {
            weatherServises.loadWeatherData(cityID: Int(city.id)) { weathers in
                guard let weathers = weathers else {
                    return
                }
                self.city = city.name
                self.cityID = Int(city.id)
                self.delegate?.updateViewController(city: city.name, weathers: weathers)
                
                DispatchQueue.main.async {
                    self.searchController.dismiss(animated: true, completion: nil)
                    self.dismiss(animated: true, completion: nil)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
}

// MARK: - UITableViewDataSource
extension CityViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filterCities.count
        }
        return cities.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CityCell") as? CityTableViewCell else {
            return UITableViewCell()
        }
        
        let city: CityData
            
        if isFiltering {
            city = filterCities[indexPath.row]
        } else {
            city = cities[indexPath.row]
        }
        
        cell.cityLabel.text = city.name
        cell.countuLabel.text = city.country
        if city.isFavorite {
            cell.favoriteImageView.image = UIImage(systemName: "star.fill")
        } else {
            cell.favoriteImageView.image = nil
        }
        return cell
    }
    
}
// MARK: - UISearchResultsUpdating
extension CityViewController: UISearchResultsUpdating {
    
    private var isSearchBarEmpty: Bool {
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    private var isFiltering: Bool {
      return searchController.isActive && !isSearchBarEmpty
    }
    
    private func filterContentForSearchText(_ searchTest: String) {
        let cityFilterFetch: NSFetchRequest<CityData> = CityData.fetchRequest()
        
        cityFilterFetch.fetchLimit = 200
        cityFilterFetch.predicate = NSPredicate(format: "%K BEGINSWITH %@", #keyPath(CityData.name), searchTest)
        
        do {
            let results = try coreDataStack.managedContex.fetch(cityFilterFetch)
            filterCities = results
            tableView.reloadData()
        } catch let error as NSError {
            print("Fetch error: \(error) description: \(error.userInfo)")
        }
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchBar = searchController.searchBar
        filterContentForSearchText(searchBar.text!)
    }
}
