//
//  ModeratorListPresenterTestCase.swift
//  ModeratorListPresenterTestCase
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import XCTest
@testable import ChewyStackOverFlow

class ModeratorListPresenterTestCase: XCTestCase {

	private enum MockError: Error {
		case forcedError
	}

	private class MockView: ModeratorListViewControllerInput {
		var failedToFetchClosure: ((Bool) -> Void)?
		func failedToFetch() {
			failedToFetchClosure?(true)
		}

		var failedToGetNextPageClosure: ((Bool) -> Void)?
		func failedToGetNextPage() {
			failedToGetNextPageClosure?(true)
		}

		var appliedViewModelClosure: (([UserTableViewCell.ViewModel]) -> Void)?
		func apply(_ viewModel: [UserTableViewCell.ViewModel]) {
			appliedViewModelClosure?(viewModel)
		}
	}

	private class MockWebService: WebService {

		var stubResult: Result<[Moderator], Error>?

		func getModerators(for page: Int?, completion: @escaping (Result<[Moderator], Error>) -> Void) {
			guard let stubResult = stubResult else { return }
			completion(stubResult)
		}
	}

	private var sut: ModeratorListPresenter!
	private var webService: MockWebService!
	private var view: MockView!

    override func setUp() {
		webService = MockWebService()
		view = MockView()
		sut = ModeratorListPresenter(webService, view: view)
    }

    override func tearDown() {
		sut = nil
		webService = nil
		view = nil
    }

    func testGetModeratorsSuccess() {
		let testExpectation = expectation(description: "testGetModeratorsSuccess")

		let moderator = Moderator(userId: 10, reputation: 1,
								  profileImage: nil, displayName: "test",
								  badgeCounts: BadgeCounts(gold: 1,
														   silver: 2,
														   bronze: 3))
		webService.stubResult = .success([moderator])

		view.appliedViewModelClosure = { (viewModel) in
			if let model = viewModel.first {
				XCTAssertEqual(model.name, "test")
			} else {
				XCTFail("could not find the applied view model")
			}
			testExpectation.fulfill()
		}

		sut.getModerators()
		waitForExpectations(timeout: 0.1)
    }

	func testGetModeratorsFailure() {
		let testExpectation = expectation(description: "testGetModeratorsFailure")

		webService.stubResult = .failure(MockError.forcedError)

		view.failedToFetchClosure = { called in
			XCTAssertTrue(called)
			testExpectation.fulfill()
		}

		sut.getModerators()
		waitForExpectations(timeout: 0.1)
    }

	func testGetNextPageSuccess() {
		let testExpectation = expectation(description: "testGetNextPageSuccess")

		let moderator = Moderator(userId: 10, reputation: 1,
								  profileImage: nil, displayName: "test2",
								  badgeCounts: BadgeCounts(gold: 1,
														   silver: 2,
														   bronze: 3))
		webService.stubResult = .success([moderator])

		view.appliedViewModelClosure = { (viewModel) in
			if let model = viewModel.first {
				XCTAssertEqual(model.name, "test2")
			} else {
				XCTFail("could not find the applied view model")
			}
			testExpectation.fulfill()
		}

		sut.getNextPage()
		waitForExpectations(timeout: 0.1)
    }

	func testGetNextPageFailure() {
		let testExpectation = expectation(description: "testGetNextPageFailure")

		webService.stubResult = .failure(MockError.forcedError)

		view.failedToGetNextPageClosure = { called in
			XCTAssertTrue(called)
			testExpectation.fulfill()
		}

		sut.getNextPage()
		waitForExpectations(timeout: 0.1)
    }

}
