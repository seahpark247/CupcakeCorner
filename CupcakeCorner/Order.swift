//
//  Order.swift
//  CupcakeCorner
//
//  Created by Seah Park on 4/6/25.
//

import Foundation

@Observable
class Order: Codable {
    enum CodingKeys: String, CodingKey {
        case _type = "type"
        case _quantity = "quantity"
        case _specialRequestEnabled = "specialRequestEnabled"
        case _extraFrosting = "extraFrosting"
        case _addSprinkles = "addSprinkles"
        case _name = "name"
        case _streetAddress = "streetAddress"
        case _city = "city"
        case _zip = "zip"
    }
    
    init() {
        loadAddressFromUserDefaults()
    }
    
    static let types = ["Vanilla", "Strawberry", "Chocolate", "Rainbow"]
    
    var type = 0
    var quantity = 3
    
    var specialRequestEnabled = false {
        didSet {
            if !specialRequestEnabled {
                extraFrosting = false
                addSprinkles = false
            }
        }
    }
    var extraFrosting = false
    var addSprinkles = false
    
    var name = "" {
        didSet { saveAddressToUserDefaults() }
    }
    var streetAddress = "" {
        didSet { saveAddressToUserDefaults() }
    }
    var city = "" {
        didSet { saveAddressToUserDefaults() }
    }
    var zip = "" {
        didSet { saveAddressToUserDefaults() }
    }

    var hasValidAddress: Bool {
        if [name, streetAddress, city, zip].contains(where: { $0.isBlank }) {
            return false
        }
        
        return true
    }
    
    var cost: Decimal {
        // $2 per cake
        var cost = Decimal(quantity) * 2
        
        // complicated cakes cost more
        cost += Decimal(type) / 2
        
        // $1/cake for extra frosting
        if extraFrosting {
            cost += Decimal(quantity)
        }
        
        // $0.50/cake for sprinkles
        if addSprinkles {
            cost += Decimal(quantity) / 2
        }
        
        return cost
    }
    
    // UserDefaults
    private let addressKey = "SavedAddress"
    
    struct Address: Codable {
        var name: String
        var streetAddress: String
        var city: String
        var zip: String
    }
    
    func saveAddressToUserDefaults() {
        let address = Address(name: name, streetAddress: streetAddress, city: city, zip: zip)
        if let data = try? JSONEncoder().encode(address) {
            UserDefaults.standard.set(data, forKey: addressKey)
        }
    }
    
    func loadAddressFromUserDefaults() {
        guard let data = UserDefaults.standard.data(forKey: addressKey),
              let address = try? JSONDecoder().decode(Address.self, from: data) else {
            return
        }
        
        name = address.name
        streetAddress = address.streetAddress
        city = address.city
        zip = address.zip
    }
    
}

extension String {
    var isBlank: Bool {
        return self.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
}
