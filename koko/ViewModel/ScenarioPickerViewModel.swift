//
//  ScenarioPickerViewModel.swift
//  koko
//
//  Created by 綸綸 on 2025/10/20.
//

import Foundation

@MainActor
final class ScenarioPickerViewModel {
    private(set) var scenarios = DataScenario.allCases
    private(set) var selected: DataScenario? = ScenarioStore.current

    func select(_ s: DataScenario) { selected = s }
    func confirmSelection() {
        ScenarioStore.current = selected
    }
}

