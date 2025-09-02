//
//  ContentView.swift
//  tip calc
//
//  Created by Jonas Larson on 02-09-2025.
//

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

struct ContentView: View {
    @State private var amountText: String = ""
    @State private var selectedPercentage: Int = 20
    @State private var splitCount: Int = 1
    @State private var copiedLabel: String? // optional place to hold a copied confirmation label if you later want to show a toast

    private let percentageOptions: [Int] = Array(stride(from: 0, through: 30, by: 5))
    private let splitOptions: [Int] = Array(1...10)

    private var currencySymbol: String {
        Locale.current.currencySymbol ?? "$"
    }

    private var currencyCode: String {
        Locale.current.currency?.identifier ?? "USD"
    }

    private var amount: Double {
        Double(amountText.replacingOccurrences(of: ",", with: ".")) ?? 0
    }

    private var percentage: Double {
        Double(selectedPercentage)
    }

    private var percentageAmount: Double {
        amount * (percentage / 100.0)
    }

    private var total: Double {
        amount + percentageAmount
    }

    private var perPersonTotal: Double {
        guard splitCount > 0 else { return 0 }
        return total / Double(splitCount)
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("Input") {
                    ZStack(alignment: .leading) {
                        if !amountText.isEmpty {
                            Text(currencySymbol)
                                .foregroundStyle(.secondary)
                                .padding(.leading, 6)
                        }

                        TextField("Amount", text: $amountText)
                            .keyboardType(.decimalPad)
                            .padding(.leading, amountText.isEmpty ? 0 : 18) // add space only when symbol is visible
                    }

                    Picker("Percentage", selection: $selectedPercentage) {
                        ForEach(percentageOptions, id: \.self) { value in
                            Text("\(value)%").tag(value)
                        }
                    }
                    .pickerStyle(.menu)

                    Picker("Split", selection: $splitCount) {
                        ForEach(splitOptions, id: \.self) { value in
                            Text("\(value) \(value == 1 ? "person" : "people")").tag(value)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("Result") {
                    resultRow(
                        title: "Base amount",
                        value: amount.formatted(.currency(code: currencyCode))
                    )

                    resultRow(
                        title: "Added percentage (\(selectedPercentage)%)",
                        value: percentageAmount.formatted(.currency(code: currencyCode))
                    )

                    resultRow(
                        title: "Total",
                        value: total.formatted(.currency(code: currencyCode)),
                        emphasize: true
                    )

                    if splitCount > 1 {
                        resultRow(
                            title: "Per person (x\(splitCount))",
                            value: perPersonTotal.formatted(.currency(code: currencyCode)),
                            emphasize: true
                        )
                    }
                }
            }
            .navigationTitle("Tip Calculator")
        }
    }

    // MARK: - Row builder with context menu

    @ViewBuilder
    private func resultRow(title: String, value: String, emphasize: Bool = false) -> some View {
        HStack {
            Text(title)
                .fontWeight(emphasize ? .semibold : .regular)
            Spacer()
            Text(value)
                .foregroundStyle(emphasize ? .primary : .secondary)
                .fontWeight(emphasize ? .semibold : .regular)
        }
        .contentShape(Rectangle()) // make whole row tappable for context menu
        .contextMenu {
            Button {
                copyToPasteboard(value)
                // If you want a visible confirmation later, you can set:
                // copiedLabel = "\(title) copied"
            } label: {
                Label("Copy", systemImage: "doc.on.doc")
            }
        }
        .accessibilityHint("Press and hold to copy")
    }

    // MARK: - Copy helper

    private func copyToPasteboard(_ text: String) {
        #if canImport(UIKit)
        UIPasteboard.general.string = text
        #elseif canImport(AppKit)
        let pb = NSPasteboard.general
        pb.clearContents()
        pb.setString(text, forType: .string)
        #endif
    }
}

#Preview {
    ContentView()
}
