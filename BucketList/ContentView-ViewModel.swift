//
//  ContentView-ViewModel.swift
//  BucketList
//
//  Created by Noalino on 10/01/2024.
//

import CoreLocation
import Foundation
import LocalAuthentication
import MapKit
import SwiftUI

extension ContentView {
    @Observable
    class ViewModel {
        private(set) var locations: [Location]
        var selectedPlace: Location?
        var isUnlocked = false
        var mapStyle: Int = 0
        var showAlert = false
        var alertTitle = ""
        var alertMessage = ""

        var selectedMapStyle: MapStyle {
            switch mapStyle {
            case 0: .standard
            case 1: .hybrid
            case 2: .imagery
            default: .standard
            }
        }

        let savePath = URL.documentsDirectory.appending(path: "SavedPlaces")

        init() {
            do {
                let data = try Data(contentsOf: savePath)
                locations = try JSONDecoder().decode([Location].self, from: data)
            } catch {
                locations = []
            }
        }

        func save() {
            do {
                let data = try JSONEncoder().encode(locations)
                try data.write(to: savePath, options: [.atomic, .completeFileProtection])
            } catch {
                print("Unable to save data.")
            }
        }

        func addLocation(at point: CLLocationCoordinate2D) {
            let newLocation = Location(id: UUID(), name: "New location", description: "", latitude: point.latitude, longitude: point.longitude)
            locations.append(newLocation)
            save()
        }

        func update(location: Location) {
            guard let selectedPlace else { return }

            if let index = locations.firstIndex(of: selectedPlace) {
                locations[index] = location
                save()
            }
        }

        func authenticate() {
            let context = LAContext()
            var error: NSError?

            if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
                let reason = "Please authenticate yourself to unlock your places."

                context.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason) { [weak self] success, authenticateError in
                    guard let self = self else { return }

                    if success {
                        self.isUnlocked = true
                    } else {
                        self.alertTitle = "Unable to authenticate"
                        self.alertMessage = "You biometrics don't match. Please try again later."
                        self.showAlert = true
                    }
                }
            } else {
                self.alertTitle = "No biometrics found"
                self.alertMessage = "Please make sure to enable biometrics."
                self.showAlert = true
            }
        }
    }
}
