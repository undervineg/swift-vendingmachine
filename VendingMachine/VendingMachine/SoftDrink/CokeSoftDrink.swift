//
//  CokeSoftDrink.swift
//  VendingMachine
//
//  Created by 심 승민 on 2017. 12. 12..
//  Copyright © 2017년 JK. All rights reserved.
//

import Foundation

class CokeSoftDrink: SoftDrink {
    private let ingredients: String
    override init(_ brand: String, _ volume: Int, _ price: Int, _ productName: String, _ manufacturedDate: Date, _ expirationDate: Date, _ calories: Int, carbonContent: Int) {
        self.ingredients = "합성착향료(콜라향)"
        super.init(brand, volume, price, productName, manufacturedDate, expirationDate, calories, carbonContent: carbonContent)
    }
    override var description: String {
        return "코카콜라(" + String.init(describing: type(of: self)) + ") - " + super.description
    }
}
