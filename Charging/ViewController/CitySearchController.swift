//
//  CitySearchController.swift
//  Charging
//
//  Created by xpg on 7/7/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import Foundation

class CitySearchController: NSObject, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
    
    unowned let cityViewController: DCSelectCityViewController
    var results = [City]()
    
    // MARK: Init
    init(cityViewController: DCSelectCityViewController) {
        self.cityViewController = cityViewController
    }
    
    // MARK: UISearchBarDelegate
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if let cities = cityViewController.citySelection?.cities as? [City] {
            results = cities.filter() { $0.name.rangeOfString(searchText) != nil }
        } else {
            results = []
        }
        cityViewController.searchDisplayController?.searchResultsTableView.reloadData()
    }
    
    // MARK: UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier("SearchCell")
        if cell == nil {
            cell = UITableViewCell(style: .Default, reuseIdentifier: "SearchCell")
        }
        cell?.textLabel?.text = results[indexPath.row].name
        return cell!
    }
    
    // MARK: UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        cityViewController.selectedCity(results[indexPath.row])
    }
}
