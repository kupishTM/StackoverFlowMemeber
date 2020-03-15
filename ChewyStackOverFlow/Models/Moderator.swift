//
//  Moderator.swift
//  ChewyStackOverFlow
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import Foundation

struct ResponseObject: Decodable {
	let items: [Moderator]
}

struct Moderator: Decodable {
	let userId: Int
	let reputation: Int
	let profileImage: URL?
	let displayName: String
	let badgeCounts: BadgeCounts

	enum CodingKeys: String, CodingKey {
		case userId
		case reputation
		case profileImage
		case displayName
		case badgeCounts
	}

	public init(from decoder: Decoder) throws {
		let container = try decoder.container(keyedBy: CodingKeys.self)
		userId = try container.decode(Int.self, forKey: .userId)
		reputation = try container.decode(Int.self, forKey: .reputation)
		displayName = try container.decode(String.self, forKey: .displayName)
		badgeCounts = try container.decode(BadgeCounts.self, forKey: .badgeCounts)

		let stringURL = try container.decode(String.self, forKey: .profileImage)
		profileImage = URL(string: stringURL)
	}

	init(userId: Int, reputation: Int, profileImage: URL?, displayName: String, badgeCounts: BadgeCounts) {
		self.userId = userId
		self.reputation = reputation
		self.profileImage = profileImage
		self.displayName = displayName
		self.badgeCounts = badgeCounts
	}
}

struct BadgeCounts: Decodable {
	let gold: Int
	let silver: Int
	let bronze: Int
}
