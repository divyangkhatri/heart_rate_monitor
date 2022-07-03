//
//  ViewController.swift
//  Heart Rate Monitor
//
//  Created by Divyang Khatri on 14/03/20.
//  Copyright © 2020 LanetTeam. All rights reserved.
//

import UIKit
import HealthKit
import WatchConnectivity

class ViewController: UIViewController,UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout {
    
    var width = CGFloat();
    var height = CGFloat();
    var healthStore : HKHealthStore!;
    var heartData = [HeartData]();
    var calender : Calendar!;
    var days = [Date]()
    var months = [Date]()
    var years = [Date]()
    var isSelected  = false;
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    @IBOutlet weak var headingChart: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var averageRestingBPMLabel: UILabel!
    @IBOutlet weak var averageRestingImageView: UIImageView!
    @IBOutlet weak var averageWalkingBPMLabel: UILabel!
    @IBOutlet weak var heartBeatingImageview: UIImageView!
    @IBOutlet weak var averageWalkingImageView: UIImageView!
    @IBOutlet weak var activeBPMLabel: UILabel!
    @IBOutlet weak var activeTimeLabel: UILabel!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    override func viewDidLoad() {
        calender = Calendar.current;
        
        var imageArray = [UIImage]()
        for i in 0...9 {
            imageArray.append(UIImage(named:"heartBeating\(i)")!)
            
        }
        heartBeatingImageview.animationImages = imageArray;
        heartBeatingImageview.animationDuration = 1.0
        heartBeatingImageview.startAnimating();
        averageWalkingImageView.animationImages = imageArray
        averageWalkingImageView.animationDuration = 1.0
        averageWalkingImageView.startAnimating();
        averageRestingImageView.animationImages = imageArray
        averageRestingImageView.animationDuration = 1.0
        averageRestingImageView.startAnimating();
        
        days = settingAllDate(from: 6, to: 0, component: .day,date: Date())
        months = settingAllDate(from: 29, to: 0, component: .day,date: Date())
        years = settingAllDate(from: 12, to: 1, component: .month,date:  Date())
       
        let dateformat = DateFormatter();
        dateformat.dateFormat = "dd/MM/yyyy"
    
        shadow(Vw: activityView)
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        height = view.safeAreaLayoutGuide.layoutFrame.height;
        width = view.safeAreaLayoutGuide.layoutFrame.width;
        super.viewDidAppear(animated);
        authorization { (success, healthStore) in
            self.healthStore = healthStore ;
            if(success){
                self.setIndicator(value: true)
                self.getLatestheartRate()
                
                DispatchQueue.main.async {
                    let layout: UICollectionViewFlowLayout = UICollectionViewFlowLayout()
                    layout.sectionInset = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10)
                    layout.scrollDirection =  .horizontal;
                    layout.minimumLineSpacing = 4
                    self.collectionView!.collectionViewLayout = layout
                    self.collectionView.register(UINib(nibName: "CollectionViewCell", bundle: nil), forCellWithReuseIdentifier: "CollectionViewCell")
                }
                let startDate = self.calender.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
                var interval = DateComponents()
                interval.minute = 1
                self.getAverageWalkingOrRestingHeartRate(isWalking: true, predicate: predicate)
                self.getAverageWalkingOrRestingHeartRate(isWalking: false, predicate: predicate)
                self.prepareQuery(predicate: predicate, interval: interval)
            }
        }
    }
    @IBAction func changeSegment(_ sender: Any) {
        let segment = sender as! UISegmentedControl;
        let index = segment.selectedSegmentIndex;
        getLatestheartRate();
        if(!isSelected){
            setSegmentText()
            if(index == 0){
                headingChart.text = "Today Heart Rate"
                let startDate = calender.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
                var interval = DateComponents()
                interval.minute = 1
                self.getAverageWalkingOrRestingHeartRate(isWalking: true, predicate: predicate)
                self.getAverageWalkingOrRestingHeartRate(isWalking: false, predicate: predicate)
                prepareQuery(predicate: predicate, interval: interval)
                
            }else if(index == 1){
                headingChart.text = "Average Heart Rate of Week"
                let startDate = calender.date(byAdding: .day, value: -6, to: Date())!;
             
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
                var interval = DateComponents()
                interval.day = 1
                self.getAverageWalkingOrRestingHeartRate(isWalking: true, predicate: predicate)
                self.getAverageWalkingOrRestingHeartRate(isWalking: false, predicate: predicate)
                prepareQuery(predicate: predicate, interval: interval)
            }else if(index == 2){
                headingChart.text = "Average Heart Rate of Month"
                let date = Date();
                let startDate = calender.date(byAdding: .day, value: -30, to: date)!;
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
                var interval = DateComponents()
                interval.day = 1
                self.getAverageWalkingOrRestingHeartRate(isWalking: true, predicate: predicate)
                self.getAverageWalkingOrRestingHeartRate(isWalking: false, predicate: predicate)
                prepareQuery(predicate: predicate, interval: interval)
            }
            else if(index == 3){
                headingChart.text = "Average Heart Rate of Year"
                let endDate = Date();
               var startDate = calender.date(byAdding: .month, value: -11, to: endDate)!;
                startDate = calender.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
             
                
                
                let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
                var interval = DateComponents()
                interval.month = 1
                self.getAverageWalkingOrRestingHeartRate(isWalking: true, predicate: predicate)
                self.getAverageWalkingOrRestingHeartRate(isWalking: false, predicate: predicate)
                prepareQuery(predicate: predicate, interval: interval)
            }
        }
        
    }
    
    
    func prepareQuery (predicate: NSPredicate?,interval : DateComponents?){
        setIndicator(value: true)
        guard let predicate = predicate else { return }
        guard let interval = interval else { return }
        getAvgHeartRate(predicate: predicate, interval: interval) { (statisticsCollections) in
            
            guard let statistics = statisticsCollections else { return }
            
            DispatchQueue.main.async {
                    self.setArray(statistics: statistics) {
                    self.setIndicator(value: false)
                    self.collectionView.reloadData();
                    self.collectionView.setContentOffset(CGPoint(x: 0, y: 0), animated: false)
                }
               
            }
            
            
        }
    }
    
    func combineArray(tempArray:[HeartData],dateArray:[Date]) -> [HeartData]{
        let formatter = DateFormatter()
        formatter.dateFormat = segmentControl.selectedSegmentIndex == 3 ? "MM:yyyy" : "dd:MM:yyyy"
        var  finalArr = [HeartData]();
        var counter = 0
        for date in dateArray {
            counter = 0
            let  tempd1 = formatter.string(from: date)
            for  temp in tempArray{
                let tempd2=formatter.string(from: temp.heartDate)
                if(tempd1 != tempd2 ){
                    counter += 1;
                }
            }
            if(counter == tempArray.count){
                finalArr.append(HeartData(heartRate: 0, heartDate: date))
            }
        }
        return  finalArr
    }
    func setIndicator(value:Bool){
        DispatchQueue.main.async {
            
            
            self.activityView.isHidden = !value
            self.view.isUserInteractionEnabled = !value
            if(value){
                self.activityIndicator.startAnimating()
            }else{
                self.activityIndicator.stopAnimating()
            }
        }
    }
    
    func setArray(statistics:HKStatisticsCollection, completion:@escaping() -> Void){
        self.heartData.removeAll()
        let beatsPerMinuteUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
        
        for statistic in statistics.statistics(){
            
            guard let quantity = statistic.averageQuantity() else { return }
            
            let value = quantity.doubleValue(for: beatsPerMinuteUnit)
            let date = statistic.startDate
            
            
            self.heartData.append(HeartData(heartRate: value, heartDate: date))
            
        }
        if(segmentControl.selectedSegmentIndex == 1){
            heartData.append(contentsOf: combineArray(tempArray: heartData, dateArray:days))
        }
        else if(segmentControl.selectedSegmentIndex == 2){
            heartData.append(contentsOf: combineArray(tempArray: heartData, dateArray:months))
        }  else if(segmentControl.selectedSegmentIndex == 3){
//            heartData.append(contentsOf: combineArray(tempArray: heartData, dateArray:years))
        }
        isSelected = false
        heartData.sort(by:  { $0.heartDate < $1.heartDate })
        completion();
       
    }
    
    func getAvgHeartRate(predicate: NSPredicate?,interval : DateComponents? , completion:@escaping(HKStatisticsCollection?) -> Void) {
        let calendar = Calendar.current
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        
        guard let predicate = predicate else { return }
        guard let interval = interval else { return }
        
        
        let anchorDate = calendar.date(bySettingHour: 0, minute: 0, second: 0, of: Date())!
        
        
        let query = HKStatisticsCollectionQuery(quantityType: heartRateType,
                                                quantitySamplePredicate: predicate,
                                                options: .discreteAverage,
                                                anchorDate: anchorDate,
                                                intervalComponents: interval)
        
        // Set the results handler
        query.initialResultsHandler = { query, results, error in
            completion(results)
        }
        
        HKHealthStore().execute(query)
    }
    
    func getLatestheartRate()
    {
        
        let startDate = Date.distantPast
        let endDate = Date()
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
        
        let heartRateType = HKQuantityType.quantityType(forIdentifier: .heartRate)!
        let sortDescriptors = [NSSortDescriptor(key: HKSampleSortIdentifierEndDate, ascending: false)]
        
        let  heartRateQuery =  HKSampleQuery(sampleType: heartRateType, predicate: predicate, limit: 1, sortDescriptors: sortDescriptors, resultsHandler: { (query, results, error) in
            guard  let result = results else { return }
            if(results!.count > 0){
            guard let currData = result[0] as? HKQuantitySample else { return }
            let beatsPerMinuteUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            DispatchQueue.main.async {
                
                self.activeBPMLabel.text =   String(Int(currData.quantity.doubleValue(for: beatsPerMinuteUnit)));
                self.activeTimeLabel.text = self.dateDifference(from: currData.endDate, to: Date())
            }
            }
        })
        healthStore.execute(heartRateQuery)
        
    }
    
    func getAverageWalkingOrRestingHeartRate(isWalking:Bool,predicate : NSPredicate){
        var  quantityType : HKQuantityType!
        if(isWalking){
            quantityType = HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        }else{
            quantityType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        }
        
        let query =   HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .discreteAverage) { (query, result, error) in
            if((error) != nil){
                print("error ",error!);
            }
            else {
                let quantity  =  result!.averageQuantity()!
                let beats: Double? = quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                
                DispatchQueue.main.async {
                    if(isWalking){
                        self.averageWalkingBPMLabel.text = String(Int(beats!));
                    }else{
                        self.averageRestingBPMLabel.text = String(Int(beats!));
                    }
                }
                
                
            }
        }
        healthStore.execute(query);
    }
    
    func shadow(Vw : UIView)
    {
        Vw.layer.masksToBounds = false
        Vw.layer.shadowOffset = CGSize(width: 0, height: 0.6)
        Vw.layer.shadowRadius = 2.0
        Vw.layer.shadowOpacity = 10.0
        Vw.layer.cornerRadius = 10.0
    }
    func setSegmentText(){
        segmentControl.setTitle("Today", forSegmentAt: 0)
        segmentControl.setTitle("Week", forSegmentAt: 1)
        segmentControl.setTitle("Month", forSegmentAt: 2)
        segmentControl.setTitle("Year", forSegmentAt: 3)
    }
    
    func dateDifference (from fromDate: Date, to toDate: Date) -> String {
        let day = calender.dateComponents([.day], from: fromDate, to: toDate).day
        
        let month = calender.dateComponents([.month], from: fromDate, to: toDate).month
        let hour = calender.dateComponents([.hour], from: fromDate, to: toDate).hour
        let minute = calender.dateComponents([.minute], from: fromDate, to: toDate).minute
        
        if(month! > 0){
            return "\(month!) month ago"
        }else if(day! >  0){
            return "\(day!) days ago"
        }
        else if(hour! > 0){
            return "\(hour!) hours ago"
        }else {
            return "\(minute!) minutes ago"
        }
        
    }
    func settingAllDate(from :  Int , to : Int ,component : Calendar.Component ,date : Date) -> [Date]{
        var temp = [Date]()
        
        for i in stride(from: from, through: to, by: -1) {
            
            var tempDate = calender.date(byAdding: component , value: -i, to: date)!
        
            if(component == Calendar.Component.month){
             
                tempDate = calender.date(bySetting: .day, value: 1, of:tempDate)!
                
            }
             tempDate  = calender.date(bySettingHour: 0, minute: 0, second: 0, of: tempDate)!
            temp.append(tempDate)
        }
        return temp
    }
    //MARK: - Collection View Methods
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        heartData.count;
    }
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let dateFormate = DateFormatter();
        switch segmentControl.selectedSegmentIndex {
        case 0:
            dateFormate.dateFormat = "h:mm a";
        case 1:
            dateFormate.dateFormat = "E";
        case 2:
            dateFormate.dateFormat = "MMM d";
        case 3:
            dateFormate.dateFormat = "MMM yy";
        default:
            dateFormate.dateFormat = "h:mm a";
        }
        
        let date = dateFormate.string(from: heartData[indexPath.row].heartDate)
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CollectionViewCell", for: indexPath) as! CollectionViewCell
        cell.bmpLabel.text = String(Int(heartData[indexPath.row].heartRate))
        
        cell.dateLabel.text = "\(date)"
        if(heartData[indexPath.row].heartRate > 0){
            cell.viewHieght.constant = CGFloat((heartData[indexPath.row].heartRate - 50 ) * 2.4 + 8)
        }else{
            cell.viewHieght.constant = 0
        }
        self.view.layoutIfNeeded();
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        CGSize(width: 50,height: height * 0.5 - 56 );
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if(segmentControl.selectedSegmentIndex == 1 || segmentControl.selectedSegmentIndex == 2){
            isSelected=true
            segmentControl.selectedSegmentIndex = 0
            let dateformat = DateFormatter();
            dateformat.dateFormat = "dd/MM/yy"
            segmentControl.setTitle(dateformat.string(from: heartData[indexPath.row].heartDate), forSegmentAt: 0);
            dateformat.dateFormat = "EEEE, MMM d, yyyy"
            headingChart.text =  dateformat.string(from:  heartData[indexPath.row].heartDate)
            var startDate = heartData[indexPath.row].heartDate;
            startDate = calender.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!;
            var endDate = Date()
            if(heartData[indexPath.row].heartDate !=  Date() ) {
                endDate = calender.date(byAdding: .hour, value: 24, to: startDate)!
            }
            
            
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            getAverageWalkingOrRestingHeartRate(isWalking: true, predicate: predicate)
            getAverageWalkingOrRestingHeartRate(isWalking: false, predicate: predicate)
            var interval = DateComponents()
            interval.minute = 1
            prepareQuery(predicate: predicate, interval: interval)
        }
        else if(segmentControl.selectedSegmentIndex == 3){
            isSelected = true
            segmentControl.selectedSegmentIndex = 2
            let dateformat = DateFormatter();
            let curentDateformatter =  DateFormatter();
            curentDateformatter.dateFormat = "MM:yy"
            dateformat.dateFormat = "MMMM"
            headingChart.text="Average Heart Rate of \(dateformat.string(from:heartData[indexPath.row].heartDate))"
            dateformat.dateFormat = "yyyy:MM:dd"
            
            
            var startDate = heartData[indexPath.row].heartDate;
            
            
        
            startDate = calender.date(byAdding: .month, value: -1, to: startDate)!
            startDate = calender.date(bySetting: .day, value: 1, of: startDate)!
        
            
         //   startDate = calender.date(bySettingHour: 0, minute: 0, second: 0, of: startDate)!
            
            
            var endDate = Date()
            months.removeAll()
            if(dateformat.string(from:heartData[indexPath.row].heartDate) !=  dateformat.string(from: Date()) ) {
                
                endDate = calender.date(byAdding: .month, value: 1, to: startDate)!
                endDate =  calender.date(byAdding: .day, value: -1, to:endDate)!
                endDate =  calender.date(bySettingHour: 23, minute: 59, second: 59, of: endDate)!
                dateformat.dateFormat =  "dd"
            
                
            months = settingAllDate(from: Int(dateformat.string(from: endDate))! - 1, to: Int(dateformat.string(from: startDate))! - 1, component: .day, date: endDate)
                
               
                
                
            }else{
                dateformat.dateFormat =  "dd"
            months = settingAllDate(from: Int(dateformat.string(from: endDate))! - 1, to: Int(dateformat.string(from: startDate))! - 1, component: .day, date: endDate)
            }
            let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: [])
            getAverageWalkingOrRestingHeartRate(isWalking: true, predicate: predicate)
            getAverageWalkingOrRestingHeartRate(isWalking: false, predicate: predicate)
            
            var interval = DateComponents()
            interval.day = 1
            prepareQuery(predicate: predicate, interval: interval)
            
        }
    }
    
    
}

