//
//  FLExtensions.swift
//  Reflex
//
//  Created by Tanner Bennett on 10/29/21.
//  Copyright © 2021 Tanner Bennett. All rights reserved.
//

import FLEX

extension FLEXTypeEncoding {
    static func encodeObjcObject(typeName: String) -> String {
        return "@\"\(typeName)\""
    }
    
    static func encodeStruct(typeName: String? = nil, fields: [String]) -> String {
        if let typeName = typeName {
            return "{\(typeName)=\(fields.joined())}"
        }
        
        return "{\(fields.joined())}"
    }
}
