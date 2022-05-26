//
//  NewProfile.swift
//  Profile
//
//  Created by Reyhan Rifqi Azzami on 23/05/22.
//  Copyright © 2022 Adrena Teknologi Indonesia. All rights reserved.
//

import Foundation
import Platform

// MARK: - DataClass
public struct NewProfile: Codable {
    public let id, email, name, phoneNumber: String
    public let username, facebookID, googleID: String?
    public let type: User.Kind
    public let metadata: [Metadata]?
    public let favorite, jobDone: Int?
    public let rating: Double?
    public let category: [Category]?
    public let avatar: Media?
    public let isVerified: Bool?
    public let bio: String?
    public let idCard: String?
    public let status: String?
    public var hasAddress: Bool

    enum CodingKeys: String, CodingKey {
        case id
        case email, name, username
        case facebookID = "facebook_id"
        case googleID = "google_id"
        case phoneNumber = "phone_number"
        case type, metadata, favorite, jobDone, rating, category
        case avatar
        case isVerified
        case bio
        case idCard
        case status
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .email)
        email = try container.decode(String.self, forKey: .name)
        phoneNumber = try container.decode(String.self, forKey: .phoneNumber)
        
        username = try container.decodeIfPresent(String.self, forKey: .username)
        facebookID = try container.decodeIfPresent(String.self, forKey: .facebookID)
        googleID = try container.decodeIfPresent(String.self, forKey: .googleID)
        
        let userType = try container.decode(String.self, forKey: .type)
        type = User.Kind(rawValue: userType) ?? .artisan
        
        metadata = try container.decodeIfPresent([Metadata].self, forKey: .metadata)
        favorite = try container.decodeIfPresent(Int.self, forKey: .favorite)
        jobDone = try container.decodeIfPresent(Int.self, forKey: .jobDone)
        
        rating = try container.decodeIfPresent(Double.self, forKey: .rating)
        category = try container.decodeIfPresent([Category].self, forKey: .category)
        let avatarURL = try container.decodeIfPresent(URL.self, forKey: .avatar)
        if let avatarURL = avatarURL {
            avatar = Media(url: avatarURL, servingURL: nil)
        } else {
            avatar = nil
        }
        
        isVerified = try container.decodeIfPresent(Bool.self, forKey: .isVerified)
        bio = try container.decodeIfPresent(String.self, forKey: .bio)
        idCard = try container.decodeIfPresent(String.self, forKey: .idCard)
        status = try container.decodeIfPresent(String.self, forKey: .status)
        
        hasAddress = false
    }
    
    // MARK: - Category
    public struct Category: Codable {
        public let id: Int
        public let name, status: String
        
        enum CodingKeys: String, CodingKey{
            case id
            case name
            case status
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            id = try container.decode(Int.self, forKey: .id)
            name = try container.decode(String.self, forKey: .name)
            status = try container.decode(String.self, forKey: .status)
        }
    }

    // MARK: - Metadatum
    public struct Metadata: Codable {
        public let categories, instagram, birthdate: String?
        
        enum CodingKeys: String, CodingKey{
            case categories
            case instagram
            case birthdate
        }
        
        public init(from decoder: Decoder) throws {
            let container = try decoder.container(keyedBy: CodingKeys.self)
            
            categories = try container.decodeIfPresent(String.self, forKey: .categories)
            instagram = try container.decodeIfPresent(String.self, forKey: .instagram)
            birthdate = try container.decodeIfPresent(String.self, forKey: .birthdate)
        }
    }
    
}

extension NewProfile{
    public var categoryTitles: String? {
        return category?.map { $0.name }.joined(separator: ", ")
    }
}
