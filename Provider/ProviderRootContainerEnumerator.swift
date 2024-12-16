//
//  ProviderRootContainerEnumerator.swift
//  Provider
//
//  Created by Wesley de Groot on 15/12/2024.
//

import Foundation
import ContactProvider
import Contacts
import OSLog

@main
class Provider: ContactProviderExtension {
    private let rootContainerEnumerator: ProviderRootContainerEnumerator

    required init() {
        // Initialize your extension here.
        rootContainerEnumerator = ProviderRootContainerEnumerator()
    }

    func configure(for domain: ContactProviderDomain) {
        // Configure your extension here.
        rootContainerEnumerator.configure(for: domain)
    }

    func enumerator(for collection: ContactItem.Identifier) -> ContactItemEnumerator {
        return rootContainerEnumerator
    }

    func invalidate() async throws {
        // TODO: Stop any enumeration and cleanup as the extension will be terminated.
    }
}

class ProviderRootContainerEnumerator: ContactItemEnumerator {
    let database = ContactItemDatabase()

    let logger = Logger(
        subsystem: "nl.wesleydegroot.debug",
        category: "ProviderRootContainerEnumerator"
    )

    func configure(for domain: ContactProviderDomain) {
        // TODO: If needed, configure your enumerator for the domain.
    }

    func enumerateContent(in page: ContactItemPage, for observer: ContactItemContentObserver) async {
        // Insert our contacts to the contact provider framework
        observer.didEnumerate(self.database.contactItems)

        // Say to the oberver that we have finished synchronisation
        observer.didFinishEnumeratingContent(upTo: "<currentDatabaseGenerationMarker>".data(using: .utf8)!)
    }


    func enumerateChanges(startingAt syncAnchor: ContactItemSyncAnchor, for observer: ContactItemChangeObserver) async {
        // update our contacts to the contact provider framework
        observer.didUpdate(self.database.contactItems)

        // In this demo we dont support "remove" altough it can be implemented by giving the identifiers for the deleted items
        // observer.didDelete(self.database.deletedItemIdentifiers)

        // Say to the oberver that we have finished synchronisation
        observer.didFinishEnumeratingChanges(
            upTo: ContactItemSyncAnchor(generationMarker: "<lastChangeGenerationMarker>".data(using: .utf8)!, offset: 0),
            moreComing: false
        )
    }


    func invalidate() async {
        // TODO: Stop the enumeration and cleanup as the extension will be terminated.
    }
}
