//
//  Array+Prefix.swift
//  OICHeist
//
//  Created by Kenna Blackburn on 9/29/25.
//

import Foundation

extension Array {
    func prefix(optionalMaxLength maxLength: Int?) -> Self.SubSequence {
        guard let maxLength else { return Self.SubSequence(self) }
        return self.prefix(maxLength)
    }
}
