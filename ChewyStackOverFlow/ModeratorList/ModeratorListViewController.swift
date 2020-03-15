
//
//  ModeratorListViewController.swift
//  ChewyStackOverFlow
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import UIKit

protocol ModeratorListViewControllerInput: AnyObject {
	func failedToFetch()
	func failedToGetNextPage()
	func apply(_ viewModel: [UserTableViewCell.ViewModel])
}

protocol ModeratorListViewControllerOutput: AnyObject {
	func getModerators()
	func getNextPage()
}

class ModeratorListViewController: UIViewController {
	typealias UserTableCellViewModel = UserTableViewCell.ViewModel

	private enum Constants {
		static let hideIndicator: CGFloat = -100.0
		static let showIndicator: CGFloat = 20.0
		static let animationDuration: TimeInterval = 0.25
		static let failureMessageDuration: TimeInterval = 1.0
		static let springWithDamping: CGFloat = 0.3
		static let initialVelocity: CGFloat = 10.0

	}

	@IBOutlet private weak var tableView: UITableView!
	@IBOutlet private weak var nextPageFetchIndicator: UIActivityIndicatorView!
	@IBOutlet private weak var nextPageIndicatorConstraint: NSLayoutConstraint!
	@IBOutlet private weak var nextPageFailureLabel: UILabel!
	@IBOutlet private weak var somethingWentWrongView: UIVisualEffectView!

	private var viewModel = [UserTableCellViewModel]()
	var presenter: ModeratorListViewControllerOutput?

	private lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self,
								 action: #selector(handleRefresh(_:)),
								 for: .valueChanged)
        return refreshControl
    }()

	override func viewDidLoad() {
		super.viewDidLoad()
		title = "StackOverflow Moderators"
		tableView.tableFooterView = UIView(frame: .zero)
		tableView.addSubview(refreshControl)

		somethingWentWrongView.isHidden = true
		nextPageFailureLabel.alpha = 0.0

		presenter = ModeratorListPresenter(view: self)
		programaticRefresh()
	}
}

// MARK: - ModeratorListViewControllerInput
extension ModeratorListViewController: ModeratorListViewControllerInput {
	func failedToGetNextPage() {
		displayNextPageFetchFailure()
	}

	func failedToFetch() {
		if refreshControl.isRefreshing {
			refreshControl.endRefreshing()
		}
		somethingWentWrongView.isHidden = false
	}

	func apply(_ viewModel: [UserTableViewCell.ViewModel]) {
		somethingWentWrongView.isHidden = true
		if refreshControl.isRefreshing {
			refreshControl.endRefreshing()
		}

		if nextPageFetchIndicator.isAnimating {
			shouldShowNextPageIndicator(false, completion: nil)
		}

		self.viewModel = viewModel
		tableView.reloadData()

	}
}

// MARK: - UITableViewDataSource, UITableViewDelegate
extension ModeratorListViewController: UITableViewDataSource, UITableViewDelegate {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		viewModel.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: UserTableViewCell.reusableID, for: indexPath) as! UserTableViewCell
		let model = viewModel[indexPath.row]
		cell.apply(model)
		return cell
	}

}

// MARK: - Refresh Control
private extension ModeratorListViewController {
	func programaticRefresh() {
		refreshControl.beginRefreshing()
		tableView.setContentOffset(CGPoint(x: 0,
										   y: tableView.contentOffset.y - refreshControl.frame.size.height),
								   animated: true)
		presenter?.getModerators()
	}

	@objc func handleRefresh(_ refreshControl: UIRefreshControl) {
		presenter?.getModerators()
    }

	func shouldShowNextPageIndicator(_ show: Bool, completion: ((Bool) -> Void)?) {
		if show {
			nextPageFetchIndicator.startAnimating()
		} else {
			nextPageFetchIndicator.stopAnimating()
		}

		self.view.layoutIfNeeded()
		UIView.animate(withDuration: Constants.animationDuration,
					   delay: 0.0,
					   usingSpringWithDamping: Constants.springWithDamping,
					   initialSpringVelocity: Constants.initialVelocity,
					   options: .curveEaseIn,
					   animations: {
						self.nextPageIndicatorConstraint.constant = show ? Constants.showIndicator : Constants.hideIndicator
						self.view.layoutIfNeeded()
		},
					   completion: completion)
	}

	func displayNextPageFetchFailure() {
		nextPageFailureLabel.alpha = 0.0
		UIView.animate(withDuration: Constants.failureMessageDuration,
					   animations: {
						self.nextPageFailureLabel.alpha = 1.0
		}) { _ in
			UIView.animate(withDuration: Constants.animationDuration,
						   delay: Constants.failureMessageDuration,
						   options: .curveEaseOut,
						   animations: {
							self.nextPageFailureLabel.alpha = 0.0
			})
		}
	}
}

// MARK: - Scrollview Delegate
extension ModeratorListViewController {
	func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
		guard scrollView.contentSize.height > scrollView.frame.height else { return }
		if scrollView.contentOffset.y >= (scrollView.contentSize.height - scrollView.bounds.size.height - 1) {
			shouldShowNextPageIndicator(true) { _ in
				self.presenter?.getNextPage()
			}
		}
	}
}
