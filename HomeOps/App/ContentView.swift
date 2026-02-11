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
            Group {
                switch selectedTab {
                case .dashboard:
                    DashboardView()
                case .collections:
                    SmartCollectionsView()
                case .settings:
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
    case dashboard, collections, settings
}

struct CustomTabBar: View {
    @Binding var selectedTab: Tab
    var onAddButtonTapped: () -> Void
    
    var body: some View {
        HStack(spacing: 0) {
            // Left side tabs
            HStack(spacing: 0) {
                TabBarButton(icon: "house.fill", label: "Dashboard", isSelected: selectedTab == .dashboard) {
                    selectedTab = .dashboard
                }
                .frame(maxWidth: .infinity)
                
                TabBarButton(icon: "square.grid.2x2.fill", label: "Collections", isSelected: selectedTab == .collections) {
                    selectedTab = .collections
                }
                .frame(maxWidth: .infinity)
            }
            .frame(maxWidth: .infinity)
            
            // Center add button
            Button(action: onAddButtonTapped) {
                ZStack {
                    Circle()
                        .fill(Color.accentColor)
                        .frame(width: 56, height: 56)
                    
                    Image(systemName: "plus")
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundColor(.white)
                }
            }
            .offset(y: -8)
            .padding(.horizontal, 20)
            
            // Right side tab
            TabBarButton(icon: "gear", label: "Settings", isSelected: selectedTab == .settings) {
                selectedTab = .settings
            }
            .frame(maxWidth: .infinity)
        }
        .padding(.horizontal, 16)
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
