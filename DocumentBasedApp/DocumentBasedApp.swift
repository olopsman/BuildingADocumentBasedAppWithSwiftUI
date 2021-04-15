/*
See LICENSE folder for this sample’s licensing information.

Abstract:
The entry point into this app.
*/

import SwiftUI

/// - Tag: AppBody
@main
struct DocumentBasedApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { ChecklistDocument() }) { configuration in
            ChecklistView()
        }
    }
}
