//
//  CommonFunction.swift
//  Heart Rate Monitor
//
//  Created by Catalina on 30/05/20.
//  Copyright © 2020 LanetTeam. All rights reserved.
//

import Foundation


func getTotalHeightofSafeArea() {
//    if #available(iOS 11.0, *) {
//        let window = UIApplication.shared.keyWindow
//        let topPadding = window?.safeAreaInsets.top
//        let bottomPadding = window?.safeAreaInsets.bottom
//        
//    }
}

func  getHeightInPercentage(){
    
}
func removeDuplicateElements(objects : [HeartData]) -> [HeartData] {
    let dateformatter  = DateFormatter();
     dateformatter.dateFormat = "h:mm a";
    var uniqueArr = [HeartData]();
    var counter = 0
    for (index,object) in objects.enumerated(){
        counter = 0
        if(index == 0){
            uniqueArr.append(object)
        }
        for anotherobject in  uniqueArr{
            let tempdate1 = dateformatter.string(from:object.heartDate);
            let tempdate2 = dateformatter.string(from:anotherobject.heartDate);
            
          
            if(tempdate1 != tempdate2){
                counter += 1;
            }
        }
        if(counter == uniqueArr.count){
            uniqueArr.append(object)
        }
    }
    
    return uniqueArr;
}
