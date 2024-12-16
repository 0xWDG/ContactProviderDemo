//
//  ContactItemDatabase.swift
//  ContactProviderDemo
//
//  Created by Wesley de Groot on 15/12/2024.
//

import Foundation
import Contacts
import ContactProvider
import OSLog

class ContactItemDatabase: ObservableObject {
    @Published public var contactItems: [ContactItem] = []
    @Published public var contactItemsJSON: [ContactItemJSON] = []

    private let logger = Logger(subsystem: "nl.wesleydegroot.debug", category: "ContactItemDatabase")
    private let fileURL = FileManager.default.containerURL(
        // App Group identifier.
        forSecurityApplicationGroupIdentifier: "group.nl.wesleydegroot.contactproviderdemo"
    )?.appendingPathComponent("ContactItems").appendingPathExtension("json")

    struct ContactItemJSON: Codable, Hashable {
        var identifier: String = UUID().uuidString
        var firstName: String
        var lastName: String
        var phoneNumber: String?
        var emailAddress: String?
    }

    init() {
        guard let fileURL else {
            logger.error("Could not find file URL.")
            return
        }

        self.logger.debug("Database URL: \(fileURL)")
        // Load items from a shared database.
        if let data = try? Data(contentsOf: fileURL) {
            let decoder = JSONDecoder()
            if let decoded = try? decoder.decode([ContactItemJSON].self, from: data) {
                contactItemsJSON = Array(Set(decoded)) // Remove any doubles
                self.logger.debug("Loaded \(self.contactItemsJSON.count) items.")

                for item in contactItemsJSON {
                    let contact: CNMutableContact = .init()
                    contact.givenName = item.firstName
                    contact.familyName = item.lastName

                    if let phoneNumber = item.phoneNumber {
                        contact.phoneNumbers = [
                            .init(
                                label: "Mobile",
                                value: CNPhoneNumber(stringValue: phoneNumber)
                            )
                        ]
                    }
                    if let emailAddress = item.emailAddress {
                        contact.emailAddresses = [
                            .init(
                                label: "Email",
                                value: emailAddress as NSString
                            )
                        ]
                    }

                    let identifier: ContactItem.Identifier = .init(item.identifier)

                    if !contactItems.contains(where: { $0 == .contact(contact, identifier) }) {
                        logger.debug("Adding \(item.firstName) to database")

                        contactItems.append(
                            .contact(contact, identifier)
                        )
                    }
                }
            }
        }
    }

    func reset() {
        contactItems.removeAll()
        contactItemsJSON.removeAll()

        try? JSONEncoder().encode(contactItemsJSON).write(to: fileURL!)
    }

    deinit {

        try? JSONEncoder().encode(contactItemsJSON).write(to: fileURL!)
        logger.debug("[DEINIT] Did save \(self.contactItemsJSON.count) entries")
    }


    func remove(_ contactItem: ContactItemJSON) {
        logger.debug("Did remove \(contactItem.firstName)")
        contactItemsJSON = contactItemsJSON
            .filter {
                $0.firstName != contactItem.firstName &&
                $0.lastName != contactItem.lastName
            }
    }

    func save(_ contactItem: ContactItemJSON) {
        contactItemsJSON.append(contactItem)

        do {
            try JSONEncoder().encode(contactItemsJSON).write(to: fileURL!)
            logger.debug("Did save \(self.contactItemsJSON.count) entries")
        } catch {
            print(error)
        }
    }
}
