//
//  ContentView.swift
//  IOS Chess
//
//  Created by Tenzin Gyaltso on 5/10/25.

//
//  ContentView.swift
//  IOS Chess
//
//  Created on 5/10/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ChessBoardView()
            .padding()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(UIColor.systemBackground))
            .edgesIgnoringSafeArea(.all)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
