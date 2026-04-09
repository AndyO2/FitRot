//
//  SelectionPersistence.swift
//  FitRot
//
//  Created by Andy Okamoto on 4/6/26.
//

import Foundation

#if canImport(FamilyControls)
import FamilyControls

enum SelectionPersistence {
    static func save(_ selection: FamilyActivitySelection) {
        guard let data = try? PropertyListEncoder().encode(selection) else { return }
        AppGroupConstants.sharedDefaults.set(data, forKey: AppGroupConstants.selectionKey)
    }

    static func load() -> FamilyActivitySelection? {
        guard let data = AppGroupConstants.sharedDefaults.data(forKey: AppGroupConstants.selectionKey) else {
            return nil
        }
        return try? PropertyListDecoder().decode(FamilyActivitySelection.self, from: data)
    }

    static func clear() {
        AppGroupConstants.sharedDefaults.removeObject(forKey: AppGroupConstants.selectionKey)
    }
}
#endif
