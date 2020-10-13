//
//  CityData+CoreDataProperties.swift
//  wether_001
//
//  Created by Fredia Wiley on 10/13/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//
//

import Foundation
import CoreData


extension CityData {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CityData> {
        return NSFetchRequest<CityData>(entityName: "CityData")
    }

    @NSManaged public var country: String?
    @NSManaged public var id: Int32
    @NSManaged public var isFavorite: Bool
    @NSManaged public var name: String

}
