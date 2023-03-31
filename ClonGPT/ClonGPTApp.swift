//
//  ClonGPTApp.swift
//  ClonGPT
//
//  Created by JSANCAGU on 29/3/23.
//

import SwiftUI
import Intents

@main
struct ClonGPTApp: App {
    
    @Environment(\.scenePhase) private var scenePhase
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }.onChange(of: scenePhase) { phase in
            INPreferences.requestSiriAuthorization({status in
                // Handle errors here
            })
        }
    }
}
