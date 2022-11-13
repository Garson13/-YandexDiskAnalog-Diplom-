//
//  FilesPreviewModel.swift
//  Skillbox Drive Diplom
//
//  Created by Гарик on 13.09.2022.
//

import UIKit


struct PublicationData: Decodable {
    var href: String
}

struct FilesPreviewModel: Decodable {
    var name: String
    var public_url: String?
    var preview: String?
    var file: String
}
