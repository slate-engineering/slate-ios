//
//  Strings.swift
//  Slate iOS (iOS)
//
//  Created by Martina Long on 1/22/21.
//

import Foundation

struct Strings {
    static let letterSets = [
        "a": "[ÀÁÂÃÅÆĀĂĄẠẢẤẦẨẪẬẮẰẲẴẶ]",
        "ae": "[Ä]",
        "c": "[ÇĆĈČ]",
        "d": "[ÐĎĐÞ]",
        "e": "[ÈÉÊËĒĔĖĘĚẸẺẼẾỀỂỄỆ]",
        "g": "[ĜĞĢǴ]",
        "h": "[ĤḦ]",
        "i": "[ÌÍÎÏĨĪĮİỈỊ]",
        "j": "[Ĵ]",
        "ij": "[Ĳ]",
        "k": "[Ķ]",
        "l": "[ĹĻĽŁ]",
        "m": "[Ḿ]",
        "n": "[ÑŃŅŇ]",
        "o": "[ÒÓÔÕØŌŎŐỌỎỐỒỔỖỘỚỜỞỠỢǪǬƠ]",
        "oe": "[ŒÖ]",
        "p": "[ṕ]",
        "r": "[ŔŖŘ]",
        "s": "[ŚŜŞŠ]",
        "ss": "[ß]",
        "t": "[ŢŤ]",
        "u": "[ÙÚÛŨŪŬŮŰŲỤỦỨỪỬỮỰƯ]",
        "ue": "[Ü]",
        "w": "[ẂŴẀẄ]",
        "x": "[ẍ]",
        "y": "[ÝŶŸỲỴỶỸ]",
        "z": "[ŹŻŽ]",
        "-": "[·/_,:;']",
      ];
    
    static func cidToUrl(_ cid: String) -> String {
        return "\(Constants.gatewayURL)/\(cid)"
    }
    
    static func getFileExtension(_ fileName: String) -> String {
        let array = fileName.components(separatedBy: ".")
        let ending = array.last ?? ""
        if ending.count <= 4 {
            return ending
        } else {
            return ""
        }
    }
    
    static func createSlug(_ string: String, base: String = "untitled") -> String {
        if string.isEmpty {
            return base
        }
        
        var slug = string.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        
        for (to, from) in letterSets {
            slug = slug.replacingOccurrences(of: from, with: to, options: [.regularExpression, .caseInsensitive])
        }
        
        slug = slug.replacingOccurrences(of: " ", with: "-") // Replace spaces with -
            .replacingOccurrences(of: "&", with: "-and-") // Replace & with 'and'
            .replacingOccurrences(of: "--+", with: "-", options: .regularExpression) // Replace multiple - with single -
        
        let characterSet = CharacterSet.alphanumerics.union(CharacterSet(charactersIn: "-")) // Remove non alphanumeric, non - characters
        slug = String(slug.unicodeScalars.filter { characterSet.contains($0) })
        
        slug = slug.trimmingCharacters(in: CharacterSet(charactersIn: "-")) // Trim - from ends
        
        return slug
    }
}
