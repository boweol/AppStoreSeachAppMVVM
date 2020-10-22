//
//  DetailViewController.swift
//  AppStoreSearchAppMVVM
//
//  Created by isens on 20/10/2020.
//  Copyright © 2020 isens. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

enum DetailViewInfoType: Int {
    case sellerName
    case fileSizeBytesString
    case genres
    case minimumOsVersion
    case languageCodesISO2A
    case contentAdvisoryRating
    case sellerNameCopyRight
    case sellerUrl
}

class DetailViewController: UIViewController {
    @IBOutlet weak var screenshotScrollView: UIScrollView!
    @IBOutlet weak var infoTableView: UITableView!
    @IBOutlet weak var artworkUrlImageView: UIImageView!
    @IBOutlet var averageUserRatingImageViews: [UIImageView]!
    
    @IBOutlet weak var newFunctionView: UIView!
    @IBOutlet weak var descriptionView: UIView!
    @IBOutlet weak var developerView: UIView!
    @IBOutlet weak var reviewView: UIView!
    
    @IBOutlet weak var trackNameLabel: UILabel!
    @IBOutlet weak var trackDetailLabel: UILabel!
    @IBOutlet weak var averageUserRatingLabel: UILabel!
    @IBOutlet weak var contentAdvisoryRatingLabel: UILabel!
    @IBOutlet weak var userRatingCountLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var releaseNotesLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var sellerNameLabel: UILabel!
    @IBOutlet weak var reviewAverageUserRatingLabel: UILabel!
    @IBOutlet weak var reviewUserRatingCountLabel: UILabel!
    
    @IBOutlet weak var openButton: UIButton!
    @IBOutlet weak var newFunctionMoreButton: UIButton!
    @IBOutlet weak var descriptionMoreButton: UIButton!
    
    @IBOutlet weak var newFunctionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var releaseNotesLabelTrailingConstraint: NSLayoutConstraint!
    @IBOutlet weak var descriptionLabelTrailingConstraint: NSLayoutConstraint!
    
    var viewModel = DetailViewModel()
    let disposeBag = DisposeBag()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureTableView()
        bind()
    }
    
    func sendData(_ appInfo: AppInfo) {
        viewModel.receivedData.accept(appInfo)
    }
    
    private func configureTableView() {
        registerCell()
        infoTableView.rowHeight = 44
    }
    
    private func registerCell() {
        let nib = UINib(nibName: DetailInfoTableViewCell.Identifier, bundle: nil)
        infoTableView.register(nib, forCellReuseIdentifier: DetailInfoTableViewCell.Identifier)
    }
    
    private func bind() {
        viewModel.receivedData.asObservable()
            .subscribe(onNext: { [weak self] item in
                guard let `self` = self, let `item` = item else { return }
                self.setInfoList(item)
                self.setUI(item)
            })
            .disposed(by: disposeBag)
        
        newFunctionMoreButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.releaseNotesLabel.sizeToFit()
                self.newFunctionViewHeightConstraint.constant = self.releaseNotesLabel.frame.height + 90
                self.newFunctionMoreButton.isHidden = true
                self.releaseNotesLabelTrailingConstraint.constant = -50
            })
            .disposed(by: disposeBag)
        
        descriptionMoreButton.rx.tap
            .subscribe(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.descriptionLabel.sizeToFit()
                self.descriptionViewHeightConstraint.constant = self.descriptionLabel.frame.height
                self.descriptionMoreButton.isHidden = true
                self.descriptionLabelTrailingConstraint.constant = -50
            })
            .disposed(by: disposeBag)
        
        viewModel.infoTableData.asObservable()
            .asDriver(onErrorJustReturn: [])
            .drive(infoTableView.rx.items(cellIdentifier: DetailInfoTableViewCell.Identifier, cellType: DetailInfoTableViewCell.self)) { row, infoDataList, cell in
                    cell.selectionStyle = .none
                
                    cell.titleLabel.text = infoDataList["title"] as? String ?? ""

                    // 셀 타입 지정
                    let key = infoDataList["type"] as? DetailViewInfoType ?? DetailViewInfoType.sellerName
                    if key == .sellerUrl {
                        cell.setType(.image, index: row)
                    } else if key == .minimumOsVersion || key == .contentAdvisoryRating {
                        cell.setType(.arrow, index: row)
                    } else {
                        cell.setType(.str, index: row)
                    }

                    // 셀 내용 적용
                    let value: String = infoDataList["value"] as? String ?? ""
                    cell.subTitleLabel.text = value
            }
            .disposed(by: disposeBag)
        
    }
    
    private func setUI(_ item: AppInfo) {
        self.artworkUrlImageView.layer.cornerRadius = 15.0
        if let artworkUrlString: String = item.artworkUrl512 {
            if let url = URL(string: artworkUrlString) {
                do {
                    let data = try Data(contentsOf: url)
                    self.artworkUrlImageView.image = UIImage(data: data)
                } catch {
                    print("artworkUrlImageView error: \(error.localizedDescription)")
                }
            }
        }
        
        self.openButton.layer.cornerRadius = 15.0

        if let trackName: String = item.trackName {
            self.trackNameLabel.text = trackName
        }        
        
        if let cellerName: String = item.sellerName {
            self.trackDetailLabel.text = cellerName
        }

        if let averageUserRating: Double = item.averageUserRating {
            for imageView in self.averageUserRatingImageViews {
                imageView.image = UIImage(systemName: "star")
            }
            for i in 0..<Int(round(averageUserRating)) {
               self.averageUserRatingImageViews[i].image = UIImage(systemName: "star.fill")
            }
        }

        if let averageUserRatingString: String = item.averageUserRatingString {
            self.averageUserRatingLabel.text = averageUserRatingString
        }

        if let contentAdvisoryRating: String = item.contentAdvisoryRating {
            self.contentAdvisoryRatingLabel.text = contentAdvisoryRating
        }

        if let userRatingCountString: String = item.userRatingCountString {
            self.userRatingCountLabel.text = userRatingCountString + "개의 평가"
        }

        if let genres: [String] = item.genres, genres.count > 0 {
            self.genresLabel.text = genres[0]
        }

        // 새로운 기능
        self.newFunctionView.layer.addBorder([.top], thick: 1.0, widthMargin: 0)

        if let version: String = item.version {
            self.versionLabel.text = "버전 " + version
        }

        if let releaseDate: String = item.currentVersionReleaseDate {
            self.setReleaseDateLabel(releaseDate)
        }

        if let releaseNotes: String = item.releaseNotes {
            self.releaseNotesLabel.text = releaseNotes
        }

        // 미리보기
        if let screenshotUrlStrings: [String] = item.screenshotUrls {
            let subViews = self.screenshotScrollView.subviews
            for subview in subViews{
                subview.removeFromSuperview()
            }
            for imageUrlString in screenshotUrlStrings {
                if let url = URL(string: imageUrlString) {
                    do {
                        let data = try Data(contentsOf: url)
                        self.addViewInScrollView(UIImage(data: data))
                    } catch {
                        print("screenshotScrollView error: \(error.localizedDescription)")
                    }
                }
            }
        }

        // 앱 설명
        self.descriptionView.layer.addBorder([.top], thick: 1.0, widthMargin: 0)
        if let description: String = item.description {
            self.descriptionLabel.text = description
        }

        // 개발자
        if let sellerName: String = item.sellerName {
            self.sellerNameLabel.text = sellerName
        }

        // 평가 및 리뷰
        self.reviewView.layer.addBorder([.bottom], thick: 1.0, widthMargin: 0)
        self.reviewAverageUserRatingLabel.text = self.averageUserRatingLabel.text
        if let userRatingCount: Int = item.userRatingCount {
            let numberFormatter = NumberFormatter()
            numberFormatter.numberStyle = .decimal
            self.reviewUserRatingCountLabel.text = (numberFormatter.string(from: NSNumber(value:userRatingCount)) ?? "") + "개의 평가"
        }
        
    }
    
    private func setInfoList(_ item: AppInfo) {
        if let sellerName = item.sellerName {
            self.viewModel.addInfoTableData(["type": DetailViewInfoType.sellerName, "title": "제공자", "value": sellerName])
        }
        if let fileSizeBytesString = item.fileSizeBytesString {
            self.viewModel.addInfoTableData(["type": DetailViewInfoType.fileSizeBytesString, "title": "크기", "value": fileSizeBytesString])
        }
        if let genres = item.genres, genres.count > 0 {
            self.viewModel.addInfoTableData(["type": DetailViewInfoType.genres, "title": "카테고리", "value": genres[0]])
        }
        if let minimumOsVersion = item.minimumOsVersion {
            self.viewModel.addInfoTableData(["type": DetailViewInfoType.minimumOsVersion, "title": "호환성", "value": minimumOsVersion, "detail": minimumOsVersion])
        }
        if let languageCodesISO2A = item.languageCodesISO2A, languageCodesISO2A.count > 0 {
            var languageCodesSrting = languageCodesISO2A[0]
            if languageCodesISO2A.count > 1 {
                languageCodesSrting += " 외 " + String(languageCodesISO2A.count - 1) + "개"

                var languageCodesDetailSring = ""
                if let languageCodesISO2AString = item.languageCodesISO2AString {
                    languageCodesDetailSring = languageCodesISO2AString
                }
                self.viewModel.addInfoTableData(["type": DetailViewInfoType.languageCodesISO2A, "title": "언어", "value": languageCodesSrting, "detail": languageCodesDetailSring])
            } else {
                self.viewModel.addInfoTableData(["type": DetailViewInfoType.languageCodesISO2A, "title": "언어", "value": languageCodesSrting])
            }
        }
        if let contentAdvisoryRating = item.contentAdvisoryRating {
            self.viewModel.addInfoTableData(["type": DetailViewInfoType.contentAdvisoryRating, "title": "연령 등급", "value": contentAdvisoryRating, "detail": contentAdvisoryRating])
        }
        if let sellerName = item.sellerName {
            self.viewModel.addInfoTableData(["type": DetailViewInfoType.sellerNameCopyRight, "title": "저작권", "value": "© " + sellerName])
        }
        if let sellerUrl = item.sellerUrl {
            self.viewModel.addInfoTableData(["type": DetailViewInfoType.sellerUrl, "title": "개발자 웹 사이트", "value": sellerUrl])
        }
    }
    
    // 배포 날짜 설정
    private func setReleaseDateLabel(_ releaseDateString: String) {
        let today = Date()
        let todayTimeInterval = today.timeIntervalSince1970
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ssZ"
        if let releaseDate = dateFormatter.date(from: releaseDateString) {
            let releaseTimeInterval = releaseDate.timeIntervalSince1970
            let timeGapInterval = Int(todayTimeInterval - releaseTimeInterval)
            let hourSec = 60 * 60
            let daySec = 24 * 60 * 60
            if timeGapInterval > (365 * daySec) {
                let year = Int(timeGapInterval / (365 * daySec))
                self.releaseDateLabel.text = String(year) + "년 전"
            } else if timeGapInterval > (30 * daySec) {
                let month = Int(timeGapInterval / (30 * daySec))
                self.releaseDateLabel.text = String(month) + "개월 전"
            } else if timeGapInterval > (7 * daySec) {
               let weak = Int(timeGapInterval / (7 * daySec))
               self.releaseDateLabel.text = String(weak) + "주 전"
            } else if timeGapInterval > daySec {
                let day = Int(timeGapInterval / daySec)
                self.releaseDateLabel.text = String(day) + "일 전"
            } else if timeGapInterval > hourSec {
                let time = Int(timeGapInterval / hourSec)
                self.releaseDateLabel.text = String(time) + "시간 전"
            }
        }
    }
    
    // 미리보기 스크롤뷰에 이미지 뷰 추가
    private func addViewInScrollView(_ image: UIImage?) {
        if let img = image {
            let xPosition = self.screenshotScrollView.contentSize.width
            let view: UIImageView = UIImageView(frame: CGRect(x: xPosition, y: 0, width: 180, height: 300))
            view.image = img
            view.layer.cornerRadius = 15.0
            view.clipsToBounds = true
            view.contentMode = .scaleAspectFill
            self.screenshotScrollView.addSubview(view)
            self.screenshotScrollView.contentSize.width += 180 + 10
        }
    }
}
