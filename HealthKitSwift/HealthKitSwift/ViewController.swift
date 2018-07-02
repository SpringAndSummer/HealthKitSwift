//
//  ViewController.swift
//  HealthKitSwift
//
//  Created by Spring on 2018/4/24.
//  Copyright © 2018年 MOKO. All rights reserved.
//

import UIKit

class ViewController: UIViewController,UITableViewDelegate,UITableViewDataSource {
    
    let permission: [String] = ["请求权限"]
    let setpCount: [String] = ["读取当天总步数","读取一定时间段内的步数","写入当天总步数","写入一定时间段的步数"]
    let height: [String] = ["读取身高","写入身高"]
    let bodyMass: [String] = ["读取体重","写入体重"]
    let bodyMassIndex: [String] = ["读取身体质量指数","写入身体质量指数"]
    let distanceWalkingRunning: [String] = ["读取步行加跑步距离","写入步行加跑步距离"]
    let flightsClimbed: [String] = ["读取当天已爬楼层","写入当天已爬楼层"]
    let respiratoryRate: [String] = ["读取呼吸速率","写入呼吸速率"]
    let dietaryEnergyConsumed: [String] = ["读取膳食能量消耗","写入膳食能量消耗"]
    let oxygenSaturation: [String] = ["血氧饱和度"]
    let bodyTemperature: [String] = ["读取体温","写入体温"]
    let bloodGlucose: [String] = ["读取血糖","写入血糖"]
    let bloodPressure: [String] = ["读取血压收缩压","写入血压收缩压","读取血压舒张压","写入血压舒张压"]
    let standHour: [String] = ["读取当天站立小时"]
    let biologicalSex: [String] = ["读取性别"]
    let dateOfBirth: [String] = ["读取出生日期"]
    let bloodType: [String] = ["读取血型"]
    let fitzpatrickSkin: [String] = ["日光反应型皮肤类型"]
    let sleepAnalysis: [String] = ["读取睡眠分析"]
    let menstrualFlow: [String] = ["读取最近一次月经"]
    let intermenstrualBleeding: [String] = ["读取点滴出血"]
    let sexualActivity: [String] = ["读取最近一次性行为"]
    
    var alertText: String = String()
    
    var _tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        initUI()
    }
    
    //MARK:UI
    func initUI() {
        _tableView = UITableView.init(frame:CGRect.init(x:0,y:0,width:self.view.frame.size.width,height:self.view.frame.size.height),style:UITableViewStyle.plain)
        _tableView.delegate = self
        _tableView.dataSource = self
        _tableView.showsVerticalScrollIndicator = false
        _tableView.tableFooterView = UIView.init()
        self.view.addSubview(_tableView)
        _tableView.register(UITableViewCell().classForCoder, forCellReuseIdentifier: "cellId")
    }
    
    //MARK:UITbleviewDelegate,UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 22
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 1
        case 1:
            return 4
        case 2:
            return 2
        case 3:
            return 2
        case 4:
            return 2
        case 5:
            return 2
        case 6:
            return 2
        case 7:
            return 2
        case 8:
            return 2
        case 9:
            return 1
        case 10:
            return 2
        case 11:
            return 2
        case 12:
            return 4
        case 13:
            return 1
        case 14:
            return 1
        case 15:
            return 1
        case 16:
            return 1
        case 17:
            return 1
        case 18:
            return 1
        case 19:
            return 1
        case 20:
            return 1
        case 21:
            return 1
        default:
            return 0
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 40
    }
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "获取权限"
        case 1:
            return "步数"
        case 2:
            return "身高"
        case 3:
            return "体重"
        case 4:
            return "身体质量指数"
        case 5:
            return "步行+跑步距离"
        case 6:
            return "已爬楼层"
        case 7:
            return "呼吸速率"
        case 8:
            return "膳食能量消耗"
        case 9:
            return "血氧饱和度"
        case 10:
            return "体温"
        case 11:
            return "血糖"
        case 12:
            return "血压"
        case 13:
            return "站立小时"
        case 14:
            return "性别"
        case 15:
            return "出生日期"
        case 16:
            return "血型"
        case 17:
            return "日光反应型皮肤类型"
        case 18:
            return "睡眠分析"
        case 19:
            return "月经"
        case 20:
            return "点滴出血"
        case 21:
            return "性行为"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellId", for: indexPath)
        
        if indexPath.section == 0 {
            cell.textLabel!.text = permission[indexPath.row]
        } else if indexPath.section == 1 {
            cell.textLabel!.text = setpCount[indexPath.row]
        } else if indexPath.section == 2 {
            cell.textLabel!.text =  height[indexPath.row]
        } else if indexPath.section == 3 {
            cell.textLabel!.text = bodyMass[indexPath.row]
        } else if indexPath.section == 4 {
            cell.textLabel!.text = bodyMassIndex[indexPath.row]
        } else if indexPath.section == 5 {
            cell.textLabel!.text = distanceWalkingRunning[indexPath.row]
        } else if indexPath.section == 6 {
            cell.textLabel!.text = flightsClimbed[indexPath.row]
        } else if indexPath.section == 7 {
            cell.textLabel!.text = respiratoryRate[indexPath.row]
        } else if indexPath.section == 8 {
            cell.textLabel!.text = dietaryEnergyConsumed[indexPath.row]
        } else if indexPath.section == 9 {
            cell.textLabel!.text = oxygenSaturation[indexPath.row]
        } else if indexPath.section == 10 {
            cell.textLabel!.text = bodyTemperature[indexPath.row]
        } else if indexPath.section == 11 {
            cell.textLabel!.text = bloodGlucose[indexPath.row]
        } else if indexPath.section == 12 {
            cell.textLabel!.text = bloodPressure[indexPath.row]
        } else if indexPath.section == 13 {
            cell.textLabel!.text = standHour[indexPath.row]
        } else if indexPath.section == 14 {
            cell.textLabel!.text = biologicalSex[indexPath.row]
        } else if indexPath.section == 15 {
            cell.textLabel!.text = dateOfBirth[indexPath.row]
        } else if indexPath.section == 16 {
            cell.textLabel!.text = bloodType[indexPath.row]
        } else if indexPath.section == 17 {
            cell.textLabel!.text = fitzpatrickSkin[indexPath.row]
        } else if indexPath.section == 18 {
            cell.textLabel!.text = sleepAnalysis[indexPath.row]
        } else if indexPath.section == 19 {
            cell.textLabel!.text = menstrualFlow[indexPath.row]
        } else if indexPath.section == 20 {
            cell.textLabel!.text = intermenstrualBleeding[indexPath.row]
        } else if indexPath.section == 21 {
            cell.textLabel!.text = sexualActivity[indexPath.row]
        }
        
        cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 12)
        cell.textLabel?.textColor = UIColor.lightGray
        cell.selectionStyle = UITableViewCellSelectionStyle.default
        cell.accessoryType = UITableViewCellAccessoryType.disclosureIndicator
        
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:     // AccessPermission(获取权限)
            if indexPath.row == 0 {
                Skoal.shared.requestHealthPermission { (response) in
                    if response == HealthStorePermissionResponse.HealthStorePermissionResponseError {
                        print("请求失败")
                    } else {
                        print("请求成功")
                    }
                }
            }
        case 1:     // StepCount(步数)
            if indexPath.row == 0 {
                Skoal.shared.readStepCountFromHealthStore { (value, error) in
                    if((error) != nil){
                         print(error!)
                    }else{
                        print("你今天走的步数为\(value)")
                    }
                }
            } else if indexPath.row == 1 {
                Skoal.shared.readStepCountFromHealthStoreWithStartTime(startTime: "2018-05-17 08:00", endTime: "2018-05-17 22:00") { (value, error) in
                    print("\(value) \(String(describing: error))")
                }
        } else if indexPath.row == 2 {
                Skoal.shared.writeStepCountToHealthStoreWithUnit(setpCount: 888) { (response, error) in
                    print(response)
                }
            } else if indexPath.row == 3 {
                Skoal.shared.writeStepCountToHealthStoreWithUnit(setpCount: 888, startTime: "2018-05-17 08:00", endTime: "2018-05-17 22:00") { (response, error) in
                    print(response)
                }
            }
        case 2:     // Height(身高)
            if indexPath.row == 0 {
                Skoal.shared.readHeightFromHealthStoreWithCompletion { (value, error) in
                    print("height = \(value)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeHeightToHealthStoreWithUnit(height: 1.80) { (response, error) in
                    print(response)
                }
            }
        case 3:     // BodyMass(体重)
            if indexPath.row == 0 {
                Skoal.shared.readBodyMassFromHealthStore{ (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeBodyMassToHealthStore(bodyMass: 70) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 4:     // BodyMassIndex(身体质量指数)
            if indexPath.row == 0 {
                Skoal.shared.readBodyMassIndexFromHealthStore { (value, error) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeBodyMassIndexToHealthStore(bodyMassIndex: 22) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 5:     // DistanceWalkingRunning(步行+跑步距离)
            if indexPath.row == 0 {
                Skoal.shared.readDistanceWalkingRunningFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeDistanceWalkingRunningToHealthStore(distanceWalkingRunning: 2000) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 6:     //FlightsClimbed(已爬楼层)
            if indexPath.row == 0 {
                Skoal.shared.readFlightsClimbedFromHealthStore { (flightsClimbed, error) in
                    print("\(flightsClimbed)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeFlightsClimbedToHealthStore(flightsClimbed: 23) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 7:     // RespiratoryRate(呼吸速率)
            if indexPath.row == 0 {
                Skoal.shared.readRespiratoryRateFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeRespiratoryRateToHealthStore(respiratoryRate: 88.8) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 8:     // DietaryEnergyConsumed(膳食能量消耗)
            if indexPath.row == 0 {
                Skoal.shared.readDietaryEnergyConsumedFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeDietaryEnergyConsumedToHealthStore(dietaryEnergyConsumed: 22.2) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 9:     // OxygenSaturation(血氧饱和度)
            if indexPath.row == 0 {
                Skoal.shared.readOxygenSaturationFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            }
        case 10:    // BodyTemperature(体温)
            if indexPath.row == 0 {
                Skoal.shared.readBodyTemperatureFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeBodyTemperatureToHealthStore(bodyTemperature: 36.5) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 11:    // BloodGlucose(血糖)
            if indexPath.row == 0 {
                Skoal.shared.readBloodGlucoseFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeBloodGlucoseToHealthStore(bloodGlucose: 16.0) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 12:    // BloodPressure(血压)
            if indexPath.row == 0 {
                Skoal.shared.readBloodPressureSystolicFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 1 {
                Skoal.shared.writeBloodPressureSystolicToHealthStore(bloodPressureSystolic: 65.0) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 2 {
                Skoal.shared.readBloodPressureDiastolicFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            } else if indexPath.row == 3 {
                Skoal.shared.writeBloodPressureDiastolicToHealthStore(bloodPressureDiastolic: 77.0) { (success, error) in
                    print("\(success)\n\(error.debugDescription)")
                }
            }
        case 13:    // StandHour(站立小时)
            if indexPath.row == 0 {
                Skoal.shared.readStandHourFromHealthStore { (value: Double, error: Error?) in
                    print("\(value)\n\(error.debugDescription)")
                }
            }
        case 14:    // BiologicalSex(性别)
            if indexPath.row == 0 {
                Skoal.shared.readBiologicalSexFromHealthStore { (sex, success) in
                    print("\(sex)\n\(String(describing: success))")
                }
            }
        case 15:    // DateOfBirth(出生日期)
            if indexPath.row == 0 {
                Skoal.shared.readDateOfBirthFromHealthStore { (date, success) in
                    print("出生日期:\(String(describing: date)) \(success)")
                }
            }
        case 16:    // BloodType(血型)
            if indexPath.row == 0 {
                Skoal.shared.readBloodTypeFromHealthStore { (bloodType:String?, success) in
                    print("血型:\(String(describing: bloodType)) \(success)")
                }
            }
        case 17:    // FitzpatrickSkin(日光反应型皮肤类型)
            if indexPath.row == 0 {
                Skoal.shared.readFitzpatrickSkinFromHealthStore { (skinType, success) in
                    print("日光反应型皮肤类型:\(String(describing: skinType)) \(success)")
                }
            }
        case 18:    // SleepAnalysis(睡眠分析)
            if indexPath.row == 0 {
                Skoal.shared.readSleepAnalysisFromHealthStore { (value, error) in
                    print("睡眠分析:\(String(describing: value)) \(String(describing: error))")
                }
            }
        case 19:    // MenstrualFlow(月经)
            if indexPath.row == 0 {
                Skoal.shared.readMenstrualFlowFromHealthStore { (value, error) in
                    print("月经:\(String(describing: value)) \(String(describing: error))")
                }
            }
        case 20:    // IntermenstrualBleeding(点滴出血)
            if indexPath.row == 0 {
                Skoal.shared.readIntermenstrualBleedingFromHealthStore { (value, error) in
                    print("点滴出血:\(String(describing: value)) \(String(describing: error))")
                }
            }
        case 21:    // SexualActivity(性行为)
            if indexPath.row == 0 {
                Skoal.shared.readSexualActivityFromHealthStore { (value, error) in
                    print("性行为:\(String(describing: value)) \(String(describing: error))")
                }
            }
        default:
            print("")
        }
        _tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}


