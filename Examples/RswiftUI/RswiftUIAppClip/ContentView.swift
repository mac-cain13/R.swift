//
//  ContentView.swift
//  RswiftUIAppClip
//
//  Created by Tom Lokhorst on 2020-09-15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, App Clip!")
            .padding()

        Image(uiImage: R.image.handIgnoreme()!)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 140)
            .border(Color.red)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
