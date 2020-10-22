//
//  SearchViewController.swift
//  AppStoreSearchAppMVVM
//
//  Created by isens on 20/10/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class SearchViewController: UIViewController {

    @IBOutlet weak var searchTableView: UITableView!
    @IBOutlet weak var indicatorView: UIActivityIndicatorView!
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchBar: UISearchBar { return searchController.searchBar }
    var viewModel = SearchViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureTableView()
        indicatorView.hidesWhenStopped = true
        setVisibleIndicator(false)
        bind()
    }
    
    private func configureSearchController() {
        searchController.obscuresBackgroundDuringPresentation = false
        searchBar.showsCancelButton = true
        searchBar.placeholder = "Enter search word"
        searchTableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
    }
    
    private func configureTableView() {
        registerCell()
        searchTableView.rowHeight = UITableView.automaticDimension
    }
    
    private func registerCell() {
        let nib = UINib(nibName: SearchTableViewCell.Identifier, bundle: nil)
        searchTableView.register(nib, forCellReuseIdentifier: SearchTableViewCell.Identifier)
    }
    
    private func bind() {
        searchBar.rx.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.searchBar.resignFirstResponder()
                self.viewModel.searchText.accept(self.searchBar.text ?? "")
                self.setVisibleIndicator(true)
            })
            .disposed(by: disposeBag)
        
        viewModel.data
            .drive(searchTableView.rx.items(cellIdentifier: SearchTableViewCell.Identifier, cellType: SearchTableViewCell.self)) { [weak self] _, appInfo, cell in
                
                if let _ = self?.indicatorView.isAnimating {
                    self?.setVisibleIndicator(false)
                }
                
                cell.selectionStyle = .none
                if let trackName: String = appInfo.trackName {
                    cell.trackNameLabel.text = trackName
                }
                if let genres: [String] = appInfo.genres, genres.count > 0 {
                    cell.genresLabel.text = genres[0]
                }
                if let averageUserRating: Double = appInfo.averageUserRating {
                    cell.setAverageUserRating(averageUserRating)
                }
                if let userRatingCountString: String = appInfo.userRatingCountString {
                    cell.userRatingCountLabel.text = userRatingCountString
                }
                if let artworkUrl: String = appInfo.artworkUrl100 {
                    cell.setArtworkUrlImage(artworkUrl)
                }
                if let screenshotUrls: [String] = appInfo.screenshotUrls {
                    cell.setScreenshotUrlImages(screenshotUrls)
                }
        }
        .disposed(by: disposeBag)
        
//        searchTableView.rx.itemSelected
//            .subscribe(onNext: { [weak self]indexPath in
//                guard let `self` = self else {return}
//                self.performSegue(withIdentifier: "DetailViewController", sender: nil)
//        }).disposed(by: disposeBag)
        
        searchTableView.rx.modelSelected(AppInfo.self)
            .subscribe(onNext: { [weak self] item in
            guard let `self` = self else {return}
            self.performSegue(withIdentifier: "DetailViewController", sender: item)
        }).disposed(by: disposeBag)
    }
    
    func setVisibleIndicator(_ isVisible: Bool) {
        if isVisible {
            indicatorView.startAnimating()
//            indicatorView.isHidden = false
        } else {
            indicatorView.stopAnimating()
//            indicatorView.isHidden = true
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let detailViewController = segue.destination as? DetailViewController else {
            return
        }
        guard let appInfo = sender as? AppInfo else {
            return
        }
        
        detailViewController.sendData(appInfo)
    }
}

