//
//  ViewController.swift
//  GCD Practice
//
//  Created by 潘立祥 on 2019/8/22.
//  Copyright © 2019 PanLiHsiang. All rights reserved.
//

import UIKit

class ViewController: UIViewController, DetailInfoProviderDelegate {
   
    @IBOutlet weak var firstRoadLabel: UILabel!
    
    @IBOutlet weak var firstLimitLabel: UILabel!
    
    @IBOutlet weak var secondRoadLabel: UILabel!
    
    @IBOutlet weak var secondLimitLabel: UILabel!
    
    @IBOutlet weak var thirdRoadLabel: UILabel!
    
    @IBOutlet weak var thirdLimitLabel: UILabel!
    
    var detaillInfo: [DetailInfo] = []
    
    let downloadGroup: DispatchGroup = DispatchGroup()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DetailInfoProvider.shared.detailInfoDelegate = self
        
    }
    
    @IBAction func groupAPI(_ sender: Any) {
        
        DetailInfoProvider.shared.fetchDetailInfo(for: .fistOffset)
        
        DetailInfoProvider.shared.fetchDetailInfo(for: .secondOffset)
        
        DetailInfoProvider.shared.fetchDetailInfo(for: .thirdOffset)
    }
    
    let semaphore = DispatchSemaphore(value: 1)
    
    let queue = DispatchQueue.global()
    
    @IBAction func semaphoreAPI(_ sender: Any) {
        
        queue.async {[weak self] in
            if self?.semaphore.wait(timeout: .distantFuture) == .success {
                
                DetailInfoProvider.shared.fetchDetailInfo(for: .fistOffset)
                
                self?.semaphore.signal()
            }
        }
        
        queue.async {[weak self] in
            if self?.semaphore.wait(timeout: .distantFuture) == .success {
                
                DetailInfoProvider.shared.fetchDetailInfo(for: .secondOffset)

                self?.semaphore.signal()
            }
        }
        
        queue.async {[weak self] in
            if self?.semaphore.wait(timeout: .distantFuture) == .success {
                
                DetailInfoProvider.shared.fetchDetailInfo(for: .thirdOffset)
                
                self?.semaphore.signal()
            }
        }
    }
    
    
    func detailInfoProvider(didGet result: [DetailInfo]) {
        detaillInfo = result
        
        queue.async {[weak self] in
            if self?.semaphore.wait(timeout: .distantFuture) == .success {
                
                DispatchQueue.main.async {
                    self?.firstRoadLabel.text = self?.detaillInfo[0].road
                    
                    self?.firstLimitLabel.text = self?.detaillInfo[0].speedLimit
                }
                
                sleep(1)
                
                self?.semaphore.signal()
            }
        }
        
        queue.async {[weak self] in
            if self?.semaphore.wait(timeout: .distantFuture) == .success {
                
                DispatchQueue.main.async {
                    self?.secondRoadLabel.text = self?.detaillInfo[1].road
                    
                    self?.secondLimitLabel.text = self?.detaillInfo[1].speedLimit
                }
                
                sleep(1)
                
                self?.semaphore.signal()
            }
        }
        
        queue.async {[weak self] in
            if self?.semaphore.wait(timeout: .distantFuture) == .success {
                
                DispatchQueue.main.async {
                    
                    self?.thirdRoadLabel.text = self?.detaillInfo[2].road
                    
                    self?.thirdLimitLabel.text = self?.detaillInfo[2].speedLimit
                }
                
                sleep(1)
                
                self?.semaphore.signal()
            }
        }
        
    }
}

