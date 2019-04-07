//
//  EventContent.swift
//  unify
//
//  Created by David Do on 4/5/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

class EventContent {
    var name: String?
    var location: String?
    var date: String?
    var time: String?
    
    init (name: String?, location: String?, date: String?, time: String?) {
        self.name = name
        self.location = location
        self.date = date
        self.time = time
    }
}
