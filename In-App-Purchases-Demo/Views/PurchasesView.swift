//
//  PurchasesView.swift
//  In-App-Purchases-Demo
//
//  Created by Carlos Rodriguez on 10/23/20.
//

import SwiftUI
import SwiftyStoreKit


///Products Store - key
let keyProduct_1 = "com.carprietoco.removeAds"
let keySharedSecret = "e943b3be7f6146ee943ec1dd0cf55515"

///UserDefaults - keys
let keyGender = "Gender"
let keyDismissAds = "keyDismissAds" // initial value is 'false'

class ObservableSettings: ObservableObject {
    @Published var userIsFemale: Bool = UserDefaults.standard.integer(forKey: keyGender) == 0 ? true : false
    @Published var removeAds: Bool = UserDefaults.standard.bool(forKey: keyDismissAds)
}

struct ButtonShape<S: Shape>: ViewModifier {
    var shape: S
    var foregroundColor: Color = .white
    var background: Color = Color.black.opacity(0.8)
    func body(content: Content) -> some View {
        content
            .font(Font.headline.weight(.semibold))
            .foregroundColor(foregroundColor)
            .padding(10)
            .background(background)
            .clipShape(shape)
    }
}

struct PurchasesView: View {
    @Environment(\.presentationMode) var presentationMode
    @EnvironmentObject var observableSettings: ObservableSettings
    @State var isSelected = false
    @State var title = ""
    @State var price = ""
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                VStack {
                    Image(observableSettings.userIsFemale ? "Workout-amico" : "Pilates-amico")
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
                    productButton
                        .padding([.top, .horizontal])
                    purchaseProductButton
                        .disabled(!isSelected)
                        .padding(.vertical, 30)
                    restorePurchasesButton
                        .padding(.bottom, 30)
                    Text("Premium subscription is required to get access to all wallpapers. Regardless whether the subscription has free trial period or not it automatically renews with the price and duration given above unless it is canceled at least 24 hours before the end of the current period. Payment will be charged to your Apple ID account at the confirmation of purchase. Your account will be charged for renewal within 24 hours prior to the end of the current period. You can manage and cancel your subscriptions by going to your account settings on the App Store after purchase. Any unused portion of a free trial period, if offered, will be forfeited when the user purchases a subscription to that publication, where applicable.")
                        .lineLimit(nil)
                        .font(.subheadline)
                        .padding([.bottom, .horizontal])
                }
                //-->[begin] - headers buttons
                HStack {
                    cancelButton
                    Spacer()
                }
                .padding([.top, .leading])
                //-->[end]
            }
        }.onAppear {
            SwiftyStoreKit.retrieveProductsInfo([keyProduct_1]) { result in
                if let product = result.retrievedProducts.first {
                    title = product.localizedTitle
                    price = product.localizedPrice
                }
            }
        }
    }
    //MARK: - Buttons
    private var cancelButton: some View {
        Button(action: {
            self.presentationMode.wrappedValue.dismiss()
        }) {
            Image(systemName: "xmark")
                .modifier(ButtonShape(shape: Circle(), foregroundColor: Color("White"), background: .primary))
        }
    }
    private var productButton: some View {
        HStack {
            Button {
                withAnimation {
                    isSelected.toggle()
                }
            } label: {
                Image(systemName: isSelected ? "largecircle.fill.circle" : "circle")
            }
            .disabled(observableSettings.removeAds)
            Text(title).bold()
            Spacer()
            Text("\(price)")
        }
        .foregroundColor(observableSettings.removeAds ? .secondary : .primary)
        .padding()
        .overlay(RoundedRectangle(cornerRadius: 12)
                    .stroke(observableSettings.removeAds ? Color.secondary : Color.accentColor, lineWidth: 2))
    }
    private var purchaseProductButton: some View {
        Button(action: {
            purchaseProduct()
        }) {
            HStack {
                Text(NSLocalizedString("continue", comment: ""))
                Image(systemName: "chevron.right")
            }
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal)
            .padding()
            .background(Capsule().fill(Color.accentColor))
        }
    }
    private var restorePurchasesButton: some View {
        Button(action: {
            restorePurchases()
        }) {
            Text("Restore Purchases").bold().foregroundColor(.primary)
        }
    }
    
    //MARK: - Actions
    func restorePurchases() {
        SwiftyStoreKit.restorePurchases(atomically: false) { results in
            if results.restoreFailedPurchases.count > 0 {
                print("Restore Failed: \(results.restoreFailedPurchases)")
            }
            else if results.restoredPurchases.count > 0 {
                for purchase in results.restoredPurchases {
                    // fetch content from your server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                }
                print("Restore Success: \(results.restoredPurchases)")
                observableSettings.removeAds = true
                UserDefaults.standard.set(true, forKey: keyDismissAds)
                self.presentationMode.wrappedValue.dismiss()
            }
            else {
                print("Nothing to Restore")
            }
        }
    }
    func purchaseProduct() {
        SwiftyStoreKit.purchaseProduct(keyProduct_1, quantity: 1, atomically: false) { result in
            switch result {
            case .success(let product):
                // fetch content from your server, then:
                if product.needsFinishTransaction {
                    SwiftyStoreKit.finishTransaction(product.transaction)
                    print("finishTransaction")
                }
                print("Purchase Success: \(product.productId)")
                observableSettings.removeAds = true
                UserDefaults.standard.set(true, forKey: keyDismissAds)
                self.presentationMode.wrappedValue.dismiss()
            case .error(let error):
                switch error.code {
                case .unknown: print("Unknown error. Please contact support")
                case .clientInvalid: print("Not allowed to make the payment")
                case .paymentCancelled: break
                case .paymentInvalid: print("The purchase identifier was invalid")
                case .paymentNotAllowed: print("The device is not allowed to make the payment")
                case .storeProductNotAvailable: print("The product is not available in the current storefront")
                case .cloudServicePermissionDenied: print("Access to cloud service information is not allowed")
                case .cloudServiceNetworkConnectionFailed: print("Could not connect to the network")
                case .cloudServiceRevoked: print("User has revoked permission to use this cloud service")
                default: print((error as NSError).localizedDescription)
                }
            }
        }
    }
}

struct PurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        PurchasesView()
    }
}
