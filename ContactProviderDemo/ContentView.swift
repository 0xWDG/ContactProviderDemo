//
//  ContentView.swift
//  ContactProviderDemo
//
//  Created by Wesley de Groot on 15/12/2024.
//

import SwiftUI
import ContactProvider

struct ContentView: View {
    @ObservedObject
    var database = ContactItemDatabase()

    @State var firstName: String = ""
    @State var lastName: String = ""
    @State var email: String = ""
    @State var phoneNumber: String = ""

    let manager = try! ContactProviderManager()

    var body: some View {
        VStack {
            Button("Send to contact provider") {
                Task {
                    await synchroniseContacts() // Synchronise contacts
                }
            }
            .buttonStyle(.borderedProminent)
            Button("Reset Database") {
                Task {
                    database.reset() // Reset the database
                    try? await manager.reset() // Reset all previously known contacts.
                }
            }
            .buttonStyle(.borderedProminent)

            List {
                ForEach(database.contactItemsJSON, id: \.firstName) { item in
                    Text("\(item.firstName) \(item.lastName)")
                }
            }

            GroupBox {
                TextField("First name", text: $firstName)
                TextField("Last name", text: $lastName)
                TextField("Email", text: $email)
                TextField("Phone number", text: $phoneNumber)

                Button("Add") {
                    saveToDatabase()
                }
            }
            .task {
                randomContact()
            }
            .background(.secondary)
        }
        .padding()
        .task {
            do {
                // May prompt the person to enable the default domain.
                try await manager.enable()
            } catch {
                // Handle the error.
            }
        }
    }

    func randomContact() {
        firstName = ["John", "Jane", "Wesley", "Alice", "Bob"].randomElement()!
        lastName = ["Doe", "Smith", "de Groot", "Johnson", "Williams"].randomElement()!
        email = "\(firstName.lowercased()).\(lastName.lowercased())@example.com"
        phoneNumber = "+31612345678"
    }

    func saveToDatabase() {
        database.save(
            .init(
                firstName: firstName,
                lastName: lastName,
                phoneNumber: phoneNumber == "" ? nil : phoneNumber,
                emailAddress: email == "" ? nil : email
            )
        )

        Task {
            randomContact()
        }
    }

    func synchroniseContacts() async {
        do {
            try await manager.signalEnumerator()
        } catch {
            // Handle the error.
            print(error)
        }
    }
}

#Preview {
    ContentView()
}
