//
//  DeviceDetailViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 11/3/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import UIKit
import StaticDataTableViewController
import MetaWear
import MessageUI
import Bolts
import MBProgressHUD
import iOSDFULibrary

extension String {
    var drop0xPrefix: String {
        return hasPrefix("0x") ? String(dropFirst(2)) : self
    }
}

class DeviceDetailViewController: StaticDataTableViewController, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate, DFUPeripheralSelectorDelegate, UITextFieldDelegate {
    var device: MBLMetaWear!
    
    @IBOutlet weak var connectionSwitch: UISwitch!
    @IBOutlet weak var connectionStateLabel: UILabel!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var setNameButton: UIButton!
    
    @IBOutlet var allCells: [UITableViewCell]!
    
    @IBOutlet var infoAndStateCells: [UITableViewCell]!
    @IBOutlet weak var mfgNameLabel: UILabel!
    @IBOutlet weak var serialNumLabel: UILabel!
    @IBOutlet weak var hwRevLabel: UILabel!
    @IBOutlet weak var fwRevLabel: UILabel!
    @IBOutlet weak var modelNumberLabel: UILabel!
    @IBOutlet weak var batteryLevelLabel: UILabel!
    @IBOutlet weak var rssiLevelLabel: UILabel!
    @IBOutlet weak var txPowerSelector: UISegmentedControl!
    @IBOutlet weak var firmwareUpdateLabel: UILabel!
    
    
    @IBOutlet weak var sensorFusionCell: UITableViewCell!
    @IBOutlet weak var sensorFusionMode: UISegmentedControl!
    @IBOutlet weak var sensorFusionOutput: UISegmentedControl!
    @IBOutlet weak var sensorFusionStartStream: UIButton!
    @IBOutlet weak var sensorFusionStopStream: UIButton!
    @IBOutlet weak var sensorFusionStartLog: UIButton!
    @IBOutlet weak var sensorFusionStopLog: UIButton!
    @IBOutlet weak var sensorFusionGraph: APLGraphView!
    
    // define a data object used to store data
    
    var sensorFusionData = Data()
    var sensorFusionArr : [eulerData] = []
    
    
    
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var pAngleLabel: UILabel!
    @IBOutlet weak var rAngleLabel: UILabel!
    @IBOutlet weak var yAngleLabel: UILabel!
    @IBOutlet weak var hAngleLabel: UILabel!
    
    
    
    struct eulerData {
        var p = 0.0
        var r = 0.0
        var y = 0.0
        var h = 0.0
    }
    
    
    
    var streamingEvents: Set<NSObject> = [] // Can't use proper type due to compiler seg fault
    var isObserving = false {
        didSet {
            if self.isObserving {
                if !oldValue {
                    self.device.addObserver(self, forKeyPath: "state", options: .new, context: nil)
                }
            } else {
                if oldValue {
                    self.device.removeObserver(self, forKeyPath: "state")
                }
            }
        }
    }
    var hud: MBProgressHUD!
    
    var controller: UIDocumentInteractionController!
    var initiator: DFUServiceInitiator?
    var dfuController: DFUServiceController?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Use this array to keep track of all streaming events, so turn them off
        // in case the user isn't so responsible
        streamingEvents = []
        // Hide every section in the beginning
        hideSectionsWithHiddenRows = true
        cells(self.allCells, setHidden: true)
        reloadData(animated: false)
        // Write in the 2 fields we know at time zero
        connectionStateLabel.text! = nameForState()
        nameTextField?.delegate = self
        nameTextField?.text = self.device.name
        // Listen for state changes
        isObserving = true
        // Start off the connection flow
        connectDevice(true)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        isObserving = false
        for obj in streamingEvents {
            if let event = obj as? MBLEvent<AnyObject> {
                event.stopNotificationsAsync()
            }
        }
        streamingEvents.removeAll()
    }

    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        OperationQueue.main.addOperation {
            self.connectionStateLabel.text! = self.nameForState()
            if self.device.state == .disconnected {
                self.deviceDisconnected()
            }
        }
    }
    
    func nameForState() -> String {
        switch device.state {
        case .connected:
            return device.programedByOtherApp ? "Connected (LIMITED)" : "Connected"
        case .connecting:
            return "Connecting"
        case .disconnected:
            return "Disconnected"
        case .disconnecting:
            return "Disconnecting"
        case .discovery:
            return "Discovery"
        }
    }
    
    func logCleanup(_ handler: @escaping MBLErrorHandler) {
        // In order for the device to actaully erase the flash memory we can't be in a connection
        // so temporally disconnect to allow flash to erase.
        isObserving = false
        device.disconnectAsync().continueOnDispatch { t in
            self.isObserving = true
            guard t.error == nil else {
                return t
            }
            return self.device.connect(withTimeoutAsync: 15)
        }.continueOnDispatch { t in
            handler(t.error)
            return nil
        }
    }
    
    func showAlertTitle(_ title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
        self.present(alertController, animated: true, completion: nil)
    }
    
    func deviceDisconnected() {
        connectionSwitch.setOn(false, animated: true)
        cells(self.allCells, setHidden: true)
        reloadData(animated: true)
    }
    
    func deviceConnected() {
        connectionSwitch.setOn(true, animated: true)
        // Perform all device specific setup
        print("ID: \(self.device.identifier.uuidString) MAC: \(self.device.mac ?? "N/A")")

        // We always have the info and state features
        cells(self.infoAndStateCells, setHidden: false)
        mfgNameLabel.text = device.deviceInfo?.manufacturerName ?? "N/A"
        serialNumLabel.text = device.deviceInfo?.serialNumber ?? "N/A"
        hwRevLabel.text = device.deviceInfo?.hardwareRevision ?? "N/A"
        fwRevLabel.text = device.deviceInfo?.firmwareRevision ?? "N/A"
        modelNumberLabel.text = "\(device.deviceInfo?.modelNumber ?? "N/A") (\(MBLModelString(device.model)))"
        txPowerSelector.selectedSegmentIndex = Int(device.settings!.transmitPower.rawValue)
        // Automaticaly send off some reads
        device.readBatteryLifeAsync().success { result in
            self.batteryLevelLabel.text = result.stringValue
        }
        device.readRSSIAsync().success { result in
            self.rssiLevelLabel.text = result.stringValue
        }
        device.checkForFirmwareUpdateAsync().continueOnDispatch { t in
            self.firmwareUpdateLabel.text = t.result != nil ? "\(t.result!) AVAILABLE!" : "Up To Date"
            return t
        }
        
        // Only allow LED module if the device is in use by other app
        if device.programedByOtherApp {
            if UserDefaults.standard.object(forKey: "ihaveseenprogramedByOtherAppmessage") == nil {
                UserDefaults.standard.set(1, forKey: "ihaveseenprogramedByOtherAppmessage")
                UserDefaults.standard.synchronize()
                self.showAlertTitle("WARNING", message: "You have connected to a device being used by another app.  To prevent errors and data loss for the other application we are only showing a limited number of features.  If you wish to take control please press 'Reset To Factory Defaults', which will wipe the device clean.")
            }
            reloadData(animated: true)
            return
        }
        
        
        if let sensorFusion = device.sensorFusion {
            cell(sensorFusionCell, setHidden: false)
            var isLogging = true
            if sensorFusion.eulerAngle.isLogging() {
                sensorFusionMode.selectedSegmentIndex = 0
            } else if sensorFusion.quaternion.isLogging() {
                sensorFusionMode.selectedSegmentIndex = 1
            } else if sensorFusion.gravity.isLogging() {
                sensorFusionMode.selectedSegmentIndex = 2
            } else if sensorFusion.linearAcceleration.isLogging() {
                sensorFusionMode.selectedSegmentIndex = 3
            } else {
                isLogging = false
            }
            sensorFusionOutput.selectedSegmentIndex = max(Int(sensorFusion.mode.rawValue) - 1, 0)
            
            if isLogging {
                sensorFusionStartLog.isEnabled = false
                sensorFusionStopLog.isEnabled = true
                sensorFusionStartStream.isEnabled = false
                sensorFusionStopStream.isEnabled = false
                sensorFusionMode.isEnabled = false
                sensorFusionOutput.isEnabled = false
            } else {
                sensorFusionStartLog.isEnabled = true
                sensorFusionStopLog.isEnabled = false
                sensorFusionStartStream.isEnabled = true
                sensorFusionStopStream.isEnabled = false
                sensorFusionMode.isEnabled = true
                sensorFusionOutput.isEnabled = true
            }
        }
        
        // Make the magic happen!
        reloadData(animated: true)
    }
    
    func connectDevice(_ on: Bool) {
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        if on {
            hud.label.text = "Connecting..."
            device.connect(withTimeoutAsync: 15).continueOnDispatch { t in
                if (t.error?._domain == kMBLErrorDomain) && (t.error?._code == kMBLErrorOutdatedFirmware) {
                    hud.hide(animated: true)
                    self.firmwareUpdateLabel.text! = "Force Update"
                    self.updateFirmware(self.setNameButton)
                    return nil
                }
                hud.mode = .text
                if t.error != nil {
                    self.showAlertTitle("Error", message: t.error!.localizedDescription)
                    hud.hide(animated: false)
                } else {
                    self.deviceConnected()
                    
                    hud.label.text! = "Connected!"
                    hud.hide(animated: true, afterDelay: 0.5)
                }
                return nil
            }
        } else {
            hud.label.text = "Disconnecting..."
            device.disconnectAsync().continueOnDispatch { t in
                self.deviceDisconnected()
                hud.mode = .text
                if t.error != nil {
                    self.showAlertTitle("Error", message: t.error!.localizedDescription)
                    hud.hide(animated: false)
                }
                else {
                    hud.label.text = "Disconnected!"
                    hud.hide(animated: true, afterDelay: 0.5)
                }
                return nil
            }
        }
    }
    
    @IBAction func connectionSwitchPressed(_ sender: Any) {
        connectDevice(connectionSwitch.isOn)
    }
    
    @IBAction func setNamePressed(_ sender: Any) {
        if UserDefaults.standard.object(forKey: "ihaveseennamemessage") == nil {
            UserDefaults.standard.set(1, forKey: "ihaveseennamemessage")
            UserDefaults.standard.synchronize()
            showAlertTitle("Notice", message: "Because of how iOS caches names, you have to disconnect and re-connect a few times or force close and re-launch the app before you see the new name!")
        }
        nameTextField.resignFirstResponder()
        device.name = nameTextField.text!
        setNameButton.isEnabled = false
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        // return NO to not change text
        self.setNameButton.isEnabled = true
        // Prevent Undo crashing bug
        if range.length + range.location > textField.text!.count {
            return false
        }
        // Make sure it's no longer than 8 characters
        let newLength = textField.text!.count + string.count - range.length
        if newLength > 8 {
            return false
        }
        // Make sure we only use ASCII characters
        return string.data(using: String.Encoding.ascii) != nil
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // called when 'return' key pressed. return NO to ignore.
        textField.resignFirstResponder()
        return true
    }
    
    @IBAction func readBatteryPressed(_ sender: Any) {
        device.readBatteryLifeAsync().success { result in
            self.batteryLevelLabel.text = result.stringValue
        }.failure { error in
            self.showAlertTitle("Error", message: error.localizedDescription)
        }
    }
    
    @IBAction func readRSSIPressed(_ sender: Any) {
        device.readRSSIAsync().success { result in
            self.rssiLevelLabel.text = result.stringValue
        }.failure { error in
            self.showAlertTitle("Error", message: error.localizedDescription)
        }
    }
    
    @IBAction func txPowerChanged(_ sender: Any) {
        device.settings?.transmitPower = MBLTransmitPower(rawValue: UInt8(txPowerSelector.selectedSegmentIndex))!
    }
    
    @IBAction func checkForFirmwareUpdatesPressed(_ sender: Any) {
        device.checkForFirmwareUpdateAsync().continueOnDispatch { t in
            guard t.error == nil else {
                self.showAlertTitle("Error", message: t.error!.localizedDescription)
                return t
            }
            self.firmwareUpdateLabel.text = t.result != nil ? "\(t.result!) AVAILABLE!" : "Up To Date"
            return t
        }
    }
    
    @IBAction func updateFirmware(_ sender: Any) {
        // Pause the screen while update is going on
        hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Updating..."
        device.prepareForFirmwareUpdateAsync().success { result in
            var selectedFirmware: DFUFirmware?
            if result.firmwareUrl.pathExtension.caseInsensitiveCompare("zip") == .orderedSame {
                selectedFirmware = DFUFirmware(urlToZipFile: result.firmwareUrl)
            } else {
                selectedFirmware = DFUFirmware(urlToBinOrHexFile: result.firmwareUrl, urlToDatFile: nil, type: .application)
            }
            self.initiator = DFUServiceInitiator(centralManager: result.centralManager, target: result.target)
            let _ = self.initiator?.with(firmware: selectedFirmware!)
            self.initiator?.forceDfu = true // We also have the DIS which confuses the DFU library
            self.initiator?.logger = self // - to get log info
            self.initiator?.delegate = self // - to be informed about current state and errors
            self.initiator?.peripheralSelector = self
            self.initiator?.progressDelegate = self // - to show progress bar
            
            self.dfuController = self.initiator?.start()
        }.failure { error in
            print("Firmware update error: \(error.localizedDescription)")
            UIAlertView(title: "Update Error", message: "Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: ".appending(error.localizedDescription), delegate: nil, cancelButtonTitle: "Okay", otherButtonTitles: "").show()
            self.hud.hide(animated: true)
        }
    }
    
    @IBAction func resetDevicePressed(_ sender: Any) {
        // Resetting causes a disconnection
        deviceDisconnected()
        // Preform the soft reset
        device.resetDevice()
    }
    
    @IBAction func factoryDefaultsPressed(_ sender: Any) {
        // Resetting causes a disconnection
        deviceDisconnected()
        // In case any pairing information is on the device mark it for removal too
        device.settings?.deleteAllBondsAsync()
        // Setting a nil configuration removes state perisited in flash memory
        device.setConfigurationAsync(nil)
    }
    
    @IBAction func putToSleepPressed(_ sender: Any) {
        // Sleep causes a disconnection
        deviceDisconnected()
        // Set it to sleep after the next reset
        device.sleepModeOnReset()
        // Preform the soft reset
        device.resetDevice()
    }
    
  
   
    func updateSensorFusionSettings() {
        
        // depending on which button toggled, vary the loggin setting, set the mode to index+1.
        // see line 202
        device.sensorFusion!.mode = MBLSensorFusionMode(rawValue: UInt8(sensorFusionMode.selectedSegmentIndex) + 1)!
        
        
        // toggle buttons, do not allow user to change how to collect data.
        sensorFusionMode.isEnabled = false
        sensorFusionOutput.isEnabled = false
        
        
        // empty the data object.
        sensorFusionData = Data()
        
        
        // init the graph
        sensorFusionGraph.fullScale = 8
    }
    
    @IBAction func sensorFusionStartStreamPressed(_ sender: Any) {
        sensorFusionStartStream.isEnabled = false
        sensorFusionStopStream.isEnabled = true
        sensorFusionStartLog.isEnabled = false
        sensorFusionStopLog.isEnabled = false
        
        // calls above function to prepare for new log
        updateSensorFusionSettings()
        
        
        //empties array
        self.sensorFusionArr = []

        
        
        var task: BFTask<AnyObject>?
        switch sensorFusionOutput.selectedSegmentIndex {
            
            // eulerAngle
        case 0:
            streamingEvents.insert(device.sensorFusion!.eulerAngle)
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.eulerAngle.startNotificationsAsync { (obj, error) in
                if let obj = obj {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.p, min: -180, max: 180), y: self.sensorFusionGraph.scale(obj.r, min: -90, max: 90), z: self.sensorFusionGraph.scale(obj.y, min: 0, max: 360), w: self.sensorFusionGraph.scale(obj.h, min: 0, max: 360))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.p),\(obj.r),\(obj.y),\(obj.h)\n".data(using: String.Encoding.utf8)!)
                   
                    
                   // here is the arr
                    self.sensorFusionArr.append(eulerData(p :obj.p, r: obj.r, y: obj.y, h: obj.h))
                }
            }
            
            // quaternion
        case 1:
            streamingEvents.insert(device.sensorFusion!.quaternion)
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.quaternion.startNotificationsAsync { (obj, error) in
                if let obj = obj {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0), w: self.sensorFusionGraph.scale(obj.w, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
            // Gravity
        case 2:
            streamingEvents.insert(device.sensorFusion!.gravity)
            sensorFusionGraph.hasW = false
            task = device.sensorFusion!.gravity.startNotificationsAsync { (obj, error) in
                if let obj = obj {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
            // Linear Acceleration
            
        case 3:
            streamingEvents.insert(device.sensorFusion!.linearAcceleration)
            switch (device.accelerometer as! MBLAccelerometerBosch).fullScaleRange {
            case .range2G:
                sensorFusionGraph.fullScale = 2.0
            case .range4G:
                sensorFusionGraph.fullScale = 4.0
            case .range8G:
                sensorFusionGraph.fullScale = 8.0
            case.range16G:
                sensorFusionGraph.fullScale = 16.0
            }
            sensorFusionGraph.hasW = false
            task = device.sensorFusion!.linearAcceleration.startNotificationsAsync { (obj, error) in
                if let obj = obj {
                    self.sensorFusionGraph.addX(obj.x, y: obj.y, z: obj.z)
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
        default:
            assert(false, "Added a new sensor fusion output?")
        }
        
        task?.failure { error in
            // Currently can't recover nicely from this error
            let alertController = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
            alertController.addAction(UIAlertAction(title: "Okay", style: .default) { alert in
                self.device.resetDevice()
            })
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    @IBAction func sensorFusionStopStreamPressed(_ sender: Any) {
        sensorFusionStartStream.isEnabled = true
        sensorFusionStopStream.isEnabled = false
        sensorFusionStartLog.isEnabled = true
        sensorFusionMode.isEnabled = true
        sensorFusionOutput.isEnabled = true
        
        switch sensorFusionOutput.selectedSegmentIndex {
        case 0:
            streamingEvents.remove(device.sensorFusion!.eulerAngle)
            device.sensorFusion!.eulerAngle.stopNotificationsAsync()
        case 1:
            streamingEvents.remove(device.sensorFusion!.quaternion)
            device.sensorFusion!.quaternion.stopNotificationsAsync()
        case 2:
            streamingEvents.remove(device.sensorFusion!.gravity)
            device.sensorFusion!.gravity.stopNotificationsAsync()
        case 3:
            streamingEvents.remove(device.sensorFusion!.linearAcceleration)
            device.sensorFusion!.linearAcceleration.stopNotificationsAsync()
        default:
            assert(false, "Added a new sensor fusion output?")
        }
        
       /*
        for obj in self.sensorFusionData {
            print(obj)
        }*/
        
        let maxP = self.sensorFusionArr.max {a, b in a.p < b.p}
        
        
        let date = Date()
        let formatter = DateFormatter()

        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        let result = formatter.string(from: date)

        
        print(self.sensorFusionArr)
        self.timeLabel.text = result
        self.pAngleLabel.text = "\(String(describing: maxP!.p))"
        self.rAngleLabel.text = "\(String(describing: maxP!.r))"
        self.yAngleLabel.text = "\(String(describing: maxP!.y))"
        self.hAngleLabel.text = "\(String(describing: maxP!.h))"
        
        
    }
    
    @IBAction func sensorFusionStartLogPressed(_ sender: Any) {
        
        // disable visual buttons
        
        sensorFusionStartLog.isEnabled = false
        sensorFusionStopLog.isEnabled = true
        sensorFusionStartStream.isEnabled = false
        sensorFusionStopStream.isEnabled = false
        
        // actually begin, based on button settings, prepare the session.
        updateSensorFusionSettings()

        
        
        switch sensorFusionOutput.selectedSegmentIndex {
        case 0:
            device.sensorFusion!.eulerAngle.startLoggingAsync()
        case 1:
            device.sensorFusion!.quaternion.startLoggingAsync()
        case 2:
            device.sensorFusion!.gravity.startLoggingAsync()
        case 3:
            switch (device.accelerometer as! MBLAccelerometerBosch).fullScaleRange {
            case .range2G:
                sensorFusionGraph.fullScale = 2.0
            case .range4G:
                sensorFusionGraph.fullScale = 4.0
            case .range8G:
                sensorFusionGraph.fullScale = 8.0
            case.range16G:
                sensorFusionGraph.fullScale = 16.0
            }
            device.sensorFusion!.linearAcceleration.startLoggingAsync()
        default:
            assert(false, "Added a new sensor fusion output?")
        }
    }

    @IBAction func sensorFusionStopLogPressed(_ sender: Any) {
        
        // buttons
        sensorFusionStartLog.isEnabled = true
        sensorFusionStopLog.isEnabled = false
        sensorFusionStartStream.isEnabled = true
        sensorFusionMode.isEnabled = true
        sensorFusionOutput.isEnabled = true
        
        
        
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        
        var task: BFTask<AnyObject>?
        let hudProgress: MetaWear.MBLFloatHandler = { number in
            hud.progress = number
        }
        
        // depending on how the button is toggled.
        switch sensorFusionOutput.selectedSegmentIndex {
            
            // Euler
            
        case 0:
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.eulerAngle.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLEulerAngleData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.p, min: -180, max: 180), y: self.sensorFusionGraph.scale(obj.r, min: -90, max: 90), z: self.sensorFusionGraph.scale(obj.y, min: 0, max: 360), w: self.sensorFusionGraph.scale(obj.h, min: 0, max: 360))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.p),\(obj.r),\(obj.y),\(obj.h)\n".data(using: String.Encoding.utf8)!)
                }
                print(self.sensorFusionData)
            }
            
            // Quaternion
        case 1:
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.quaternion.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLQuaternionData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0), w: self.sensorFusionGraph.scale(obj.w, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
                print(self.sensorFusionData)
            }

            // Gravity
        case 2:
            sensorFusionGraph.hasW = false
            task = device.sensorFusion!.gravity.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLAccelerometerData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
            print(self.sensorFusionData)

            // Linear Acceleration
        case 3:
            sensorFusionGraph.hasW = false
            task = device.sensorFusion!.linearAcceleration.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLAccelerometerData] {
                    self.sensorFusionGraph.addX(obj.x, y: obj.y, z: obj.z)
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
                print(self.sensorFusionData)

            }

        default:
            assert(false, "Added a new sensor fusion output?")
        }
        
        
        
        task?.success { array in
            hud.mode = .indeterminate
            hud.label.text! = "Clearing Log..."
            self.logCleanup { error in
                hud.hide(animated: true)
                if error != nil {
                    self.connectDevice(false)
                    print(self.sensorFusionData)

                }
            }
        }.failure { error in
            self.connectDevice(false)
            hud.hide(animated: true)
        }
    }
    // Calls the function that manages sending Data.
    @IBAction func sensorFusionSendDataPressed(_ sender: Any) {
        send(sensorFusionData, title: "SensorFusion")
    }
    
    func send(_ data: Data, title: String) {
        // Get current Time/Date
        let dateFormatter = DateFormatter()
        // set swedish format
        dateFormatter.dateFormat = "dd_MM_yyyy-HH_mm_ss"
        let dateString = dateFormatter.string(from: Date())
        let name = "\(title)_\(dateString).csv"
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent(name)
        do {
            try data.write(to: fileURL, options: .atomic)
            // Popup the default share screen
            self.controller = UIDocumentInteractionController(url: fileURL)
            if !self.controller.presentOptionsMenu(from: view.bounds, in: view, animated: true) {
                self.showAlertTitle("Error", message: "No programs installed that could save the file")
            }
        } catch let error {
            self.showAlertTitle("Error", message: error.localizedDescription)
        }
    }
    
    // MARK: - DFU Service delegate methods
    
    func dfuStateDidChange(to state: DFUState) {
        if state == .completed {
            hud?.mode = .text
            hud?.label.text = "Success!"
            hud?.hide(animated: true, afterDelay: 2.0)
        }
    }
    
    func dfuError(_ error: DFUError, didOccurWithMessage message: String) {
        print("Firmware update error \(error): \(message)")
        
        let alertController = UIAlertController(title: "Update Error", message: "Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: \(message)", preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        
        hud?.hide(animated: true)
    }
    
    func dfuProgressDidChange(for part: Int, outOf totalParts: Int, to progress: Int,
                              currentSpeedBytesPerSecond: Double, avgSpeedBytesPerSecond: Double) {
        hud?.progress = Float(progress) / 100.0
    }
    
    func logWith(_ level: LogLevel, message: String) {
        if level.rawValue >= LogLevel.application.rawValue {
            print("\(level.name()): \(message)")
        }
    }
    
    func select(_ peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber, hint name: String?) -> Bool {
        return peripheral.identifier == device.identifier
    }
    
    func filterBy(hint dfuServiceUUID: CBUUID) -> [CBUUID]? {
        return nil
    }
}


