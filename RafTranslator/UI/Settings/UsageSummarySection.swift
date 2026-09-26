import SwiftUI
import SwiftData

/// "Token Usage & Billing" card: totals, refresh pricing rates, and reset history.
struct UsageSummarySection: View {
    let viewModel: SettingsViewModel

    @Environment(\.modelContext) private var modelContext
    @State private var showClearConfirmation = false

    var body: some View {
        Section {
            LabeledContent("Total Requests", value: "\(viewModel.usageSummary.totalRequests)")
            LabeledContent("Total Tokens Processed", value: formattedTokenCount)
            LabeledContent("Overall Cost (USD)", value: formattedCost(viewModel.usageSummary.grandTotalCostUsd, decimals: 4))
            LabeledContent("Average Cost / Request", value: formattedCost(viewModel.usageSummary.averageCostUsd, decimals: 5))

            Button("Refresh Rates") {
                try? UsageRepository.refreshDefaultRates(context: modelContext)
            }
            Button("Reset Stats", role: .destructive) {
                showClearConfirmation = true
            }
        } header: {
            Text("Token Usage & Billing")
        } footer: {
            Text("Estimated costs based on Google's paid-tier API pricing. Free-tier keys aren't actually billed.")
        }
        .confirmationDialog(
            "Clear all usage history?",
            isPresented: $showClearConfirmation,
            titleVisibility: .visible
        ) {
            Button("Reset Stats", role: .destructive) {
                try? UsageRepository.clearHistory(context: modelContext)
                viewModel.loadUsageSummary(context: modelContext)
            }
        }
    }

    private var formattedTokenCount: String {
        viewModel.usageSummary.grandTotalTokens.formatted(.number.grouping(.automatic))
    }

    private func formattedCost(_ value: Double, decimals: Int) -> String {
        "$" + value.formatted(.number.precision(.fractionLength(decimals)))
    }
}
