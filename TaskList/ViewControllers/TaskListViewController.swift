//
//  ViewController.swift
//  TaskList
//
//  Created by Alexey Efimov on 02.04.2023.
//

import UIKit

final class TaskListViewController: UITableViewController {
    
    private let cellID = "task"
    private var taskList: [Task] = []
    
    private let storageManager = StorageManager.shared

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellID)
        setupNavigationBar()
        fetchData()
    }
    
    private func addNewTask() {
        showAlert(
            withTitle: "New Task",
            andMessage: "What do you want to do?",
            descriptionTask: ""
        ) { [weak self] result in
            self?.save(result)
        }
    }
    
    private func fetchData() {
        storageManager.fetchData { [weak self] result in
            switch result {
            case .success(let tasks):
                self?.taskList = tasks
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    private func showAlert(withTitle title: String, andMessage message: String, descriptionTask: String, completion: @escaping (String) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let saveAction = UIAlertAction(title: "Save Task", style: .default) { _ in
            guard let task = alert.textFields?.first?.text, !task.isEmpty else { return }
            completion(task)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .destructive)
        alert.addAction(saveAction)
        alert.addAction(cancelAction)
        alert.addTextField { textField in
            textField.placeholder = "New Task"
            textField.text = descriptionTask
        }
        present(alert, animated: true)
    }
    
    private func save(_ taskName: String) {
        storageManager.saveTask(taskName: taskName) { [weak self] task in
            self?.taskList.append(task)
            self?.tableView.insertRows(at: [IndexPath(row: (self?.taskList.count ?? 0) - 1, section: 0) ], with: .automatic)
        }
    }
    
    
}

// MARK: - Setup UI
private extension TaskListViewController {
    func setupNavigationBar() {
        title = "Task List"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        navBarAppearance.backgroundColor = UIColor(named: "MilkBlue")
        
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            systemItem: .add,
            primaryAction: UIAction { [unowned self] _ in
                addNewTask()
            }
        )
        
        navigationController?.navigationBar.tintColor = .white
    }
}

// MARK: - UITableViewDataSource
extension TaskListViewController {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        taskList.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellID, for: indexPath)
        let task = taskList[indexPath.row]
        var content = cell.defaultContentConfiguration()
        content.text = task.title
        cell.contentConfiguration = content
        return cell
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        let task = taskList[indexPath.row]
        
        if editingStyle == .delete {
            taskList.remove(at: indexPath.row)
            storageManager.delete(task: task)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let task = taskList[indexPath.row]
        
        showAlert(
            withTitle: "Edit Task",
            andMessage: "What do you want to do editing?",
            descriptionTask: taskList[indexPath.row].title ?? ""
        ) { [weak self] result in
            self?.storageManager.edit(task: task, newNameTask: result)
            self?.tableView.reloadData()
        }
    }
}
