//
//  Constants.swift
//  uni.fy
//
//  Created by Julian Ricky Moore on 3/19/19.
//  Copyright © 2019 Priya Patel. All rights reserved.
//

import Foundation
import Firebase

struct Constants {
    struct refs {
        static let databaseRoot = Database.database().reference()
        static let databaseChats = databaseRoot.child("chats")
        static let databaseUsers = databaseRoot.child("users")
        static let databaseCourses = databaseRoot.child("courses")
    }
}
