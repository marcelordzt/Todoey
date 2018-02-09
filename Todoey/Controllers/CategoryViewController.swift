//
//  CategoryViewController.swift
//  Todoey
//
//  Created by Marcelo Rodriguez on 2/7/18.
//  Copyright © 2018 Marcelo Rodriguez. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class CategoryViewController: SwipeTableViewController {

	let realm = try! Realm()

	var categories : Results<Category>?

	override func viewDidLoad() {

		super.viewDidLoad()
		loadCategories()
	}

	//MARK: - TableView DataSource Methods

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return categories?.count ?? 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = super.tableView(tableView, cellForRowAt: indexPath)

		if let category = categories?[indexPath.row] {
			cell.textLabel?.text = category.name

			guard let categoryColor = HexColor(category.colorHex) else { fatalError() }
			cell.backgroundColor = categoryColor
			cell.textLabel?.textColor = ContrastColorOf(categoryColor, returnFlat: true)
		}
		return cell
	}

	//MARK: - TableView Delegate Methods

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		performSegue(withIdentifier: "goToItems", sender: self)
	}

	override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

		let destinationVC = segue.destination as! TodoListViewController
		if let indexPath = tableView.indexPathForSelectedRow {
			destinationVC.selectedCategory = categories?[indexPath.row]
		}
	}

	//MARK: - Data Manipulation Methods

	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

		var textField = UITextField()

		let alert = UIAlertController(title: "Add New Category", message: "", preferredStyle: .alert)

		let action = UIAlertAction(title: "Add Category", style: .default) { (action) in

			let newCategory = Category()
			newCategory.name = textField.text!
			newCategory.colorHex = UIColor.randomFlat.hexValue()

			self.save(category: newCategory)
		}

		alert.addTextField { (alertTextField) in
			alertTextField.placeholder = "Create new item"
			textField = alertTextField
		}

		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}

	func save(category: Category) {

		do {
			try realm.write {
				realm.add(category)
			}
		}
		catch {
			print("Error saving context: \(error)")
		}
		tableView.reloadData()
	}

	func loadCategories() {

		categories = realm.objects(Category.self)

		tableView.reloadData()
	}

	//MARK: - Delete Data From Swipe
	override func updateModel(at indexPath: IndexPath) {
		if let category = self.categories?[indexPath.row] {
			do {
				try self.realm.write {
					self.realm.delete(category)
				}
			}
			catch {
				print("Error saving context: \(error)")
			}
		}
	}
}
