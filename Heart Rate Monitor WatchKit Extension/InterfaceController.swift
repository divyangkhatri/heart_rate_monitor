//
//  InterfaceController.swift
//  Heart Rate Monitor WatchKit Extension
//
//  Created by Divyang Khatri on 14/03/20.
//  Copyright © 2020 LanetTeam. All rights reserved.
//

import WatchKit
import Foundation
import HealthKit

class InterfaceController: WKInterfaceController,  HKLiveWorkoutBuilderDelegate,HKWorkoutSessionDelegate {
    
    @IBOutlet weak var heartRateLabel: WKInterfaceLabel!
    var heartRateQuery : HKObserverQuery! = nil
    var healthStore : HKHealthStore!;
    var session: HKWorkoutSession!
    var builder: HKLiveWorkoutBuilder!
    @IBOutlet weak var imageView: WKInterfaceImage!
    
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
    }
    override func willActivate() {
        
        imageView.setImageNamed("AnimateHeart");
        imageView.startAnimatingWithImages(in:NSRange(location: 0, length: 38) , duration:3, repeatCount:0);
        
        super.willActivate()
        authorization { (success, healthkit) in
            
            self.healthStore =  healthkit;
            if(success){
                
                let configuration = HKWorkoutConfiguration()
                configuration.activityType = .running
                configuration.locationType = .outdoor
                
                do {
                    self.session = try HKWorkoutSession(healthStore: self.healthStore, configuration: configuration)
                    self.builder = self.session.associatedWorkoutBuilder()
                } catch {
                    self.dismiss()
                    return
                }
                self.session.delegate = self
                self.builder.delegate = self
                
                self.builder.dataSource = HKLiveWorkoutDataSource(healthStore: self.healthStore,
                                                                  workoutConfiguration: configuration)
                
                self.session.startActivity(with: Date())
                self.builder.beginCollection(withStart: Date()) { (success, error) in
                    
                }
            }
            
        }
        
    }
    
    override func didDeactivate() {
        
        if((session) != nil){
            session.end()
            
            builder.endCollection(withEnd: Date()) { (success, error) in
                self.builder.finishWorkout { (workout, error) in
                    
                    super.didDeactivate();
                }
            }
        }
        
    }
    
    
    
    
    func updateLabel(statistics: HKStatistics?) {
        guard  let statistics = statistics else {
            return
        }
        DispatchQueue.main.async {
            
            let heartRateUnit = HKUnit.count().unitDivided(by: HKUnit.minute())
            let value = statistics.mostRecentQuantity()?.doubleValue(for: heartRateUnit)
            
            self.heartRateLabel.setText("\(Int(value!)) BPM")
            
        }
    }
    
    
    var observeQuery: HKObserverQuery!
    
    
    
    
    
    
    // MARK: - Workout Session  Delegate
    func workoutSession(_ workoutSession: HKWorkoutSession, didChangeTo toState: HKWorkoutSessionState, from fromState: HKWorkoutSessionState, date: Date) {
        
        
    }
    
    func workoutSession(_ workoutSession: HKWorkoutSession, didFailWithError error: Error) {
        
    }
    func handle(_ workoutConfiguration: HKWorkoutConfiguration){
        print("start");
    }
    
    
    // MARK: - Workout Builder  Delegate
    
    func workoutBuilder(_ workoutBuilder: HKLiveWorkoutBuilder, didCollectDataOf collectedTypes: Set<HKSampleType>) {
        for type in collectedTypes {
            guard let quantityType = type as? HKQuantityType else {
                return
            }
            
            let statistics = workoutBuilder.statistics(for: quantityType)
            
            updateLabel(statistics: statistics)
        }
    }
    
    func workoutBuilderDidCollectEvent(_ workoutBuilder: HKLiveWorkoutBuilder) {
        
    }
    
}
