// MachOExplore
// Created by: resse

import SwiftUI
import Combine

@main
struct MachOExploreApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.windowResizabilityContentSize()
    }
}

extension Scene {
    func windowResizabilityContentSize() -> some Scene {
        if #available(macOS 13.0, *) {
            return windowResizability(.contentSize)
        } else {
            return self
        }
    }
}
