//
//  ScreenRecorder.swift
//  RegionShare
//
//  Created by David on 30.03.23.
//
//  Description:
//  A model object that provides the interface to capture screen content.
//

import Combine
import Foundation
import OSLog
import ScreenCaptureKit

@MainActor
class ScreenRecorder: ObservableObject {
    private let logger = Logger()
    
    /// A view that renders the screen content.
    lazy var capturePreview: CapturePreview = .init()
    
    @Published var isRunning = false
    
    @Published var contentSize = CGSize(width: 1, height: 1)
    private var scaleFactor: Int { Int(NSScreen.main?.backingScaleFactor ?? 2) }
    
    @Published var currentDisplay: SCDisplay? { didSet { updateEngine() } }
    private var availableApps = [SCRunningApplication]()
    
    // The object that manages the SCStream.
    private let captureEngine = CaptureEngine()
    
    // Combine subscribers.
    private var subscriptions = Set<AnyCancellable>()
    
    var canRecord: Bool {
        get async {
            do {
                // If the app doesn't have Screen Recording permission, this call generates an exception.
                try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
                return true
            } catch {
                return false
            }
        }
    }
    
    /// Starts capturing screen content.
    func start() async {
        // Exit early if already running.
        guard !isRunning else { return }
        
        await refreshAvailableContent()
        guard let filter = contentFilter else { fatalError("No filter found") }
        
        do {
            let config = streamConfiguration
            // Update the running state.
            isRunning = true
            // Start the stream and await new video frames.
            for try await frame in captureEngine.startCapture(configuration: config, filter: filter) {
                capturePreview.updateFrame(frame)
                if contentSize != frame.size {
                    // Update the content size if it changed.
                    contentSize = frame.size
                }
            }
        } catch {
            logger.error("\(error.localizedDescription)")
            // Unable to start the stream. Set the running state to false.
            isRunning = false
        }
    }
    
    /// Stops capturing screen content.
    func stop() async {
        guard isRunning else { return }
        await captureEngine.stopCapture()
        let stopFrame = CapturedFrame(surface: nil, contentRect: .zero, contentScale: 0, scaleFactor: 0)
        capturePreview.updateFrame(stopFrame)
        isRunning = false
    }
    
    /// - Tag: UpdateCaptureConfig
    private func updateEngine() {
        guard isRunning else { return }
        guard let filter = contentFilter else { return }
            
        Task {
            await captureEngine.update(configuration: streamConfiguration, filter: filter)
        }
    }
    
    /// - Tag: GetAvailableContent
    private func refreshAvailableContent() async {
        do {
            // Retrieve the available screen content to capture.
            let availableContent = try await SCShareableContent.excludingDesktopWindows(false, onScreenWindowsOnly: true)
            currentDisplay = availableContent.displays.first
            availableApps = availableContent.applications
        } catch {
            logger.error("Failed to get the shareable content: \(error.localizedDescription)")
        }
    }
    
    /// - Tag: UpdateFilter
    private var contentFilter: SCContentFilter? {
        let filter: SCContentFilter
        
        guard let display = currentDisplay else { logger.error("No display found"); return nil }
        var excludedApps = [SCRunningApplication]()
        
        // Exclude this app from the stream by matching its bundle identifier.
        excludedApps = availableApps.filter { app in
            Bundle.main.bundleIdentifier == app.bundleIdentifier
        }
        
        // Create a content filter with excluded apps.
        filter = SCContentFilter(display: display, excludingApplications: excludedApps, exceptingWindows: [])
    
        return filter
    }
    
    private var streamConfiguration: SCStreamConfiguration {
        let streamConfig = SCStreamConfiguration()
        
        // Configure audio capture.
        streamConfig.capturesAudio = false
        
        // Configure the display content width and height.
        if let unwrappedFrame = NSApplication.shared.mainWindow?.frame {
            streamConfig.sourceRect = unwrappedFrame
            streamConfig.width = Int(unwrappedFrame.width)
            streamConfig.height = Int(unwrappedFrame.height)
        }
        
        // Set the capture interval at 30 fps.
        streamConfig.minimumFrameInterval = CMTime(value: 1, timescale: 30)
        
        // Increase the depth of the frame queue to ensure high fps at the expense of increasing
        // the memory footprint of WindowServer.
        streamConfig.queueDepth = 5
        
        return streamConfig
    }
}

extension SCDisplay {
    var displayName: String {
        "Display: \(width) x \(height)"
    }
}
