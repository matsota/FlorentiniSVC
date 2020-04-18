//
//  EmployeesViewController.swift
//  FlorentiniSVC
//
//  Created by Andrew Matsota on 17.04.2020.
//  Copyright © 2020 Andrew Matsota. All rights reserved.
//

import UIKit

class EmployeeListViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NetworkManager.shared.fetchEmployeeData(success: { (data) in
            self.employeeData = data
            self.tableView.reloadData()
        }) { (error) in
            print("ERROR: EmployeeListViewController/viewDidLoad/fetchEmployeeData: ", error.localizedDescription)
            self.present(UIAlertController.completionDoneTwoSec(title: "", message: ""), animated: true)
        }
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Введите имя сотрудника"
        navigationItem.searchController = searchController
        definesPresentationContext = true
        
    }
    
    //MARK: - Implementation
    private var employeeData = [DatabaseManager.EmployeeData]()
    private var filteredEmployessData = [DatabaseManager.EmployeeData]()
    private let searchController = UISearchController(searchResultsController: nil)
    private var searchBarIsEmpty: Bool {
        guard let text = searchController.searchBar.text else {return false}
        return text.isEmpty
    }
    private var isFiltering: Bool {
        return searchController.isActive && !searchBarIsEmpty
    }
    
    //MARK: - Table view
    @IBOutlet private weak var tableView: UITableView!
    
}









//MARK: - Extension

//MARK: - Search Results
extension EmployeeListViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearch(search: searchController.searchBar.text!)
    }
    
    private func filterContentForSearch(search text: String) {
        filteredEmployessData = employeeData.filter({ (data: DatabaseManager.EmployeeData) -> Bool in
            
            return data.name.lowercased().contains(text.lowercased())
        })
        tableView.reloadData()
    }
    
}


//MARK: - Table View
extension EmployeeListViewController: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isFiltering {
            return filteredEmployessData.count
        }
        return employeeData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: NavigationCases.IDVC.EmloyeeListTVCell.rawValue, for: indexPath) as! EmloyeeListTableViewCell
        
        cell.tag = indexPath.row
        cell.delegate = self
        
        var fetch: DatabaseManager.EmployeeData
        
        if isFiltering {
            fetch = self.filteredEmployessData[cell.tag]
        }else{
            fetch = self.employeeData[cell.tag]
        }
        
        let name = fetch.name,
        position = fetch.position

        cell.fill(name: name, position: position)
        
        return cell
    }
    
}

//MARK: - Cell delegate
extension EmployeeListViewController: EmloyeeListTableViewCellDelegate {
    
    func changeEmployeeposition(_ cell: EmloyeeListTableViewCell) {
        
    }
    
}
