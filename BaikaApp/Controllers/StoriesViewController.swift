//
//  StoriesViewController.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import UIKit

class StoriesViewController: UIViewController {
    
    
    @IBOutlet weak var backButton: UIButton!
    var shouldShowBackButton = false
    
    @IBOutlet weak var agesCollectionView: UICollectionView!
    @IBOutlet weak var themCollectionView: UICollectionView!
    @IBOutlet weak var tableView: UITableView!
    

    
    override func viewDidLoad() {
        super.viewDidLoad()
        if !shouldShowBackButton {
            backButton.isUserInteractionEnabled = false
            backButton.setImage(.moon, for: .normal)
        }
        
        self.title = "Hikayeler"
        registerCells()
        // Do any additional setup after loading the view.
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
        return 3
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StoriesCVCell", for: indexPath) as! StoriesCollectionViewCell
        
        return cell
    }
    
}

extension StoriesViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StoriesTVCell", for: indexPath) as! StoriesTableViewCell
        return cell
    }
}
