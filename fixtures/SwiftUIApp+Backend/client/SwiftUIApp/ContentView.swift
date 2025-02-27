//
//  ContentView.swift
//  SwiftUIApp
//
//  Created by Derian Córdoba on 26/2/25.
//

import SwiftUI
import SecureKeys

struct ContentView: View {
    
    // Initializer to print the keys (Testing purposes)
    init() {
        print("My super secret key: \(key(for: .superSecret))")
        print("Firebase API key: \(key(for: .firebaseApiKey))")
        print("Stripe API key: \(key(for: .stripeApiKey))")
    }
    
    var body: some View {
        VStack {
            Text("SwiftUI app + Backend fixture")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
