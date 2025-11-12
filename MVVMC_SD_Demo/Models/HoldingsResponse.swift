//
//  HoldingsResponse.swift
//  MVVMC_SD_Demo
//
//  Created by Satyam Dixit on 12/11/25.
//


// MARK: - Holding.swift
import Foundation

struct HoldingsResponse: Codable {
    let data: HoldingsData?
}

struct HoldingsData: Codable {
    let userHolding: [Holding]?
}

struct Holding: Codable {
    let symbol: String?
    let quantity: Double?
    let ltp: Double?
    let avgPrice: Double?
    let close: Double?
}
