//
//  StoriesViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import UIKit

class StoriesViewController: UIViewController {
    
    var shouldShowBackButton = false
    
    private let viewModel = StoriesViewModel()
    
    @IBOutlet weak var emptyStateView: UIView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var agesCollectionView: UICollectionView!
    @IBOutlet weak var themCollectionView: UICollectionView!
    @IBOutlet weak var tableView: DynamicHeightTableView!
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        if !shouldShowBackButton {
            backButton.isUserInteractionEnabled = false
            backButton.setImage(.moon, for: .normal)
        }
        self.title = "Hikayeler"
        registerCells()
        bindViewModel()
        
        
        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchStories() // veya veri çekme metodunuz her ne ise
    }
    
    private func bindViewModel() {
            viewModel.onStoriesUpdated = { [weak self] in
                guard let self = self else { return }
                self.tableView.reloadData()
                self.updateEmptyState()
            }
            
            viewModel.onError = { [weak self] errorMessage in
                let alert = UIAlertController(title: "Hata", message: errorMessage, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                self?.present(alert, animated: true)
            }
        }

    private func registerCells(){
        let collectionCellNib = UINib(nibName: "StoriesCollectionViewCell", bundle: nil)
        
        agesCollectionView.register(collectionCellNib, forCellWithReuseIdentifier: "StoriesCVCell")
        agesCollectionView.dataSource = self
        agesCollectionView.delegate = self
                
        themCollectionView.register(collectionCellNib, forCellWithReuseIdentifier: "StoriesCVCell")
        themCollectionView.dataSource = self
        themCollectionView.delegate = self
        
        let tableViewCellNib = UINib(nibName: "StoriesTableViewCell", bundle: nil)
        tableView.register(tableViewCellNib, forCellReuseIdentifier: "StoriesTVCell")
        tableView.dataSource = self
        tableView.delegate = self
        
        tableView.backgroundColor = AppColors.background
                                
    }
     
    func updateEmptyState() {
        tableView.isHidden = viewModel.isEmpty
        emptyStateView.isHidden = !viewModel.isEmpty
            
    }
    
    
    @IBAction func backButtonTapped(_ sender: Any) {
        
        print("backbuttontapped")
        navigationController?.popViewController(animated: true)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
extension StoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
           if collectionView == agesCollectionView {
               return viewModel.ageFilters.count
           } else {
               return viewModel.themeFilters.count
           }
       }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCVCell", for: indexPath) as! StoriesCollectionViewCell
            
            var isCellSelected: Bool
            
            if collectionView == agesCollectionView {
                let filter = viewModel.ageFilters[indexPath.row]
                cell.titleLabel.text = filter.title
                isCellSelected = viewModel.isAgeSelected(at: indexPath.row)
            } else {
                let filter = viewModel.themeFilters[indexPath.row]
                cell.titleLabel.text = filter.title
                isCellSelected = viewModel.isThemeSelected(at: indexPath.row)
            }
            
            if isCellSelected {
                cell.layer.borderWidth = 1.5
                cell.backgroundColor = UIColor(hex: "A8D8EA").withAlphaComponent(0.2)
                cell.layer.borderColor = UIColor(hex: "A8D8EA").withAlphaComponent(0.3).cgColor
                cell.titleLabel.textColor = UIColor(hex: "A8D8EA").withAlphaComponent(1)
            } else {
                cell.backgroundColor = .clear
                cell.layer.borderWidth = 1.0
                cell.layer.borderColor = UIColor(hex: "000000").withAlphaComponent(0.0).cgColor
                cell.titleLabel.textColor = UIColor(hex: "FFFFFF").withAlphaComponent(0.6)
            }
            
            return cell
        }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if collectionView == agesCollectionView {
            viewModel.toggleAgeFilter(at: indexPath.row)
            agesCollectionView.reloadData()
        } else {
            viewModel.toggleThemeFilter(at: indexPath.row)
            themCollectionView.reloadData()
        }
    }
    
                            
}

extension StoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfStories
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesTVCell", for: indexPath) as! StoriesTableViewCell
            let story = viewModel.story(at: indexPath.row)
            cell.configureCell(with: story)
            return cell
        }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedStory = viewModel.story(at: indexPath.row)
        
        let storyboard = UIStoryboard(name: "StoryDetails", bundle: nil)
        
        let detailVC = storyboard.instantiateViewController(identifier: "StoryDetail") { coder in

            return StoryDetailsViewController(coder: coder, story: selectedStory)
        }
//        detailVC.hidesBottomBarWhenPushed = false
        self.navigationController?.pushViewController(detailVC, animated: true)
        
    }
}
