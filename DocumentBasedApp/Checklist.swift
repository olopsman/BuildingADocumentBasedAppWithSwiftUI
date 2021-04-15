/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This file defines `Checklist` and `ChecklistItem`.
*/

import Foundation

/// - Tag: DataModel
struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var isChecked = false
    var title: String
}

struct Checklist: Identifiable, Codable {
    var id = UUID()
    var items: [ChecklistItem]
}

extension ChecklistItem: Equatable {
    static func ==(lhs: ChecklistItem, rhs: ChecklistItem) -> Bool {
        lhs.id == rhs.id
    }
}

// Provide some default content.
extension Checklist {
    // Provide an empty list.
    static let emptyList = Checklist(items: [])
    
    // Provide some starter content.
    static let item1 = ChecklistItem(title: "Item 1.")
    static let item2 = ChecklistItem(title: "Item 2.")
    static let item3 = ChecklistItem(title: "Item 3.")
    
    static let demoList = Checklist(items: [ item1, item2, item3 ])
}

// Define some operations.
extension Checklist {
    mutating func addItem(item: ChecklistItem) {
        items.append(item)
    }
    
    mutating func addItem(title: String) {
        addItem(item: ChecklistItem(title: title))
    }
}
