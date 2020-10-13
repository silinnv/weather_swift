//
//  WeatherTableViewCell.swift
//  wether_001
//
//  Created by Fredia Wiley on 9/19/20.
//  Copyright © 2020 Nikita Silin. All rights reserved.
//

import UIKit

class WeatherTableViewCell: UITableViewCell {
    @IBOutlet weak var temp: UILabel!
    @IBOutlet weak var tempMinLabrel: UILabel!
    @IBOutlet var weatherImageView: UIImageView!
    @IBOutlet weak var weakDayLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
}
