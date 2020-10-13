//
//  MainWeather.swift
//  wether_001
//
//  Created by Fredia Wiley on 10/13/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import Foundation

struct MainWeather: Codable {
    var temperature: Double
    var temperatureMin: Double
    var temperatureFeelsLike: Double
    
    enum CodingKeys: String, CodingKey {
        case temperature            = "temp"
        case temperatureMin         = "temp_min"
        case temperatureFeelsLike   = "feels_like"
    }
}
