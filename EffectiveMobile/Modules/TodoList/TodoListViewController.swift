//
//  TodoListViewController.swift
//  EffectiveMobile
//
//  Created by Roman Romanov on 29.07.2025.
//

import UIKit

protocol TodoListViewControllerProtocol: AnyObject {
	var presenter: TodoListPresenterProtocol? { get set }
	func update(with todos: TodoListModel?)
	func update(with error: String)

	func reloadTableView()
	func reloadCell(with indexPath: IndexPath)
}

final class TodoListViewController: UIViewController, TodoListViewControllerProtocol {

	// MARK: - Public Properties

	var presenter: TodoListPresenterProtocol?

	// MARK: - Private Properties

	private var todoListModel: TodoListModel?

	private lazy var tableView: UITableView = {
		let tableView = UITableView()
		tableView.register(TodoCell.self, forCellReuseIdentifier: TodoCell.identifier)
		tableView.isHidden = true
		return tableView
	}()

	private lazy var errorLabel: UILabel = {
		let label = UILabel()
		label.isHidden = true
		label.font = .systemFont(ofSize: 26, weight: .bold)
		label.textColor = AppColor.Text.error
		return label
	}()

	private lazy var footer: UIView = {
		let view = UIView()
		view.backgroundColor = AppColor.Background.footer
		return view
	}()

	private lazy var createNoteButton: UIButton = {
		var button = UIButton()
		let symbolConfig = UIImage.SymbolConfiguration(pointSize: 22, weight: .medium)
		button.setImage(UIImage(systemName: "square.and.pencil", withConfiguration: symbolConfig), for: .normal)
		button.tintColor = AppColor.Button.primary
		return button
	}()

	private lazy var taskCountLabel: UILabel = {
		var label = UILabel()
		label.textColor = AppColor.Text.primary
		label.text = "0 Задач"
		label.textAlignment = .center
		return label
	}()

	private lazy var searchController: UISearchController = UISearchController()

	// MARK: - viewDidLoad

	override func viewDidLoad() {
		super.viewDidLoad()
		view.backgroundColor = AppColor.Background.primary

		setupNavigationBar()
		setupSearchController()
		setupErrorLabel()

		setupFooter()
		setupCreateNewTodoButton()
		setupTaskCounterLabel()
		setupTableView()
	}

	// MARK: - Public Methods

	func update(with todos: TodoListModel?) {
		print("update table view")
		DispatchQueue.main.async {
			self.updateSearchResults(for: self.searchController)
			self.reloadTableView()
			self.tableView.isHidden = false
			self.taskCountLabel.text = self.presenter?.getTodosCountString(for: self.todoListModel)
		}
	}

	func update(with error: String) {
		DispatchQueue.main.async {
			self.errorLabel.text = error
			self.errorLabel.isHidden = false
			self.tableView.isHidden = true
			self.todoListModel = nil
			self.taskCountLabel.text = ""
		}
	}

	func reloadCell(with indexPath: IndexPath) {
		self.tableView.reloadRows(at: [indexPath], with: .automatic)
	}

	func reloadTableView() {
		self.tableView.reloadData()
	}
}

// MARK: - Private Methods

private extension TodoListViewController {

	func setupNavigationBar() {
		navigationItem.title = "Задачи"
		navigationController?.navigationBar.prefersLargeTitles = true
		navigationItem.largeTitleDisplayMode = .always
	}

	func setupErrorLabel() {
		view.addSubviews(errorLabel)
		NSLayoutConstraint.activate([
			errorLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
			errorLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor)
		])
	}

	func setupFooter() {
		view.addSubviews(footer)
		NSLayoutConstraint.activate([
			footer.bottomAnchor.constraint(equalTo: view.bottomAnchor),
			footer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			footer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
			footer.heightAnchor.constraint(equalToConstant: 83)
		])
	}

	func setupCreateNewTodoButton() {
		createNoteButton.addTarget(self, action: #selector(didTapCreateNote), for: .touchUpInside)
		footer.addSubviews(createNoteButton)
		NSLayoutConstraint.activate([
			createNoteButton.trailingAnchor.constraint(equalTo: footer.trailingAnchor),
			createNoteButton.widthAnchor.constraint(equalToConstant: 68),
			createNoteButton.heightAnchor.constraint(equalToConstant: 44),
			createNoteButton.topAnchor.constraint(equalTo: footer.topAnchor, constant: 5)
		])
	}

	func setupTaskCounterLabel() {
		footer.addSubviews(taskCountLabel)
		NSLayoutConstraint.activate([
			taskCountLabel.centerXAnchor.constraint(equalTo: footer.centerXAnchor),
			taskCountLabel.topAnchor.constraint(equalTo: footer.topAnchor, constant: 20),
			taskCountLabel.widthAnchor.constraint(equalToConstant: 200),
			taskCountLabel.heightAnchor.constraint(equalToConstant: 20)
		])
	}

	func setupSearchController() {
		searchController.obscuresBackgroundDuringPresentation = false
		searchController.searchBar.placeholder = "Search"
		navigationItem.searchController = searchController
		definesPresentationContext = true
		searchController.searchResultsUpdater = self
	}

	func setupTableView() {
		view.addSubviews(tableView)
		tableView.backgroundColor = AppColor.Background.primary
		tableView.delegate = self
		tableView.dataSource = self

		NSLayoutConstraint.activate([
			tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
			tableView.bottomAnchor.constraint(equalTo: footer.topAnchor),
			tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
			tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
		])
	}

	@objc func didTapCreateNote(_ sender: UIButton) {
		presenter?.didTapCreateNewTodo()
	}
}

// MARK: - TodoCellDelegate

extension TodoListViewController: TodoCellDelegate {

	func didTapCheckbox(for cell: TodoCell) {
		if let indexPath = tableView.indexPath(for: cell) {
			guard let todo = todoListModel?.todos[indexPath.row] else { return }
			presenter?.didTapDone(at: indexPath, for: todo)
		}
	}
}

// MARK: - UISearchResultsUpdating

extension TodoListViewController: UISearchResultsUpdating {

	func updateSearchResults(for searchController: UISearchController) {
		let query = searchController.searchBar.text ?? ""
		todoListModel = presenter?.searchTodo(with: query)
		reloadTableView()
		taskCountLabel.text = presenter?.getTodosCountString(for: todoListModel)
	}
}

// MARK: - UITableViewDataSource

extension TodoListViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		presenter?.getTodosCount() ?? 0
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		guard let todoListModel else { return UITableViewCell() }

		if let cell = tableView.dequeueReusableCell(withIdentifier: TodoCell.identifier, for: indexPath) as? TodoCell {
			if todoListModel.todos.indices.contains(indexPath.row) {
				let todo = todoListModel.todos[indexPath.row]
				cell.delegate = self
				cell.configure(with: todo)
				return cell
			}
		}

		return UITableViewCell()
	}
}

// MARK: - UITableViewDelegate

extension TodoListViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		tableView.deselectRow(at: indexPath, animated: true)
		guard let todo = todoListModel?.todos[indexPath.row] else { return }
		presenter?.didTapEditTodo(with: todo.id)
	}

	func tableView(
		_ tableView: UITableView,
		trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath
	)
	-> UISwipeActionsConfiguration? {
		let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
			guard let id = self?.todoListModel?.todos[indexPath.row].id else { return }
			self?.presenter?.didDeleteTodo(with: id)
			completionHandler(true)
		}
		let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
		configuration.performsFirstActionWithFullSwipe = true
		return configuration
	}

	func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
		UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
			let editAction = UIAction(title: "Редактировать", image: UIImage(named: "edit")) { _ in
				guard let id = self.todoListModel?.todos[indexPath.row].id else { return }
				self.presenter?.didTapEditTodo(with: id)
			}

			let shareAction = UIAction(title: "Поделиться", image: UIImage(named: "share")) { _ in
				guard
					let title = self.todoListModel?.todos[indexPath.row].title,
					let shareText = self.todoListModel?.todos[indexPath.row].description
				else { return }
				let shareContent: [Any] = [title, shareText]
				let activityController = UIActivityViewController(
					activityItems: shareContent,
					applicationActivities: nil
				)
				self.present(activityController, animated: true, completion: nil)
			}

			let deleteAction = UIAction(title: "Удалить", image: UIImage(named: "trash"), attributes: .destructive) { _ in
				guard let id = self.todoListModel?.todos[indexPath.row].id else { return }
				self.presenter?.didDeleteTodo(with: id)
			}

			return UIMenu(title: "", children: [editAction, shareAction, deleteAction])
		}
	}
}
