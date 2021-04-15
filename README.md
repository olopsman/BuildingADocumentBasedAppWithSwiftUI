# Building a Document-Based App with SwiftUI

Create, save, and open documents in a SwiftUI multiplatform app.

## Overview

This sample creates a checklist document that can have one or more checklist items. The user can select and deselect the checkboxes of items in the list, add and delete items, and rearrange items. The sample implements a [`DocumentGroup`](https://developer.apple.com/documentation/swiftui/documentgroup) scene, and adopts the [`ReferenceFileDocument`](https://developer.apple.com/documentation/swiftui/referencefiledocument) protocol.

## Configure the Sample Code Project

To build and run this sample on your device, you must first select your development team for the project's target using these steps:
1. Open the sample with the latest version of Xcode.
2. Select the top-level project.
3. For the project's target, choose your team from the Team drop-down menu in the Signing & Capabilities pane to let Xcode automatically manage your provisioning profile.

## Create the Data Model

This sample is a simple checklist app that keeps track of one or more items in a checklist, and whether the checkboxes of the items are in a selected state. The app has a data model that defines `ChecklistItem` and `Checklist` objects, and these objects conform to [`Codable`](https://developer.apple.com/documentation/swift/codable) to enable easy serialization. They also conform to [`Identifiable`](https://developer.apple.com/documentation/swift/identifiable) for unique identification during enumeration.
``` swift
struct ChecklistItem: Identifiable, Codable {
    var id = UUID()
    var isChecked = false
    var title: String
}

struct Checklist: Identifiable, Codable {
    var id = UUID()
    var items: [ChecklistItem]
}
```
[View in Source](x-source-tag://DataModel)

## Export the App's Document Type

The app defines and exports a custom checklist document type that tells the operating system to open checklist documents with this app. The app does this by including an entry in its [Information Property List](https://developer.apple.com/documentation/bundleresources/information_property_list) file under the [`CFBundleDocumentTypes`](https://developer.apple.com/documentation/bundleresources/information_property_list/cfbundledocumenttypes) and [`UTExportedTypeDeclarations`](https://developer.apple.com/documentation/bundleresources/information_property_list/utexportedtypedeclarations) keys.
Additionally, the sample defines the bundle's exported type as a [Uniform Type Identifier](https://developer.apple.com/documentation/uniformtypeidentifiers/uttype) to support the sample app's data format.
``` swift
extension UTType {
    static let checklistDocument = UTType(exportedAs: "com.example.checklist")
}
```

For more information, see [Defining File and Data Types for Your App](https://developer.apple.com/documentation/uniformtypeidentifiers/defining_file_and_data_types_for_your_app).

## Define the App's Scene

A document-based SwiftUI app returns a [`DocumentGroup`](https://developer.apple.com/documentation/swiftui/documentgroup) scene from its `body` property. The `newDocument` parameter that an app supplies to the document group's [init(newDocument:editor:)](https://developer.apple.com/documentation/swiftui/documentgroup/init(newdocument:editor:)-4toe2) initializer must conform to [`FileDocument`](https://developer.apple.com/documentation/swiftui/filedocument) or [`ReferenceFileDocument`](https://developer.apple.com/documentation/swiftui/referencefiledocument). This sample adopts `ReferenceFileDocument`. The trailing closure of the initializer returns a view that renders the document's contents.
``` swift
@main
struct DocumentBasedApp: App {
    var body: some Scene {
        DocumentGroup(newDocument: { ChecklistDocument() }) { configuration in
            ChecklistView()
        }
    }
}
```
[View in Source](x-source-tag://AppBody)

## Adopt the Reference File Document Protocol

The sample's `ChecklistDocument` structure adopts the [`ReferenceFileDocument`](https://developer.apple.com/documentation/swiftui/referencefiledocument) protocol to serialize checklists to and from files. This sample implements the required properties and methods to conform to the protocol. The [`readableContentTypes`](https://developer.apple.com/documentation/swiftui/filedocument/readablecontenttypes) property defines the types that the sample can read, namely, the `.checklistDocument` type.
``` swift
static var readableContentTypes: [UTType] { [.checklistDocument] }
```
[View in Source](x-source-tag://ContentType)

The sample reads data from a document in the [`init(configuration:)`](https://developer.apple.com/documentation/swiftui/filedocument/init(configuration:)) method. After reading the file's data, the initializer uses a [`JSONDecoder`](https://developer.apple.com/documentation/foundation/jsondecoder) to deserialize the data into model objects.
``` swift
init(configuration: ReadConfiguration) throws {
    guard let data = configuration.file.regularFileContents
    else {
        throw CocoaError(.fileReadCorruptFile)
    }
    self.checklist = try JSONDecoder().decode(Checklist.self, from: data)
}
```
[View in Source](x-source-tag://DocumentInit)

When the user saves the document, the sample returns a snapshot of the document's data for serialization in the [`snapshot(contentType:)`](https://developer.apple.com/documentation/swiftui/referencefiledocument/snapshot(contenttype:)) instance method.
``` swift
func snapshot(contentType: UTType) throws -> Checklist {
    checklist // Make a copy.
}
```
[View in Source](x-source-tag://Snapshot)

Conversely, in the [`fileWrapper(configuration:)`](https://developer.apple.com/documentation/swiftui/filedocument/filewrapper(configuration:)) method, a [`JSONEncoder`](https://developer.apple.com/documentation/foundation/jsonencoder) instance serializes the data model into a `FileWrapper` object that represents the data in the file system.
``` swift
func fileWrapper(snapshot: Checklist, configuration: WriteConfiguration) throws -> FileWrapper {
    let data = try JSONEncoder().encode(snapshot)
    let fileWrapper = FileWrapper(regularFileWithContents: data)
    return fileWrapper
}
```
[View in Source](x-source-tag://FileWrapper)

## Register Undo and Redo Actions
In an app that uses `FileDocument` for its document object, undo management and the registration of undo actions are automatic. However, because this sample uses a `ReferenceFileDocument` document class, the sample itself must perform undo management. Implementing undo management also alerts SwiftUI when the document changes. The [`UndoManager`](https://developer.apple.com/documentation/foundation/undomanager) class handles undo management, and SwiftUI supplies an instance of this class in the environment.
``` swift
@Environment(\.undoManager) var undoManager
```
[View in Source](x-source-tag://UndoManager)

In this sample, the SwiftUI views handle user actions by calling the `ChecklistDocument` and passing along the `UndoManager` object.
``` swift
document.toggleItem(item.wrappedValue, undoManager: undoManager)
```
[View in Source](x-source-tag://ToggleAction)

The `ChecklistDocument` toggles the `isChecked` state of the `ChecklistItem`, and registers an undo action that calls itself. This way, the sample doesn't need to register a redo action when performing an undo action.
``` swift
func toggleItem(_ item: ChecklistItem, undoManager: UndoManager? = nil) {
    let index = checklist.items.firstIndex(of: item)!
    
    checklist.items[index].isChecked.toggle()
    
    undoManager?.registerUndo(withTarget: self) { doc in
        // Because it calls itself, this is redoable, as well.
        doc.toggleItem(item, undoManager: undoManager)
    }
}
```
[View in Source](x-source-tag://PerformToggle)
