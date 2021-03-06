//
//  VendingMachine.swift
//  VendingMachine
//
//  Created by 심 승민 on 2017. 12. 14..
//  Copyright © 2017년 JK. All rights reserved.
//

import Foundation

// inventory를 Collection 프로토콜로 캡슐화.
class VendingMachine: Machine, Sequence {
    // Iterator.Element의 타입앨리아스
    typealias Element = Beverage
    typealias ProductType = Beverage
    private var stockManager: StockManager<VendingMachine, Beverage>!
    private var moneyManager: MoneyManager<VendingMachine>!
    let start: Int
    private var recentChanged: Beverage
    private var isManagerRemoved: Bool
    init() {
        self.start = 0
        self.recentChanged = Beverage()
        self.isManagerRemoved = false
        // 장부기록, 돈관리의 책임을 위임.
        self.stockManager = StockManager(self)
        self.moneyManager = MoneyManager(self)
    }
    // 자판기 내 음료수 인스턴스 저장.
    private var inventory: [Beverage] = [] {
        // 상태변화가 생길 때마다 장부 및 잔액을 업데이트.
        didSet(oldInventory) {
            // 음료수 단순 제거 시 (구입 + 관리 시 제거)
            let removed = isRemoved(oldInventory, inventory)
            // 음료수 구입 시
            let purchased = isPurchased(removed)
            // 재고를 넣을 때와 음료수를 빼먹을 때 둘 다 업데이트.
            stockManager.updateStock(recentChanged, isNewArrival: !removed)
            // manager가 제거한 음료수 개수는 업데이트 안 함.
            stockManager.recordPurchasedHistory(recentChanged, isPurchased: purchased)
            // 잔액은 음료수를 빼먹을 때만 업데이트. manager가 제거한 음료수 가격은 업데이트 안 함.
            moneyManager.updateBalance(recentChanged, isPurchased: purchased)
            isManagerRemoved = false
        }
    }

    private func isPurchased(_ isRemoved: Bool) -> Bool {
        return (isRemoved && !isManagerRemoved)
    }

    // 구입된 경우 true 반환.
    private func isRemoved(_ oldStock: [Beverage], _ currStock: [Beverage]) -> Bool {
        return oldStock.count > currStock.count
    }

    func makeIterator() -> ClassIteratorOf<Beverage> {
        return ClassIteratorOf(inventory)
    }

    var count: Int {
        return inventory.count
    }
    var last: Beverage? {
        return inventory.last
    }
}

extension VendingMachine {
    typealias MenuType = Menu
    // 선택 가능한 메뉴.
    enum Menu: EnumCollection, Purchasable {
        case strawberryMilk
        case bananaMilk
        case chocoMilk
        case coke
        case cider
        case fanta
        case top
        case cantata
        case georgia

        // 각 메뉴의 가격은 노출 가능.
        var price: Int {
            return generate().price
        }

        var productName: String {
            return generate().productName
        }

        // 각 메뉴별 Beverage 인스턴스 생성.
        fileprivate func generate() -> Beverage {
            var beverage = Beverage()
            switch self {
            case .strawberryMilk: beverage = StrawBerryMilk(self)
            case .bananaMilk: beverage = BananaMilk(self)
            case .chocoMilk: beverage = ChocoMilk(self)
            case .coke: beverage = CokeSoftDrink(self)
            case .cider: beverage = CiderSoftDrink(self)
            case .fanta: beverage = FantaSoftDrink(self)
            case .top: beverage = TopCoffee(self)
            case .cantata: beverage = CantataCoffee(self)
            case .georgia: beverage = GeorgiaCoffee(self)
            }
            return beverage
        }

    }
}

extension VendingMachine: Managable {
    // 모든 메뉴의 재고를 count개씩 자판기에 공급.
    func fullSupply(_ count: Int) {
        for menu in MenuType.allValues {
            supply(productType: menu, count)
        }
    }

    // 특정상품의 재고를 N개 공급.
    func supply(productType: MenuType, _ addCount: Stock) {
        for _ in 0..<addCount {
            // 인벤토리에 추가.
            self.recentChanged = productType.generate()
            inventory.append(recentChanged)
        }
    }

    // 특정상품의 재고를 N개 제거.
    func remove(productType: MenuType, _ addCount: Stock) {
        for _ in 0..<addCount {
            isManagerRemoved = true
            _ = self.pop(productType)
        }
    }

    // 시작이후 구매 상품 이력 반환.
    func showPurchasedList() -> [HistoryInfo] {
        return stockManager.showPurchasedHistory()
    }
}

extension VendingMachine: UserServable {
    // 주화 삽입.
    func insertMoney<MachineType>(_ money: MoneyManager<MachineType>.Unit) {
        guard let moneyUnit = money as? MoneyManager<VendingMachine>.Unit else { return }
        moneyManager.insert(money: moneyUnit)
    }

    // 구매가능한 음료 중 선택한 음료수를 반환.
    func popProduct(_ menu: MenuType) -> ProductType? {
        // 품절이 아닌 상품 중, 현재 금액으로 살 수 있는 메뉴 리스트를 받아옴.
        let affordableList = moneyManager.showAffordableList(from: stockManager.showSellingList())
        // 리스트에 선택한 상품이 있는 경우, 해당 음료수 반환. 없는 경우, nil 반환. (아무일도 일어나지 않음)
        guard affordableList.contains(menu) else { return nil }
        return pop(menu)
    }

    // 자판기 인벤토리에서 특정 메뉴의 음료수를 반환.
    private func pop(_ menu: MenuType) -> Beverage? {
        for (position, beverage) in inventory.enumerated() where menu == beverage.menuType {
            self.recentChanged = beverage
            return inventory.remove(at: position)
        }
        return nil
    }

    // 잔액을 확인.
    func showBalance() -> Balance {
        return moneyManager.balance
    }

    // 전체 상품 재고를 (사전으로 표현하는) 종류별로 반환.
    func checkTheStock() -> [MenuType : Stock] {
        return stockManager.showStockList()
    }

    func showAffordableProducts() -> [MenuType] {
        return moneyManager.showAffordableList(from: stockManager.showSellingList())
    }

    // 유통기한이 지난 재고 리스트 반환.
    func showExpiredProducts(on day: Date) -> [MenuType:Stock] {
        return stockManager.showExpiredList(on: day)
    }

    // 따뜻한 음료 리스트 리턴.
    func showHotProducts() -> [MenuType] {
        // 커피타입인 경우만 해당.
        return MenuType.allValues.filter {
            guard let coffee = $0.generate() as? Coffee else { return false }
            return coffee.isHot
        }
    }

}
