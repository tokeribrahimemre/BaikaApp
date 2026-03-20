//
//  DynamicTableView.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 20.03.2026.
//

import UIKit

class DynamicHeightTableView: UITableView {
    
    // TableView'un içeriğinin toplam boyunu kendi "doğal boyu" olarak belirler
    override var intrinsicContentSize: CGSize {
        self.layoutIfNeeded()
        return CGSize(width: UIView.noIntrinsicMetric, height: contentSize.height)
    }
    
    // İçeriğe yeni veri eklendiğinde (reloadData) boyunu tekrar hesaplamasını söyler
    override var contentSize: CGSize {
        didSet {
            self.invalidateIntrinsicContentSize()
        }
    }
}
