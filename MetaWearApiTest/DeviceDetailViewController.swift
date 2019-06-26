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
    
    @IBOutlet weak var mechanicalSwitchCell: UITableViewCell!
    @IBOutlet weak var mechanicalSwitchLabel: UILabel!
    @IBOutlet weak var startSwitch: UIButton!
    @IBOutlet weak var stopSwitch: UIButton!
    
    @IBOutlet weak var ledCell: UITableViewCell!
    
    @IBOutlet weak var tempCell: UITableViewCell!
    @IBOutlet weak var tempChannelSelector: UISegmentedControl!
    @IBOutlet weak var channelTypeLabel: UILabel!
    @IBOutlet weak var tempratureLabel: UILabel!
    @IBOutlet weak var readPinLabel: UILabel!
    @IBOutlet weak var readPinTextField: UITextField!
    @IBOutlet weak var enablePinLabel: UILabel!
    @IBOutlet weak var enablePinTextField: UITextField!
    
    @IBOutlet weak var accelerometerMMA8452QCell: UITableViewCell!
    @IBOutlet weak var accelerometerScale: UISegmentedControl!
    @IBOutlet weak var sampleFrequency: UISegmentedControl!
    @IBOutlet weak var highPassFilterSwitch: UISwitch!
    @IBOutlet weak var hpfCutoffFreq: UISegmentedControl!
    @IBOutlet weak var lowNoiseSwitch: UISwitch!
    @IBOutlet weak var activePowerScheme: UISegmentedControl!
    @IBOutlet weak var autoSleepSwitch: UISwitch!
    @IBOutlet weak var sleepSampleFrequency: UISegmentedControl!
    @IBOutlet weak var sleepPowerScheme: UISegmentedControl!
    @IBOutlet weak var startAccelerometer: UIButton!
    @IBOutlet weak var stopAccelerometer: UIButton!
    @IBOutlet weak var startLog: UIButton!
    @IBOutlet weak var stopLog: UIButton!
    @IBOutlet weak var accelerometerGraph: APLGraphView!
    @IBOutlet weak var tapDetectionAxis: UISegmentedControl!
    @IBOutlet weak var tapDetectionType: UISegmentedControl!
    @IBOutlet weak var startTap: UIButton!
    @IBOutlet weak var stopTap: UIButton!
    @IBOutlet weak var tapLabel: UILabel!
    var tapCount = 0
    @IBOutlet weak var startShake: UIButton!
    @IBOutlet weak var stopShake: UIButton!
    @IBOutlet weak var shakeLabel: UILabel!
    var shakeCount = 0
    @IBOutlet weak var startOrientation: UIButton!
    @IBOutlet weak var stopOrientation: UIButton!
    @IBOutlet weak var orientationLabel: UILabel!
    var accelerometerDataArray: [MBLAccelerometerData] = []
    
    @IBOutlet weak var accelerometerBMI160Cell: UITableViewCell!
    @IBOutlet weak var accelerometerBMI160Scale: UISegmentedControl!
    @IBOutlet weak var accelerometerBMI160Frequency: UISegmentedControl!
    @IBOutlet weak var accelerometerBMI160StartStream: UIButton!
    @IBOutlet weak var accelerometerBMI160StopStream: UIButton!
    @IBOutlet weak var accelerometerBMI160StartLog: UIButton!
    @IBOutlet weak var accelerometerBMI160StopLog: UIButton!
    @IBOutlet weak var accelerometerBMI160Graph: APLGraphView!
    @IBOutlet weak var accelerometerBMI160TapType: UISegmentedControl!
    @IBOutlet weak var accelerometerBMI160StartTap: UIButton!
    @IBOutlet weak var accelerometerBMI160StopTap: UIButton!
    @IBOutlet weak var accelerometerBMI160TapLabel: UILabel!
    var accelerometerBMI160TapCount = 0
    @IBOutlet weak var accelerometerBMI160StartFlat: UIButton!
    @IBOutlet weak var accelerometerBMI160StopFlat: UIButton!
    @IBOutlet weak var accelerometerBMI160FlatLabel: UILabel!
    @IBOutlet weak var accelerometerBMI160StartOrient: UIButton!
    @IBOutlet weak var accelerometerBMI160StopOrient: UIButton!
    @IBOutlet weak var accelerometerBMI160OrientLabel: UILabel!
    @IBOutlet weak var accelerometerBMI160StartStep: UIButton!
    @IBOutlet weak var accelerometerBMI160StopStep: UIButton!
    @IBOutlet weak var accelerometerBMI160StepLabel: UILabel!
    var accelerometerBMI160StepCount = 0
    var accelerometerBMI160Data: [MBLAccelerometerData] = []
    
    @IBOutlet weak var accelerometerBMA255Cell: UITableViewCell!
    @IBOutlet weak var accelerometerBMA255Scale: UISegmentedControl!
    @IBOutlet weak var accelerometerBMA255Frequency: UISegmentedControl!
    @IBOutlet weak var accelerometerBMA255StartStream: UIButton!
    @IBOutlet weak var accelerometerBMA255StopStream: UIButton!
    @IBOutlet weak var accelerometerBMA255StartLog: UIButton!
    @IBOutlet weak var accelerometerBMA255StopLog: UIButton!
    @IBOutlet weak var accelerometerBMA255Graph: APLGraphView!
    @IBOutlet weak var accelerometerBMA255TapType: UISegmentedControl!
    @IBOutlet weak var accelerometerBMA255StartTap: UIButton!
    @IBOutlet weak var accelerometerBMA255StopTap: UIButton!
    @IBOutlet weak var accelerometerBMA255TapLabel: UILabel!
    var accelerometerBMA255TapCount = 0
    @IBOutlet weak var accelerometerBMA255StartFlat: UIButton!
    @IBOutlet weak var accelerometerBMA255StopFlat: UIButton!
    @IBOutlet weak var accelerometerBMA255FlatLabel: UILabel!
    @IBOutlet weak var accelerometerBMA255StartOrient: UIButton!
    @IBOutlet weak var accelerometerBMA255StopOrient: UIButton!
    @IBOutlet weak var accelerometerBMA255OrientLabel: UILabel!
    var accelerometerBMA255Data: [MBLAccelerometerData] = []
   
  
    
    
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
        
        if device.led != nil {
            cell(ledCell, setHidden: false)
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
        
        // Go through each module and enable the correct cell for the modules on this particular MetaWear
        if device.mechanicalSwitch != nil {
            cell(mechanicalSwitchCell, setHidden: false)
        }
        if device.temperature != nil {
            cell(tempCell, setHidden: false)
            // The number of channels is variable
            tempChannelSelector.removeAllSegments()
            for i in 0..<device.temperature!.channels.count {
                tempChannelSelector.insertSegment(withTitle: "\(i)", at: i, animated: false)
            }
            tempChannelSelector.selectedSegmentIndex = 0
            tempChannelSelectorPressed(tempChannelSelector)
        }
        
        if (device.accelerometer is MBLAccelerometerMMA8452Q) {
            cell(accelerometerMMA8452QCell, setHidden: false)
            if device.accelerometer!.dataReadyEvent.isLogging() {
                startLog.isEnabled = false
                stopLog.isEnabled = true
                startAccelerometer.isEnabled = false
                stopAccelerometer.isEnabled = false
            } else {
                startLog.isEnabled = true
                stopLog.isEnabled = false
                startAccelerometer.isEnabled = true
                stopAccelerometer.isEnabled = false
            }
        } else if (device.accelerometer is MBLAccelerometerBMI160) {
            cell(accelerometerBMI160Cell, setHidden: false)
            if device.accelerometer!.dataReadyEvent.isLogging() {
                accelerometerBMI160StartLog.isEnabled = false
                accelerometerBMI160StopLog.isEnabled = true
                accelerometerBMI160StartStream.isEnabled = false
                accelerometerBMI160StopStream.isEnabled = false
            } else {
                accelerometerBMI160StartLog.isEnabled = true
                accelerometerBMI160StopLog.isEnabled = false
                accelerometerBMI160StartStream.isEnabled = true
                accelerometerBMI160StopStream.isEnabled = false
            }
        } else if (device.accelerometer is MBLAccelerometerBMA255) {
            cell(accelerometerBMA255Cell, setHidden: false)
            if device.accelerometer!.dataReadyEvent.isLogging() {
                accelerometerBMA255StartLog.isEnabled = false
                accelerometerBMA255StopLog.isEnabled = true
                accelerometerBMA255StartStream.isEnabled = false
                accelerometerBMA255StopStream.isEnabled = false
            } else {
                accelerometerBMA255StartLog.isEnabled = true
                accelerometerBMA255StopLog.isEnabled = false
                accelerometerBMA255StartStream.isEnabled = true
                accelerometerBMA255StopStream.isEnabled = false
            }
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
    
    @IBAction func readSwitchPressed(_ sender: Any) {
        device.mechanicalSwitch?.switchValue.readAsync().success { result in
            self.mechanicalSwitchLabel.text = result.value.boolValue ? "Down" : "Up"
        }
    }
    
    @IBAction func startSwitchNotifyPressed(_ sender: Any) {
        startSwitch.isEnabled = false
        stopSwitch.isEnabled = true
        streamingEvents.insert(device.mechanicalSwitch!.switchUpdateEvent)
        device.mechanicalSwitch!.switchUpdateEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.mechanicalSwitchLabel.text = obj.value.boolValue ? "Down" : "Up"
            }
        }
    }
    
    @IBAction func stopSwitchNotifyPressed(_ sender: Any) {
        startSwitch.isEnabled = true
        stopSwitch.isEnabled = false
        streamingEvents.remove(device.mechanicalSwitch!.switchUpdateEvent)
        device.mechanicalSwitch!.switchUpdateEvent.stopNotificationsAsync()
    }
    
    @IBAction func turn(onGreenLEDPressed sender: Any) {
        device.led?.setLEDColorAsync(UIColor.green, withIntensity: 1.0)
    }
    
    @IBAction func flashGreenLEDPressed(_ sender: Any) {
        device.led?.flashColorAsync(UIColor.green, withIntensity: 1.0)
    }
    
    @IBAction func turn(onRedLEDPressed sender: Any) {
        device.led?.setLEDColorAsync(UIColor.red, withIntensity: 1.0)
    }
    
    @IBAction func flashRedLEDPressed(_ sender: Any) {
        device.led?.flashColorAsync(UIColor.red, withIntensity: 1.0)
    }
    
    @IBAction func turn(onBlueLEDPressed sender: Any) {
        device.led?.setLEDColorAsync(UIColor.blue, withIntensity: 1.0)
    }
    
    @IBAction func flashBlueLEDPressed(_ sender: Any) {
        device.led?.flashColorAsync(UIColor.blue, withIntensity: 1.0)
    }
    
    @IBAction func turnOffLEDPressed(_ sender: Any) {
        device.led?.setLEDOnAsync(false, withOptions: 1)
    }
    
    @IBAction func tempChannelSelectorPressed(_ sender: Any) {
        let selected = device.temperature!.channels[tempChannelSelector.selectedSegmentIndex]
        if selected == device.temperature!.onDieThermistor {
            channelTypeLabel.text = "On-Die"
        } else if selected == device.temperature!.onboardThermistor {
            channelTypeLabel.text = "On-Board"
        } else if selected == device.temperature!.externalThermistor {
            channelTypeLabel.text = "External"
        } else {
            channelTypeLabel.text = "Custom"
        }
        
        if selected is MBLExternalThermistor {
            self.readPinLabel.isHidden = false
            self.readPinTextField.isHidden = false
            self.enablePinLabel.isHidden = false
            self.enablePinTextField.isHidden = false
        } else {
            self.readPinLabel.isHidden = true
            self.readPinTextField.isHidden = true
            self.enablePinLabel.isHidden = true
            self.enablePinTextField.isHidden = true
        }
    }
    
    @IBAction func readTempraturePressed(_ sender: Any) {
        let selected = device.temperature!.channels[tempChannelSelector.selectedSegmentIndex]
        if let selected = selected as? MBLExternalThermistor {
            selected.readPin = UInt8(readPinTextField.text!) ?? 0
            selected.enablePin = UInt8(enablePinTextField.text!) ?? 0
        }
        selected.readAsync().success { result in
            self.tempratureLabel.text = result.value.stringValue.appending("°C")
        }
    }
    // RZCOM - Called by accelerometer init function.
    func updateAccelerometerSettings() {
        // selects accelerometer
        let accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
        
        if accelerometerScale.selectedSegmentIndex == 0 {
            accelerometerGraph.fullScale = 2
        } else if accelerometerScale.selectedSegmentIndex == 1 {
            accelerometerGraph.fullScale = 4
        } else {
            accelerometerGraph.fullScale = 8
        }
        
        accelerometerMMA8452Q.fullScaleRange = MBLAccelerometerRange(rawValue: UInt8(accelerometerScale.selectedSegmentIndex))!
        accelerometerMMA8452Q.sampleFrequency = Double(sampleFrequency.titleForSegment(at: sampleFrequency.selectedSegmentIndex)!)!
        accelerometerMMA8452Q.highPassFilter = highPassFilterSwitch.isOn
        accelerometerMMA8452Q.highPassCutoffFreq = MBLAccelerometerCutoffFreq(rawValue: UInt8(hpfCutoffFreq.selectedSegmentIndex))!
        accelerometerMMA8452Q.lowNoise = lowNoiseSwitch.isOn
        accelerometerMMA8452Q.activePowerScheme = MBLAccelerometerPowerScheme(rawValue: UInt8(activePowerScheme.selectedSegmentIndex))!
        accelerometerMMA8452Q.autoSleep = autoSleepSwitch.isOn
        accelerometerMMA8452Q.sleepSampleFrequency = MBLAccelerometerSleepSampleFrequency(rawValue: UInt8(sleepSampleFrequency.selectedSegmentIndex))!
        accelerometerMMA8452Q.sleepPowerScheme = MBLAccelerometerPowerScheme(rawValue: UInt8(sleepPowerScheme.selectedSegmentIndex))!
        accelerometerMMA8452Q.tapDetectionAxis = MBLAccelerometerAxis(rawValue: UInt8(tapDetectionAxis.selectedSegmentIndex))
        accelerometerMMA8452Q.tapType = MBLAccelerometerTapType(rawValue: UInt8(tapDetectionType.selectedSegmentIndex))!
    }
    
    
    // RZCOM - Start of accelerometer..
    @IBAction func startAccelerationPressed(_ sender: Any) {
        // visually fixes buttons
        startAccelerometer.isEnabled = false
        stopAccelerometer.isEnabled = true
        
        // disables option to log data
        startLog.isEnabled = false
        stopLog.isEnabled = false
        
        
        // important, todo: define
        updateAccelerometerSettings()
        
        // removes previous data in sampleArr
        accelerometerDataArray.removeAll()
        
        // todo: find
        streamingEvents.insert(device.accelerometer!.dataReadyEvent)
        
        
        
        device.accelerometer!.dataReadyEvent.startNotificationsAsync { (acceleration, error) in
            if let acceleration = acceleration {
                // used for graphing
                self.accelerometerGraph.addX(acceleration.x, y: acceleration.y, z: acceleration.z)
                // Add data to data array for saving
                self.accelerometerDataArray.append(acceleration)
            }
        }
    }
    
    @IBAction func stopAccelerationPressed(_ sender: Any) {
        startAccelerometer.isEnabled = true
        stopAccelerometer.isEnabled = false
        startLog.isEnabled = true
        streamingEvents.remove(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.stopNotificationsAsync()
    }
    
    @IBAction func startAccelerometerLog(_ sender: Any) {
        startLog.isEnabled = false
        stopLog.isEnabled = true
        startAccelerometer.isEnabled = false
        stopAccelerometer.isEnabled = false
        
        
        
        updateAccelerometerSettings()
        device.accelerometer!.dataReadyEvent.startLoggingAsync()
    }
    
    @IBAction func stopAccelerometerLog(_ sender: Any) {
        stopLog.isEnabled = false
        startLog.isEnabled = true
        startAccelerometer.isEnabled = true
        // hud is popup showing text
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        device.accelerometer!.dataReadyEvent.downloadLogAndStopLoggingAsync(true) { number in
            hud.progress = number
        }.success { array in
            // use what's stored in memory to add to array.
            self.accelerometerDataArray = array as! [MBLAccelerometerData]
            // add all the data to graph
            for acceleration in self.accelerometerDataArray {
                self.accelerometerGraph.addX(acceleration.x, y: acceleration.y, z: acceleration.z)
            }
            hud.mode = .indeterminate
            hud.label.text = "Clearing Log..."
            self.logCleanup { error in
                hud.hide(animated: true)
                if error != nil {
                    self.connectDevice(false)
                }
            }
        }.failure { error in
            self.connectDevice(false)
            hud.hide(animated: true)
        }
    }
    
    @IBAction func sendDataPressed(_ sender: Any) {
        var accelerometerData = Data()
        // RZCOM
        // for each dE in array, add the time and x,y,z.
        for dataElement in accelerometerDataArray {
            /* TODO: currently poor timestamp, shows number with decimals, should show timestamp. */ accelerometerData.append("\(dataElement.timestamp.timeIntervalSince1970),\(dataElement.x),\(dataElement.y),\(dataElement.z)\n".data(using: String.Encoding.utf8)!)
        }
        
        send(accelerometerData, title: "AccData")
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
    
    @IBAction func startTapPressed(_ sender: Any) {
        startTap.isEnabled = false
        stopTap.isEnabled = true
        updateAccelerometerSettings()
        let accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
        streamingEvents.insert(accelerometerMMA8452Q.tapEvent)
        accelerometerMMA8452Q.tapEvent.startNotificationsAsync { (obj, error) in
            if obj != nil {
                self.tapCount += 1
                self.tapLabel.text = "Tap Count: \(self.tapCount)"
            }
        }
    }
    
    @IBAction func stopTapPressed(_ sender: Any) {
        startTap.isEnabled = true
        stopTap.isEnabled = false
        let accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
        streamingEvents.remove(accelerometerMMA8452Q.tapEvent)
        accelerometerMMA8452Q.tapEvent.stopNotificationsAsync()
        tapCount = 0
        tapLabel.text = "Tap Count: 0"
    }

    @IBAction func startShakePressed(_ sender: Any) {
        startShake.isEnabled = false
        stopShake.isEnabled = true
        updateAccelerometerSettings()
        let accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
        streamingEvents.insert(accelerometerMMA8452Q.shakeEvent)
        accelerometerMMA8452Q.shakeEvent.startNotificationsAsync { (obj, error) in
            if obj != nil {
                self.shakeCount += 1
                self.shakeLabel.text = "Shakes: \(self.shakeCount)"
            }
        }
    }
    
    @IBAction func stopShakePressed(_ sender: Any) {
        startShake.isEnabled = true
        stopShake.isEnabled = false
        let accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
        streamingEvents.remove(accelerometerMMA8452Q.shakeEvent)
        accelerometerMMA8452Q.shakeEvent.stopNotificationsAsync()
        shakeCount = 0
        shakeLabel.text = "Shakes: 0"
    }
    
    @IBAction func startOrientationPressed(_ sender: Any) {
        startOrientation.isEnabled = false
        stopOrientation.isEnabled = true
        updateAccelerometerSettings()
        let accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
        streamingEvents.insert(accelerometerMMA8452Q.orientationEvent)
        accelerometerMMA8452Q.orientationEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                switch obj.orientation {
                case .portrait:
                    self.orientationLabel.text = "Portrait"
                case .portraitUpsideDown:
                    self.orientationLabel.text = "PortraitUpsideDown"
                case .landscapeLeft:
                    self.orientationLabel.text = "LandscapeLeft"
                case .landscapeRight:
                    self.orientationLabel.text = "LandscapeRight"
                }
            }
        }
    }
    
    @IBAction func stopOrientationPressed(_ sender: Any) {
        startOrientation.isEnabled = true
        stopOrientation.isEnabled = false
        let accelerometerMMA8452Q = device.accelerometer as! MBLAccelerometerMMA8452Q
        streamingEvents.remove(accelerometerMMA8452Q.orientationEvent)
        accelerometerMMA8452Q.orientationEvent.stopNotificationsAsync()
        self.orientationLabel.text = "XXXXXXXXXXXXXX"
    }
    
    func updateAccelerometerBMI160Settings() {
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        switch self.accelerometerBMI160Scale.selectedSegmentIndex {
        case 0:
            accelerometerBMI160.fullScaleRange = .range2G
            self.accelerometerBMI160Graph.fullScale = 2
        case 1:
            accelerometerBMI160.fullScaleRange = .range4G
            self.accelerometerBMI160Graph.fullScale = 4
        case 2:
            accelerometerBMI160.fullScaleRange = .range8G
            self.accelerometerBMI160Graph.fullScale = 8
        case 3:
            accelerometerBMI160.fullScaleRange = .range16G
            self.accelerometerBMI160Graph.fullScale = 16
        default:
            print("Unexpected accelerometerBMI160Scale value")
        }
        
        accelerometerBMI160.sampleFrequency = Double(self.accelerometerBMI160Frequency.titleForSegment(at: self.accelerometerBMI160Frequency.selectedSegmentIndex)!)!
        accelerometerBMI160.tapEvent.type = MBLAccelerometerTapType(rawValue: UInt8(self.tapDetectionType.selectedSegmentIndex))!
        accelerometerBMI160.filterMode = .normal
    }
    
    @IBAction func accelerometerBMI160StartStreamPressed(_ sender: Any) {
        accelerometerBMI160StartStream.isEnabled = false
        accelerometerBMI160StopStream.isEnabled = true
        accelerometerBMI160StartLog.isEnabled = false
        accelerometerBMI160StopLog.isEnabled = false
        updateAccelerometerBMI160Settings()
        accelerometerBMI160Data.removeAll()
        streamingEvents.insert(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.accelerometerBMI160Graph.addX(obj.x, y: obj.y, z: obj.z)
                self.accelerometerBMI160Data.append(obj)
            }
        }
    }
    
    @IBAction func accelerometerBMI160StopStreamPressed(_ sender: Any) {
        accelerometerBMI160StartStream.isEnabled = true
        accelerometerBMI160StopStream.isEnabled = false
        accelerometerBMI160StartLog.isEnabled = true
        streamingEvents.remove(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.stopNotificationsAsync()
    }
    
    @IBAction func accelerometerBMI160StartLogPressed(_ sender: Any) {
        accelerometerBMI160StartLog.isEnabled = false
        accelerometerBMI160StopLog.isEnabled = true
        accelerometerBMI160StartStream.isEnabled = false
        accelerometerBMI160StopStream.isEnabled = false
        updateAccelerometerBMI160Settings()
        device.accelerometer!.dataReadyEvent.startLoggingAsync()
    }
    
    @IBAction func accelerometerBMI160StopLogPressed(_ sender: Any) {
        accelerometerBMI160StartLog.isEnabled = true
        accelerometerBMI160StopLog.isEnabled = false
        accelerometerBMI160StartStream.isEnabled = true
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        device.accelerometer!.dataReadyEvent.downloadLogAndStopLoggingAsync(true) { number in
            hud.progress = number
        }.success { array in
            self.accelerometerBMI160Data = array as! [MBLAccelerometerData]
            for obj in self.accelerometerBMI160Data {
                self.accelerometerBMI160Graph.addX(obj.x, y: obj.y, z: obj.z)
            }
            hud.mode = .indeterminate
            hud.label.text = "Clearing Log..."
            self.logCleanup { error in
                hud.hide(animated: true)
                if error != nil {
                    self.connectDevice(false)
                }
            }
        }.failure { error in
            self.connectDevice(false)
            hud.hide(animated: true)
        }
    }
    
    @IBAction func accelerometerBMI160EmailDataPressed(_ sender: Any) {
        var accelerometerData = Data()
        for dataElement in accelerometerBMI160Data {
            accelerometerData.append("\(dataElement.timestamp.timeIntervalSince1970),\(dataElement.x),\(dataElement.y),\(dataElement.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(accelerometerData, title: "AccData")
    }
    
    @IBAction func accelerometerBMI160StartTapPressed(_ sender: Any) {
        accelerometerBMI160StartTap.isEnabled = false
        accelerometerBMI160StopTap.isEnabled = true
        updateAccelerometerBMI160Settings()
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.insert(accelerometerBMI160.tapEvent)
        accelerometerBMI160.tapEvent.startNotificationsAsync { (obj, error) in
            if obj != nil {
                self.accelerometerBMI160TapCount += 1
                self.accelerometerBMI160TapLabel.text = "Tap Count: \(self.accelerometerBMI160TapCount)"
            }
        }
    }
    
    @IBAction func accelerometerBMI160StopTapPressed(_ sender: Any) {
        accelerometerBMI160StartTap.isEnabled = true
        accelerometerBMI160StopTap.isEnabled = false
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.remove(accelerometerBMI160.tapEvent)
        accelerometerBMI160.tapEvent.stopNotificationsAsync()
        self.accelerometerBMI160TapCount = 0
        self.accelerometerBMI160TapLabel.text = "Tap Count: 0"
    }
    
    @IBAction func accelerometerBMI160StartFlatPressed(_ sender: Any) {
        accelerometerBMI160StartFlat.isEnabled = false
        accelerometerBMI160StopFlat.isEnabled = true
        updateAccelerometerBMI160Settings()
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.insert(accelerometerBMI160.flatEvent)
        accelerometerBMI160.flatEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.accelerometerBMI160FlatLabel.text = obj.isFlat ? "Flat" : "Not Flat"
            }
        }
    }
    
    @IBAction func accelerometerBMI160StopFlatPressed(_ sender: Any) {
        accelerometerBMI160StartFlat.isEnabled = true
        accelerometerBMI160StopFlat.isEnabled = false
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.remove(accelerometerBMI160.flatEvent)
        accelerometerBMI160.flatEvent.stopNotificationsAsync()
        accelerometerBMI160FlatLabel.text = "XXXXXXX"
    }
    
    @IBAction func accelerometerBMI160StartOrientPressed(_ sender: Any) {
        accelerometerBMI160StartOrient.isEnabled = false
        accelerometerBMI160StopOrient.isEnabled = true
        updateAccelerometerBMI160Settings()
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.insert(accelerometerBMI160.orientationEvent)
        accelerometerBMI160.orientationEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                switch obj.orientation {
                case .portrait:
                    self.accelerometerBMI160OrientLabel.text = "Portrait"
                case .portraitUpsideDown:
                    self.accelerometerBMI160OrientLabel.text = "PortraitUpsideDown"
                case .landscapeLeft:
                    self.accelerometerBMI160OrientLabel.text = "LandscapeLeft"
                case .landscapeRight:
                    self.accelerometerBMI160OrientLabel.text = "LandscapeRight"
                }
            }
        }
    }
    
    @IBAction func accelerometerBMI160StopOrientPressed(_ sender: Any) {
        accelerometerBMI160StartOrient.isEnabled = true
        accelerometerBMI160StopOrient.isEnabled = false
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.remove(accelerometerBMI160.orientationEvent)
        accelerometerBMI160.orientationEvent.stopNotificationsAsync()
        accelerometerBMI160OrientLabel.text = "XXXXXXXXXXXXXX"
    }
    
    @IBAction func accelerometerBMI160StartStepPressed(_ sender: Any) {
        accelerometerBMI160StartStep.isEnabled = false
        accelerometerBMI160StopStep.isEnabled = true
        updateAccelerometerBMI160Settings()
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.insert(accelerometerBMI160.stepEvent)
        accelerometerBMI160.stepEvent.startNotificationsAsync { (obj, error) in
            if obj != nil {
                self.accelerometerBMI160StepCount += 1
                self.accelerometerBMI160StepLabel.text = "Step Count: \(self.accelerometerBMI160StepCount)"
            }
        }
    }
    
    @IBAction func accelerometerBMI160StopStepPressed(_ sender: Any) {
        accelerometerBMI160StartStep.isEnabled = true
        accelerometerBMI160StopStep.isEnabled = false
        let accelerometerBMI160 = self.device.accelerometer as! MBLAccelerometerBMI160
        streamingEvents.remove(accelerometerBMI160.stepEvent)
        accelerometerBMI160.stepEvent.stopNotificationsAsync()
        accelerometerBMI160StepCount = 0
        accelerometerBMI160StepLabel.text = "Step Count: 0"
    }
    
    func updateAccelerometerBMA255Settings() {
        let accelerometerBMA255 = self.device.accelerometer as! MBLAccelerometerBMA255
        switch self.accelerometerBMA255Scale.selectedSegmentIndex {
        case 0:
            accelerometerBMA255.fullScaleRange = .range2G
            self.accelerometerBMA255Graph.fullScale = 2
        case 1:
            accelerometerBMA255.fullScaleRange = .range4G
            self.accelerometerBMA255Graph.fullScale = 4
        case 2:
            accelerometerBMA255.fullScaleRange = .range8G
            self.accelerometerBMA255Graph.fullScale = 8
        case 3:
            accelerometerBMA255.fullScaleRange = .range16G
            self.accelerometerBMA255Graph.fullScale = 16
        default:
            print("Unexpected accelerometerBMA255Scale value")
        }
        
        accelerometerBMA255.sampleFrequency = Double(accelerometerBMA255Frequency.titleForSegment(at: accelerometerBMA255Frequency.selectedSegmentIndex)!)!
        accelerometerBMA255.tapEvent.type = MBLAccelerometerTapType(rawValue: UInt8(tapDetectionType.selectedSegmentIndex))!
    }
    
    @IBAction func accelerometerBMA255StartStreamPressed(_ sender: Any) {
        accelerometerBMA255StartStream.isEnabled = false
        accelerometerBMA255StopStream.isEnabled = true
        accelerometerBMA255StartLog.isEnabled = false
        accelerometerBMA255StopLog.isEnabled = false
        updateAccelerometerBMA255Settings()
        accelerometerBMA255Data.removeAll()
        streamingEvents.insert(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.accelerometerBMA255Graph.addX(obj.x, y: obj.y, z: obj.z)
                self.accelerometerBMA255Data.append(obj)
            }
        }
    }
    
    @IBAction func accelerometerBMA255StopStreamPressed(_ sender: Any) {
        accelerometerBMA255StartStream.isEnabled = true
        accelerometerBMA255StopStream.isEnabled = false
        accelerometerBMA255StartLog.isEnabled = true
        streamingEvents.remove(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.stopNotificationsAsync()
    }
    
    @IBAction func accelerometerBMA255StartLogPressed(_ sender: Any) {
        accelerometerBMA255StartLog.isEnabled = false
        accelerometerBMA255StopLog.isEnabled = true
        accelerometerBMA255StartStream.isEnabled = false
        accelerometerBMA255StopStream.isEnabled = false
        updateAccelerometerBMA255Settings()
        device.accelerometer!.dataReadyEvent.startLoggingAsync()
    }
    
    @IBAction func accelerometerBMA255StopLogPressed(_ sender: Any) {
        accelerometerBMA255StartLog.isEnabled = true
        accelerometerBMA255StopLog.isEnabled = false
        accelerometerBMA255StartStream.isEnabled = true
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        device.accelerometer!.dataReadyEvent.downloadLogAndStopLoggingAsync(true) { number in
            hud.progress = number
        }.success { array in
            self.accelerometerBMA255Data = array as! [MBLAccelerometerData]
            for obj in self.accelerometerBMA255Data {
                self.accelerometerBMA255Graph.addX(obj.x, y: obj.y, z: obj.z)
            }
            hud.mode = .indeterminate
            hud.label.text = "Clearing Log..."
            self.logCleanup { error in
                hud.hide(animated: true)
                if error != nil {
                    self.connectDevice(false)
                }
            }
        }.failure { error in
            self.connectDevice(false)
            hud.hide(animated: true)
        }
    }
    
    @IBAction func accelerometerBMA255EmailDataPressed(_ sender: Any) {
        var accelerometerData = Data()
        for dataElement in accelerometerBMA255Data {
            accelerometerData.append("\(dataElement.timestamp.timeIntervalSince1970),\(dataElement.x),\(dataElement.y),\(dataElement.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(accelerometerData, title: "AccData")
    }
    
    @IBAction func accelerometerBMA255StartTapPressed(_ sender: Any) {
        accelerometerBMA255StartTap.isEnabled = false
        accelerometerBMA255StopTap.isEnabled = true
        updateAccelerometerBMA255Settings()
        let accelerometerBMA255 = device.accelerometer as! MBLAccelerometerBMA255
        streamingEvents.insert(accelerometerBMA255.tapEvent)
        accelerometerBMA255.tapEvent.startNotificationsAsync { (obj, error) in
            if obj != nil {
                self.accelerometerBMA255TapCount += 1
                self.accelerometerBMA255TapLabel.text = "Tap Count: \(self.accelerometerBMA255TapCount)"
            }
        }
    }
    
    @IBAction func accelerometerBMA255StopTapPressed(_ sender: Any) {
        accelerometerBMA255StartTap.isEnabled = true
        accelerometerBMA255StopTap.isEnabled = false
        let accelerometerBMA255 = device.accelerometer as! MBLAccelerometerBMA255
        streamingEvents.remove(accelerometerBMA255.tapEvent)
        accelerometerBMA255.tapEvent.stopNotificationsAsync()
        accelerometerBMA255TapCount = 0
        accelerometerBMA255TapLabel.text = "Tap Count: 0"
    }
    
    @IBAction func accelerometerBMA255StartFlatPressed(_ sender: Any) {
        accelerometerBMA255StartFlat.isEnabled = false
        accelerometerBMA255StopFlat.isEnabled = true
        updateAccelerometerBMA255Settings()
        let accelerometerBMA255 = device.accelerometer as! MBLAccelerometerBMA255
        streamingEvents.insert(accelerometerBMA255.flatEvent)
        accelerometerBMA255.flatEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.accelerometerBMA255FlatLabel.text = obj.isFlat ? "Flat" : "Not Flat"
            }
        }
    }
    
    @IBAction func accelerometerBMA255StopFlatPressed(_ sender: Any) {
        accelerometerBMA255StartFlat.isEnabled = true
        accelerometerBMA255StopFlat.isEnabled = false
        let accelerometerBMA255 = device.accelerometer as! MBLAccelerometerBMA255
        streamingEvents.remove(accelerometerBMA255.flatEvent)
        accelerometerBMA255.flatEvent.stopNotificationsAsync()
        accelerometerBMA255FlatLabel.text = "XXXXXXX"
    }
    
    @IBAction func accelerometerBMA255StartOrientPressed(_ sender: Any) {
        accelerometerBMA255StartOrient.isEnabled = false
        accelerometerBMA255StopOrient.isEnabled = true
        updateAccelerometerBMA255Settings()
        let accelerometerBMA255 = device.accelerometer as! MBLAccelerometerBMA255
        streamingEvents.insert(accelerometerBMA255.orientationEvent)
        accelerometerBMA255.orientationEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                switch obj.orientation {
                case .portrait:
                    self.accelerometerBMA255OrientLabel.text = "Portrait"
                case .portraitUpsideDown:
                    self.accelerometerBMA255OrientLabel.text = "PortraitUpsideDown"
                case .landscapeLeft:
                    self.accelerometerBMA255OrientLabel.text = "LandscapeLeft"
                case .landscapeRight:
                    self.accelerometerBMA255OrientLabel.text = "LandscapeRight"
                }
            }
        }
    }
    
    @IBAction func accelerometerBMA255StopOrientPressed(_ sender: Any) {
        accelerometerBMA255StartOrient.isEnabled = true
        accelerometerBMA255StopOrient.isEnabled = false
        let accelerometerBMA255 = device.accelerometer as! MBLAccelerometerBMA255
        streamingEvents.remove(accelerometerBMA255.orientationEvent)
        accelerometerBMA255.orientationEvent.stopNotificationsAsync()
        accelerometerBMA255OrientLabel.text = "XXXXXXXXXXXXXX"
    }
    
   
    func updateSensorFusionSettings() {
        
        // depending on which button toggled, vary the loggin setting, set the mode to index+1.
        device.sensorFusion!.mode = MBLSensorFusionMode(rawValue: UInt8(sensorFusionMode.selectedSegmentIndex) + 1)!
        
        
        // buttons, do not allow user to change how to collect data.
        sensorFusionMode.isEnabled = false
        sensorFusionOutput.isEnabled = false
        
        
        // initilize the data object.
        sensorFusionData = Data()
        
        
        // init the graph
        sensorFusionGraph.fullScale = 8
    }
    
    @IBAction func sensorFusionStartStreamPressed(_ sender: Any) {
        sensorFusionStartStream.isEnabled = false
        sensorFusionStopStream.isEnabled = true
        sensorFusionStartLog.isEnabled = false
        sensorFusionStopLog.isEnabled = false
        updateSensorFusionSettings()
        
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
        
        switch sensorFusionOutput.selectedSegmentIndex {
            
            // Euler
            
        case 0:
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.eulerAngle.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLEulerAngleData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.p, min: -180, max: 180), y: self.sensorFusionGraph.scale(obj.r, min: -90, max: 90), z: self.sensorFusionGraph.scale(obj.y, min: 0, max: 360), w: self.sensorFusionGraph.scale(obj.h, min: 0, max: 360))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.p),\(obj.r),\(obj.y),\(obj.h)\n".data(using: String.Encoding.utf8)!)
                }
            }
            
            // Quaternion
        case 1:
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.quaternion.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLQuaternionData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0), w: self.sensorFusionGraph.scale(obj.w, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
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
            // Linear Acceleration
        case 3:
            sensorFusionGraph.hasW = false
            task = device.sensorFusion!.linearAcceleration.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLAccelerometerData] {
                    self.sensorFusionGraph.addX(obj.x, y: obj.y, z: obj.z)
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
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
