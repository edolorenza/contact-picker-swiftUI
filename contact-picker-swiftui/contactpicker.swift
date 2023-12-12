//
//  ContactPickerView.swift
//  contact-picker-swiftui
//
//  Created by Edo Lorenza on 12/12/23.
//

import SwiftUI
import ContactsUI
import Combine

struct ContactPickerView: View {
    
    @State private var pickedNumber: String?
    @StateObject private var coordinator = Coordinator()
    
    var body: some View {
        VStack {
            Button("Open Contact Picker") {
                openContactPicker()
            }
            .padding()
            
            Text(pickedNumber ?? "")
                .padding()
        }
        .onReceive(coordinator.$pickedNumber, perform: { phoneNumber in
            self.pickedNumber = phoneNumber
        })
        .environmentObject(coordinator)
    }
    
    func openContactPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = coordinator
        contactPicker.displayedPropertyKeys = [CNContactPhoneNumbersKey]
        contactPicker.predicateForEnablingContact = NSPredicate(format: "phoneNumbers.@count > 0")
        contactPicker.predicateForSelectionOfContact = NSPredicate(format: "phoneNumbers.@count == 1")
        contactPicker.predicateForSelectionOfProperty = NSPredicate(format: "key == 'phoneNumbers'")
        let scenes = UIApplication.shared.connectedScenes
        let windowScenes = scenes.first as? UIWindowScene
        let window = windowScenes?.windows.first
        window?.rootViewController?.present(contactPicker, animated: true, completion: nil)
    }
     
    class Coordinator: NSObject, ObservableObject, CNContactPickerDelegate {
        @Published var pickedNumber: String?
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            // Clear the pickedNumber initially
            self.pickedNumber = nil
            
            // Check if the contact has selected phone numbers
            if let phoneNumber = contact.phoneNumbers.first?.value.stringValue {
                handlePhoneNumber(phoneNumber)
            }
        }
        
        func contactPicker(_ picker: CNContactPickerViewController, didSelect contactProperty: CNContactProperty) {
            
            if contactProperty.key == CNContactPhoneNumbersKey,
               let phoneNumber = contactProperty.value as? CNPhoneNumber {
                
                let phoneNumberString = phoneNumber.stringValue
                // Now phoneNumberString contains the phone number, which is "0877 88118918" in this case
                print("Phone Number: \(phoneNumberString)")
                
                // You can now use phoneNumberString as needed
                handlePhoneNumber(phoneNumberString)
            }
        }
        
        private func handlePhoneNumber(_ phoneNumber: String) {
            let phoneNumberWithoutSpace = phoneNumber.replacingOccurrences(of: " ", with: "")
            
            // Check if the phone number starts with "+"
            let sanitizedPhoneNumber = phoneNumberWithoutSpace.hasPrefix("+") ? String(phoneNumberWithoutSpace.dropFirst()) : phoneNumberWithoutSpace
            
            DispatchQueue.main.async {
                self.pickedNumber = sanitizedPhoneNumber
            }
        }
    }
}
