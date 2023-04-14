//
//  ContentView.swift
//  RegionShare
//
//  Created by David on 30.03.23.
//

import Combine
import OSLog
import ScreenCaptureKit
import SwiftUI

struct ContentView: View {
    @State var isUnauthorized = false

    @StateObject var screenRecorder = ScreenRecorder()

    var body: some View {
        VStack {
            if isUnauthorized {
                VStack(spacing: 0) {
                    Text("⛔️🙈")
                        .font(.largeTitle)
                        .padding(.top)
                    Text("No screen recording permission")
                        .font(.largeTitle)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16.0)
                    Text("Region Share works by recording your entire screen, then turning the desired area into a new window that you can share. To grant permission open System Settings and go to Privacy & Security > Screen Recording and activate Region Share.")
                        .font(.title2)
                        .multilineTextAlignment(.center)
                        .padding(16.0)
                }
                .frame(maxWidth: 800)
            } else {
                screenRecorder.capturePreview
                    .frame(maxWidth: .infinity, maxHeight: .infinity).ignoresSafeArea()
            }
        }
        .onAppear {
            Task {
                if await screenRecorder.canRecord {
                    await screenRecorder.start()
                } else {
                    isUnauthorized = true
                }
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
