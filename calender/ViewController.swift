//
//  ViewController.swift
//  calender
//
//  Created by Ken Alparslan on 2021-07-11.
//

import UIKit
import RxSwift
import Reachability

class ViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    let imageManager = ImageManager()
    let bag = DisposeBag()
    let dayIndex = (Date().dayNumberOfWeek() ?? 0)
    var currentDay = 0
    var currentWeek: [Date] = []
    var animationTimer: Timer? = nil
    let reachability = try! Reachability()
    var didRequest: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.collectionView.register(UINib(nibName: String(describing: DayCollectionViewCell.self), bundle: nil), forCellWithReuseIdentifier: String(describing: DayCollectionViewCell.self))
        currentDay = dayIndex <= 1 ? 6 : dayIndex - 2
        print("Requesting an image")
        startAnimation()
        imageManager.subject.subscribe(onNext: { status in
            if (status) {
                self.updateUI()
            } else {
                self.didRequest = false
            }
        }).disposed(by: bag)
        NotificationCenter.default.addObserver(self, selector: #selector(reachabilityChanged(note:)), name: .reachabilityChanged, object: reachability)
        do{
          try reachability.startNotifier()
        }catch{
          print("could not start reachability notifier")
        }
        imageManager.requestImages()
        didRequest = true
        currentWeek = week()
        print(currentDay)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        reachability.stopNotifier()
        NotificationCenter.default.removeObserver(self, name: .reachabilityChanged, object: reachability)
    }
    
    @objc func reachabilityChanged(note: Notification) {

      let reachability = note.object as! Reachability

      switch reachability.connection {
      case .wifi:
          print("Reachable via WiFi")
        if !didRequest {
            imageManager.requestImages()
            didRequest = true
        }
      case .cellular:
          print("Reachable via Cellular")
      case .unavailable:
        print("Network not reachable")
      default:
        print("  ")
      }
    }
    
    func updateUI() {
        if animationTimer != nil {
            animationTimer?.invalidate()
            animationTimer = nil
        }
        DispatchQueue.main.async {
            self.collectionView.removeBluerLoader()
            self.collectionView.reloadData()
        }
    }
    
    func startAnimation() {
        self.collectionView.showBlurLoader()
        animationTimer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { timer in
            self.updateUI()
            timer.invalidate()
            self.animationTimer = nil
        })
    }
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
        
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 7
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: self.collectionView.frame.height/3)
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: DayCollectionViewCell.self), for: indexPath) as? DayCollectionViewCell else { return UICollectionViewCell() }
        cell.dayLbl.text = currentWeek[indexPath.row].dayOfWeek()
        if self.imageManager.images.count > 0 {
            if let data = try? Data(contentsOf: self.imageManager.images[indexPath.row]) {
                cell.petImageView.image = UIImage(data: data)?.imageResized(to: cell.frame.size)
                cell.petImageView.backgroundColor = .clear
            }
        } else {
            cell.petImageView.backgroundColor = indexPath.row % 2 == 1 ? UIColor.lightBlue : UIColor.lightPink
        }
        if indexPath.row == currentDay {
            cell.dayLbl.textColor = UIColor.red
        } else {
            cell.dayLbl.textColor = UIColor.white
        }
        return cell
    }
    
    func week() -> [Date] {
        var calendar = Calendar.autoupdatingCurrent
        calendar.firstWeekday = 2 // Start on Monday (or 1 for Sunday)
        let today = calendar.startOfDay(for: Date())
        var week = [Date]()
        if let weekInterval = calendar.dateInterval(of: .weekOfYear, for: today) {
            for i in 0...6 {
                if let day = calendar.date(byAdding: .day, value: i, to: weekInterval.start) {
                    week += [day]
                }
            }
        }
        return week
    }
}

