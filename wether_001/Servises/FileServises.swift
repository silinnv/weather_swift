//
//  FileServises.swift
//  wether_001
//
//  Created by Fredia Wiley on 10/7/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import Foundation

struct City: Codable {
    let id: Int
    let name: String
    let state: String
    let country: String
}

typealias FileComplition = ([City]?) -> Void

struct CityFileServises {
    
    private let fileName = "city"
    private let fileExtention = "txt"
    
    func loadCity(complition: FileComplition) {
        
        guard let cityListURL = Bundle.main.url(forResource: fileName, withExtension: fileExtention) else {
            print("Invalid URL")
            return
        }
        
        guard let data = try? Data(contentsOf: cityListURL) else {
            print("Get data error")
            complition(nil)
            return
        }
        
        let decoder = JSONDecoder()
        guard let cityList = try? decoder.decode([City].self, from: data) else {
            complition(nil)
            print("Decode data error")
            return
        }
        complition(cityList)
    }
}
