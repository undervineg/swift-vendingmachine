//
//  Person.swift
//  VendingMachine
//
//  Created by yangpc on 2017. 11. 23..
//  Copyright © 2017년 JK. All rights reserved.
//

import Foundation

protocol EnableMode {
    mutating func makeMenu() -> (mode: VendingMachineMode, money: Int, menu: [Drink], inventory: [Drink:Count])
    mutating func action(option: Int, detail: Int) throws
}