//
//  ContentView.swift
//  In-App-Purchases-Demo
//
//  Created by Carlos Rodriguez on 9/21/20.
//

import SwiftUI

struct ContentView: View {
    @ObservedObject var productsStore: ProductsStore
    @EnvironmentObject var observableSettings: ObservableSettings
    @State var showStoreView = false
    
    var body: some View {
        VStack {
            //-->[begin] - title
            HStack {
                Text("In-App Purchases").font(.title).bold()
                Spacer()
                shoppingCartButton
            }
            .padding()
            //-->[end]
            VStack {
                Text("Implement In-App Purchases with SwiftUI.")
                    .padding()
                    .foregroundColor(Color("White"))
                    .background(Color.primary)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                if !observableSettings.removeAds {
                    Image("ImageAd")
                        .renderingMode(.original)
                        .resizable()
                        .scaledToFit()
                }
                Spacer()
            }
            .sheet(isPresented: $showStoreView, content: {
                //SwiftyStoreKit
                PurchasesView()
                //IAPManager ->
                //RemoveAdsView(productStore: self.productsStore, myProduct: productsStore.products.first!)
            })
            .edgesIgnoringSafeArea(.bottom)
            //-->[begin] - uncomment for test
            //.onAppear(perform: {
                //UserDefaults.standard.set(false, forKey: keyHideAds)
            //})
            //-->[end]
        }
    }
    //MARK: - Buttons
    private var shoppingCartButton: some View {
        Button(action: {
            showStoreView.toggle()
        }, label: {
            Image(systemName: "cart.fill")
                .font(.headline)
                .foregroundColor(Color("White"))
                .padding(10)
                .background(Color.primary)
                .clipShape(Circle())
        })
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(productsStore: ProductsStore.init())
    }
}
