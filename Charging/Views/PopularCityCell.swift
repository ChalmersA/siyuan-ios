//
//  PopularCityCell.swift
//  Charging
//
//  Created by xpg on 7/7/15.
//  Copyright (c) 2015 xpg. All rights reserved.
//

import UIKit

let CollectionItemHorizontalSpacing: CGFloat = 20.0
let CollectionItemVerticalSpacing: CGFloat = 16.0
let CollectionItemHeight: CGFloat = 40.0
let CollectionItemPerRow = 3

class PopularCityCell: UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {

    @IBOutlet weak var cityCollectionView: UICollectionView!

    var cities = [City]()
    var placeholderText: String?
    weak var delegate: SelectCityDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        cityCollectionView.scrollEnabled = false
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // MARK: City
    func configForCities(cityArray: [City]) {
        cities = cityArray
        placeholderText = nil
        cityCollectionView.reloadData()
    }
    
    func configForLocationCity(city: City?, placeholder: String) {
        if let city = city {
            cities = [city]
        } else {
            cities = []
        }
        placeholderText = placeholder
        cityCollectionView.reloadData()
    }
    
    // MARK: UICollectionViewDelegate
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if indexPath.row < cities.count {
            delegate?.selectedCity(cities[indexPath.row])
        } else if indexPath.row == 0 {
            delegate?.selectedCity(nil)
        }
    }
    
    // MARK: UICollectionViewDataSource
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        if cities.count == 0 {
            if placeholderText != nil {
                return 1
            } else {
                return 0
            }
        }
        return cities.count
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier("CityCollectionCell", forIndexPath: indexPath) as! CityCollectionCell
        cell.cityLabel.text = nil
        if indexPath.row < cities.count {
            cell.cityLabel.text = cities[indexPath.row].name
        } else if indexPath.row == 0 {
            cell.cityLabel.text = placeholderText
        }
        return cell
    }
    
    // MARK: UICollectionViewDelegateFlowLayout
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let width = (CGRectGetWidth(collectionView.bounds) - CollectionItemHorizontalSpacing * CGFloat(CollectionItemPerRow + 1)) / CGFloat(CollectionItemPerRow)
        return CGSize(width: width, height: CollectionItemHeight)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CollectionItemHorizontalSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAtIndex section: Int) -> CGFloat {
        return CollectionItemVerticalSpacing
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: CollectionItemVerticalSpacing, left: CollectionItemHorizontalSpacing, bottom: CollectionItemVerticalSpacing, right: CollectionItemHorizontalSpacing)
    }
    
    class func cellHeightWithCityCount(count: Int) -> CGFloat {
        if count == 0 {
            return 0
        }
        let row = ceil(CGFloat(count) / CGFloat(CollectionItemPerRow))
        return row * (CollectionItemHeight + CollectionItemVerticalSpacing) + CollectionItemVerticalSpacing
    }

}

class CityCollectionCell: UICollectionViewCell {
    @IBOutlet weak var cityLabel: UILabel!
    
    override func awakeFromNib() {
        setBorderColor(UIColor(white: 0.9, alpha: 1), width: 1)
    }
    
    override var highlighted: Bool {
        didSet {
            if highlighted {
                backgroundColor = UIColor.lightGrayColor()
                cityLabel.textColor = UIColor.whiteColor()
            } else {
                backgroundColor = UIColor.whiteColor()
                cityLabel.textColor = UIColor.darkGrayColor()
            }
        }
    }
}
