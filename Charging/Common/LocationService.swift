//
//  LocationService.swift
//  Charging
//
//  Created by chenzhibin on 15/10/15.
//  Copyright © 2015年 xpg. All rights reserved.
//

import UIKit

class LocationService: NSObject {
    var locationAddress: String?
    var locationCoordinate: CLLocation?
    var addressUpdatedHandler: ((String) -> Void)?
    
    private lazy var locationSevice: BMKLocationService = { [weak weakSelf = self] in
        let locationSevice = BMKLocationService()
        if let strongSelf = weakSelf  {
            locationSevice.delegate = strongSelf
        }
        return locationSevice
        }()
    
    private lazy var reverseGeoSearch: BMKGeoCodeSearch = { [weak weakSelf = self] in
        let reverseGeoSearch = BMKGeoCodeSearch()
        if let strongSelf = weakSelf {
            reverseGeoSearch.delegate = strongSelf
        }
        return reverseGeoSearch
        }()
    
    func startUserLocationService() {
        locationSevice.startUserLocationService()
    }
    
    deinit {
        addressUpdatedHandler = nil
        locationSevice.stopUserLocationService()
        // MARK: if we do not used reverseGeoSearch (not having location permission), calling 'delegate = nil' will make a crash: as it is lazy property, '.delegate' will call initiate mathod, but 'self' is being dealloc, "Cannot form weak reference to instance (0x7fd96e561360) of class Charging.LocationService. It is possible that this object was over-released, or is in the process of deallocation." (0x7fd96e561360 is self).
        locationSevice.delegate = nil
        reverseGeoSearch.delegate = nil
    }
}

extension LocationService: BMKLocationServiceDelegate {
    func didUpdateBMKUserLocation(userLocation: BMKUserLocation!) {
        let option = BMKReverseGeoCodeOption()
        option.reverseGeoPoint = userLocation.location.coordinate
        reverseGeoSearch.reverseGeoCode(option)
    }
}

extension LocationService: BMKGeoCodeSearchDelegate {
    func onGetReverseGeoCodeResult(searcher: BMKGeoCodeSearch!, result: BMKReverseGeoCodeResult!, errorCode error: BMKSearchErrorCode) {
        if error == BMK_SEARCH_NO_ERROR {
            locationCoordinate = CLLocation(latitude: result.location.latitude, longitude: result.location.longitude)
            locationAddress = result.addressDetail.city
            if let handler = addressUpdatedHandler, address = locationAddress {
                handler(address)
            }
        }
    }
}
