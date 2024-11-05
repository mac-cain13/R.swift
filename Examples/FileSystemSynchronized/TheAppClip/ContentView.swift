//
//  ContentView.swift
//  TheAppClip
//
//  Created by Tom Lokhorst on 2020-09-15.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Hello, App Clip!")
            .padding()

        Image(R.image.handIgnoreme)
            .resizable()
            .aspectRatio(1, contentMode: .fit)
            .frame(width: 140)
            .border(Color(R.color.myColor))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
