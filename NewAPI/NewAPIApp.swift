//
//  NewAPIApp.swift
//  NewAPI
//
//  Created by Alex Beattie on 9/20/23.
//

import SwiftUI

@main

struct NewAPIApp: App {
    init() {
           // Configure URLCache
           URLCache.shared.memoryCapacity = 50 * 1024 * 1024 // 50 MB
           URLCache.shared.diskCapacity = 100 * 1024 * 1024 // 100 MB
       }
    var body: some Scene {
        
        WindowGroup {
            
            MainTabView()
                .preferredColorScheme(.dark)

        }
    }
}
