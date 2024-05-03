//
//  MainTabView.swift
//  NewAPI
//
//  Created by Alex Beattie on 3/19/24.
//

import SwiftUI

struct MainTabView: View {
    @StateObject var vm = ListingPublisherViewModel()
    @State private var selectedTab = 0 // Set the initial tab programmatically
    
    var body: some View {
        TabView(selection: $selectedTab) {
            ContentView()
                .tabItem {
                    Image(systemName: "house")
                    Text("Home")
                }
                .tag(0)
            
            NewMapView(listings: Array(vm.results))
                .tabItem {
                    Image(systemName: "map")
                    Text("Map")
                }
                .tag(1)
        }
        .tabViewStyle(DefaultTabViewStyle())
    }
}
