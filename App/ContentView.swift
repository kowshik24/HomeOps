//
//  ContentView.swift
//  HomeOps
//
//  Created by Kowshik on 11/2/26.
//

import SwiftUI

struct ContentView: View {
    @State private var isAddItemPresented = false
    
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Dashboard", systemImage: "house.fill")
                }
            
            // This is a placeholder to trigger the sheet
            Text("")
                .tabItem {
                    Label("Add Item", systemImage: "plus.circle.fill")
                }
                .onAppear {
                    // A bit of a hack to use a tab item to present a sheet
                    // A custom tab bar would be a more robust solution
                    if !isAddItemPresented {
                        isAddItemPresented = true
                    }
                }
            
            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
        }
        .sheet(isPresented: $isAddItemPresented) {
            AddItemView()
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
