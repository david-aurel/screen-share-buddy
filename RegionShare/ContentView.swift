//
//  ContentView.swift
//  RegionShare
//
//  Created by David on 30.03.23.
//

import SwiftUI

struct ContentView: View {
    @State var isUnauthorized = true

    // @StateObject let screenRecorder = ScreenRecorder()

    var body: some View {
        if isUnauthorized {
            VStack(spacing: 0) {
                Text("⛔️🙈")
                    .font(.largeTitle)
                    .padding(.top)
                Text("No screen recording permission")
                    .font(.largeTitle)
                    .multilineTextAlignment(.center)
                Text("Open System Settings and go to Privacy & Security > Screen Recording to grant permission.")
                    .font(.title2)
                    .multilineTextAlignment(.center)
                    .padding(.top, 8)
            }
            .frame(maxWidth: 800)
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
