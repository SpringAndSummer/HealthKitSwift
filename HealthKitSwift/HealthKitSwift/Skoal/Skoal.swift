//
//  Skoal.swift
//  HealthKitSwift
//
//  Created by Spring on 2018/4/24.
//  Copyright © 2018年 MOKO. All rights reserved.
//

import UIKit
import HealthKit
enum HealthStorePermissionResponse:UInt {
    case HealthStorePermissionResponseError = 0
    case HealthStorePermissionResponseSuccess
}
typealias HealthStorePermissionResponseBlock = (_ permissionResponse:HealthStorePermissionResponse) -> ()
class Skoal: NSObject {
    var permissionResponseBlock:HealthStorePermissionResponseBlock?
    static let shared = Skoal.init()
    var store:HKHealthStore = HKHealthStore()
    
    // MARK:获取权限
    func requestHealthPermission(block:@escaping HealthStorePermissionResponseBlock) -> Void {
        if #available(iOS 8.0, *){
            if(!HKHealthStore.isHealthDataAvailable()){
                print("Skoal:该设备不支持HealthKit")
            }else{
            let store = HKHealthStore()
            let readObjectTypes:Set = self.readObjectTypes()
            let writeObjectTypes:Set = self.writeObjectTypes()
            store.requestAuthorization(toShare: (writeObjectTypes as! Set<HKSampleType>), read: readObjectTypes) { (success, error) in
                if(success){
                    block(.HealthStorePermissionResponseSuccess)
                }else{
                    block(.HealthStorePermissionResponseError)
                }
            }
        }
        }else{
            print("Skoal:HealthKit暂不支持iOS8以下系统,请更新你的系统。")
        }
    }
    
    // MARK:获取步数
    func readStepCountFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void{
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByToday()
        let query = HKSampleQuery.init(sampleType: stepCountType, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            var sum:Double = 0
            for sample in results!{
                let tmpSample:HKQuantitySample = sample as! HKQuantitySample
                print(sample)
                print(sample.classForCoder)
                sum = sum + Double((String.init(format: "%@", tmpSample.quantity)).components(separatedBy: " ")[0])!
            }
            completion(sum, error)
        }
        self.store.execute(query)
    }
    
    func readStepCountFromHealthStoreWithStartTime(startTime:String, endTime:String,completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByPeriodOfTimeWithStartTime(startTime: startTime, endTime: endTime)
        let query = HKSampleQuery.init(sampleType: stepCountType, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            var sum:Double = 0
            for sample in results!{
                let tmpSample:HKQuantitySample = sample as! HKQuantitySample
                sum = sum + Double((String.init(format: "%@", tmpSample.quantity)).components(separatedBy: " ")[0])!
            }
            completion(sum, error)
        }
        self.store.execute(query)
    }
    
    func writeStepCountToHealthStoreWithUnit(setpCount:Double, completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let quantity = HKQuantity.init(unit: HKUnit.count(), doubleValue: setpCount)
        let sample = HKQuantitySample.init(type: stepCountType, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            completion(success, error)
        }
    }
    
    func writeStepCountToHealthStoreWithUnit(setpCount:Double, startTime:String, endTime:String, completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let stepCountType = HKObjectType.quantityType(forIdentifier: .stepCount)!
        let quantity = HKQuantity.init(unit: HKUnit.count(), doubleValue: setpCount)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale.init(identifier: "zh_CN")
        let tmpStartDate = formatter.date(from: startTime)
        let tmpEndDate = formatter.date(from: endTime)
        let sample = HKQuantitySample.init(type: stepCountType, quantity: quantity, start: tmpStartDate!, end: tmpEndDate!, metadata: nil)
        self.store.save(sample) { (success, error) in
            completion(success, error)
        }
    }
    
    //---------------------------------------
    // MARK:身高
    //---------------------------------------
    func readHeightFromHealthStoreWithCompletion(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let heightType = HKObjectType.quantityType(forIdentifier: .height)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: heightType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let height = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(height, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    func writeHeightToHealthStoreWithUnit(height:Double, completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let heightType = HKObjectType.quantityType(forIdentifier: .height)
        let quantity = HKQuantity.init(unit: HKUnit.meter(), doubleValue: height)
        let sample = HKQuantitySample.init(type: heightType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            completion(success, error)
        }
    }
    
    // MARK: 获取体重
    func readBodyMassFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void{
        let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: bodyMassType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
            let bodyMass = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(bodyMass, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    // MARK: 写入体重
    func writeBodyMassToHealthStore(bodyMass:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void{
        let bodyMassType = HKObjectType.quantityType(forIdentifier: .bodyMass)
        let quantity = HKQuantity.init(unit: HKUnit.gram(), doubleValue: bodyMass)
        let sample = HKQuantitySample.init(type: bodyMassType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    // MARK: 获取身体质量指数
    func readBodyMassIndexFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void{
        let bodyMassIndexType = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: bodyMassIndexType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let bodyMassIndex = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(bodyMassIndex, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    func writeBodyMassIndexToHealthStore(bodyMassIndex:Double, completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let bodyMassIndexType = HKSampleType.quantityType(forIdentifier: .bodyMassIndex)
        let quantity = HKQuantity.init(unit: HKUnit.count(), doubleValue: bodyMassIndex)
        let sample = HKQuantitySample.init(type: bodyMassIndexType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
        
    }
    
    // MARK: 步行&跑步距离
    func readDistanceWalkingRunningFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let distanceWalkingRunningType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: distanceWalkingRunningType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            var distanceWalkingRunning:Double = 0.0
            if (results?.count)! > 0{
                distanceWalkingRunning = distanceWalkingRunning + Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
            }
            completion(distanceWalkingRunning, error)
        }
        self.store.execute(query)
    }
    
    func writeDistanceWalkingRunningToHealthStore(distanceWalkingRunning:Double, completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let distanceWalkingRunningType = HKSampleType.quantityType(forIdentifier: .distanceWalkingRunning)
        let quantity = HKQuantity.init(unit: HKUnit.meter(), doubleValue: distanceWalkingRunning)
        let sample = HKQuantitySample.init(type: distanceWalkingRunningType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    // MARK: 已爬楼层
    func readFlightsClimbedFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let flightsClimbedType = HKSampleType.quantityType(forIdentifier: .flightsClimbed)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: flightsClimbedType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            var flightsClimbed:Double = 0.0
            if (results?.count)! > 0{
                flightsClimbed = flightsClimbed + Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
            }
            completion(flightsClimbed, error)
        }
        self.store.execute(query)
    }
    
    
    func writeFlightsClimbedToHealthStore(flightsClimbed:Double, completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let flightsClimbedType = HKSampleType.quantityType(forIdentifier: .flightsClimbed)
        let quantity = HKQuantity.init(unit: HKUnit.count(), doubleValue: flightsClimbed)
        let sample = HKQuantitySample.init(type: flightsClimbedType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    //MARK: 呼吸速率
    func readRespiratoryRateFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let respiratoryRateType = HKSampleType.quantityType(forIdentifier: .respiratoryRate)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: respiratoryRateType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            var respiratoryRate:Double = 0.0
            if (results?.count)! > 0{
                respiratoryRate = respiratoryRate + Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
            }
            completion(respiratoryRate, error)
        }
        self.store.execute(query)
    }
    
    func writeRespiratoryRateToHealthStore(respiratoryRate:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let respiratoryRateType = HKSampleType.quantityType(forIdentifier: .respiratoryRate)
        let quantity = HKQuantity.init(unit: HKUnit.init(from: "count/min"), doubleValue: respiratoryRate)
        let sample = HKQuantitySample.init(type: respiratoryRateType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
        
    }
    
    // MARK: 膳食能量消耗
    func readDietaryEnergyConsumedFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let dietaryEnergyConsumedType = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: dietaryEnergyConsumedType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let respiratoryRate = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(respiratoryRate, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    func writeDietaryEnergyConsumedToHealthStore(dietaryEnergyConsumed:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let dietaryEnergyConsumedType = HKSampleType.quantityType(forIdentifier: .dietaryEnergyConsumed)
        let quantity = HKQuantity.init(unit: HKUnit.kilocalorie(), doubleValue: dietaryEnergyConsumed)
        let sample = HKQuantitySample.init(type: dietaryEnergyConsumedType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    // MARK: OxygenSaturation(血氧饱和度)
    func readOxygenSaturationFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let oxygenSaturationType = HKSampleType.quantityType(forIdentifier: .oxygenSaturation)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: oxygenSaturationType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let oxygenSaturation = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(oxygenSaturation, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    //MARK: BodyTemperature(体温)
    func readBodyTemperatureFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let bodyTemperatureType = HKSampleType.quantityType(forIdentifier: .bodyTemperature)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: bodyTemperatureType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let bodyTemperature = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(bodyTemperature, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    func writeBodyTemperatureToHealthStore(bodyTemperature:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let bodyTemperatureType = HKSampleType.quantityType(forIdentifier: .bodyTemperature)
        let quantity = HKQuantity.init(unit: HKUnit.degreeCelsius(), doubleValue: bodyTemperature)
        let sample = HKQuantitySample.init(type: bodyTemperatureType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    //MARK: BloodGlucose(血糖)
    func readBloodGlucoseFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let bloodGlucoseType = HKSampleType.quantityType(forIdentifier: .bloodGlucose)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: bloodGlucoseType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let bloodGlucose = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(bloodGlucose, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    func writeBloodGlucoseToHealthStore(bloodGlucose:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let bloodGlucoseType = HKSampleType.quantityType(forIdentifier: .bloodGlucose)
        let quantity = HKQuantity.init(unit: HKUnit.init(from: "mg/dl"), doubleValue: bloodGlucose)
        let sample = HKQuantitySample.init(type: bloodGlucoseType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    //MARK: BloodPressure(血压)
    func readBloodPressureSystolicFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let bloodPressureSystolicType = HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: bloodPressureSystolicType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let bloodPressureSystolic = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(bloodPressureSystolic, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    func writeBloodPressureSystolicToHealthStore(bloodPressureSystolic:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let bloodPressureSystolicType = HKSampleType.quantityType(forIdentifier: .bloodPressureSystolic)
        let quantity = HKQuantity.init(unit: HKUnit.millimeterOfMercury(), doubleValue: bloodPressureSystolic)
        let sample = HKQuantitySample.init(type: bloodPressureSystolicType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    func readBloodPressureDiastolicFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let bloodPressureDiastolicType = HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: bloodPressureDiastolicType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if (results?.count)! > 0{
                let bloodPressureDiastolic = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                completion(bloodPressureDiastolic, error)
            }else{
                completion(0, error)
            }
        }
        self.store.execute(query)
    }
    
    func writeBloodPressureDiastolicToHealthStore(bloodPressureDiastolic:Double,completion:@escaping (_ response:Bool,_ error:Error?) -> Void) -> Void {
        let bloodPressureDiastolicType = HKSampleType.quantityType(forIdentifier: .bloodPressureDiastolic)
        let quantity = HKQuantity.init(unit: HKUnit.millimeterOfMercury(), doubleValue: bloodPressureDiastolic)
        let sample = HKQuantitySample.init(type: bloodPressureDiastolicType!, quantity: quantity, start: Date(), end: Date(), metadata: nil)
        self.store.save(sample) { (success, error) in
            if(success){
                completion(true, error)
            }else{
                completion(false, error)
            }
        }
    }
    
    //MARK: StandHour(站立小时)
    func readStandHourFromHealthStore(completion:@escaping (_ value:Double,_ error:Error?) -> Void) -> Void {
        let appleStandHourType = HKCategoryType.categoryType(forIdentifier: .appleStandHour)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: appleStandHourType!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            var appleStandHour:Double = 0.0
            if (results?.count)! > 0{
                appleStandHour = appleStandHour + Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
            }
            completion(appleStandHour, error)
        }
        self.store.execute(query)
    }
    
    //MARK: BiologicalSex(性别)
    func readBiologicalSexFromHealthStore(completion:@escaping (_ value:String,_ success:Bool?) -> Void) -> Void{
        var sex = ""
        do{
            let sexObject = try self.store.biologicalSex()
                switch sexObject.biologicalSex {
                case .notSet:
                    sex = "未设置"
                case .male:
                    sex = "女性"
                case .female:
                    sex = "男性"
                case .other:
                    sex = "其他"
                }
                completion(sex, true)
        }catch{
             completion(sex, true)
        }
    }
    
    //MARK: 出生日期
    func readDateOfBirthFromHealthStore(completion:@escaping (_ value:Date?,_ sussess:Bool) -> Void) -> Void {
        do{
            let components = try self.store.dateOfBirthComponents()
            let calendar = Calendar.current
            let date = calendar.date(from: components)
            let zone = NSTimeZone.system
            let interval = zone.secondsFromGMT(for: date!)
            let dateOfBrith = date?.addingTimeInterval(TimeInterval(interval))
            completion(dateOfBrith!, true)
        }catch{
            completion(nil, false)
        }
    }
    
    //MARK: 血型
    func readBloodTypeFromHealthStore(completion:@escaping (_ value:String?,_ sussess:Bool) -> Void) -> Void {
        do{
            let bloodTypeObject:HKBloodTypeObject = try self.store.bloodType()
            var type = ""
            switch bloodTypeObject.bloodType {
            case .notSet:
                type = "未设置"
                break
            case .aPositive:
                type = "A型血阳性"
                break
            case .aNegative:
                type = "A型血阴性";
                break
            case .bPositive:
                type = "B型血阳性";
                break
            case .bNegative:
                type = "B型血阴性";
                break
            case .abPositive:
                type = "AB型血阳性";
                break
            case .abNegative:
                type = "AB型血阴性";
                break
            case .oPositive:
                type = "O型血阳性";
                break
            case .oNegative:
                type = "O型血阴性";
                break
            }
            completion(type, true)
        }catch{
            completion(nil, false)
        }
    }
    
    //MARK 日光反应型皮肤类型
    func readFitzpatrickSkinFromHealthStore(completion:@escaping (_ skinType:String?,_ sussess:Bool) -> Void) -> Void {
        do{
            let skinTypeObject:HKFitzpatrickSkinTypeObject = try self.store.fitzpatrickSkinType()
            var type = ""
            switch skinTypeObject.skinType {
            case .notSet:
                type = "未设置"
                break
            case .I:
                type = "I型"
                break
            case .II:
                type = "II型";
                break
            case .III:
                type = "III型";
                break
            case .IV:
                type = "IV型";
                break
            case .V:
                type = "V型";
                break
            case .VI:
                type = "VI型";
                break
            }
            completion(type, true)
        }catch{
            completion(nil, false)
        }
    }
    
    //MARK 睡眠分析
    func readSleepAnalysisFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .sleepAnalysis)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    let sleepAnalysis = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(sleepAnalysis, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    //MARK MenstrualFlow(月经)
    func readMenstrualFlowFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .menstrualFlow)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    let menstrualFlow = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(menstrualFlow, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    //MARK IntermenstrualBleeding(点滴出血)
    func readIntermenstrualBleedingFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    let menstrualFlow = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(menstrualFlow, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    //MARK SexualActivity(性行为)
    func readSexualActivityFromHealthStore(completion:@escaping (_ value:Double?,_ error:Error?) -> Void) -> Void {
        let type = HKObjectType.categoryType(forIdentifier: .sexualActivity)
        let startSort = NSSortDescriptor.init(key: HKSampleSortIdentifierStartDate, ascending: false)
        let endSort = NSSortDescriptor.init(key: HKSampleSortIdentifierEndDate, ascending: false)
        let predicate = self.predicateSampleByLatestData()
        let query = HKSampleQuery.init(sampleType: type!, predicate: predicate, limit: 0, sortDescriptors: [startSort,endSort]) { (query, results, error) in
            if(error != nil){
                completion(nil, error!)
            }else{
                if (results?.count)! > 0{
                    let sexualActivity = Double((String.init(format: "%@", (results?.first)!)).components(separatedBy: " ")[0])!
                    completion(sexualActivity, error)
                }else{
                    completion(0, error)
                }
            }
        }
        self.store.execute(query)
    }
    
    
    //---------------------------------------
    // MARK:谓词样本
    //---------------------------------------
    func predicateSampleByToday() -> NSPredicate {
        let calendar = NSCalendar.current
        let dateNow = Date.init()
        let set:Set<Calendar.Component> = [Calendar.Component.year,Calendar.Component.month,Calendar.Component.day]
        var components = calendar.dateComponents(set, from: dateNow)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startDate = calendar.date(from: components)
        let endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate!)
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate, options: HKQueryOptions.init(rawValue: 0))
        return predicate
    }
    
    //predicate sample is the latest data(谓词样本为最新数据)
    func predicateSampleByLatestData() -> NSPredicate {
        let calendar = NSCalendar.current
        let dateNow = Date()
        let set:Set<Calendar.Component> = [Calendar.Component.year,Calendar.Component.month,Calendar.Component.day]
        var components = calendar.dateComponents(set, from: dateNow)
        components.hour = 0
        components.minute = 0
        components.second = 0
        let startDate = calendar.date(from: components)
        let endDate = calendar.date(byAdding: Calendar.Component.day, value: 1, to: startDate!)
        let predicate = HKQuery.predicateForSamples(withStart: nil, end: endDate, options: HKQueryOptions.init(rawValue: 0))
        return predicate
    }

    //predicate sample is time period data(谓词样本为时间段数据)
    func predicateSampleByPeriodOfTimeWithStartTime(startTime:String, endTime:String) -> NSPredicate {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        formatter.locale = Locale.init(identifier: "zh_CN")
        let tmpStartTime = formatter.date(from: startTime)
        let tmpEndTime = formatter.date(from: endTime)
        let predicate = HKQuery.predicateForSamples(withStart: tmpStartTime, end: tmpEndTime, options: HKQueryOptions.init(rawValue: 0))
        return predicate
    }
    
    //---------------------------------------
    // MARK:权限集合
    //---------------------------------------
    //读权限集合
    func readObjectTypes() -> Set<HKObjectType> {
        let height = HKObjectType.quantityType(forIdentifier: .height)                     //身高
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)                 //体重
        let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)       //身体质量指数
        let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)               //步数
        let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) //步行+跑步
        let flightsClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed)                 //已爬楼层
        let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate) //呼吸速率
        let dietaryEnergyConsumed = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) //膳食能量消耗
        
        let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)//血氧饱和度
        let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature)//体温
        let bloodGlucose = HKObjectType.quantityType(forIdentifier: .bloodGlucose)//血糖
        let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)//血压收缩压
        let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)//血压舒张压
        let standHour = HKCategoryType.categoryType(forIdentifier: .appleStandHour) //站立小时
        let activitySummary = HKObjectType.activitySummaryType()//健身记录
        let biologicalSex = HKObjectType.characteristicType(forIdentifier: .biologicalSex) //性别
        
        let dateOfBirth = HKObjectType.characteristicType(forIdentifier: .dateOfBirth)//出生日期
        let bloodType = HKObjectType.characteristicType(forIdentifier: .bloodType)//血型
        let fitzpatrickSkinType = HKCategoryType.characteristicType(forIdentifier: .fitzpatrickSkinType)//日光反应型皮肤类型
        let sleepAnalysis = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)//睡眠分析
        let menstrualFlow = HKObjectType.categoryType(forIdentifier: .menstrualFlow)//月经
        let intermenstrualBleeding = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)//点滴出血
        let sexualActivity = HKObjectType.categoryType(forIdentifier: .sexualActivity)//性行为
        
        let set:Set<HKObjectType> = [
            height!,
            bodyMass!,
            bodyMassIndex!,
            stepCount!,
            distanceWalkingRunning!,
            flightsClimbed!,
            respiratoryRate!,
            dietaryEnergyConsumed!,
            
            oxygenSaturation!,
            bodyTemperature!,
            bloodGlucose!,
            bloodPressureSystolic!,
            bloodPressureDiastolic!,
            standHour!,
            activitySummary,
            biologicalSex!,
            
            dateOfBirth!,
            bloodType!,
            fitzpatrickSkinType!,
            sleepAnalysis!,
            menstrualFlow!,
            intermenstrualBleeding!,
            sexualActivity!
        ]
        return set
    }
    //写权限集合
    func writeObjectTypes() -> Set<HKObjectType> {
        let height = HKObjectType.quantityType(forIdentifier: .height)                     //身高
        let bodyMass = HKObjectType.quantityType(forIdentifier: .bodyMass)                 //体重
        let bodyMassIndex = HKObjectType.quantityType(forIdentifier: .bodyMassIndex)       //身体质量指数
        let stepCount = HKObjectType.quantityType(forIdentifier: .stepCount)               //步数
        let distanceWalkingRunning = HKObjectType.quantityType(forIdentifier: .distanceWalkingRunning) //步行+跑步
        let flightsClimbed = HKObjectType.quantityType(forIdentifier: .flightsClimbed)                 //已爬楼层
        let respiratoryRate = HKObjectType.quantityType(forIdentifier: .respiratoryRate) //呼吸速率
        let dietaryEnergyConsumed = HKObjectType.quantityType(forIdentifier: .dietaryEnergyConsumed) //膳食能量消耗
        
        let oxygenSaturation = HKObjectType.quantityType(forIdentifier: .oxygenSaturation)//血氧饱和度
        let bodyTemperature = HKObjectType.quantityType(forIdentifier: .bodyTemperature)//体温
        let bloodGlucose = HKObjectType.quantityType(forIdentifier: .bloodGlucose)//血糖
        let bloodPressureSystolic = HKObjectType.quantityType(forIdentifier: .bloodPressureSystolic)//血压收缩压
        let bloodPressureDiastolic = HKObjectType.quantityType(forIdentifier: .bloodPressureDiastolic)//血压舒张压
        let sleepAnalysis = HKCategoryType.categoryType(forIdentifier: .sleepAnalysis)//睡眠分析
        let menstrualFlow = HKObjectType.categoryType(forIdentifier: .menstrualFlow)//月经
        let intermenstrualBleeding = HKObjectType.categoryType(forIdentifier: .intermenstrualBleeding)//点滴出血
        let sexualActivity = HKObjectType.categoryType(forIdentifier: .sexualActivity)//性行为
        
        let set:Set<HKObjectType> = [
            height!,
            bodyMass!,
            bodyMassIndex!,
            stepCount!,
            distanceWalkingRunning!,
            flightsClimbed!,
            respiratoryRate!,
            dietaryEnergyConsumed!,
            
            oxygenSaturation!,
            bodyTemperature!,
            bloodGlucose!,
            bloodPressureSystolic!,
            bloodPressureDiastolic!,
            
            sleepAnalysis!,
            menstrualFlow!,
            intermenstrualBleeding!,
            sexualActivity!
        ]
        return set
    }

}
