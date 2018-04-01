//
//  Bitmex.swift
//  AKPositionCalculator
//
//  Created by choukh on 2018/3/18.
//

import Foundation
import Moya

enum Bitmex {

    case swap
    case quarterly
    case biquarterly

    struct Instrument: Decodable {
        let symbol: String
        let rootSymbol: String?
        let state: String?
        let typ: String?
        let listing: String?
        let front: String?
        let expiry: String?
        let settle: String?
        let relistInterval: String?
        let inverseLeg: String?
        let sellLeg: String?
        let buyLeg: String?
        let optionStrikePcnt: Double?
        let optionStrikeRound: Double?
        let optionStrikePrice: Double?
        let optionMultiplier: Double?
        let positionCurrency: String?
        let underlying: String?
        let quoteCurrency: String?
        let underlyingSymbol: String?
        let reference: String?
        let referenceSymbol: String?
        let calcInterval: String?
        let publishInterval: String?
        let publishTime: String?
        let maxOrderQty: Double?
        let maxPrice: Double?
        let lotSize: Double?
        let tickSize: Double?
        let multiplier: Double?
        let settlCurrency: String?
        let underlyingToPositionMultiplier: Double?
        let underlyingToSettleMultiplier: Double?
        let quoteToSettleMultiplier: Double?
        let isQuanto: Bool?
        let isInverse: Bool?
        let initMargin: Double?
        let maintMargin: Double?
        let riskLimit: Double?
        let riskStep: Double?
        let limit: Double?
        let capped: Bool?
        let taxed: Bool?
        let deleverage: Bool?
        let makerFee: Double?
        let takerFee: Double?
        let settlementFee: Double?
        let insuranceFee: Double?
        let fundingBaseSymbol: String?
        let fundingQuoteSymbol: String?
        let fundingPremiumSymbol: String?
        let fundingTimestamp: String?
        let fundingInterval: String?
        let fundingRate: Double?
        let indicativeFundingRate: Double?
        let rebalanceTimestamp: String?
        let rebalanceInterval: String?
        let openingTimestamp: String?
        let closingTimestamp: String?
        let sessionInterval: String?
        let prevClosePrice: Double?
        let limitDownPrice: Double?
        let limitUpPrice: Double?
        let bankruptLimitDownPrice: Double?
        let bankruptLimitUpPrice: Double?
        let prevTotalVolume: Double?
        let totalVolume: Double?
        let volume: Double?
        let volume24h: Double?
        let prevTotalTurnover: Double?
        let totalTurnover: Double?
        let turnover: Double?
        let turnover24h: Double?
        let prevPrice24h: Double?
        let vwap: Double?
        let highPrice: Double?
        let lowPrice: Double?
        let lastPrice: Double?
        let lastPriceProtected: Double?
        let lastTickDirection: String?
        let lastChangePcnt: Double?
        let bidPrice: Double?
        let midPrice: Double?
        let askPrice: Double?
        let impactBidPrice: Double?
        let impactMidPrice: Double?
        let impactAskPrice: Double?
        let hasLiquidity: Bool?
        let openInterest: Double?
        let openValue: Double?
        let fairMethod: String?
        let fairBasisRate: Double?
        let fairBasis: Double?
        let fairPrice: Double?
        let markMethod: String?
        let markPrice: Double?
        let indicativeTaxRate: Double?
        let indicativeSettlePrice: Double?
        let optionUnderlyingPrice: Double?
        let settledPrice: Double?
        let timestamp: String?
    }
}

extension Bitmex: TargetType {

    var baseURL: URL {
        return URL(string: "https://www.bitmex.com/api/v1")!
    }

    var path: String {
        switch self {
        case .swap, .quarterly, .biquarterly:
            return "/instrument"
        }
    }

    var method: Moya.Method {
        switch self {
        case .swap, .quarterly, .biquarterly:
            return .get
        }
    }

    var sampleData: Data {
        return Data()
    }

    var task: Task {
        switch self {
        case .swap:
            return .requestParameters(parameters: ["symbol": "XBT"], encoding: URLEncoding.queryString)
        case .quarterly:
            return .requestParameters(parameters: ["symbol": "XBT:quarterly"], encoding: URLEncoding.queryString)
        case .biquarterly:
            return .requestParameters(parameters: ["symbol": "XBT:biquarterly"], encoding: URLEncoding.queryString)
        }
    }

    var headers: [String: String]? {
        return ["Content-type": "application/json"]
    }
}
