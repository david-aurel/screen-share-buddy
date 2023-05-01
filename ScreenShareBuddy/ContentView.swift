//
//  ContentView.swift
//  ScreenShareBuddy
//
//  Created by David on 01.05.23.
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
                    Text("Screen Share Buddy works by recording your screen, then displaying it in a new window that can be shared to other applications. To grant permission, open System Settings and go to Privacy & Security > Screen Recording. Then tick the checkbox for Screen Share Buddy.")
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
        // Update portion of screen to capture whenever the window is moved or resized
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didMoveNotification)) { _ in
            screenRecorder.update()
        }
        .onReceive(NotificationCenter.default.publisher(for: NSWindow.didResizeNotification)) { _ in
            screenRecorder.update()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
