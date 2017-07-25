//
//  Helpers.swift
//  Storytel
//
//  Created by Pavel Kazantsev on 6/22/17.
//  Copyright © 2017 PaKaz.net. All rights reserved.
//

import Foundation

struct GenericError: Error, CustomStringConvertible {
    let message: String
    init(_ message: String) {
        self.message = message
    }

    var description: String {
        return message
    }
}

func dlog(_ message: @autoclosure () -> String, file: StaticString = #file, line: Int = #line, function: StaticString = #function) {
#if DEBUG
    print(Date(), function, ":", message())
#endif
}

