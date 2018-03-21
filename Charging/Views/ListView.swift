//
//  ListView.swift
//  Charging
//
//  Created by xpg on 7/28/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

class ListView: UITableView, UITableViewDataSource, UITableViewDelegate {
    
    // MARK: Properties
    static let cellReuseIdentifier = "ListCell"
    lazy var prototypeLabel: UILabel = {
        let label = UILabel()
        return label
        }()
    var items: [String] = []
    var selectedIndex: Int?
    var didSelectIndex: ((Int) -> Void)?
    
    // MARK: Initialization
    init(items: [String], selectedIndex: Int) {
        self.items = items
        self.selectedIndex = selectedIndex
        super.init(frame: CGRectZero, style: UITableViewStyle.Plain)
        
        self.registerClass(UITableViewCell.self, forCellReuseIdentifier: ListView.cellReuseIdentifier)
        dataSource = self
        delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // MARK: - UIView
    override func intrinsicContentSize() -> CGSize {
        let width = items.map({ [unowned self] (item) -> CGFloat in
            self.prototypeLabel.text = item
            return self.prototypeLabel.intrinsicContentSize().width
            }).reduce(0, combine: { (maxWidth, width) -> CGFloat in
                return (width > maxWidth) ? width : maxWidth
            }) + 32
        return CGSize(width: width, height: CGFloat(44 * items.count))
    }
    
    // MARK: - UITableViewDataSource
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(ListView.cellReuseIdentifier, forIndexPath: indexPath) 
        cell.textLabel?.text = items[indexPath.row]
        
        cell.textLabel?.textColor = UIColor.darkTextColor()
        if let selectedIndex = selectedIndex {
            if indexPath.row == selectedIndex {
                cell.textLabel?.textColor = UIColor.paletteButtonLightBlueColor()
            }
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        selectedIndex = indexPath.row
        tableView.reloadData()
        if let didSelectIndex = didSelectIndex {
            didSelectIndex(indexPath.row)
        }
    }
}
