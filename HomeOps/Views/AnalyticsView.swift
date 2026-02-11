//
//  AnalyticsView.swift
//  HomeOps
//
//  Analytics Dashboard with Charts and Insights
//

import SwiftUI
import SwiftData
import Charts

struct AnalyticsView: View {
    @Query private var items: [Item]
    
    var body: some View {
        ScrollView {
            VStack(spacing: AppSpacing.lg) {
                // Overview Stats
                overviewStats
                
                // Category Breakdown Chart
                categoryBreakdown
                
                // Value Analysis
                valueAnalysis
                
                // Warranty Timeline
                warrantyTimeline
                
                // Monthly Trends
                monthlyTrends
                
                // Insights & Recommendations
                insightsSection
            }
            .padding(AppSpacing.md)
        }
        .background(AppColors.background)
        .navigationTitle("Analytics")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    // MARK: - Overview Stats
    private var overviewStats: some View {
        VStack(spacing: AppSpacing.md) {
            Text("Overview")
                .font(AppTypography.title2)
                .fontWeight(.bold)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppSpacing.md) {
                MiniStatCard(icon: "archivebox.fill", title: "Total Items", value: "\(items.count)", color: .blue)
                MiniStatCard(icon: "dollarsign.circle.fill", title: "Total Value", value: formattedTotalValue, color: .green)
                MiniStatCard(icon: "chart.line.uptrend.xyaxis", title: "Avg. Warranty", value: "\(avgWarrantyMonths) mo", color: .purple)
                MiniStatCard(icon: "calendar.badge.clock", title: "This Month", value: "\(itemsAddedThisMonth)", color: .orange)
            }
        }
    }
    
    // MARK: - Category Breakdown
    private var categoryBreakdown: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Category Breakdown")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            VStack(spacing: AppSpacing.sm) {
                if #available(iOS 16.0, *) {
                    Chart(categoryData) { data in
                        SectorMark(
                            angle: .value("Count", data.count),
                            innerRadius: .ratio(0.6),
                            angularInset: 1.5
                        )
                        .foregroundStyle(by: .value("Category", data.category))
                        .cornerRadius(5)
                    }
                    .frame(height: 250)
                    .chartLegend(position: .bottom, alignment: .center, spacing: 8)
                } else {
                    // Fallback for iOS 15
                    VStack(spacing: AppSpacing.xs) {
                        ForEach(categoryData, id: \.category) { data in
                            CategoryBar(category: data.category, count: data.count, total: items.count)
                        }
                    }
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
        }
    }
    
    // MARK: - Value Analysis
    private var valueAnalysis: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Value Analysis")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            VStack(spacing: AppSpacing.sm) {
                ValueRow(label: "Total Protected Value", value: formattedTotalValue, color: .green)
                ValueRow(label: "Average Item Value", value: formattedAvgValue, color: .blue)
                ValueRow(label: "Highest Value Item", value: formattedHighestValue, color: .purple)
                
                Divider()
                
                Text("Top 5 Most Valuable")
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                ForEach(topValueItems.prefix(5)) { item in
                    HStack {
                        Text(item.name)
                            .font(AppTypography.callout)
                            .lineLimit(1)
                        Spacer()
                        Text(item.formattedPrice)
                            .font(AppTypography.callout)
                            .fontWeight(.semibold)
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 2)
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
        }
    }
    
    // MARK: - Warranty Timeline
    private var warrantyTimeline: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Warranty Timeline")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            VStack(spacing: AppSpacing.sm) {
                HStack(spacing: AppSpacing.lg) {
                    TimelineSegment(count: activeWarranties, label: "Active", color: .green)
                    TimelineSegment(count: expiringWarranties, label: "Expiring", color: .orange)
                    TimelineSegment(count: expiredWarranties, label: "Expired", color: .red)
                }
                
                if #available(iOS 16.0, *) {
                    Chart {
                        BarMark(
                            x: .value("Status", "Active"),
                            y: .value("Count", activeWarranties)
                        )
                        .foregroundStyle(.green)
                        
                        BarMark(
                            x: .value("Status", "Expiring"),
                            y: .value("Count", expiringWarranties)
                        )
                        .foregroundStyle(.orange)
                        
                        BarMark(
                            x: .value("Status", "Expired"),
                            y: .value("Count", expiredWarranties)
                        )
                        .foregroundStyle(.red)
                    }
                    .frame(height: 150)
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
        }
    }
    
    // MARK: - Monthly Trends
    private var monthlyTrends: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Purchase Trends")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            VStack(spacing: AppSpacing.sm) {
                if #available(iOS 16.0, *) {
                    Chart(monthlyData) { data in
                        LineMark(
                            x: .value("Month", data.month),
                            y: .value("Items", data.count)
                        )
                        .foregroundStyle(.blue)
                        .interpolationMethod(.catmullRom)
                        
                        AreaMark(
                            x: .value("Month", data.month),
                            y: .value("Items", data.count)
                        )
                        .foregroundStyle(.blue.opacity(0.1))
                        .interpolationMethod(.catmullRom)
                    }
                    .frame(height: 200)
                    .chartXAxis {
                        AxisMarks(values: .automatic) { value in
                            AxisValueLabel()
                                .font(.caption2)
                        }
                    }
                } else {
                    // Fallback display
                    Text("Last 6 months: \(itemsAddedLast6Months) items added")
                        .font(AppTypography.callout)
                        .foregroundColor(.secondary)
                }
            }
            .padding(AppSpacing.md)
            .cardStyle()
        }
    }
    
    // MARK: - Insights Section
    private var insightsSection: some View {
        VStack(alignment: .leading, spacing: AppSpacing.md) {
            Text("Insights & Recommendations")
                .font(AppTypography.title2)
                .fontWeight(.bold)
            
            VStack(spacing: AppSpacing.sm) {
                if expiringWarranties > 0 {
                    InsightCard(
                        icon: "exclamationmark.triangle.fill",
                        title: "Action Needed",
                        message: "\(expiringWarranties) item(s) have warranties expiring soon. Review them now.",
                        color: .orange
                    )
                }
                
                if let mostCommonCategory = mostCommonCategory {
                    InsightCard(
                        icon: "chart.bar.fill",
                        title: "Top Category",
                        message: "\(mostCommonCategory) is your most tracked category with \(categoryCount(mostCommonCategory)) items.",
                        color: .blue
                    )
                }
                
                if avgWarrantyMonths < 12 {
                    InsightCard(
                        icon: "lightbulb.fill",
                        title: "Tip",
                        message: "Consider extended warranties for high-value electronics to increase protection.",
                        color: .purple
                    )
                }
                
                if itemsWithoutPrice > 0 {
                    InsightCard(
                        icon: "info.circle.fill",
                        title: "Complete Your Data",
                        message: "\(itemsWithoutPrice) item(s) don't have purchase prices. Add them for better value tracking.",
                        color: .cyan
                    )
                }
            }
        }
    }
    
    // MARK: - Computed Properties
    
    private var formattedTotalValue: String {
        let total = items.compactMap { $0.purchasePrice }.reduce(0, +)
        return formatCurrency(total)
    }
    
    private var formattedAvgValue: String {
        let itemsWithPrice = items.compactMap { $0.purchasePrice }
        guard !itemsWithPrice.isEmpty else { return "$0" }
        let avg = itemsWithPrice.reduce(0, +) / Double(itemsWithPrice.count)
        return formatCurrency(avg)
    }
    
    private var formattedHighestValue: String {
        let highest = items.compactMap { $0.purchasePrice }.max() ?? 0
        return formatCurrency(highest)
    }
    
    private var topValueItems: [Item] {
        items.filter { $0.purchasePrice != nil }
            .sorted { ($0.purchasePrice ?? 0) > ($1.purchasePrice ?? 0) }
    }
    
    private var avgWarrantyMonths: Int {
        guard !items.isEmpty else { return 0 }
        return items.map { $0.warrantyDurationMonths }.reduce(0, +) / items.count
    }
    
    private var itemsAddedThisMonth: Int {
        let calendar = Calendar.current
        let now = Date()
        return items.filter {
            calendar.isDate($0.purchaseDate, equalTo: now, toGranularity: .month)
        }.count
    }
    
    private var itemsAddedLast6Months: Int {
        let sixMonthsAgo = Calendar.current.date(byAdding: .month, value: -6, to: Date()) ?? Date()
        return items.filter { $0.purchaseDate >= sixMonthsAgo }.count
    }
    
    private var activeWarranties: Int {
        items.filter { $0.daysRemaining > 30 }.count
    }
    
    private var expiringWarranties: Int {
        items.filter { $0.daysRemaining > 0 && $0.daysRemaining <= 30 }.count
    }
    
    private var expiredWarranties: Int {
        items.filter { $0.daysRemaining <= 0 }.count
    }
    
    private var categoryData: [CategoryData] {
        let grouped = Dictionary(grouping: items) { $0.category }
        return grouped.map { CategoryData(category: $0.key, count: $0.value.count) }
            .sorted { $0.count > $1.count }
    }
    
    private var mostCommonCategory: String? {
        categoryData.first?.category
    }
    
    private func categoryCount(_ category: String) -> Int {
        items.filter { $0.category == category }.count
    }
    
    private var itemsWithoutPrice: Int {
        items.filter { $0.purchasePrice == nil }.count
    }
    
    private var monthlyData: [MonthlyData] {
        let calendar = Calendar.current
        
        var data: [MonthlyData] = []
        for monthOffset in 0..<6 {
            guard let monthDate = calendar.date(byAdding: .month, value: -monthOffset, to: Date()) else { continue }
            let monthName = monthDate.formatted(.dateTime.month(.abbreviated))
            let count = items.filter { calendar.isDate($0.purchaseDate, equalTo: monthDate, toGranularity: .month) }.count
            data.append(MonthlyData(month: monthName, count: count))
        }
        return data.reversed()
    }
    
    private func formatCurrency(_ value: Double) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.locale = Locale.current
        return formatter.string(from: NSNumber(value: value)) ?? "$0"
    }
}

// MARK: - Supporting Types

struct CategoryData: Identifiable {
    let id = UUID()
    let category: String
    let count: Int
}

struct MonthlyData: Identifiable {
    let id = UUID()
    let month: String
    let count: Int
}

// MARK: - Supporting Views

struct MiniStatCard: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppSpacing.xs) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            Text(value)
                .font(AppTypography.title3)
                .fontWeight(.bold)
            
            Text(title)
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(AppSpacing.md)
        .cardStyle(elevation: .low)
    }
}

struct ValueRow: View {
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Text(label)
                .font(AppTypography.callout)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(AppTypography.callout)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
    }
}

struct TimelineSegment: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: AppSpacing.xs) {
            Text("\(count)")
                .font(AppTypography.title1)
                .fontWeight(.bold)
                .foregroundColor(color)
            Text(label)
                .font(AppTypography.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct CategoryBar: View {
    let category: String
    let count: Int
    let total: Int
    
    private var percentage: Double {
        guard total > 0 else { return 0 }
        return Double(count) / Double(total)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(category)
                    .font(AppTypography.caption)
                Spacer()
                Text("\(count)")
                    .font(AppTypography.caption)
                    .fontWeight(.medium)
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Rectangle()
                        .fill(Color(.systemGray5))
                        .frame(width: geometry.size.width, height: 8)
                    
                    Rectangle()
                        .fill(AppColors.primary)
                        .frame(width: geometry.size.width * percentage, height: 8)
                }
            }
            .frame(height: 8)
            .cornerRadius(4)
        }
    }
}

struct InsightCard: View {
    let icon: String
    let title: String
    let message: String
    let color: Color
    
    var body: some View {
        HStack(alignment: .top, spacing: AppSpacing.md) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(AppTypography.callout)
                    .fontWeight(.semibold)
                Text(message)
                    .font(AppTypography.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding(AppSpacing.md)
        .background(color.opacity(0.1))
        .cornerRadius(AppRadius.md)
    }
}

#Preview {
    AnalyticsView()
        .modelContainer(for: Item.self, inMemory: true)
}
