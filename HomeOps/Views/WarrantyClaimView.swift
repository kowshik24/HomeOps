//
//  WarrantyClaimView.swift
//  HomeOps
//
//  Warranty Claims Assistant
//

import SwiftUI
import MessageUI

struct WarrantyClaimView: View {
    let item: Item
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentStep = 1
    @State private var claimReason = ""
    @State private var issueDescription = ""
    @State private var showingMailComposer = false
    @State private var showingCopyConfirmation = false
    
    let totalSteps = 4
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: AppSpacing.lg) {
                    // Progress Indicator
                    progressIndicator
                    
                    // Step Content
                    stepContent
                }
                .padding(AppSpacing.md)
            }
            .background(AppColors.background)
            .navigationTitle("Warranty Claim")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
        }
    }
    
    // MARK: - Progress Indicator
    private var progressIndicator: some View {
        VStack(spacing: AppSpacing.sm) {
            HStack(spacing: 0) {
                ForEach(1...totalSteps, id: \.self) { step in
                    if step > 1 {
                        Rectangle()
                            .fill(step <= currentStep ? AppColors.primary : Color.secondary.opacity(0.3))
                            .frame(height: 2)
                    }
                    
                    ZStack {
                        Circle()
                            .fill(step <= currentStep ? AppColors.primary : Color.secondary.opacity(0.3))
                            .frame(width: 32, height: 32)
                        
                        if step < currentStep {
                            Image(systemName: "checkmark")
                                .font(.caption)
                                .foregroundColor(.white)
                        } else {
                            Text("\(step)")
                                .font(AppTypography.caption)
                                .foregroundColor(.white)
                        }
                    }
                }
            }
            
            Text("Step \(currentStep) of \(totalSteps)")
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
        }
        .padding(.vertical, AppSpacing.md)
    }
    
    // MARK: - Step Content
    @ViewBuilder
    private var stepContent: some View {
        switch currentStep {
        case 1:
            step1ReviewItem
        case 2:
            step2ClaimReason
        case 3:
            step3PrepareDocuments
        case 4:
            step4Contact
        default:
            EmptyView()
        }
    }
    
    // MARK: - Step 1: Review Item
    private var step1ReviewItem: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Review Item Details")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            VStack(spacing: AppSpacing.md) {
                InfoRow(icon: "tag", label: "Product", value: item.name)
                InfoRow(icon: "building.2", label: "Store", value: item.storeName ?? "Not specified")
                InfoRow(icon: "calendar", label: "Purchase Date", value: item.purchaseDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(icon: "calendar.badge.exclamationmark", label: "Warranty Expires", value: item.warrantyExpirationDate.formatted(date: .abbreviated, time: .omitted))
                InfoRow(icon: "hourglass", label: "Days Remaining", value: "\(item.daysRemaining) days")
                
                if let _ = item.purchasePrice {
                    InfoRow(icon: "dollarsign.circle", label: "Purchase Price", value: item.formattedPrice)
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
            
            if item.daysRemaining < 0 {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundColor(.orange)
                    Text("Your warranty has expired. Some manufacturers may still honor claims shortly after expiration.")
                        .font(AppTypography.footnote)
                        .foregroundColor(.secondary)
                }
                .padding(AppSpacing.md)
                .background(Color.orange.opacity(0.1))
                .cornerRadius(AppRadius.md)
            }
            
            Button(action: { withAnimation { currentStep = 2 } }) {
                Text("Continue")
                    .font(AppTypography.headline)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.md)
                    .background(AppColors.primary)
                    .cornerRadius(AppRadius.md)
            }
            .pressableButton()
        }
    }
    
    // MARK: - Step 2: Claim Reason
    private var step2ClaimReason: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("What's the issue?")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            Text("Select the reason for your warranty claim")
                .font(AppTypography.callout)
                .foregroundColor(.secondary)
            
            VStack(spacing: AppSpacing.sm) {
                ClaimReasonButton(reason: "Defective Product", icon: "exclamationmark.triangle", isSelected: claimReason == "Defective Product") {
                    claimReason = "Defective Product"
                }
                
                ClaimReasonButton(reason: "Stopped Working", icon: "power", isSelected: claimReason == "Stopped Working") {
                    claimReason = "Stopped Working"
                }
                
                ClaimReasonButton(reason: "Damaged in Transit", icon: "shippingbox", isSelected: claimReason == "Damaged in Transit") {
                    claimReason = "Damaged in Transit"
                }
                
                ClaimReasonButton(reason: "Missing Parts", icon: "puzzlepiece.extension", isSelected: claimReason == "Missing Parts") {
                    claimReason = "Missing Parts"
                }
                
                ClaimReasonButton(reason: "Other Issue", icon: "ellipsis.circle", isSelected: claimReason == "Other Issue") {
                    claimReason = "Other Issue"
                }
            }
            
            VStack(alignment: .leading, spacing: AppSpacing.xs) {
                Text("Describe the issue")
                    .font(AppTypography.callout)
                    .fontWeight(.medium)
                
                TextEditor(text: $issueDescription)
                    .frame(height: 120)
                    .font(AppTypography.body)
                    .padding(AppSpacing.xs)
                    .background(Color(.systemBackground))
                    .cornerRadius(AppRadius.sm)
                    .overlay(
                        RoundedRectangle(cornerRadius: AppRadius.sm)
                            .stroke(Color.secondary.opacity(0.2), lineWidth: 1)
                    )
            }
            .padding(AppSpacing.md)
            .cardStyle()
            
            HStack(spacing: AppSpacing.md) {
                Button(action: { withAnimation { currentStep = 1 } }) {
                    Text("Back")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(AppRadius.md)
                }
                .pressableButton()
                
                Button(action: { withAnimation { currentStep = 3 } }) {
                    Text("Continue")
                        .font(AppTypography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(claimReason.isEmpty ? Color.secondary : AppColors.primary)
                        .cornerRadius(AppRadius.md)
                }
                .pressableButton()
                .disabled(claimReason.isEmpty)
            }
        }
    }
    
    // MARK: - Step 3: Prepare Documents
    private var step3PrepareDocuments: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Prepare Documents")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            Text("Make sure you have these documents ready:")
                .font(AppTypography.callout)
                .foregroundColor(.secondary)
            
            VStack(spacing: AppSpacing.sm) {
                DocumentChecklistItem(
                    icon: "doc.text",
                    title: "Proof of Purchase",
                    description: "Receipt or invoice",
                    isAvailable: item.receiptImageData != nil
                )
                
                DocumentChecklistItem(
                    icon: "calendar",
                    title: "Purchase Date",
                    description: item.purchaseDate.formatted(date: .abbreviated, time: .omitted),
                    isAvailable: true
                )
                
                DocumentChecklistItem(
                    icon: "photo",
                    title: "Product Photos",
                    description: "Photos showing the issue",
                    isAvailable: false
                )
                
                DocumentChecklistItem(
                    icon: "barcode",
                    title: "Serial Number",
                    description: item.serialNumber ?? "Not provided",
                    isAvailable: item.serialNumber != nil
                )
            }
            
            HStack(spacing: AppSpacing.md) {
                Button(action: { withAnimation { currentStep = 2 } }) {
                    Text("Back")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(AppRadius.md)
                }
                .pressableButton()
                
                Button(action: { withAnimation { currentStep = 4 } }) {
                    Text("Continue")
                        .font(AppTypography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(AppColors.primary)
                        .cornerRadius(AppRadius.md)
                }
                .pressableButton()
            }
        }
    }
    
    // MARK: - Step 4: Contact
    private var step4Contact: some View {
        VStack(alignment: .leading, spacing: AppSpacing.lg) {
            Text("Submit Your Claim")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            Text("We've prepared a warranty claim email for you")
                .font(AppTypography.callout)
                .foregroundColor(.secondary)
            
            // Email Preview
            VStack(alignment: .leading, spacing: AppSpacing.md) {
                Text("Email Preview")
                    .font(AppTypography.headline)
                
                VStack(alignment: .leading, spacing: AppSpacing.sm) {
                    EmailPreviewRow(label: "Subject", value: "Warranty Claim - \(item.name)")
                    EmailPreviewRow(label: "To", value: item.storeName ?? "Customer Service")
                    
                    Divider()
                    
                    VStack(alignment: .leading, spacing: AppSpacing.xs) {
                        Text("Message:")
                            .font(AppTypography.caption)
                            .foregroundColor(.secondary)
                        
                        Text(emailBody)
                            .font(AppTypography.footnote)
                            .padding(AppSpacing.sm)
                            .background(Color(.systemGray6))
                            .cornerRadius(AppRadius.sm)
                    }
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
            
            VStack(spacing: AppSpacing.sm) {
                Button(action: { showingMailComposer = true }) {
                    Label("Open in Mail", systemImage: "envelope.fill")
                        .font(AppTypography.headline)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(AppColors.primary)
                        .cornerRadius(AppRadius.md)
                }
                .pressableButton()
                
                Button(action: copyEmailToClipboard) {
                    Label("Copy to Clipboard", systemImage: "doc.on.doc")
                        .font(AppTypography.headline)
                        .foregroundColor(AppColors.primary)
                        .frame(maxWidth: .infinity)
                        .padding(AppSpacing.md)
                        .background(AppColors.primary.opacity(0.1))
                        .cornerRadius(AppRadius.md)
                }
                .pressableButton()
            }
            
            if showingCopyConfirmation {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.green)
                    Text("Email copied to clipboard!")
                        .font(AppTypography.footnote)
                }
                .padding(AppSpacing.sm)
                .background(Color.green.opacity(0.1))
                .cornerRadius(AppRadius.sm)
                .transition(.scale.combined(with: .opacity))
            }
            
            Button(action: { withAnimation { currentStep = 3 } }) {
                Text("Back")
                    .font(AppTypography.headline)
                    .foregroundColor(AppColors.primary)
                    .frame(maxWidth: .infinity)
                    .padding(AppSpacing.md)
                    .background(AppColors.primary.opacity(0.1))
                    .cornerRadius(AppRadius.md)
            }
            .pressableButton()
        }
    }
    
    // MARK: - Email Body
    private var emailBody: String {
        """
        Dear \(item.storeName ?? "Customer Service"),
        
        I am writing to file a warranty claim for the following product:
        
        Product: \(item.name)
        Purchase Date: \(item.purchaseDate.formatted(date: .long, time: .omitted))
        \(item.purchasePrice != nil ? "Purchase Price: \(item.formattedPrice)" : "")
        \(item.serialNumber != nil ? "Serial Number: \(item.serialNumber!)" : "")
        
        Reason for Claim: \(claimReason)
        
        Issue Description:
        \(issueDescription)
        
        The product is still under warranty (expires \(item.warrantyExpirationDate.formatted(date: .long, time: .omitted))). I have attached proof of purchase and photos documenting the issue.
        
        Please advise on the next steps for processing this warranty claim.
        
        Thank you for your assistance.
        
        Best regards
        """
    }
    
    // MARK: - Actions
    private func copyEmailToClipboard() {
        UIPasteboard.general.string = emailBody
        withAnimation {
            showingCopyConfirmation = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showingCopyConfirmation = false
            }
        }
        
        HapticManager.shared.notification(type: .success)
    }
}

// MARK: - Supporting Views

struct ClaimReasonButton: View {
    let reason: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: icon)
                    .font(.title3)
                    .foregroundColor(isSelected ? AppColors.primary : .secondary)
                Text(reason)
                    .font(AppTypography.callout)
                    .foregroundColor(isSelected ? AppColors.primary : .primary)
                Spacer()
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(AppColors.primary)
                }
            }
            .padding(AppSpacing.md)
            .background(isSelected ? AppColors.primary.opacity(0.1) : AppColors.surface)
            .cornerRadius(AppRadius.md)
            .overlay(
                RoundedRectangle(cornerRadius: AppRadius.md)
                    .stroke(isSelected ? AppColors.primary : Color.clear, lineWidth: 2)
            )
        }
        .pressableButton()
    }
}

struct DocumentChecklistItem: View {
    let icon: String
    let title: String
    let description: String
    let isAvailable: Bool
    
    var body: some View {
        HStack(spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(isAvailable ? .green : .secondary)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(AppTypography.callout)
                    .fontWeight(.medium)
                Text(description)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Image(systemName: isAvailable ? "checkmark.circle.fill" : "circle")
                .foregroundColor(isAvailable ? .green : .secondary)
        }
        .padding(AppSpacing.md)
        .background(isAvailable ? Color.green.opacity(0.05) : AppColors.surface)
        .cornerRadius(AppRadius.md)
    }
}

struct EmailPreviewRow: View {
    let label: String
    let value: String
    
    var body: some View {
        HStack {
            Text("\(label):")
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(AppTypography.callout)
                .fontWeight(.medium)
        }
    }
}

#Preview {
    WarrantyClaimView(item: Item(name: "MacBook Pro", purchaseDate: .now.addingTimeInterval(-100 * 24 * 3600), warrantyMonths: 12, category: "Electronics"))
}
