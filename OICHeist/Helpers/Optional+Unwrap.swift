//
//  Optional+Unwrap.swift
//  OICHeist
//
//  Created by Kenna Blackburn on 9/29/25.
//

import Foundation

extension Optional {
    func unwrap<E: Error>(throwing error: E) throws -> Wrapped {
        guard let wrapped = self else { throw error }
        return wrapped
    }
}
