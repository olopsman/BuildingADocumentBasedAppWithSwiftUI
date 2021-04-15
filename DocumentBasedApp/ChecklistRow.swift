/*
See LICENSE folder for this sample’s licensing information.

Abstract:
This file defines the view of a checklist row.
*/

import SwiftUI

struct ChecklistRow: View {
    @Binding var item: ChecklistItem
    
    // Define these handlers as properties that you initialize
    // at the callsite to facilitate preview and testing.
    var onCheckToggle: () -> Void
    var onTextCommit: (_ oldTitle: String) -> Void
    
    @State private var oldTitle: String = ""
        
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Button {
                onCheckToggle()
            } label: {
                Image(systemName: item.isChecked ? "checkmark.square" : "square")
            }
            .buttonStyle(BorderlessButtonStyle())
            
            TextField("", text: $item.title) { isEditing in
                // When editing starts, save the old title for undo purposes.
                if isEditing {
                    // Save the old title when editing starts.
                    oldTitle = item.title
                }
            } onCommit: {
                // The commit handler registers an undo action using the old title.
                onTextCommit(oldTitle)
            }

            Spacer()
        }
    }
}

struct ChecklistRow_Previews: PreviewProvider {
    
    // Define a shim for the preview of ChecklistRow.
    struct RowContainer: View {
        @StateObject private var document = ChecklistDocument()

        var body: some View {
            ChecklistRow(item: $document.checklist.items[0]) {
                document.toggleItem(document.checklist.items[0])
            } onTextCommit: { _ in
                
            }
        }
    }

    static var previews: some View {
        RowContainer()
            .previewLayout(.sizeThatFits)
    }
}
