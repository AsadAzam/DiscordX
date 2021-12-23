//
//  HelperFunctions.swift
//  DiscordX
//
//  Created by Asad Azam on 28/9/20.
//  Copyright © 2021 Asad Azam. All rights reserved.
//

import Foundation

func getFileExt(_ file: String) -> String? {
    if let ext = file.split(separator: ".").last {
        return String(ext)
    }
    return nil
}

func withoutFileExt(_ file: String) -> String {
    if !file.contains(".") || file.last == "." {
        return file
    }

    var ret = file
    while (ret.popLast() != ".") {}
    return ret
}
