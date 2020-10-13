//
//  File.swift
//  wether_001
//
//  Created by Fredia Wiley on 9/18/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import Foundation

struct JSONWeather: Codable {
    var cod: String
    var list: [Weather]
}

struct Weather: Codable {
    private var date: Int
    private var main: MainWeather
    private var weather: [InfoWeather]
    private var wind: WindWeather
    
    var time: Date {
        return Date(timeIntervalSince1970: TimeInterval(date))
    }
    
    var tempFormat: String {
        let tempInt = Int(main.temperature)
        return String(format: "%+dº", tempInt)
    }
    
    var tempMinFormat: String {
        let tempInt = Int(main.temperatureMin)
        return String(format: "%+dº", tempInt)
    }
    
    var iconID: Int {
        return weather.first?.id ?? 0
    }
    
    var weatherDescription: String {
        return weather.first?.description.uppercased() ?? ""
    }
    
    enum CodingKeys: String, CodingKey {
        case date = "dt"
        
        case main
        case weather
        case wind
    }
    
}
