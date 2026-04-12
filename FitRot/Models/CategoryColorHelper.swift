//
//  CategoryColorHelper.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/9/26.
//

import SwiftUI

enum CategoryColorHelper {
    static func color(for categoryName: String) -> Color {
        let name = categoryName.lowercased()
        if name.contains("social") { return .blue }
        if name.contains("entertainment") { return .purple }
        if name.contains("productivity") { return .green }
        if name.contains("finance") { return .cyan }
        if name.contains("education") { return .orange }
        if name.contains("game") { return .red }
        if name.contains("health") { return .pink }
        if name.contains("shopping") { return .yellow }
        if name.contains("news") || name.contains("reading") { return .indigo }
        if name.contains("photo") || name.contains("creativity") { return .mint }
        return .gray
    }

    static func icon(for categoryName: String) -> String {
        let name = categoryName.lowercased()
        if name.contains("social") { return "bubble.left.and.bubble.right.fill" }
        if name.contains("entertainment") { return "tv.fill" }
        if name.contains("productivity") { return "briefcase.fill" }
        if name.contains("finance") { return "dollarsign.circle.fill" }
        if name.contains("education") { return "book.fill" }
        if name.contains("game") { return "gamecontroller.fill" }
        if name.contains("health") { return "heart.fill" }
        if name.contains("shopping") { return "cart.fill" }
        if name.contains("news") || name.contains("reading") { return "newspaper.fill" }
        if name.contains("photo") || name.contains("creativity") { return "paintbrush.fill" }
        return "square.grid.2x2.fill"
    }
}
