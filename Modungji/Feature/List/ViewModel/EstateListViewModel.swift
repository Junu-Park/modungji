//
//  EstateListViewModel.swift
//  Modungji
//
//  Created by 박준우 on 9/22/25.
//

import Combine
import Foundation

final class EstateListViewModel: ObservableObject {
    struct State {
        var estateList: [EstateResponseEntity] = []
        var selectedFilter: EstateListFilterType = .area
    }
    @Published var state: State = .init()
    
    private weak var pathModel: PathModel?
    
    init(estateList: [EstateResponseEntity], pathModel: PathModel) {
        self.pathModel = pathModel
        self.state.estateList = estateList
        
        self.sortingData(selectedFilter: self.state.selectedFilter)
    }
    
    enum Action {
        case tapFilter(selectedFilter: EstateListFilterType)
        case tapEstate(estateID: String)
        case tapBack
    }
    
    func action(_ action: Action) {
        switch action {
        case .tapFilter(let selectedFilter):
            self.sortingData(selectedFilter: selectedFilter)
        case .tapEstate(let estateID):
            self.pathModel?.push(.detail(estateID: estateID))
        case .tapBack:
            self.pathModel?.pop()
        }
    }
    
    private func sortingData(selectedFilter: EstateListFilterType) {
        self.state.selectedFilter = selectedFilter
        
        switch selectedFilter {
        case .area:
            self.state.estateList.sort(by: { $0.area > $1.area })
        case .deposit:
            self.state.estateList.sort(by: { $0.deposit < $1.deposit })
        case .monthlyRent:
            self.state.estateList.sort(by: { $0.monthlyRent < $1.monthlyRent })
        case .buildYear:
            self.state.estateList.sort(by: { self.convertToDate($0.builtYear) > self.convertToDate($1.builtYear) })
        }
    }
    
    private func convertToDate(_ date: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        
        return formatter.date(from: date) ?? Date()
    }
}
