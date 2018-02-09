//
//  ViewController.swift
//  Todoey
//
//  Created by Marcelo Rodriguez on 1/30/18.
//  Copyright © 2018 Marcelo Rodriguez. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class TodoListViewController: SwipeTableViewController {

	let realm = try! Realm()

	@IBOutlet weak var searchBar: UISearchBar!

	var items: Results<Item>?

	var selectedCategory : Category? {

		didSet {
			loadItems()
		}
	}

	override func viewDidLoad() {
		super.viewDidLoad()
	}

	override func viewWillAppear(_ animated: Bool) {

		title = selectedCategory?.name

		guard let colorHex = selectedCategory?.colorHex else { fatalError() }
		
		updateNavBar(withHexColor: colorHex)
	}

	override func viewWillDisappear(_ animated: Bool) {

		updateNavBar(withHexColor: "1D9BF6")
	}

	//MARK: - NavBar Setup Methods

	func updateNavBar(withHexColor hexColor: String) {

		guard let navBar = navigationController?.navigationBar else { fatalError("Navigation controller does not exist.") }

		guard let navBarColor = HexColor(hexColor) else { fatalError() }

		let contrastColor = ContrastColorOf(navBarColor, returnFlat: true)
		navBar.barTintColor = navBarColor
		navBar.tintColor = contrastColor
		navBar.largeTitleTextAttributes = [NSAttributedStringKey.foregroundColor: contrastColor]
		searchBar.barTintColor = navBarColor
	}

	//MARK - Tableview Datasource Methods

	override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return items?.count ?? 1
	}

	override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = super.tableView(tableView, cellForRowAt: indexPath)

		if let item = items?[indexPath.row] {

			cell.textLabel?.text = item.title
			cell.accessoryType = item.done ? .checkmark : .none

			if let color = HexColor(selectedCategory!.colorHex)?.darken(byPercentage: CGFloat(indexPath.row)/CGFloat(items!.count)) {
				cell.backgroundColor = color
				cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
			}

		} else {

			cell.textLabel?.text = "No Items Added"
		}

		return cell
	}

	override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		if let item = items?[indexPath.row] {
			do {
				try realm.write {
					item.done = !item.done
				}
			} catch {
				print("Error: \(error)")
			}
		}

		tableView.reloadData()

		tableView.deselectRow(at: indexPath, animated: true)
	}

	//MARK - Add New Item

	@IBAction func addButtonPressed(_ sender: UIBarButtonItem) {

		var textField = UITextField()

		let alert = UIAlertController(title: "Add New Item", message: "", preferredStyle: .alert)

		let action = UIAlertAction(title: "Add Item", style: .default) { (action) in

			if let currentCategory = self.selectedCategory {

				do {
					try self.realm.write {
						let newItem = Item()
						newItem.title = textField.text!
						newItem.dateCreated = Date()
						currentCategory.items.append(newItem)
					}
				}
				catch {
					print("Error: \(error)")
				}
			}

			self.tableView.reloadData()
		}

		alert.addTextField { (alertTextField) in

			alertTextField.placeholder = "Create new item"
			textField = alertTextField
		}

		alert.addAction(action)
		present(alert, animated: true, completion: nil)
	}

	func loadItems() {

		items = selectedCategory?.items.sorted(byKeyPath: "title", ascending: true)

		tableView.reloadData()
	}

	//MARK: - Delete Data From Swipe
	override func updateModel(at indexPath: IndexPath) {
		if let item = self.items?[indexPath.row] {
			do {
				try self.realm.write {
					self.realm.delete(item)
				}
			}
			catch {
				print("Error saving context: \(error)")
			}
		}
	}
}

//MARK - SearchBar Methods

extension TodoListViewController : UISearchBarDelegate {

	func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

		if searchBar.text?.count == 0 {
			loadItems()
			return
		}

		items = selectedCategory?.items.filter("title CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "dateCreated", ascending: true)
		tableView.reloadData()
	}

	func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {

		if searchBar.text?.count == 0 {
			loadItems()

			DispatchQueue.main.async {
				searchBar.resignFirstResponder()
			}
		}
	}
}



