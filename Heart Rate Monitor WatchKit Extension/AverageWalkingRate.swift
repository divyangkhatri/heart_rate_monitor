//
//  AverageWalkingRate.swift
//  Heart Rate Monitor WatchKit Extension
//
//  Created by Catalina on 25/05/20.
//  Copyright © 2020 LanetTeam. All rights reserved.
//


import WatchKit
import HealthKit


class AverageWalkingRate: WKInterfaceController {
    
    @IBOutlet weak var restinglabel: WKInterfaceLabel!
    @IBOutlet weak var walkinglabel: WKInterfaceLabel!
    var calender : Calendar!
    
    var healthStore : HKHealthStore!;
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        calender = Calendar.current
        
    }
    override func didAppear() {
        super.didAppear();
    }
    override func willActivate() {
        super.willActivate();
        authorization { (success, healthStore) in
            
            self.healthStore = healthStore;
            if(success){
                
                self.getAverageWalkingOrRestingHeartRate(isWalking: true)
                self.getAverageWalkingOrRestingHeartRate(isWalking: false)
              
            }
        }
    }
   func getAverageWalkingOrRestingHeartRate(isWalking:Bool){
        var  quantityType : HKQuantityType!
        if(isWalking){
            quantityType = HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!
        }else{
            quantityType = HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
        }
        let startDate = calender.date(bySettingHour: 0, minute: 0, second: 0, of: Date())
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: Date(), options: [])
        let query =   HKStatisticsQuery(quantityType: quantityType, quantitySamplePredicate: predicate, options: .discreteAverage) { (query, result, error) in
            if((error) != nil){
                print("error ",error!);
            }
            else {
                let quantity  =  result!.averageQuantity()!
                let beats: Double? = quantity.doubleValue(for: HKUnit.count().unitDivided(by: HKUnit.minute()))
                if(beats != 0){
                DispatchQueue.main.async {
                    if(isWalking){
                        self.walkinglabel.setText(String(Int(beats!)));
                    }else{
                        self.restinglabel.setText(String(Int(beats!)));
                    }
                }
                }
                
            }
        }
        healthStore.execute(query);
    }
}
