//
//  LandmarkListViewModel.swift
//  SwiftUIExample
//
//  Created by 이광용 on 2019/06/18.
//  Copyright © 2019 GwangYongLee. All rights reserved.
//

import SwiftUI
import Combine

final class LandmarkListViewModel: BindableObject {
    var didChange = PassthroughSubject<LandmarkListViewModel, Never>()
    var showFavoritesOnly: Bool = false {
        didSet {
            didChange.send(self)
        }
    }
    private weak var repository: Repository<Landmark>!
    
    private var displayLandmarks: [Landmark] = []
    
    var cellViewModels: [LandmarkCellViewModel] {
        displayLandmarks.map {
            LandmarkCellViewModel(landmark: $0,
                                  repository: self.repository)
        }
    }
    
    private var cancellables: [Cancellable] = []
    init(repository: Repository<Landmark>) {
        self.repository = repository
        let stream = repository.didChange.combineLatest(didChange) { (items, viewModel) -> [Landmark] in
            items.filter {
                viewModel.showFavoritesOnly == $0.isFavorite || $0.isFavorite
            }
        }.assign(to: \.displayLandmarks, on: self)
        cancellables.append(stream)
        didChange.send(self)
    }
    func reload() {
        didChange.send(self)
    }
    func preformRemoveLandmark(indexes: [Int]) {
        indexes.map { index in
            displayLandmarks[index]
        }
        .forEach {
            repository.delete(item: $0)
        }
    }
}
