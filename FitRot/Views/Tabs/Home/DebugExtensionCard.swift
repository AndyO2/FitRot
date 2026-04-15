//
//  DebugExtensionCard.swift
//  FitRot
//
//  Temporary debug view — remove before shipping.
//

import SwiftUI

struct DebugExtensionCard: View {
    @State private var isExpanded = false
    @State private var values: [String: String] = [:]
    @State private var confirmationMessage: String?

    private let defaults = AppGroupConstants.sharedDefaults
    private let keys = [
        "debug_intervalDidStart",
        "debug_intervalDidEnd",
        "debug_selectionLoaded",
        "debug_monitorError",
        "debug_monitorErrorTime",
    ]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button {
                withAnimation { isExpanded.toggle() }
                if isExpanded { refresh() }
            } label: {
                HStack {
                    Text("Extension Debug")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundStyle(.secondary)
                    Spacer()
                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundStyle(.secondary)
                }
            }
            .buttonStyle(.plain)

            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(keys, id: \.self) { key in
                        HStack(alignment: .top) {
                            Text(key.replacingOccurrences(of: "debug_", with: ""))
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                                .frame(width: 120, alignment: .leading)
                            Text(values[key] ?? "—")
                                .font(.caption2.monospaced())
                                .foregroundStyle(.primary)
                        }
                    }
                }

                Button("Refresh") {
                    refresh()
                    confirmationMessage = "Refreshed!"
                }
                .font(.caption2)
                .buttonStyle(.bordered)
                .controlSize(.regular)
                .frame(maxWidth: .infinity)

                Button("Clear") {
                    for key in keys { defaults.removeObject(forKey: key) }
                    refresh()
                    confirmationMessage = "Cleared!"
                }
                .font(.caption2)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .controlSize(.regular)
                .frame(maxWidth: .infinity)
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .alert("Debug", isPresented: Binding(
            get: { confirmationMessage != nil },
            set: { if !$0 { confirmationMessage = nil } }
        )) {
            Button("OK") { confirmationMessage = nil }
        } message: {
            Text(confirmationMessage ?? "")
        }
    }

    private func refresh() {
        var result: [String: String] = [:]
        for key in keys {
            if let val = defaults.object(forKey: key) {
                if let ts = val as? Double {
                    let date = Date(timeIntervalSince1970: ts)
                    let fmt = DateFormatter()
                    fmt.dateFormat = "HH:mm:ss"
                    result[key] = fmt.string(from: date)
                } else {
                    result[key] = "\(val)"
                }
            }
        }
        values = result
    }
}
