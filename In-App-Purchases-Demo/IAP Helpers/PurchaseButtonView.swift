//
//  PurchaseButtonView.swift
//  In-App-Purchases-Demo
//
//  Created by Carlos Rodriguez on 9/24/20.
//

import Foundation
import SwiftUI
import StoreKit

struct PurchaseButtonView: View {
    var product: SKProduct
    @Binding var isSelected: Bool
    var body: some View {
        HStack {
            Button {
                withAnimation {
                    isSelected.toggle()
                }
            } label: {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
            }
            Text(product.localizedTitle).bold()
            Spacer()
            Text("\(product.localizedPrice)")
        }
    }
}

struct BuyButton: View {
    var block: SuccessBlock!
    var product: SKProduct!
    var body: some View {
        Button(action: {
            self.block()
        }) {
            HStack {
                Text("Continue")
                Image(systemName: "chevron.right")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding()
            .background(Capsule().fill(Color.accentColor))
        }
    }
}
