//
//  ModeratorListPresenter.swift
//  ChewyStackOverFlow
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import Foundation

// MARK: - Entity Model
extension ModeratorListPresenter {
	class DataNavigator {
		var moderators: [Moderator]
		var currentPage: Int

		init() {
			moderators = [Moderator]()
			currentPage = 0
		}

		func reset() {
			moderators.removeAll()
			currentPage = 0
		}

		func append(_ entries: [Moderator]) {
			self.moderators += entries
		}

		@discardableResult
		func nextPage() -> Int {
			currentPage += 1
			return currentPage
		}

		func previousPage() {
			let previousPage = currentPage - 1
			currentPage = previousPage >= 0 ? previousPage : 0
		}
	}
}

// MARK: - Class Definition
final class ModeratorListPresenter {

	private let webService: WebService
	private weak var view: ModeratorListViewControllerInput?

	private var entity = DataNavigator()
	private var isLoadingData = false

	init(_ webService: WebService = StackOverflowApiService.shared, view: ModeratorListViewControllerInput) {
		self.view = view
		self.webService = webService
	}
}

// MARK: - ModeratorListViewControllerOutput
extension ModeratorListPresenter: ModeratorListViewControllerOutput {
	func getModerators() {
		isLoadingData = true
		entity.reset()

		webService.getModerators(for: nil) { [weak self] (result) in
			self?.isLoadingData = false

			switch result {
			case .success(let moderators):
				self?.entity.append(moderators)
				self?.entity.nextPage()

				let viewModels: [UserTableViewCell.ViewModel] = moderators.map {
					UserTableViewCell.ViewModel(name: $0.displayName,
												imageUrl: $0.profileImage,
												reputation: $0.reputation,
												goldCount: $0.badgeCounts.gold,
												silverCount: $0.badgeCounts.silver,
												browzeCount: $0.badgeCounts.bronze)
				}

				DispatchQueue.main.async {
					self?.view?.apply(viewModels)
				}
			case .failure:
				DispatchQueue.main.async {
					self?.view?.failedToFetch()
				}

			}
		}
	}

	func getNextPage() {
		isLoadingData = true

		webService.getModerators(for: entity.nextPage()) { [weak self] (result) in
			self?.isLoadingData = false

			switch result {
			case .success(let moderators):
				print(moderators)
				guard let strongSelf = self else {
					self?.entity.previousPage()
					self?.view?.failedToGetNextPage()
					return
				}

				strongSelf.entity.append(moderators)

				let viewModels: [UserTableViewCell.ViewModel] = strongSelf.entity.moderators.map {
					UserTableViewCell.ViewModel(name: $0.displayName,
												imageUrl: $0.profileImage,
												reputation: $0.reputation,
												goldCount: $0.badgeCounts.gold,
												silverCount: $0.badgeCounts.silver,
												browzeCount: $0.badgeCounts.bronze)
				}

				DispatchQueue.main.async {
					strongSelf.view?.apply(viewModels)
				}

			case .failure:
				self?.entity.previousPage()
				self?.view?.failedToGetNextPage()
			}
		}
	}
}
