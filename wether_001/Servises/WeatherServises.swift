//
//  WeatherClient.swift
//  wether_001
//
//  Created by Fredia Wiley on 9/17/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import Foundation

typealias WeatherComplition = ([Weather]?) -> Void

struct WeatherServises {

    static var shared = WeatherServises()
    private init() {}
    
    private let apiKey = "*** YOUR KEY FROM api.openweathermap.org ***"
    
    func loadWeatherData(for city: String, complition: WeatherComplition? = nil) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?q=\(city)&appid=\(apiKey)&units=metric"
        loadData(urlString: urlString, complition: complition)
    }
    
    func loadWeatherData(cityID: Int, complition: WeatherComplition? = nil) {
        let urlString = "https://api.openweathermap.org/data/2.5/forecast?id=\(cityID)&appid=\(apiKey)&units=metric"
        loadData(urlString: urlString, complition: complition)
    }
    
    private func loadData(urlString: String, complition: WeatherComplition? = nil) {
        
        guard let url = URL(string: urlString), let data = try? Data(contentsOf: url) else {
            complition?(nil)
            return
        }
        
        let decoder = JSONDecoder()
        guard let weatherJSON = try? decoder.decode(JSONWeather.self, from: data) else {
            complition?(nil)
            print("Error load data")
            return
        }
        complition?(weatherJSON.list)
    }
}
