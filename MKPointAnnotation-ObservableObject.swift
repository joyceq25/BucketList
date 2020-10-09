//
//  MKPointAnnotation-ObservableObject.swift
//  BucketList
//
//  Created by Ping Yun on 10/9/20.
//

import MapKit

extension MKPointAnnotation: ObservableObject {
    public var wrappedTitle: String {
        get {
            self.title ?? "Unknown value"
        }
        
        set {
            self.title = newValue
        }
    }
    
    public var wrappedSubtitle: String {
        get {
            self.subtitle ?? "Unknown value"
        }
        
        set {
            subtitle = newValue 
        }
    }
}
