// Copyright (c) Microsoft Corporation. All rights reserved.
// Author: Vikrant Singh (github.com/VikrantSingh01)
// Licensed under the MIT License.

import SwiftUI
import ACCore

/// Floating diagnostics overlay for debugging Adaptive Card rendering.
/// Shows element count, parse time, and an expandable detail panel.
struct DiagnosticsOverlayView: View {
    let card: AdaptiveCard
    let parseTimeMs: Double

    @State private var isExpanded = false

    private var elementCount: Int {
        countElements(card.body ?? [])
    }

    private var actionCount: Int {
        (card.actions ?? []).count
    }

    var body: some View {
        VStack(alignment: .trailing, spacing: 0) {
            // Floating badge — always visible
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack(spacing: 4) {
                    Image(systemName: "info.circle.fill")
                        .font(.system(size: 10))
                    Text("\(elementCount) elements")
                        .font(.system(size: 9, weight: .medium, design: .monospaced))
                    if parseTimeMs > 0 {
                        Text("• \(String(format: "%.1f", parseTimeMs))ms")
                            .font(.system(size: 9, weight: .medium, design: .monospaced))
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Color.black.opacity(0.75))
                .foregroundColor(.white)
                .cornerRadius(4)
            }
            .buttonStyle(.plain)

            // Expanded detail panel
            if isExpanded {
                VStack(alignment: .leading, spacing: 6) {
                    Group {
                        detailRow("Elements", "\(elementCount)")
                        detailRow("Actions", "\(actionCount)")
                        detailRow("Parse", "\(String(format: "%.2f", parseTimeMs))ms")
                        detailRow("Version", card.version ?? "–")
                        if let lang = card.lang { detailRow("Lang", lang) }
                        if card.rtl == true { detailRow("RTL", "true") }
                        if card.refresh != nil { detailRow("Refresh", "configured") }
                    }
                }
                .padding(8)
                .background(Color.black.opacity(0.85))
                .foregroundColor(.white)
                .cornerRadius(6)
                .frame(maxWidth: 200)
                .transition(.opacity.combined(with: .scale(scale: 0.9, anchor: .topTrailing)))
            }
        }
    }

    private func detailRow(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .frame(width: 60, alignment: .leading)
            Text(value)
                .font(.system(size: 9, design: .monospaced))
        }
    }

    private func countElements(_ elements: [CardElement]) -> Int {
        var count = 0
        for element in elements {
            count += 1
            switch element {
            case .container(let c):
                count += countElements(c.items ?? [])
            case .columnSet(let cs):
                for col in cs.columns {
                    count += countElements(col.items ?? [])
                }
            case .table(let t):
                for row in t.rows {
                    for cell in row.cells {
                        count += countElements(cell.items ?? [])
                    }
                }
            default:
                break
            }
        }
        return count
    }
}
