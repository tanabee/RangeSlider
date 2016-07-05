//
//  ViewController.swift
//  RangeSlider
//
//  Created by 田邉　裕貴 on 2016/07/04.
//  Copyright © 2016年 example. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var rangeSlider: RangeSlider!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        rangeSlider.delegate = self
    }
}

extension ViewController: RangeSliderDelegate {
    func rangeSliderValueChanged(left: Float, right: Float) {
        print(left, right)
    }
}
