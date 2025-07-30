//
//  TodoEditViewController.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 30.07.2025.
//

import UIKit

protocol TodoEditViewControllerProtocol: AnyObject {
	var presenter: TodoEditPresenterProtocol? { get set }
}

final class TodoEditViewController: UIViewController, TodoEditViewControllerProtocol {

	// MARK: - Public Properties

	var presenter: TodoEditPresenterProtocol?

	// MARK: - Private Properties

	private lazy var dateLabel: UILabel = {
		var label = UILabel()
		label.font = UIFont.systemFont(ofSize: 12)
		label.textColor = AppColor.Text.secondary
		return label
	}()

	private lazy var titleField: UITextField = {
		var textField = UITextField()
		textField.placeholder = presenter?.textViewPlaceholder
		textField.textColor = AppColor.Text.primary
		textField.font = UIFont.systemFont(ofSize: 34)
		return textField
	}()

	private lazy var descriptionTextView: UITextView = {
		var textView = UITextView()
		textView.text = "Текст задачи..."
		textView.textColor = AppColor.Text.primary
		textView.font = UIFont.systemFont(ofSize: 16)
		return textView
	}()

	// MARK: - viewDidLoad

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = AppColor.Background.primary

		setupTitle()
		setupDate()
		setupDescription()
		setupNavigationBar()
	}
}

// MARK: - Private Methods

private extension TodoEditViewController {

	func setupTitle() {
		view.addSubviews(titleField)
		titleField.delegate = self
		titleField.text = presenter?.viewModel?.title
		NSLayoutConstraint.activate([
			titleField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
			titleField.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
			titleField.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
			titleField.heightAnchor.constraint(greaterThanOrEqualToConstant: 41)
		])
	}

	func setupNavigationBar() {
		let button = UIButton(type: .system)
		button.setTitle("Назад", for: .normal)
		button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
		button.addTarget(self, action: #selector(tapBackButton), for: .touchUpInside)
		button.tintColor = AppColor.Button.primary
		let backBtn = UIBarButtonItem(customView: button)
		navigationItem.leftBarButtonItem = backBtn
	}

	func setupDate() {
		view.addSubviews(dateLabel)
		dateLabel.text = presenter?.viewModel?.date
		NSLayoutConstraint.activate([
			dateLabel.topAnchor.constraint(equalTo: titleField.bottomAnchor, constant: 8),
			dateLabel.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
			dateLabel.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
			dateLabel.heightAnchor.constraint(equalToConstant: 16)
		])
	}

	func setupDescription() {
		view.addSubviews(descriptionTextView)
		descriptionTextView.delegate = self

		if let description = presenter?.viewModel?.description {
			descriptionTextView.text = description
		}

		NSLayoutConstraint.activate([
			descriptionTextView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
			descriptionTextView.leadingAnchor.constraint(equalTo: titleField.leadingAnchor),
			descriptionTextView.trailingAnchor.constraint(equalTo: titleField.trailingAnchor),
			descriptionTextView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
		])
	}

	@objc private func tapBackButton() {
		dismiss(animated: true)
		presenter?.didTapBack(title: titleField.text ?? "", description: descriptionTextView.text ?? "")
	}
}

// MARK: - UITextFieldDelegate

extension TodoEditViewController: UITextFieldDelegate {

	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
	}
}

// MARK: - UITextViewDelegate

extension TodoEditViewController: UITextViewDelegate {

	func textViewDidBeginEditing(_ textView: UITextView) {
		if textView.text == presenter?.textViewPlaceholder {
			textView.text = nil
			textView.textColor = AppColor.Text.primary
		}
	}

	func textViewDidEndEditing(_ textView: UITextView) {
		textView.textColor = textView.text == presenter?.textViewPlaceholder
			? AppColor.Text.placeholder
			: AppColor.Text.primary
	}

	func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
		if text == "\n" {
			textView.resignFirstResponder()
			return false
		}
		return true
	}
}
