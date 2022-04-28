//
//  AVProperty.swift
//  AVCaches
//
//  Created by lee on 2022/4/28
//

import Foundation
 
class AVProperty<T>: NSObject {
    
    let userDefaults = UserDefaults(suiteName: "UserDefaults.youpi.AVProperty")
    
    let key: String
    
    var value: T {
        didSet {
            sync()
        }
    }
    
    init(key k: String, default: T) {
        key = k
        value = (userDefaults?.object(forKey: key) as? T) ?? `default`
        super.init()
    }
    
    func sync() {
        userDefaults?.set(value, forKey: key)
    }
    
    static func removeAll(contains: String? = nil) {
        guard let _userDefaults = UserDefaults(suiteName: "UserDefaults.youpi.AVProperty") else {
            return
        }
        if let _contains = contains {
            for node in _userDefaults.dictionaryRepresentation() where node.key.contains(_contains) {
                _userDefaults.removeObject(forKey: node.key)
            }
        } else {
            for node in _userDefaults.dictionaryRepresentation() {
                _userDefaults.removeObject(forKey: node.key)
            }
        }
    }
}
