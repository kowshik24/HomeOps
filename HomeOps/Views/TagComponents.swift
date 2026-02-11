//
//  TagComponents.swift
//  HomeOps
//
//  Tag UI Components
//

import SwiftUI
import Combine

// MARK: - Tag Chip
struct TagChip: View {
    let tag: String
    var isSelected: Bool = false
    var onRemove: (() -> Void)? = nil
    
    var body: some View {
        HStack(spacing: 4) {
            Text(tag)
                .font(AppTypography.caption)
                .fontWeight(.medium)
            
            if let onRemove = onRemove {
                Button(action: onRemove) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.caption2)
                }
            }
        }
        .padding(.horizontal, AppSpacing.sm)
        .padding(.vertical, AppSpacing.xs)
        .background(isSelected ? AppColors.primary : AppColors.surfaceVariant)
        .foregroundColor(isSelected ? .white : .primary)
        .cornerRadius(AppRadius.sm)
    }
}

// MARK: - Flow Layout for Tags
struct FlowLayout: Layout {
    var spacing: CGFloat = 8
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(
            in: proposal.replacingUnspecifiedDimensions().width,
            subviews: subviews,
            spacing: spacing
        )
        return result.size
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(
            in: bounds.width,
            subviews: subviews,
            spacing: spacing
        )
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                     y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }
    
    struct FlowResult {
        var size: CGSize
        var positions: [CGPoint]
        
        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var positions: [CGPoint] = []
            var size: CGSize = .zero
            var currentX: CGFloat = 0
            var currentY: CGFloat = 0
            var lineHeight: CGFloat = 0
            
            for subview in subviews {
                let subviewSize = subview.sizeThatFits(.unspecified)
                
                if currentX + subviewSize.width > maxWidth && currentX > 0 {
                    // Move to next line
                    currentX = 0
                    currentY += lineHeight + spacing
                    lineHeight = 0
                }
                
                positions.append(CGPoint(x: currentX, y: currentY))
                currentX += subviewSize.width + spacing
                lineHeight = max(lineHeight, subviewSize.height)
                size.width = max(size.width, currentX - spacing)
            }
            
            size.height = currentY + lineHeight
            self.size = size
            self.positions = positions
        }
    }
}

// MARK: - Tag Manager
class TagManager: ObservableObject {
    static let shared = TagManager()
    
    let predefinedTags = [
        "Important",
        "Gift",
        "Urgent",
        "High Value",
        "Replacement Needed",
        "Under Review",
        "Extended Warranty",
        "Limited Edition",
        "Vintage",
        "Collectible"
    ]
    
    @Published var customTags: [String] = []
    
    private let customTagsKey = "customTags"
    
    var allTags: [String] {
        (predefinedTags + customTags).sorted()
    }
    
    private init() {
        loadCustomTags()
    }
    
    func addCustomTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !allTags.contains(trimmed) else { return }
        customTags.append(trimmed)
        saveCustomTags()
    }
    
    func deleteCustomTag(_ tag: String) {
        customTags.removeAll { $0 == tag }
        saveCustomTags()
    }
    
    private func saveCustomTags() {
        UserDefaults.standard.set(customTags, forKey: customTagsKey)
    }
    
    private func loadCustomTags() {
        if let saved = UserDefaults.standard.stringArray(forKey: customTagsKey) {
            customTags = saved
        }
    }
}

// MARK: - Tag Picker Sheet
struct TagPickerSheet: View {
    @StateObject private var tagManager = TagManager.shared
    @Binding var selectedTags: Set<String>
    @Environment(\.dismiss) private var dismiss
    
    @State private var newTagText = ""
    
    var body: some View {
        NavigationView {
            List {
                Section {
                    HStack {
                        TextField("New Tag", text: $newTagText)
                        Button("Add") {
                            tagManager.addCustomTag(newTagText)
                            selectedTags.insert(newTagText)
                            newTagText = ""
                        }
                        .disabled(newTagText.isEmpty)
                    }
                } header: {
                    Text("Create New Tag")
                }
                
                Section {
                    ForEach(tagManager.allTags, id: \.self) { tag in
                        Button(action: {
                            if selectedTags.contains(tag) {
                                selectedTags.remove(tag)
                            } else {
                                selectedTags.insert(tag)
                            }
                        }) {
                            HStack {
                                Text(tag)
                                    .foregroundColor(.primary)
                                Spacer()
                                if selectedTags.contains(tag) {
                                    Image(systemName: "checkmark")
                                        .foregroundColor(AppColors.primary)
                                }
                            }
                        }
                    }
                } header: {
                    Text("Available Tags")
                }
            }
            .navigationTitle("Select Tags")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
    }
}
