//
//  ContentView.swift
//  SwiftUIApp
//
//  Created by Derian Córdoba on 26/2/25.
//

import SwiftUI
import SecureKeys

struct ContentView: View {
    var body: some View {
        VStack {
            Text("My super secret key: \(key(for: .superSecret))")
            
            Text("Firebase API key: \(key(for: .firebaseApiKey))")
            
            Text("Stripe API key: \(key(for: .stripeApiKey))")
        }
        .padding()
    }
}

#Preview {
    ContentView()
}
