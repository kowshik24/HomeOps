//
//  HomeOpsApp.swift
//  HomeOps
//
//  Created by Kowshik on 11/2/26.
//

import SwiftUI
import SwiftData

@main
struct HomeOpsApp: App {
    init() {
        // Initialize console logger to manage known warnings
        _ = ConsoleLogger.shared
        print("🚀 HomeOps starting...")
    }
    
    // Create ModelContainer with automatic migration error recovery
    var modelContainer: ModelContainer = {
        let schema = Schema([Item.self])
        
        // Helper function to get the default store URL
        func getDefaultStoreURL() -> URL? {
            guard let appSupport = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first else {
                return nil
            }
            return appSupport.appendingPathComponent("default.store")
        }
        
        // Helper function to delete corrupted database
        func deleteCorruptedDatabase() {
            guard let storeURL = getDefaultStoreURL() else { return }
            
            let fileManager = FileManager.default
            let storePath = storeURL.path
            
            print("🗑️  Deleting corrupted database...")
            
            // Delete the main store file and its companions
            let filesToDelete = [
                storePath,
                storePath + "-shm",
                storePath + "-wal"
            ]
            
            for file in filesToDelete {
                if fileManager.fileExists(atPath: file) {
                    try? fileManager.removeItem(atPath: file)
                    print("   ✓ Deleted: \(URL(fileURLWithPath: file).lastPathComponent)")
                }
            }
            
            print("✅ Database reset complete")
        }
        
        // First attempt: Try to load the existing database
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true
        )
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            print("✅ ModelContainer created successfully")
            container.mainContext.autosaveEnabled = true
            return container
        } catch {
            print("❌ Failed to create ModelContainer (first attempt)")
            print("   Error: \(error)")
            
            // Check if it's a migration error
            let errorString = String(describing: error)
            if errorString.contains("migration") || errorString.contains("134110") {
                print("🔧 Detected migration error - attempting automatic fix...")
                
                // Delete the corrupted database
                deleteCorruptedDatabase()
                
                // Second attempt: Try creating a fresh database
                do {
                    let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
                    print("✅ ModelContainer created successfully (after database reset)")
                    container.mainContext.autosaveEnabled = true
                    return container
                } catch {
                    print("❌ Failed to create ModelContainer even after reset: \(error)")
                }
            }
            
            // Final fallback: Use in-memory storage
            print("⚠️  Using in-memory storage as last resort")
            print("   Data will NOT persist between app launches")
            
            do {
                let fallbackConfig = ModelConfiguration(
                    schema: schema,
                    isStoredInMemoryOnly: true
                )
                let fallbackContainer = try ModelContainer(for: schema, configurations: [fallbackConfig])
                print("✅ In-memory ModelContainer created")
                return fallbackContainer
            } catch {
                fatalError("❌ FATAL: Could not create any ModelContainer: \(error)")
            }
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(modelContainer)
    }
}
