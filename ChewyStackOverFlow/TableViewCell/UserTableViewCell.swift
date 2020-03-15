//
//  UserTableViewCell.swift
//  ChewyStackOverFlow
//
//  Created by Ivan A. Echeverria on 3/13/20.
//  Copyright © 2020 Ivan A. Echeverria. All rights reserved.
//

import UIKit
import SDWebImage

class UserTableViewCell: UITableViewCell {
	static let reusableID = "UserTableViewCell"

	struct ViewModel {
		let name: String
		let imageUrl: URL?
		let reputation: Int
		let goldCount: Int
		let silverCount: Int
		let browzeCount: Int
	}

	@IBOutlet weak var profileImageView: UIImageView!
	@IBOutlet weak var userFullName: UILabel!
	@IBOutlet weak var reputation: UILabel!
	@IBOutlet weak var goldBadgeView: BadgeView!
	@IBOutlet weak var silverBadgeView: BadgeView!
	@IBOutlet weak var bronzeBadgeView: BadgeView!

	func apply(_ viewModel: ViewModel) {
		userFullName.text = viewModel.name
		profileImageView.sd_setImage(with: viewModel.imageUrl,
									 placeholderImage: UIImage(named: "placeHolderImage"))
		reputation.text = "\(viewModel.reputation) REPUTATION"
		goldBadgeView.apply(with: NumberFormat.shortenNumber(viewModel.goldCount),
							style: .gold)
		silverBadgeView.apply(with: NumberFormat.shortenNumber(viewModel.silverCount),
							  style: .silver)
		bronzeBadgeView.apply(with: NumberFormat.shortenNumber(viewModel.browzeCount),
							  style: .bronze)
	}

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

	override func prepareForReuse() {
		super.prepareForReuse()
		profileImageView.image = nil
	}
}
