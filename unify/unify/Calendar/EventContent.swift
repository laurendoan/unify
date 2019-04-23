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
    var start: String?
    var end: String?
    var course: String?
    var courseRef: String?
    var parentRef: String?
    
    init (name: String?, location: String?, date: String?, start: String?,
          end: String?, course: String?, courseRef: String, parentRef: String) {
        self.name = name
        self.location = location
        self.date = date
        self.start = start
        self.end = end
        self.course = course
        self.courseRef = courseRef
        self.parentRef = parentRef
    }
}
