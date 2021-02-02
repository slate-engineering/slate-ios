//
//  Helpers.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation

extension String: Identifiable {
    public var id: String { self }
}

extension Data {
    func toString() -> String {
        return String(decoding: self, as: UTF8.self)
    }
}

extension Comparable {
    func clamped(to r: ClosedRange<Self>) -> Self {
        let min = r.lowerBound, max = r.upperBound
        return self < min ? min : (max < self ? max : self)
    }
    
    func lowerBounded(by min: Self) -> Self {
        return self < min ? min : self
    }
    
    func upperBounded(by max: Self) -> Self {
        return self > max ? max : self
    }
}

extension Encodable {
    func toString() -> String {
        guard let encoded = try? JSONEncoder().encode(self) else {
            return "Failed to encode object"
        }
        return encoded.toString()
    }
}

// NOTE(martina): Property wrapper to give codable optional properties a default value

protocol DecodableDefaultSource {
    associatedtype Value: Decodable
    static var defaultValue: Value { get }
}

enum DecodableDefault {}

extension DecodableDefault {
    @propertyWrapper
    struct Wrapper<Source: DecodableDefaultSource> {
        typealias Value = Source.Value
        var wrappedValue = Source.defaultValue
    }
}

extension DecodableDefault.Wrapper: Decodable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        wrappedValue = try container.decode(Value.self)
    }
}

extension DecodableDefault {
    typealias Source = DecodableDefaultSource
    typealias List = Decodable & ExpressibleByArrayLiteral
    typealias Map = Decodable & ExpressibleByDictionaryLiteral

    enum Sources {
        enum True: Source {
            static var defaultValue: Bool { true }
        }

        enum False: Source {
            static var defaultValue: Bool { false }
        }

        enum EmptyString: Source {
            static var defaultValue: String { "" }
        }

//        enum EmptyList<T: List>: Source {
//            static var defaultValue: T { [] }
//        }

        enum EmptyMap<T: Map>: Source {
            static var defaultValue: T { [:] }
        }
    }
}

extension DecodableDefault {
    typealias True = Wrapper<Sources.True>
    typealias False = Wrapper<Sources.False>
    typealias EmptyString = Wrapper<Sources.EmptyString>
//    typealias EmptyList<T: List> = Wrapper<Sources.EmptyList<T>>
    typealias EmptyMap<T: Map> = Wrapper<Sources.EmptyMap<T>>
}

struct Article: Decodable {
    var title: String
    @DecodableDefault.EmptyString var body: String
    @DecodableDefault.False var isFeatured: Bool
    @DecodableDefault.True var isActive: Bool
//    @DecodableDefault.EmptyList var comments: [Comment]
    @DecodableDefault.EmptyMap var flags: [String : Bool]
}

extension DecodableDefault.Wrapper: Encodable where Value: Encodable {
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(wrappedValue)
    }
}

extension KeyedDecodingContainer {
    func decode<T>(_ type: DecodableDefault.Wrapper<T>.Type,
                   forKey key: Key) throws -> DecodableDefault.Wrapper<T> {
        try decodeIfPresent(type, forKey: key) ?? .init()
    }
}

