//
//  ViewController.swift
//  SmartTraining
//
//  Created by IPDEC on 02/10/19.
//  Copyright © 2019 IPDEC. All rights reserved.
//

import UIKit
import CoreBluetooth


let pulseirasCBUUID = CBUUID(string: "0xFEF5")
let pulseirasInfoCBUUID = CBUUID(string: "0x180A")
let pulseirasMac = CBUUID(string: "0x2A23")


class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, CBCentralManagerDelegate, CBPeripheralDelegate{
    
    @IBOutlet weak var startButton: UIButton!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var distance: UITextField!
    @IBOutlet weak var time: UITextField!
    @IBOutlet weak var elapsedTime: UILabel!
    var centralManager: CBCentralManager!
    var model: String = ""
//    var pulseiras = [CBPeripheral]()
    var timer:Timer?
    var timeLeft = 5
    var timerIsRunning = false;
    var numFile = 0;
//    var beacons = [String: [String]]()
    var beacons = [String]()
    var csvString = "\("DISTANCE"),\("BEACON_ALIAS"),\("RSSI"),\("TIMESTAMP"),\("PHONE_MODEL")\n"
//    private var data: [String] = []
    
    @IBAction func endEditingDistance(_ sender: Any) {
//        if !distance.text!.isEmpty && time.text!.isEmpty{
//            startButton.isEnabled = true
//        }else{
//            startButton.isEnabled = false
//        }
    }
    @IBAction func endEditingTime(_ sender: Any) {
//        if !distance.text!.isEmpty && time.text!.isEmpty{
//             startButton.isEnabled = true
//        }else{
//             startButton.isEnabled = false
//        }
    }
    
    @IBAction func inputDistance(_ sender: Any) {
        print(distance.text!)
        print(time.text!)
        
        timeLeft = Int(time.text!)!*60
        timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(onTimerFires), userInfo: nil, repeats: true)
        timerIsRunning = true;
        centralManager.scanForPeripherals(withServices: [pulseirasCBUUID])
        
        
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        print(UIDevice.current.modelName)
        model = UIDevice.current.modelName
        distance.keyboardType = .decimalPad
        time.keyboardType = .decimalPad

        self.hideKeyboardWhenTappedAround();
        
    }
    
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cellId")!
        if !beacons.isEmpty{
                let beacon = beacons[indexPath.row]
                cell = tableView.dequeueReusableCell(withIdentifier: "cellId")!
                cell.textLabel?.text = String(beacon)
                return cell
            
           
        }
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return beacons.count
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        
        switch central.state {
        case .unknown:
            print("central.state is .unknown")
        case .resetting:
            print("central.state is .resetting")
        case .unsupported:
            print("central.state is .unsupported")
        case .unauthorized:
            print("central.state is .unauthorized")
        case .poweredOff:
            print("central.state is .poweredOff")
        case .poweredOn:
            centralManager.scanForPeripherals(withServices: [pulseirasCBUUID])
            print("central.state is .poweredOn")
        }
        
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any], rssi RSSI: NSNumber) {

        var man: Data
        man = advertisementData["kCBAdvDataManufacturerData"] as! Data
        let alias = SchoodUtil.extractAlias(man);

        if timerIsRunning{
            let timestamp = NSDate().timeIntervalSince1970
            csvString = csvString.appending("\(String(describing: String(distance!.text!))), \(String(describing: String(alias!).uppercased())) ,\(String(describing: RSSI)),\(String(describing: timestamp)), \(String(describing: model))\n")
//            csvString = csvString.appending("\(String(describing: String(alias!).uppercased())) ,\(String(describing: RSSI)),\(String(describing: model)),\(String(describing: String(distance!.text!)))\n")
//            print(csvString)
        }
        
        
        if !beacons.isEmpty {
//            print("Added beacon")
            if !self.beacons.contains(String(alias!).uppercased()){
                beacons.append(String(alias!).uppercased())
                print(beacons)
            }
        }else{
            beacons.append(String(alias!).uppercased())
        }
        
       
        if(!timerIsRunning){
            self.tableView.reloadData()
        }
        if(timerIsRunning){
            centralManager.scanForPeripherals(withServices: [pulseirasCBUUID])
            
        }
        
    
    }
    
    @objc func writeToCsv(){
       
        do {
            let path =  NSURL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("CSVRec_" + distance.text! + ".csv")
            try csvString.write(to: path!, atomically: true, encoding: .utf8)
            let vc = UIActivityViewController(activityItems: [path!], applicationActivities: [])
            present(vc, animated: true, completion: nil)
        } catch {
            print("error creating file")
        }

        print("CSV DONE!!")
    }
    
    @objc func onTimerFires(){
        timeLeft -= 1
//        timeLabel.text = "\(timeLeft) seconds left"
        elapsedTime.text = String(timeLeft)
//        print("Timer is running!")
        if timeLeft <= 0 {
            timerIsRunning = false;
            print("Timer ended!");
            timer?.invalidate()
            timer = nil
            writeToCsv()
            
        }
    }
    




    
}

public extension UIDevice {
    
    var modelName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        
        switch identifier {
        case "iPod5,1":                                 return "iPod Touch 5"
        case "iPod7,1":                                 return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
        case "iPhone4,1":                               return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
        case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
        case "iPhone7,2":                               return "iPhone 6"
        case "iPhone7,1":                               return "iPhone 6 Plus"
        case "iPhone8,1":                               return "iPhone 6s"
        case "iPhone8,2":                               return "iPhone 6s Plus"
        case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
        case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
        case "iPhone8,4":                               return "iPhone SE"
        case "iPhone10,1", "iPhone10,4":                return "iPhone 8"
        case "iPhone10,2", "iPhone10,5":                return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6":                return "iPhone X"
        case "iPhone11,8":                              return "iPhone XR"
        case "iPhone11,2":                              return "iPhone XS"
        case "iPhone11,6":                              return "iPhone XS Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
        case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
        case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
        case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
        case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
        case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
        case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
        case "AppleTV5,3":                              return "Apple TV"
        case "i386", "x86_64":                          return "Simulator"
        default:                                        return identifier
        }
    }
    
}

extension UIViewController {
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}


extension Data{
    func hexEncodedString() -> String {
        let hexDigits = Array("0123456789abcdef".utf16)
        var hexChars = [UTF16.CodeUnit]()
        hexChars.reserveCapacity(count * 2)
        
        for byte in self {
            let (index1, index2) = Int(byte).quotientAndRemainder(dividingBy: 16)
            hexChars.insert(hexDigits[index2], at: 0)
            hexChars.insert(hexDigits[index1], at: 0)
        }
        return String(utf16CodeUnits: hexChars, count: hexChars.count)
    }
}

extension String {
    func separate(every stride: Int = 4, with separator: Character = " ") -> String {
        return String(enumerated().map { $0 > 0 && $0 % stride == 0 ? [separator, $1] : [$1]}.joined())
    }
}
