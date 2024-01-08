//
//  Location.swift
//  BucketList
//
//  Created by Noalino on 09/01/2024.
//

import Foundation

struct Location: Codable, Equatable, Identifiable {
    let id: UUID
    var name: String
    var description: String
    var latitude: Double
    var longitude: Double
}
