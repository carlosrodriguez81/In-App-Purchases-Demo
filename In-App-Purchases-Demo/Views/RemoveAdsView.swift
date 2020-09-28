//
//  RemoveAdsView.swift
//  In-App-Purchases-Demo
//
//  Created by Carlos Rodriguez on 9/21/20.
//

import SwiftUI
import StoreKit

struct RemoveAdsView: View {
    @Environment(\.presentationMode) var presentationMode
    @State var isSelected = false
    @State var userIsFemale = Bool.random()
    @ObservedObject var productStore: ProductsStore
    var myProduct: SKProduct
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack {
                    Image(userIsFemale ? "Workout-amico" : "Pilates-amico")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: geometry.size.width)
                        .background(Color.orange)
                    HStack {
                        VStack(alignment: .leading, spacing: 5) {
                            Text("Go Premium").font(.title).fontWeight(.heavy)
                            Text("Premium features just for you").font(.headline)
                        }
                        Spacer()
                    }
                    .padding(.horizontal)
                    HStack {
                        PurchaseButtonView(product: myProduct, isSelected: $isSelected)
                    }
                    .padding()
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.accentColor, lineWidth: 2)
                    )
                    .padding(.vertical, 40)
                    .padding(.horizontal)
                    Text("Premium subscription is required to get access to all wallpapers. Regardless whether the subscription has free trial period or not it automatically renews with the price and duration given above unless it is canceled at least 24 hours before the end of the current period. Payment will be charged to your Apple ID account at the confirmation of purchase. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.")
                        .lineLimit(nil)
                        .font(.footnote)
                        .padding(.horizontal)
                    Spacer()
                    BuyButton(block: { self.purchaseProduct(skproduct: self.myProduct) }, product: self.myProduct)
                        .disabled(!isSelected)
                        .padding(.bottom)
                }
                //-->[begin] - headers buttons
                HStack {
                    cancelButton
                    Spacer()
                }
                .padding([.top, .leading])
                //-->[end]
            }
        }
    }
    //MARK: - Buttons
    private var cancelButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .font(.headline)
                .foregroundColor(Color("White"))
                .padding(10)
                .background(Color.primary)
                .clipShape(Circle())
        }
    }
    //MARK: - Actions
    func purchaseProduct(skproduct : SKProduct){
        print("did tap purchase product: \(skproduct.productIdentifier)")
        isSelected = true
        IAPManager.shared.purchaseProduct(product: skproduct, success: {
            self.isSelected = false
            ProductsStore.shared.handleUpdateStore()
            presentationMode.wrappedValue.dismiss()
            UserDefaults.standard.set(true, forKey: keyHideAds)
            productStore.hideAds = true
            print("Successful purchase!!")
        }) { (error) in
            self.isSelected = false
            ProductsStore.shared.handleUpdateStore()
            print("Error:", error as Any)
        }
    }
}

struct RemoveAdsView_Previews: PreviewProvider {
    static var previews: some View {
        RemoveAdsView(productStore: .init(), myProduct: .init())
    }
}
