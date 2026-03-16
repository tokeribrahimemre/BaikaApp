//
//  WebServices.swift
//  BaikaApp
//
//  Created by İbrahim Emre Toker on 15.03.2026.
//
import Foundation

enum WebServiceError: Error {
    case serverError
    case parsinError
}


class WebServices {
    func downloadData(url: URL, completion: @escaping (Result<[Deneme], WebServiceError>) -> Void) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            
            if let error = error {
                completion(.failure(.serverError))
            } else if let data = data {
                let myResult =  try? JSONDecoder().decode([Deneme].self, from: data)
                if let myResult = myResult {
                    completion(.success(myResult))
                } else {
                    completion(.failure(.parsinError))
                }
            }
        }
    }
}
