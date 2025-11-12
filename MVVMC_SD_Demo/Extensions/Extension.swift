//
//  Extension.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


import Foundation
extension Double {
    func roundedString(fractionDigits: Int = 2) -> String {
        return String(format: "%.\(fractionDigits)f", self)
    }
}

extension Error {
    var userFriendlyMessage: String {
        let nsError = self as NSError
        return nsError.localizedFailureReason ?? nsError.localizedDescription
    }
}
