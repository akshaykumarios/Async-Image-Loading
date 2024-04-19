//
//  PhotoCollectionViewController.swift
//  Async Image Loading
//
//  Created by Akshay Kumar on 14/04/24.
//

import UIKit

final class PhotoCollectionViewController: UICollectionViewController {
    
    private var dataSource: UICollectionViewDiffableDataSource<Section, Item>! = nil
    var imageObjects: [Item] = []
    var currentPage: Int = 1
    var isPaginating: Bool = false
    
    private func createCollectionLayout() -> UICollectionViewLayout {
        let itemSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.25),
                                              heightDimension: .fractionalHeight(1.0))
        let item = NSCollectionLayoutItem(layoutSize: itemSize)
        item.contentInsets = NSDirectionalEdgeInsets(top: 1, leading: 1, bottom: 1, trailing: 1)
        let groupSize = NSCollectionLayoutSize(widthDimension: .fractionalWidth(1.0),
                                               heightDimension: .fractionalWidth(0.25))
        let group = NSCollectionLayoutGroup
            .horizontal(layoutSize: groupSize,
                        subitems: [item])
        let section = NSCollectionLayoutSection(group: group)
        let layout = UICollectionViewCompositionalLayout(section: section)
        return layout
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationTitle()
    }
    
    private func setNavigationTitle() {
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.title = "Photos"
        configureDatasource()
    }
    
    private func configureDatasource() {
        collectionView.collectionViewLayout = createCollectionLayout()
        //        MARK: CollectionViewCell Registration
        let cellRegistration = UICollectionView.CellRegistration<UICollectionViewCell, Item> { (cell, indexPath, item) in
            
            var content = UIListContentConfiguration.cell()
            content.directionalLayoutMargins = .zero
            content.axesPreservingSuperviewLayoutMargins = []
            content.imageProperties.reservedLayoutSize = cell.bounds.size
            content.image = item.image
            content.text = nil
            
            // MARK: Caching images from URLs
            ImageCache.shared.loadImage(from: item.urls.smallS3Url as NSURL, for: item) { (fetchedItem, image) in
                if let img = image, img != fetchedItem.image {
                    var updatedSnapshot = self.dataSource.snapshot()
                    if let datasourceIndex = updatedSnapshot.indexOfItem(fetchedItem) {
                        let updatedItem = self.imageObjects[datasourceIndex]
                        updatedItem.image = img
                        
                        DispatchQueue.main.async { [weak self] in
                            updatedSnapshot.reloadItems([updatedItem])
                            self?.dataSource.apply(updatedSnapshot, animatingDifferences: true)
                        }
                    }
                }
            }
            
            cell.layer.shouldRasterize = true
            cell.layer.rasterizationScale = UIScreen.main.scale
            cell.backgroundColor = .label
            cell.contentConfiguration = content
        }
        
        // MARK: Datasource handling
        dataSource = UICollectionViewDiffableDataSource<Section, Item>(collectionView: collectionView) {
            (collectionView, indexPath, item)
            -> UICollectionViewCell? in
            return collectionView
                .dequeueConfiguredReusableCell(using:
                                                cellRegistration,
                                               for: indexPath, item: item)
        }
        
        // MARK: number of initial pages to load
        if imageObjects.isEmpty {
            for index in 1...5 {
                currentPage = index
                getPhotosFromAPI(for: index)
            }
        }
    }
    
    // MARK: Get image URLs from API and processing it for cache.
    private func getPhotosFromAPI(for page: Int) {
        Task {
            do {
                let photos: [Item] = try await DataTaskManager.shared
                    .dataTask(with:
                                RequestObj(currentPage: page))
                photos.forEach { [weak self] item in
                    let newItem = Item(urls: item.urls,
                                       image: ImageCache.shared
                        .placeholderImage!)
                    self?.imageObjects.append(newItem)
                }
            } catch RequestError.noInternet {
                showAlert(with: "No internet connection")
            } catch let error {
                showAlert(with: error.localizedDescription)
            }
            setInitialData()
        }
    }
    
    // MARK: Apply initial snapshot to datasource
    private func setInitialData() {
        var initialSnapshot = NSDiffableDataSourceSnapshot<Section, Item>()
        initialSnapshot.appendSections([.main])
        initialSnapshot.appendItems(self.imageObjects)
        dataSource.apply(initialSnapshot, animatingDifferences: false)
    }
    
    private func showAlert(with message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel))
        present(alert, animated: true)
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        isPaginating = false
    }
    
    override func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(2)) {
            if ((self.collectionView.contentOffset.y + self.collectionView.frame.size.height) + 120 >= self.collectionView.contentSize.height) && !self.isPaginating {
                self.isPaginating = true
                self.currentPage += 1
                Task(priority: .background) {
                    self.getPhotosFromAPI(for: self.currentPage)
                }
            }
        }
    }
}
