//
//  DenemeViewModel.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//

import Foundation

class DenemeViewModel {
    
    func requestData() {
        guard let url = URL(string: "https://raw.githubusercontent.com/ibrahim-emre-toker/BaikaApp/main/data.json") else { return }
        WebServices().downloadData(url: url) { result in
            switch result {
            case .success(let data):
                print("data")
            case .failure(let error):
                print("error")
            }
            
        }
    }
}
