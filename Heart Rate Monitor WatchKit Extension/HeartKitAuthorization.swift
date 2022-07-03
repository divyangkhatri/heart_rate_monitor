//
//  HeartKitAuthorization.swift
//  Heart Rate Monitor
//
//  Created by Catalina on 27/05/20.
//  Copyright © 2020 LanetTeam. All rights reserved.
//

import Foundation
import HealthKit
func authorization(completion:@escaping (Bool ,HKHealthStore) -> Void ){
    let healthStore = HKHealthStore();
    let typesToShare: Set = [
        HKQuantityType.workoutType()
    ]
    
    let typesToRead: Set = [
        HKQuantityType.quantityType(forIdentifier: .heartRate)!,
        HKQuantityType.quantityType(forIdentifier: .walkingHeartRateAverage)!,
        HKQuantityType.quantityType(forIdentifier: .restingHeartRate)!
    ]
    healthStore.requestAuthorization(toShare: typesToShare, read: typesToRead) { (sucess, error) in
        if((error) != nil){
            print("authorization error: \(error!)");
            return;
        }
        completion(sucess,healthStore);
        
    }
    
}
