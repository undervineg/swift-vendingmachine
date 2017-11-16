//
//  StrawBerryMilk.swift
//  VendingMachine
//
//  Created by yangpc on 2017. 11. 16..
//  Copyright © 2017년 JK. All rights reserved.
//

import Foundation

class StrawBerryMilk: Milk {
    var ratioOfStrawBerrySyrup: String
    init?(productTpye: String,
          brand: String,
          weight: String,
          price: String,
          name: String,
          dateOfManufacture: String,
          calorie: String,
          farmCode: String,
          ingredients: [String],
          ratioOfStrawBerrySyrup: String) {
        self.ratioOfStrawBerrySyrup = ratioOfStrawBerrySyrup
        super.init(productTpye: productTpye,
                   brand: brand,
                   weight: weight,
                   price: price,
                   name: name,
                   dateOfManufacture: dateOfManufacture,
                   calorie: calorie,
                   farmCode: farmCode,
                   ingredients: ingredients)
    }
    
}