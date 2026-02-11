//
//  ContentView.swift
//  HomeOps
//
//  Created by Kowshik on 11/2/26.
//

import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab: Tab = .dashboard
    @State private var isAddItemSheetPresented = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Content
            ZStack {
                if selectedTab == .dashboard {
                    DashboardView()
                } else if selectedTab == .settings {
                    SettingsView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            CustomTabBar(selectedTab: $selectedTab, onAddButtonTapped: {
                isAddItemSheetPresented = true
            })
        }
        .sheet(isPresented: $isAddItemSheetPresented) {
            AddItemView()
        }
    }
}

enum Tab {
    case dashboard, settings
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var onAddButtonTapped: () -> Void
    
    var body: some View {
        HStack {
            TabBarButton(icon: "house.fill", label: "Dashboard", isSelected: selectedTab == .dashboard) {
                selectedTab = .dashboard
            }
            
            Spacer()
            
            Button(action: onAddButtonTapped) {
                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 50))
                    .foregroundColor(.accentColor)
            }
            
            Spacer()
            
            TabBarButton(icon: "gear", label: "Settings", isSelected: selectedTab == .settings) {
                selectedTab = .settings
            }
        }
        .padding(.horizontal, 30)
        .padding(.top, 12)
        .padding(.bottom, 30)
        .background(.thinMaterial)
    }
}

struct TabBarButton: View {
    let icon: String
    let label: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.title2)
                Text(label)
                    .font(.caption)
            }
            .foregroundColor(isSelected ? .accentColor : .secondary)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: Item.self, inMemory: true)
}
