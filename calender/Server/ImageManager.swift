//
//  ImageManager.swift
//  calender
//
//  Created by Ken Alparslan on 2021-07-11.
//

import Foundation
import RxSwift

class ImageManager {
    
    var session = URLSession.shared
    let url = URL(string: "https://api.thedogapi.com/v1/images/search?limit=7")! // https://api.thedogapi.com/v1/images/search
    var images: [URL] = []
    let subject = PublishSubject<Bool>()

    func observeDownloadProcess() -> Observable<Bool> {
        return subject.asObservable()
    }
    
    func notifyObservers(success: Bool) {
        subject.onNext(success)
    }
    
    func requestImages() {
        let task = session.dataTask(with: url) { data, response, error in
            print("image received")
            if data != nil {
                if let json = try? JSONSerialization.jsonObject(with: data!, options: []) as? [Any] {
                    for i in 0..<json.count {
                        if let breeds = json[i] as? [String: Any], let img = breeds["url"] as? String, let url = URL(string: img) {
                            self.images.append(url)
                        } else {
                            print("error parsing the data")
                        }
                    }
                }
            }

            for i in 0..<self.images.count {
                print(self.images[i])
            }
            if error == nil {
                self.notifyObservers(success: true)
            } else {
                print("Error occured while downloading images")
                self.notifyObservers(success: false)
            }
        }
        task.resume()
    }
}
