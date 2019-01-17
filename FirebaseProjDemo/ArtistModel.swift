//
//  ArtistModel.swift
//  FirebaseProjDemo
//
//  Created by admin on 1/17/19.
//  Copyright © 2019 admin. All rights reserved.
//

import Foundation

class ArtistModel {
    var id: String?
    var name: String?
    var genre: String?
    init(id: String?, name: String?, genre: String?) {
        self.id = id
        self.name = name
        self.genre = genre
    }
}
