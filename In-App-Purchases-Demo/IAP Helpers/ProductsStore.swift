//
//  ProductStore.swift
//  In-App-Purchases-Demo
//
//  Created by Carlos Rodriguez on 9/24/20.
//

import SwiftUI
import StoreKit

class ProductsStore: ObservableObject {
    @Published var hideAds: Bool = UserDefaults.standard.bool(forKey: keyHideAds)
    
    static let shared = ProductsStore()
    
    @Published var products: [SKProduct] = []
    @Published var anyString = "123" // little trick to force reload ContentView from PurchaseView by just changing any Published value
    
    func handleUpdateStore(){
        anyString = UUID().uuidString
    }
    
    func initializeProducts(){
        IAPManager.shared.startWith(arrayOfIds: [product_1, subscription_1], sharedSecret: shared_secret) { products in
            self.products = products
        }
    }
}
