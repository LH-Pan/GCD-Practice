//
//  ApiAccess.swift
//  GCD Practice
//
//  Created by 潘立祥 on 2019/8/22.
//  Copyright © 2019 PanLiHsiang. All rights reserved.
//

import Foundation

import UIKit

protocol DetailInfoProviderDelegate: AnyObject {
    
    func detailInfoProvider(didGet result: [DetailInfo])
    
}

class DetailInfoProvider {
    
    weak var detailInfoDelegate: DetailInfoProviderDelegate?
    
    static let shared = DetailInfoProvider()
    
    let downloadGroup: DispatchGroup = DispatchGroup()
    
    // MARK: GCD Group 時要關掉 didSet
    var dataProvider: [DetailInfo] = []
    {

        didSet {
            detailInfoDelegate?.detailInfoProvider(didGet: dataProvider)
        }
    }
    
    func fetchDetailInfo(for offset: TaipeiUrl.Offset) {
        
        var completeUrl: URLComponents
        
        switch offset {
            
        case .fistOffset: completeUrl = TaipeiUrl.Offset.fistOffset.taipeiAPI
            
        case .secondOffset: completeUrl = TaipeiUrl.Offset.secondOffset.taipeiAPI
            
        case .thirdOffset: completeUrl = TaipeiUrl.Offset.thirdOffset.taipeiAPI
        }
        
        guard let url = completeUrl.url else { return }
        // MARK: GCD Group
//        downloadGroup.enter()
        
        let task = URLSession.shared.dataTask(with: url) {(data, response, error) in
            
            if error != nil {
                
                print ("dataTask error")
                
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            let statusCode = httpResponse.statusCode
            
            if statusCode >= 200 && statusCode < 300 {
            
            guard let data = data, let utf8Text = String(data: data, encoding: .utf8) else { return }
                
//                print(utf8Text)
            
            do {
                let decoder = JSONDecoder()
                
                let resultInfo = try decoder.decode(TaipeiResult.self, from: data)
                
                let detailInfo = resultInfo.result
                
                let detailInformation = detailInfo.results
                
                self.dataProvider.append(contentsOf: detailInformation)
                
                print("API Done")
            
            } catch {
            
                print ("Decode error!")
                }
            }
            // MARK: GCD Group
//            self.downloadGroup.leave()
            
            if statusCode >= 400 && statusCode < 500 {
                
                guard let error = error else { return}
                
                print(error)
            }
        }
        task.resume()
        // MARK: GCD Group
//        downloadGroup.notify(queue: .main) { [weak self] in
//
//            self?.detailInfoDelegate?.detailInfoProvider(didGet: self?.dataProvider ?? [])
//
//        }
     }
}

class TaipeiUrl{
    
    enum Offset: String {
        
        case fistOffset = "0"
        
        case secondOffset = "10"
        
        case thirdOffset = "20"
    
    var taipeiAPI: URLComponents {
        
        var taipeiAPI = URLComponents()
        
        taipeiAPI.scheme = "https"
        
        taipeiAPI.host = "data.taipei"
        
        taipeiAPI.path = "/opendata/datalist/apiAccess"
        
        taipeiAPI.queryItems = [
            
            URLQueryItem(name: "scope", value: "resourceAquire"),
            
            URLQueryItem(name: "rid", value: "5012e8ba-5ace-4821-8482-ee07c147fd0a"),
            
            URLQueryItem(name: "limit", value: "1"),
            
            URLQueryItem(name: "offset", value: rawValue)
        
        ]
        
            return taipeiAPI
        }
    }
}

struct TaipeiResult: Codable {
    
    let result: ResultInfo
}

struct ResultInfo: Codable {
    
    let limit: Int
    
    let offset: Int
    
    let count: Int
    
    let sort: String
    
    var results: [DetailInfo]
    
}

struct DetailInfo: Codable {
    
    let functions: String
    
    let area: String
    
    let no: String
    
    let direction: String
    
    let speedLimit: String
    
    let location: String
    
    let Id: Int
    
    let road: String
    
    enum CodingKeys: String, CodingKey {
        case Id = "_id"
        case speedLimit = "speed_limit"
        case functions, area, no, direction, location, road
    }
}
