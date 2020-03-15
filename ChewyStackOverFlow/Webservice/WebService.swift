//
//  WebService.swift
//  ChewyStackOverFlow
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import Foundation

protocol WebService {
	func getModerators(for page: Int?, completion: @escaping (Result<[Moderator], Error>) -> Void)

}

// MARK: - Configuation
extension StackOverflowApiService {
	private enum OrderOptions: String {
		case decending = "desc"
		case ascending = "asc"
	}

	private enum Configuration {
		static let baseURL = "https://api.stackexchange.com/2.2/users/moderators"
		static let pageKey = "page"
		static let pageSizeKey = "pagesize"
		static let orderKey = "order"
		static let sortKey = "sort"
		static let siteKey = "site"
	}
}

// MARK: - WebService Implementation
final class StackOverflowApiService: WebService {
	enum ApiServiceError: Error {
		case couldNotParse
		case countNotCreateURL
	}

	static let shared = StackOverflowApiService()

	private let defaultSession: URLSession = {
		let session = URLSession(configuration: .default)
		return session
	}()

	private var dataTask: URLSessionDataTask?

	func getModerators(for page: Int?, completion: @escaping (Result<[Moderator], Error>) -> Void) {
		guard let request = generateURLRequest(for: page) else {
			completion(.failure(ApiServiceError.countNotCreateURL))
			return
		}

		dataTask = defaultSession.dataTask(with: request) { [weak self] (data, _, error) in 
			if let error = error {
				completion(Result.failure(error))
			}

			if let data = data, let responseObject = self?.encodeJSON(data, into: ResponseObject.self) {
				completion(Result.success(responseObject.items))
			} else {
				completion(Result.failure(ApiServiceError.couldNotParse))
			}
		}

		dataTask?.resume()
	}
}

// MARK: - URLRequest & Parsing
private extension StackOverflowApiService {

	enum DateError: Error {
		case invalidDate
	}

	func generateURLRequest(for page: Int?) -> URLRequest? {
		guard var urlComponents = URLComponents(string: Configuration.baseURL) else { return nil }

		var queries = [
			URLQueryItem(name: Configuration.pageSizeKey, value: "10"),
			URLQueryItem(name: Configuration.orderKey, value: OrderOptions.decending.rawValue),
			URLQueryItem(name: Configuration.sortKey, value: "reputation"),
			URLQueryItem(name: Configuration.siteKey, value: "stackoverflow")
		]

		if let page = page {
			let pageQuery = URLQueryItem(name: Configuration.pageKey, value: "\(page)")
			queries.append(pageQuery)
		}

		urlComponents.queryItems = queries

		if let url = urlComponents.url {
			return URLRequest(url: url)
		}
		return nil
	}

	func encodeJSON<T: Decodable>(_ data: Data, into type: T.Type) -> T? {
		do {
			let decoder = JSONDecoder()
			decoder.keyDecodingStrategy = .convertFromSnakeCase
			let object = try decoder.decode(type, from: data)
			return object

		} catch {
			if let decodingError = error as? DecodingError {
				print("decoding Error: \(decodingError.errorDescription as Any)")
			}
		}
		return nil
	}
}
