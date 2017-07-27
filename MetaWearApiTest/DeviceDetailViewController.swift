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
    var drop0xPrefix:          String { return hasPrefix("0x") ? String(characters.dropFirst(2)) : self }
}

class DeviceDetailViewController: StaticDataTableViewController, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate, DFUPeripheralSelectorDelegate {
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
    var accelerometerDataArray = [MBLAccelerometerData]()
    
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
    var accelerometerBMI160Data = [MBLAccelerometerData]()
    
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
    var accelerometerBMA255Data = [MBLAccelerometerData]()
    
    @IBOutlet weak var gyroBMI160Cell: UITableViewCell!
    @IBOutlet weak var gyroBMI160Scale: UISegmentedControl!
    @IBOutlet weak var gyroBMI160Frequency: UISegmentedControl!
    @IBOutlet weak var gyroBMI160StartStream: UIButton!
    @IBOutlet weak var gyroBMI160StopStream: UIButton!
    @IBOutlet weak var gyroBMI160StartLog: UIButton!
    @IBOutlet weak var gyroBMI160StopLog: UIButton!
    @IBOutlet weak var gyroBMI160Graph: APLGraphView!
    var gyroBMI160Data = [MBLGyroData]()
    
    @IBOutlet weak var magnetometerBMM150Cell: UITableViewCell!
    @IBOutlet weak var magnetometerBMM150StartStream: UIButton!
    @IBOutlet weak var magnetometerBMM150StopStream: UIButton!
    @IBOutlet weak var magnetometerBMM150StartLog: UIButton!
    @IBOutlet weak var magnetometerBMM150StopLog: UIButton!
    @IBOutlet weak var magnetometerBMM150Graph: APLGraphView!
    var magnetometerBMM150Data = [MBLMagnetometerData]()
    
    @IBOutlet weak var gpioCell: UITableViewCell!
    @IBOutlet weak var gpioPinSelector: UISegmentedControl!
    @IBOutlet weak var gpioPinChangeType: UISegmentedControl!
    @IBOutlet weak var gpioStartPinChange: UIButton!
    @IBOutlet weak var gpioStopPinChange: UIButton!
    @IBOutlet weak var gpioPinChangeLabel: UILabel!
    var gpioPinChangeCount = 0
    @IBOutlet weak var gpioDigitalValue: UILabel!
    @IBOutlet weak var gpioAnalogAbsoluteButton: UIButton!
    @IBOutlet weak var gpioAnalogAbsoluteValue: UILabel!
    @IBOutlet weak var gpioAnalogRatioButton: UIButton!
    @IBOutlet weak var gpioAnalogRatioValue: UILabel!
    
    @IBOutlet weak var hapticCell: UITableViewCell!
    @IBOutlet weak var hapticPulseWidth: UITextField!
    @IBOutlet weak var hapticDutyCycle: UITextField!
    
    @IBOutlet weak var iBeaconCell: UITableViewCell!
    
    @IBOutlet weak var barometerBMP280Cell: UITableViewCell!
    @IBOutlet weak var barometerBMP280Oversampling: UISegmentedControl!
    @IBOutlet weak var barometerBMP280Averaging: UISegmentedControl!
    @IBOutlet weak var barometerBMP280Standby: UISegmentedControl!
    @IBOutlet weak var barometerBMP280StartStream: UIButton!
    @IBOutlet weak var barometerBMP280StopStream: UIButton!
    @IBOutlet weak var barometerBMP280Altitude: UILabel!
    
    @IBOutlet weak var barometerBME280Cell: UITableViewCell!
    @IBOutlet weak var barometerBME280Oversampling: UISegmentedControl!
    @IBOutlet weak var barometerBME280Averaging: UISegmentedControl!
    @IBOutlet weak var barometerBME280Standby: UISegmentedControl!
    @IBOutlet weak var barometerBME280StartStream: UIButton!
    @IBOutlet weak var barometerBME280StopStream: UIButton!
    @IBOutlet weak var barometerBME280Altitude: UILabel!
    
    @IBOutlet weak var ambientLightLTR329Cell: UITableViewCell!
    @IBOutlet weak var ambientLightLTR329Gain: UISegmentedControl!
    @IBOutlet weak var ambientLightLTR329Integration: UISegmentedControl!
    @IBOutlet weak var ambientLightLTR329Measurement: UISegmentedControl!
    @IBOutlet weak var ambientLightLTR329StartStream: UIButton!
    @IBOutlet weak var ambientLightLTR329StopStream: UIButton!
    @IBOutlet weak var ambientLightLTR329Illuminance: UILabel!
    
    @IBOutlet weak var proximityTSL2671Cell: UITableViewCell!
    @IBOutlet weak var proximityTSL2671Drive: UISegmentedControl!
    @IBOutlet weak var proximityTSL2671IntegrationLabel: UILabel!
    @IBOutlet weak var proximityTSL2671IntegrationSlider: UISlider!
    @IBOutlet weak var proximityTSL2671PulseLabel: UILabel!
    @IBOutlet weak var proximityTSL2671PulseStepper: UIStepper!
    @IBOutlet weak var proximityTSL2671StartStream: UIButton!
    @IBOutlet weak var proximityTSL2671StopStream: UIButton!
    @IBOutlet weak var proximityTSL2671Proximity: UILabel!
    var proximityTSL2671Event: MBLEvent<MBLNumericData>!
    
    @IBOutlet weak var photometerTCS3472Cell: UITableViewCell!
    @IBOutlet weak var photometerTCS3472Gain: UISegmentedControl!
    @IBOutlet weak var photometerTCS3472IntegrationLabel: UILabel!
    @IBOutlet weak var photometerTCS3472IntegrationSlider: UISlider!
    @IBOutlet weak var photometerTCS3472LedFlashSwitch: UISwitch!
    @IBOutlet weak var photometerTCS3472StartStream: UIButton!
    @IBOutlet weak var photometerTCS3472StopStream: UIButton!
    @IBOutlet weak var photometerTCS3472RedColor: UILabel!
    @IBOutlet weak var photometerTCS3472GreenColor: UILabel!
    @IBOutlet weak var photometerTCS3472BlueColor: UILabel!
    @IBOutlet weak var photometerTCS3472ClearColor: UILabel!
    var photometerTCS3472Event: MBLEvent<MBLRGBData>!
    
    @IBOutlet weak var hygrometerBME280Cell: UITableViewCell!
    @IBOutlet weak var hygrometerBME280Oversample: UISegmentedControl!
    @IBOutlet weak var hygrometerBME280StartStream: UIButton!
    @IBOutlet weak var hygrometerBME280StopStream: UIButton!
    @IBOutlet weak var hygrometerBME280Humidity: UILabel!
    var hygrometerBME280Event: MBLEvent<MBLNumericData>!
    
    @IBOutlet weak var i2cCell: UITableViewCell!
    @IBOutlet weak var i2cSizeSelector: UISegmentedControl!
    @IBOutlet weak var i2cDeviceAddress: UITextField!
    @IBOutlet weak var i2cRegisterAddress: UITextField!
    @IBOutlet weak var i2cReadByteLabel: UILabel!
    @IBOutlet weak var i2cWriteByteField: UITextField!
    
    @IBOutlet weak var conductanceCell: UITableViewCell!
    @IBOutlet weak var conductanceGain: UISegmentedControl!
    @IBOutlet weak var conductanceVoltage: UISegmentedControl!
    @IBOutlet weak var conductanceRange: UISegmentedControl!
    @IBOutlet weak var conductanceChannelStepper: UIStepper!
    @IBOutlet weak var conductanceChannelLabel: UILabel!
    @IBOutlet weak var conductanceStartStream: UIButton!
    @IBOutlet weak var conductanceStopStream: UIButton!
    @IBOutlet weak var conductanceLabel: UILabel!
    var conductanceEvent: MBLEvent<MBLNumericData>!
    
    @IBOutlet weak var neopixelCell: UITableViewCell!
    @IBOutlet weak var neopixelColor: UISegmentedControl!
    @IBOutlet weak var neopixelSpeed: UISegmentedControl!
    @IBOutlet weak var neopixelPin: UISegmentedControl!
    @IBOutlet weak var neopixelLengthStepper: UIStepper!
    @IBOutlet weak var neopixelLengthLabel: UILabel!
    @IBOutlet weak var neopixelSetRed: UIButton!
    @IBOutlet weak var neopixelSetGreen: UIButton!
    @IBOutlet weak var neopixelSetBlue: UIButton!
    @IBOutlet weak var neopixelSetRainbow: UIButton!
    @IBOutlet weak var neopixelRotateRight: UIButton!
    @IBOutlet weak var neopixelRotateLeft: UIButton!
    @IBOutlet weak var neopixelTurnOff: UIButton!
    var neopixelStrand: MBLNeopixelStrand!
    var neopixelStrandInitTask: BFTask<AnyObject>!
    
    @IBOutlet weak var sensorFusionCell: UITableViewCell!
    @IBOutlet weak var sensorFusionMode: UISegmentedControl!
    @IBOutlet weak var sensorFusionOutput: UISegmentedControl!
    @IBOutlet weak var sensorFusionStartStream: UIButton!
    @IBOutlet weak var sensorFusionStopStream: UIButton!
    @IBOutlet weak var sensorFusionStartLog: UIButton!
    @IBOutlet weak var sensorFusionStopLog: UIButton!
    @IBOutlet weak var sensorFusionGraph: APLGraphView!
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
        nameTextField.text = self.device.name
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
        if let mac = device.settings?.macAddress {
            mac.readAsync().success { result in
                print("ID: \(self.device.identifier.uuidString) MAC: \(result.value)")
            }
        } else {
            print("ID: \(device.identifier.uuidString)")
        }
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
        device.checkForFirmwareUpdateAsync().success { result in
            self.firmwareUpdateLabel.text = result.boolValue ? "AVAILABLE!" : "Up To Date"
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
        
        if device.gyro is MBLGyroBMI160 {
            cell(gyroBMI160Cell, setHidden: false)
            if device.gyro!.dataReadyEvent.isLogging() {
                gyroBMI160StartLog.isEnabled = false
                gyroBMI160StopLog.isEnabled = true
                gyroBMI160StartStream.isEnabled = false
                gyroBMI160StopStream.isEnabled = false
            }
            else {
                gyroBMI160StartLog.isEnabled = true
                gyroBMI160StopLog.isEnabled = false
                gyroBMI160StartStream.isEnabled = true
                gyroBMI160StopStream.isEnabled = false
            }
        }
        
        if let magnetometerBMM150 = device.magnetometer as? MBLMagnetometerBMM150 {
            cell(magnetometerBMM150Cell, setHidden: false)
            if magnetometerBMM150.periodicMagneticField.isLogging() {
                magnetometerBMM150StartLog.isEnabled = false
                magnetometerBMM150StopLog.isEnabled = true
                magnetometerBMM150StartStream.isEnabled = false
                magnetometerBMM150StopStream.isEnabled = false
            }
            else {
                magnetometerBMM150StartLog.isEnabled = true
                magnetometerBMM150StopLog.isEnabled = false
                magnetometerBMM150StartStream.isEnabled = true
                magnetometerBMM150StopStream.isEnabled = false
            }
        }
        
        if device.gpio != nil {
            if device.gpio!.pins.count > 0 {
                cell(gpioCell, setHidden: false)
                // The number of pins is variable
                gpioPinSelector.removeAllSegments()
                for i in 0..<device.gpio!.pins.count {
                    gpioPinSelector.insertSegment(withTitle: "\(i)", at: i, animated: false)
                }
                gpioPinSelector.selectedSegmentIndex = 0
            }
        }
        
        if device.hapticBuzzer != nil {
            cell(hapticCell, setHidden: false)
        }
        
        if device.iBeacon != nil {
            cell(iBeaconCell, setHidden: false)
        }
        
        if device.barometer is MBLBarometerBMP280 {
            cell(barometerBMP280Cell, setHidden: false)
        } else if device.barometer is MBLBarometerBME280 {
            cell(barometerBME280Cell, setHidden: false)
        }
        
        if device.ambientLight is MBLAmbientLightLTR329 {
            cell(ambientLightLTR329Cell, setHidden: false)
        }
        
        if device.proximity is MBLProximityTSL2671 {
            cell(proximityTSL2671Cell, setHidden: false)
        }
        
        if device.photometer is MBLPhotometerTCS3472 {
            cell(photometerTCS3472Cell, setHidden: false)
        }
        
        if device.hygrometer is MBLHygrometerBME280 {
            cell(hygrometerBME280Cell, setHidden: false)
        }
        
        if device.serial != nil {
            cell(i2cCell, setHidden: false)
        }
        
        if device.conductance != nil {
            conductanceChannelStepper.maximumValue = Double(device.conductance!.channels.count - 1)
            cell(conductanceCell, setHidden: false)
        }
        
        if device.neopixel != nil {
            cell(neopixelCell, setHidden: false)
            // The number of pins is variable
            neopixelPin.removeAllSegments()
            for i in 0..<device.gpio!.pins.count {
                neopixelPin.insertSegment(withTitle: "\(i)", at: i, animated: false)
            }
            neopixelPin.selectedSegmentIndex = 0
            gpioPinSelectorPressed(self.gpioPinSelector)
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
        if range.length + range.location > textField.text!.characters.count {
            return false
        }
        // Make sure it's no longer than 8 characters
        let newLength = textField.text!.characters.count + string.characters.count - range.length
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
        device.checkForFirmwareUpdateAsync().success { result in
            self.firmwareUpdateLabel.text = result.boolValue ? "AVAILABLE!" : "Up To Date"
        }.failure { error in
            self.showAlertTitle("Error", message: error.localizedDescription)
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
    
    func updateAccelerometerSettings() {
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
    
    @IBAction func startAccelerationPressed(_ sender: Any) {
        startAccelerometer.isEnabled = false
        stopAccelerometer.isEnabled = true
        startLog.isEnabled = false
        stopLog.isEnabled = false
        updateAccelerometerSettings()
        // These variables are used for data recording
        var array = [MBLAccelerometerData]() /* capacity: 1000 */
        accelerometerDataArray = array
        streamingEvents.insert(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.startNotificationsAsync { (acceleration, error) in
            if let acceleration = acceleration {
                self.accelerometerGraph.addX(acceleration.x, y: acceleration.y, z: acceleration.z)
                // Add data to data array for saving
                array.append(acceleration)
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
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        device.accelerometer!.dataReadyEvent.downloadLogAndStopLoggingAsync(true) { number in
            hud.progress = number
        }.success { array in
            self.accelerometerDataArray = array as! [MBLAccelerometerData]
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
        for dataElement in accelerometerDataArray {
            accelerometerData.append("\(dataElement.timestamp.timeIntervalSince1970),\(dataElement.x),\(dataElement.y),\(dataElement.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(accelerometerData, title: "AccData")
    }
    
    func send(_ data: Data, title: String) {
        // Get current Time/Date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM_dd_yyyy-HH_mm_ss"
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
    }
    
    @IBAction func accelerometerBMI160StartStreamPressed(_ sender: Any) {
        accelerometerBMI160StartStream.isEnabled = false
        accelerometerBMI160StopStream.isEnabled = true
        accelerometerBMI160StartLog.isEnabled = false
        accelerometerBMI160StopLog.isEnabled = false
        updateAccelerometerBMI160Settings()
        var array = [MBLAccelerometerData]() /* capacity: 1000 */
        accelerometerBMI160Data = array
        streamingEvents.insert(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.accelerometerBMI160Graph.addX(obj.x, y: obj.y, z: obj.z)
                array.append(obj)
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
        var array = [MBLAccelerometerData]() /* capacity: 1000 */
        accelerometerBMA255Data = array
        streamingEvents.insert(device.accelerometer!.dataReadyEvent)
        device.accelerometer!.dataReadyEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.accelerometerBMA255Graph.addX(obj.x, y: obj.y, z: obj.z)
                array.append(obj)
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
    
    func updateGyroBMI160Settings() {
        let gyroBMI160 = self.device.gyro as! MBLGyroBMI160
        switch self.gyroBMI160Scale.selectedSegmentIndex {
        case 0:
            gyroBMI160.fullScaleRange = .range125
            self.gyroBMI160Graph.fullScale = 1
        case 1:
            gyroBMI160.fullScaleRange = .range250
            self.gyroBMI160Graph.fullScale = 2
        case 2:
            gyroBMI160.fullScaleRange = .range500
            self.gyroBMI160Graph.fullScale = 4
        case 3:
            gyroBMI160.fullScaleRange = .range1000
            self.gyroBMI160Graph.fullScale = 8
        case 4:
            gyroBMI160.fullScaleRange = .range2000
            self.gyroBMI160Graph.fullScale = 16
        default:
            print("Unexpected gyroBMI160Scale value")
        }
        
        gyroBMI160.sampleFrequency = Double(self.gyroBMI160Frequency.titleForSegment(at: self.gyroBMI160Frequency.selectedSegmentIndex)!)!
    }
    
    @IBAction func gyroBMI160StartStreamPressed(_ sender: Any) {
        gyroBMI160StartStream.isEnabled = false
        gyroBMI160StopStream.isEnabled = true
        gyroBMI160StartLog.isEnabled = false
        gyroBMI160StopLog.isEnabled = false
        updateGyroBMI160Settings()
        var array = [MBLGyroData]() /* capacity: 1000 */
        gyroBMI160Data = array
        streamingEvents.insert(device.gyro!.dataReadyEvent)
        device.gyro!.dataReadyEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                // TODO: Come up with a better graph interface, we need to scale value
                // to show up right
                self.gyroBMI160Graph.addX(obj.x * 0.008, y: obj.y * 0.008, z: obj.z * 0.008)
                array.append(obj)
            }
        }
    }
    
    @IBAction func gyroBMI160StopStreamPressed(_ sender: Any) {
        gyroBMI160StartStream.isEnabled = true
        gyroBMI160StopStream.isEnabled = false
        gyroBMI160StartLog.isEnabled = true
        streamingEvents.remove(device.gyro!.dataReadyEvent)
        device.gyro!.dataReadyEvent.stopNotificationsAsync()
    }
    
    @IBAction func gyroBMI160StartLogPressed(_ sender: Any) {
        gyroBMI160StartLog.isEnabled = false
        gyroBMI160StopLog.isEnabled = true
        gyroBMI160StartStream.isEnabled = false
        gyroBMI160StopStream.isEnabled = false
        updateGyroBMI160Settings()
        device.gyro!.dataReadyEvent.startLoggingAsync()
    }
    
    @IBAction func gyroBMI160StopLogPressed(_ sender: Any) {
        gyroBMI160StartLog.isEnabled = true
        gyroBMI160StopLog.isEnabled = false
        gyroBMI160StartStream.isEnabled = true
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        device.gyro!.dataReadyEvent.downloadLogAndStopLoggingAsync(true) { number in
            hud.progress = number
        }.success { array in
            self.gyroBMI160Data = array as! [MBLGyroData]
            for obj in self.gyroBMI160Data {
                self.gyroBMI160Graph.addX(obj.x * 0.008, y: obj.y * 0.008, z: obj.z * 0.008)
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
    
    @IBAction func gyroBMI160EmailDataPressed(_ sender: Any) {
        var gyroData = Data()
        for dataElement in self.gyroBMI160Data {
            gyroData.append("\(dataElement.timestamp.timeIntervalSince1970),\(dataElement.x),\(dataElement.y),\(dataElement.z)\n".data(using: String.Encoding.utf8)!)
        }
        self.send(gyroData, title: "GyroData")
    }
    
    @IBAction func magnetometerBMM150StartStreamPressed(_ sender: Any) {
        magnetometerBMM150StartStream.isEnabled = false
        magnetometerBMM150StopStream.isEnabled = true
        magnetometerBMM150StartLog.isEnabled = false
        magnetometerBMM150StopLog.isEnabled = false
        var array = [MBLMagnetometerData]() /* capacity: 1000 */
        magnetometerBMM150Data = array
        magnetometerBMM150Graph.fullScale = 4
        let magnetometerBMM150 = device.magnetometer as! MBLMagnetometerBMM150
        streamingEvents.insert(magnetometerBMM150.periodicMagneticField)
        magnetometerBMM150.periodicMagneticField.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                // TODO: Come up with a better graph interface, we need to scale value
                // to show up right
                self.magnetometerBMM150Graph.addX(obj.x * 20000.0, y: obj.y * 20000.0, z: obj.z * 20000.0)
                array.append(obj)
            }
        }
    }
    
    @IBAction func magnetometerBMM150StopStreamPressed(_ sender: Any) {
        magnetometerBMM150StartStream.isEnabled = true
        magnetometerBMM150StopStream.isEnabled = false
        magnetometerBMM150StartLog.isEnabled = true
        let magnetometerBMM150 = device.magnetometer as! MBLMagnetometerBMM150
        streamingEvents.remove(magnetometerBMM150.periodicMagneticField)
        magnetometerBMM150.periodicMagneticField.stopNotificationsAsync()
    }
    
    @IBAction func magnetometerBMM150StartLogPressed(_ sender: Any) {
        magnetometerBMM150StartLog.isEnabled = false
        magnetometerBMM150StopLog.isEnabled = true
        magnetometerBMM150StartStream.isEnabled = false
        magnetometerBMM150StopStream.isEnabled = false
        magnetometerBMM150Graph.fullScale = 4
        let magnetometerBMM150 = device.magnetometer as! MBLMagnetometerBMM150
        magnetometerBMM150.periodicMagneticField.startLoggingAsync()
    }
    
    @IBAction func magnetometerBMM150StopLogPressed(_ sender: Any) {
        magnetometerBMM150StartLog.isEnabled = true
        magnetometerBMM150StopLog.isEnabled = false
        magnetometerBMM150StartStream.isEnabled = true
        let hud = MBProgressHUD.showAdded(to: UIApplication.shared.keyWindow!, animated: true)
        hud.mode = .determinateHorizontalBar
        hud.label.text = "Downloading..."
        let magnetometerBMM150 = self.device.magnetometer as! MBLMagnetometerBMM150
        magnetometerBMM150.periodicMagneticField.downloadLogAndStopLoggingAsync(true) { number in
            hud.progress = number
        }.success { array in
            self.magnetometerBMM150Data = array as! [MBLMagnetometerData]
            for obj in self.magnetometerBMM150Data {
                self.magnetometerBMM150Graph.addX(obj.x * 20000.0, y: obj.y * 20000.0, z: obj.z * 20000.0)
            }
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
    
    @IBAction func magnetometerBMM150SendDataPressed(_ sender: Any) {
        var magnetometerData = Data()
        for dataElement in magnetometerBMM150Data {
            magnetometerData.append("\(dataElement.timestamp.timeIntervalSince1970),\(dataElement.x),\(dataElement.y),\(dataElement.z)\n".data(using: String.Encoding.utf8)!)
        }
        send(magnetometerData, title: "MagnetometerData")
    }
    
    @IBAction func gpioPinSelectorPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        if pin.analogAbsolute != nil {
            self.gpioAnalogAbsoluteButton.isHidden = false
            self.gpioAnalogAbsoluteValue.isHidden = false
        } else {
            self.gpioAnalogAbsoluteButton.isHidden = true
            self.gpioAnalogAbsoluteValue.isHidden = true
        }
        if pin.analogRatio != nil {
            self.gpioAnalogRatioButton.isHidden = false
            self.gpioAnalogRatioValue.isHidden = false
        } else {
            self.gpioAnalogRatioButton.isHidden = true
            self.gpioAnalogRatioValue.isHidden = true
        }
    }
    
    @IBAction func setPullUpPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.setConfiguration(.pullup)
    }
    
    @IBAction func setPullDownPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.setConfiguration(.pulldown)
    }
    
    @IBAction func setNoPullPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.setConfiguration(.nopull)
    }
    
    @IBAction func setPinPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.setToDigitalValueAsync(true)
    }
    
    @IBAction func clearPinPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.setToDigitalValueAsync(false)
    }
    
    @IBAction func gpioStartPinChangePressed(_ sender: Any) {
        gpioStartPinChange.isEnabled = false
        gpioStopPinChange.isEnabled = true
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        if gpioPinChangeType.selectedSegmentIndex == 0 {
            pin.changeType = .rising
        } else if gpioPinChangeType.selectedSegmentIndex == 1 {
            pin.changeType = .falling
        } else {
            pin.changeType = .any
        }
        
        streamingEvents.insert(pin.changeEvent!)
        pin.changeEvent?.startNotificationsAsync { (obj, error) in
            if obj != nil {
                self.gpioPinChangeCount += 1
                self.gpioPinChangeLabel.text = "Change Count: \(self.gpioPinChangeCount)"
            }
        }
    }
    
    @IBAction func gpioStopPinChangePressed(_ sender: Any) {
        gpioStartPinChange.isEnabled = true
        gpioStopPinChange.isEnabled = false
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        streamingEvents.remove(pin.changeEvent!)
        pin.changeEvent!.stopNotificationsAsync()
        gpioPinChangeCount = 0
        gpioPinChangeLabel.text = "Change Count: 0"
    }
    
    @IBAction func readDigitalPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.digitalValue!.readAsync().success { result in
            self.gpioDigitalValue.text = result.value.boolValue ? "1" : "0"
        }
    }
    
    @IBAction func readAnalogAbsolutePressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.analogAbsolute!.readAsync().success { result in
            self.gpioAnalogAbsoluteValue.text = String(format: "%.3fV", result.value.doubleValue)
        }
    }
    
    @IBAction func readAnalogRatioPressed(_ sender: Any) {
        let pin = device.gpio!.pins[gpioPinSelector.selectedSegmentIndex]
        pin.analogRatio!.readAsync().success { result in
            self.gpioAnalogRatioValue.text = String(format: "%.3f", result.value.doubleValue)
        }
    }
    
    @IBAction func startHapticDriverPressed(_ sender: UIButton) {
        var dcycle = UInt8(hapticDutyCycle.text!) ?? 248
        dcycle = min(dcycle, 248)
        dcycle = max(dcycle, 0)
        hapticDutyCycle.text = String(dcycle)
        
        var pwidth = UInt16(hapticPulseWidth.text!) ?? 500
        pwidth = min(pwidth, 10000)
        pwidth = max(pwidth, 0)
        hapticPulseWidth.text = String(pwidth)
        
        sender.isEnabled = false
        device.hapticBuzzer!.startHapticAsync(dutyCycle: dcycle, pulseWidth: pwidth) {
            sender.isEnabled = true
        }
    }
    
    @IBAction func startBuzzerDriverPressed(_ sender: UIButton) {
        var pwidth = UInt16(hapticPulseWidth.text!) ?? 500
        pwidth = min(pwidth, 10000)
        pwidth = max(pwidth, 0)
        hapticPulseWidth.text = String(pwidth)

        sender.isEnabled = false
        device.hapticBuzzer?.startBuzzerAsync(pulseWidth: pwidth) {
            sender.isEnabled = true
        }
    }
    
    @IBAction func startiBeaconPressed(_ sender: Any) {
        // TODO: Expose the other iBeacon parameters
        device.iBeacon?.setBeaconOnAsync(true)
    }
    
    @IBAction func stopiBeaconPressed(_ sender: Any) {
        device.iBeacon?.setBeaconOnAsync(false)
    }
    
    @IBAction func barometerBMP280StartStreamPressed(_ sender: Any) {
        barometerBMP280StartStream.isEnabled = false
        barometerBMP280StopStream.isEnabled = true
        let barometerBMP280 = device.barometer as! MBLBarometerBMP280
        if barometerBMP280Oversampling.selectedSegmentIndex == 0 {
            barometerBMP280.pressureOversampling = .ultraLowPower
        } else if barometerBMP280Oversampling.selectedSegmentIndex == 1 {
            barometerBMP280.pressureOversampling = .lowPower
        } else if barometerBMP280Oversampling.selectedSegmentIndex == 2 {
            barometerBMP280.pressureOversampling = .standard
        } else if barometerBMP280Oversampling.selectedSegmentIndex == 3 {
            barometerBMP280.pressureOversampling = .highResolution
        } else {
            barometerBMP280.pressureOversampling = .ultraHighResolution
        }
        
        if barometerBMP280Averaging.selectedSegmentIndex == 0 {
            barometerBMP280.hardwareAverageFilter = .off
        } else if barometerBMP280Averaging.selectedSegmentIndex == 1 {
            barometerBMP280.hardwareAverageFilter = .average2
        } else if barometerBMP280Averaging.selectedSegmentIndex == 2 {
            barometerBMP280.hardwareAverageFilter = .average4
        } else if barometerBMP280Averaging.selectedSegmentIndex == 3 {
            barometerBMP280.hardwareAverageFilter = .average8
        } else {
            barometerBMP280.hardwareAverageFilter = .average16
        }
        
        if barometerBMP280Standby.selectedSegmentIndex == 0 {
            barometerBMP280.standbyTime = .standby0_5
        } else if barometerBMP280Standby.selectedSegmentIndex == 1 {
            barometerBMP280.standbyTime = .standby62_5
        } else if barometerBMP280Standby.selectedSegmentIndex == 2 {
            barometerBMP280.standbyTime = .standby125
        } else if barometerBMP280Standby.selectedSegmentIndex == 3 {
            barometerBMP280.standbyTime = .standby250
        } else if barometerBMP280Standby.selectedSegmentIndex == 4 {
            barometerBMP280.standbyTime = .standby500
        } else if barometerBMP280Standby.selectedSegmentIndex == 5 {
            barometerBMP280.standbyTime = .standby1000
        } else if barometerBMP280Standby.selectedSegmentIndex == 6 {
            barometerBMP280.standbyTime = .standby2000
        } else {
            barometerBMP280.standbyTime = .standby4000
        }
        
        streamingEvents.insert(barometerBMP280.periodicAltitude)
        barometerBMP280.periodicAltitude.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.barometerBMP280Altitude.text = String(format: "%.3f", obj.value.doubleValue)
            }
        }
    }
    
    @IBAction func barometerBMP280StopStreamPressed(_ sender: Any) {
        barometerBMP280StartStream.isEnabled = true
        barometerBMP280StopStream.isEnabled = false
        let barometerBMP280 = device.barometer as! MBLBarometerBMP280
        streamingEvents.remove(barometerBMP280.periodicAltitude)
        barometerBMP280.periodicAltitude.stopNotificationsAsync()
        barometerBMP280Altitude.text = "X.XXX"
    }
    
    @IBAction func barometerBME280StartStreamPressed(_ sender: Any) {
        barometerBME280StartStream.isEnabled = false
        barometerBME280StopStream.isEnabled = true
        let barometerBME280 = device.barometer as! MBLBarometerBME280
        if barometerBMP280Oversampling.selectedSegmentIndex == 0 {
            barometerBME280.pressureOversampling = .ultraLowPower
        } else if barometerBME280Oversampling.selectedSegmentIndex == 1 {
            barometerBME280.pressureOversampling = .lowPower
        } else if barometerBME280Oversampling.selectedSegmentIndex == 2 {
            barometerBME280.pressureOversampling = .standard
        } else if barometerBME280Oversampling.selectedSegmentIndex == 3 {
            barometerBME280.pressureOversampling = .highResolution
        } else {
            barometerBME280.pressureOversampling = .ultraHighResolution
        }
        
        if barometerBME280Averaging.selectedSegmentIndex == 0 {
            barometerBME280.hardwareAverageFilter = .off
        } else if barometerBME280Averaging.selectedSegmentIndex == 1 {
            barometerBME280.hardwareAverageFilter = .average2
        } else if barometerBME280Averaging.selectedSegmentIndex == 2 {
            barometerBME280.hardwareAverageFilter = .average4
        } else if barometerBME280Averaging.selectedSegmentIndex == 3 {
            barometerBME280.hardwareAverageFilter = .average8
        } else {
            barometerBME280.hardwareAverageFilter = .average16
        }
        
        if barometerBME280Standby.selectedSegmentIndex == 0 {
            barometerBME280.standbyTime = .standby0_5
        } else if barometerBME280Standby.selectedSegmentIndex == 1 {
            barometerBME280.standbyTime = .standby10
        } else if barometerBME280Standby.selectedSegmentIndex == 2 {
            barometerBME280.standbyTime = .standby20
        } else if barometerBME280Standby.selectedSegmentIndex == 3 {
            barometerBME280.standbyTime = .standby62_5
        } else if barometerBME280Standby.selectedSegmentIndex == 4 {
            barometerBME280.standbyTime = .standby125
        } else if barometerBME280Standby.selectedSegmentIndex == 5 {
            barometerBME280.standbyTime = .standby250
        } else if barometerBME280Standby.selectedSegmentIndex == 6 {
            barometerBME280.standbyTime = .standby500
        } else {
            barometerBME280.standbyTime = .standby1000
        }
        
        streamingEvents.insert(barometerBME280.periodicAltitude)
        barometerBME280.periodicAltitude.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.barometerBME280Altitude.text = String(format: "%.3f", obj.value.doubleValue)
            }
        }
    }
    
    @IBAction func barometerBME280StopStreamPressed(_ sender: Any) {
        barometerBME280StartStream.isEnabled = true
        barometerBME280StopStream.isEnabled = false
        let barometerBME280 = device.barometer as! MBLBarometerBME280
        streamingEvents.remove(barometerBME280.periodicAltitude)
        barometerBME280.periodicAltitude.stopNotificationsAsync()
        barometerBME280Altitude.text = "X.XXX"
    }
    
    @IBAction func ambientLightLTR329StartStreamPressed(_ sender: Any) {
        ambientLightLTR329StartStream.isEnabled = false
        ambientLightLTR329StopStream.isEnabled = true
        let ambientLightLTR329 = device.ambientLight as! MBLAmbientLightLTR329
        switch ambientLightLTR329Gain.selectedSegmentIndex {
        case 0:
            ambientLightLTR329.gain = .gain1X
        case 1:
            ambientLightLTR329.gain = .gain2X
        case 2:
            ambientLightLTR329.gain = .gain4X
        case 3:
            ambientLightLTR329.gain = .gain8X
        case 4:
            ambientLightLTR329.gain = .gain48X
        default:
            ambientLightLTR329.gain = .gain96X
        }
        
        switch ambientLightLTR329Integration.selectedSegmentIndex {
        case 0:
            ambientLightLTR329.integrationTime = .integration50ms
        case 1:
            ambientLightLTR329.integrationTime = .integration100ms
        case 2:
            ambientLightLTR329.integrationTime = .integration150ms
        case 3:
            ambientLightLTR329.integrationTime = .integration200ms
        case 4:
            ambientLightLTR329.integrationTime = .integration250ms
        case 5:
            ambientLightLTR329.integrationTime = .integration300ms
        case 6:
            ambientLightLTR329.integrationTime = .integration350ms
        default:
            ambientLightLTR329.integrationTime = .integration400ms
        }
        
        switch ambientLightLTR329Measurement.selectedSegmentIndex {
        case 0:
            ambientLightLTR329.measurementRate = .rate50ms
        case 1:
            ambientLightLTR329.measurementRate = .rate100ms
        case 2:
            ambientLightLTR329.measurementRate = .rate200ms
        case 3:
            ambientLightLTR329.measurementRate = .rate500ms
        case 4:
            ambientLightLTR329.measurementRate = .rate1000ms
        default:
            ambientLightLTR329.measurementRate = .rate2000ms
        }
        
        streamingEvents.insert(ambientLightLTR329.periodicIlluminance)
        ambientLightLTR329.periodicIlluminance.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.ambientLightLTR329Illuminance.text = String(format: "%.3f", obj.value.doubleValue)
            }
        }
    }
    
    @IBAction func ambientLightLTR329StopStreamPressed(_ sender: Any) {
        ambientLightLTR329StartStream.isEnabled = true
        ambientLightLTR329StopStream.isEnabled = false
        let ambientLightLTR329 = device.ambientLight as! MBLAmbientLightLTR329
        streamingEvents.remove(ambientLightLTR329.periodicIlluminance)
        ambientLightLTR329.periodicIlluminance.stopNotificationsAsync()
        ambientLightLTR329Illuminance.text = "X.XXX"
    }
    
    @IBAction func proximityTSL2671IntegrationSliderChanged(_ sender: Any) {
        proximityTSL2671IntegrationLabel.text = String(format: "%.2f", proximityTSL2671IntegrationSlider.value)
    }
    
    @IBAction func proximityTSL2671PulseStepperChanged(_ sender: Any) {
        proximityTSL2671PulseLabel.text = "\(Int(round(proximityTSL2671PulseStepper.value)))"
    }
    
    @IBAction func proximityTSL2671StartStreamPressed(_ sender: Any) {
        proximityTSL2671StartStream.isEnabled = false
        proximityTSL2671StopStream.isEnabled = true
        proximityTSL2671Drive.isEnabled = false
        proximityTSL2671IntegrationSlider.isEnabled = false
        proximityTSL2671PulseStepper.isEnabled = false
        let proximityTSL2671 = device.proximity as! MBLProximityTSL2671
        switch proximityTSL2671Drive.selectedSegmentIndex {
        case 0:
            proximityTSL2671.drive = .drive12_5mA
        default:
            proximityTSL2671.drive = .drive25mA
        }
        
        proximityTSL2671.integrationTime = Double(proximityTSL2671IntegrationSlider.value)
        proximityTSL2671.proximityPulses = UInt8(round(proximityTSL2671PulseStepper.value))
        proximityTSL2671Event = proximityTSL2671.proximity!.periodicRead(withPeriod: 700)
        streamingEvents.insert(proximityTSL2671Event)
        proximityTSL2671Event.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.proximityTSL2671Proximity.text = obj.value.stringValue
            }
        }
    }
    
    @IBAction func proximityTSL2671StopStreamPressed(_ sender: Any) {
        proximityTSL2671StartStream.isEnabled = true
        proximityTSL2671StopStream.isEnabled = false
        proximityTSL2671Drive.isEnabled = true
        proximityTSL2671IntegrationSlider.isEnabled = true
        proximityTSL2671PulseStepper.isEnabled = true
        streamingEvents.remove(proximityTSL2671Event)
        proximityTSL2671Event.stopNotificationsAsync()
        proximityTSL2671Proximity.text = "XXXX"
    }
    
    @IBAction func photometerTCS3472IntegrationSliderChanged(_ sender: Any) {
        photometerTCS3472IntegrationLabel.text = String(format: "%.1f", photometerTCS3472IntegrationSlider.value)
    }
    
    @IBAction func photometerTCS3472StartStreamPressed(_ sender: Any) {
        photometerTCS3472StartStream.isEnabled = false
        photometerTCS3472StopStream.isEnabled = true
        photometerTCS3472Gain.isEnabled = false
        photometerTCS3472IntegrationSlider.isEnabled = false
        photometerTCS3472LedFlashSwitch.isEnabled = false
        let photometerTCS3472 = device.photometer as! MBLPhotometerTCS3472
        switch photometerTCS3472Gain.selectedSegmentIndex {
        case 0:
            photometerTCS3472.gain = .gain1X
        case 1:
            photometerTCS3472.gain = .gain4X
        case 2:
            photometerTCS3472.gain = .gain16X
        default:
            photometerTCS3472.gain = .gain60X
        }
        
        photometerTCS3472.integrationTime = Double(photometerTCS3472IntegrationSlider.value)
        photometerTCS3472.ledFlash = photometerTCS3472LedFlashSwitch.isOn
        photometerTCS3472Event = photometerTCS3472.color!.periodicRead(withPeriod: 700)
        streamingEvents.insert(photometerTCS3472Event)
        photometerTCS3472Event.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.photometerTCS3472RedColor.text = "\(obj.red)"
                self.photometerTCS3472GreenColor.text = "\(obj.green)"
                self.photometerTCS3472BlueColor.text = "\(obj.blue)"
                self.photometerTCS3472ClearColor.text = "\(obj.clear)"
            }
        }
    }
    
    @IBAction func photometerTCS3472StopStreamPressed(_ sender: Any) {
        photometerTCS3472StartStream.isEnabled = true
        photometerTCS3472StopStream.isEnabled = false
        photometerTCS3472Gain.isEnabled = true
        photometerTCS3472IntegrationSlider.isEnabled = true
        photometerTCS3472LedFlashSwitch.isEnabled = true
        streamingEvents.remove(photometerTCS3472Event)
        photometerTCS3472Event.stopNotificationsAsync()
        photometerTCS3472RedColor.text = "XXXX"
        photometerTCS3472GreenColor.text = "XXXX"
        photometerTCS3472BlueColor.text = "XXXX"
        photometerTCS3472ClearColor.text = "XXXX"
    }
    
    @IBAction func hygrometerBME280StartStreamPressed(_ sender: Any) {
        hygrometerBME280StartStream.isEnabled = false
        hygrometerBME280StopStream.isEnabled = true
        hygrometerBME280Oversample.isEnabled = false
        let hygrometerBME280 = device.hygrometer as! MBLHygrometerBME280
        switch hygrometerBME280Oversample.selectedSegmentIndex {
        case 0:
            hygrometerBME280.humidityOversampling = .oversample1X
        case 1:
            hygrometerBME280.humidityOversampling = .oversample2X
        case 2:
            hygrometerBME280.humidityOversampling = .oversample4X
        case 3:
            hygrometerBME280.humidityOversampling = .oversample8X
        default:
            hygrometerBME280.humidityOversampling = .oversample16X
        }
        
        hygrometerBME280Event = device.hygrometer!.humidity!.periodicRead(withPeriod: 700)
        streamingEvents.insert(hygrometerBME280Event)
        hygrometerBME280Event.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.hygrometerBME280Humidity.text = String(format: "%.2f", obj.value.doubleValue)
            }
        }
    }
    
    @IBAction func hygrometerBME280StopStreamPressed(_ sender: Any) {
        hygrometerBME280StartStream.isEnabled = true
        hygrometerBME280StopStream.isEnabled = false
        hygrometerBME280Oversample.isEnabled = true
        streamingEvents.remove(hygrometerBME280Event)
        hygrometerBME280Event.stopNotificationsAsync()
        hygrometerBME280Humidity.text = "XX.XX"
    }
    
    
    @IBAction func conductanceStartStreamPressed(_ sender: Any) {
        conductanceStartStream.isEnabled = false
        conductanceStopStream.isEnabled = true
        conductanceGain.isEnabled = false
        conductanceVoltage.isEnabled = false
        conductanceRange.isEnabled = false
        conductanceChannelStepper.isEnabled = false
        device.conductance!.gain = MBLConductanceGain(rawValue: UInt8(conductanceGain.selectedSegmentIndex))!
        device.conductance!.voltage = MBLConductanceVoltage(rawValue: UInt8(conductanceVoltage.selectedSegmentIndex))!
        device.conductance!.range = MBLConductanceRange(rawValue: UInt8(conductanceRange.selectedSegmentIndex))!
        let channel = Int(round(conductanceChannelStepper.value))
        device.conductance!.calibrateAsync()
        conductanceEvent = device.conductance!.channels[channel].periodicRead(withPeriod: 500)
        streamingEvents.insert(conductanceEvent)
        conductanceEvent.startNotificationsAsync { (obj, error) in
            if let obj = obj {
                self.conductanceLabel.text = obj.value.stringValue
            }
        }
    }
    
    @IBAction func conductanceStopStreamPressed(_ sender: Any) {
        conductanceStartStream.isEnabled = true
        conductanceStopStream.isEnabled = false
        conductanceGain.isEnabled = true
        conductanceVoltage.isEnabled = true
        conductanceRange.isEnabled = true
        conductanceChannelStepper.isEnabled = true
        streamingEvents.remove(conductanceEvent)
        conductanceEvent.stopNotificationsAsync()
        conductanceLabel.text = "XXXX"
    }
    
    @IBAction func conductanceChannelChanged(_ sender: Any) {
        conductanceChannelLabel.text = "\(Int(round(conductanceChannelStepper.value)))"
    }
    
    @IBAction func i2cReadBytesPressed(_ sender: Any) {
        if let deviceAddress = UInt8(i2cDeviceAddress.text!.drop0xPrefix, radix: 16) {
            if let registerAddress = UInt8(i2cRegisterAddress.text!.drop0xPrefix, radix: 16) {
                var length: UInt8 = 1
                if i2cSizeSelector.selectedSegmentIndex == 1 {
                    length = 2
                } else if i2cSizeSelector.selectedSegmentIndex == 2 {
                    length = 4
                }
                let reg = device.serial!.data(atDeviceAddress: deviceAddress, registerAddress: registerAddress, length: length)
                reg.readAsync().success { result in
                    self.i2cReadByteLabel.text = result.data?.description
                }
            } else {
                i2cRegisterAddress.text = ""
            }
        } else {
            i2cDeviceAddress.text = ""
        }
    }
    
    @IBAction func i2cWriteBytesPressed(_ sender: Any) {
        if let deviceAddress = UInt8(i2cDeviceAddress.text!.drop0xPrefix, radix: 16) {
            if let registerAddress = UInt8(i2cRegisterAddress.text!.drop0xPrefix, radix: 16) {
                if var writeData = Int32(i2cWriteByteField.text!.drop0xPrefix, radix: 16) {
                    var length: UInt8 = 1
                    if i2cSizeSelector.selectedSegmentIndex == 1 {
                        length = 2
                    } else if i2cSizeSelector.selectedSegmentIndex == 2 {
                        length = 4
                    }
                    let reg = device.serial!.data(atDeviceAddress: deviceAddress, registerAddress: registerAddress, length: length)
                    reg.writeAsync(Data(bytes: &writeData, count: Int(length)))
                }
                i2cWriteByteField.text = ""
            } else {
                i2cRegisterAddress.text = ""
            }
        } else {
            i2cDeviceAddress.text = ""
        }
    }
    
    @IBAction func neopixelLengthChanged(_ sender: Any) {
        neopixelLengthLabel.text = "\(Int(round(neopixelLengthStepper.value)))"
    }
    
    func neopixelInitStrand() -> BFTask<AnyObject> {
        if neopixelStrand == nil {
            neopixelStrand = device.neopixel!.strand(withColor: MBLColorOrdering(rawValue: UInt8(neopixelColor.selectedSegmentIndex))!,
                                                     speed: MBLStrandSpeed(rawValue: UInt8(neopixelSpeed.selectedSegmentIndex))!,
                                                     pin: UInt8(neopixelPin.selectedSegmentIndex),
                                                     length: UInt8(round(neopixelLengthStepper.value)))
            neopixelStrandInitTask = neopixelStrand.initializeAsync()
            neopixelColor.isEnabled = false
            neopixelSpeed.isEnabled = false
            neopixelPin.isEnabled = false
            neopixelLengthStepper.isEnabled = false
        }
        return neopixelStrandInitTask
    }
    
    func neopixelSetColor(_ color: UIColor) {
        let max = UInt8(round(neopixelLengthStepper.value))
        for i in 0..<max {
            neopixelStrand.setPixelAsync(i, color: color)
        }
    }
    
    @IBAction func neopixelSetRedPressed(_ sender: Any) {
        neopixelInitStrand().success { result in
            self.neopixelSetColor(UIColor.red)
        }
    }
    
    @IBAction func neopixelSetGreenPressed(_ sender: Any) {
        neopixelInitStrand().success { result in
            self.neopixelSetColor(UIColor.green)
        }
    }
    
    @IBAction func neopixelSetBluePressed(_ sender: Any) {
        neopixelInitStrand().success { result in
            self.neopixelSetColor(UIColor.blue)
        }
    }
    
    @IBAction func neopixelSetRainbowPressed(_ sender: Any) {
        neopixelInitStrand().success { result in
            self.neopixelStrand.setRainbowWithHoldAsync(false)
        }
    }
    
    @IBAction func neopixelRotateLeftPressed(_ sender: Any) {
        neopixelInitStrand().success { result in
            self.neopixelStrand.rotateStrand(withDirectionAsync: .towardsBoard, repetitions: 0xFF, period: 100)
        }
    }
    
    @IBAction func neopixelRotateRightPressed(_ sender: Any) {
        neopixelInitStrand().success { result in
            self.neopixelStrand.rotateStrand(withDirectionAsync: .awayFromBoard, repetitions: 0xFF, period: 100)
        }
    }
    
    @IBAction func neopixelTurnOffPressed(_ sender: Any) {
        neopixelInitStrand().success { result in
            self.neopixelStrand.clearAllPixelsAsync()
        }
        neopixelSetRed.isEnabled = false
        neopixelSetGreen.isEnabled = false
        neopixelSetBlue.isEnabled = false
        neopixelSetRainbow.isEnabled = false
        neopixelRotateRight.isEnabled = false
        neopixelRotateLeft.isEnabled = false
        neopixelTurnOff.isEnabled = false
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.5) {
            self.neopixelStrand.deinitializeAsync()
            self.neopixelStrand = nil
            self.neopixelColor.isEnabled = true
            self.neopixelSpeed.isEnabled = true
            self.neopixelPin.isEnabled = true
            self.neopixelLengthStepper.isEnabled = true
            self.neopixelSetRed.isEnabled = true
            self.neopixelSetGreen.isEnabled = true
            self.neopixelSetBlue.isEnabled = true
            self.neopixelSetRainbow.isEnabled = true
            self.neopixelRotateRight.isEnabled = true
            self.neopixelRotateLeft.isEnabled = true
            self.neopixelTurnOff.isEnabled = true
        }
    }
    
    func updateSensorFusionSettings() {
        device.sensorFusion!.mode = MBLSensorFusionMode(rawValue: UInt8(sensorFusionMode.selectedSegmentIndex) + 1)!
        sensorFusionMode.isEnabled = false
        sensorFusionOutput.isEnabled = false
        sensorFusionData = Data()
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
        case 0:
            streamingEvents.insert(device.sensorFusion!.eulerAngle)
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.eulerAngle.startNotificationsAsync { (obj, error) in
                if let obj = obj {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.p, min: -180, max: 180), y: self.sensorFusionGraph.scale(obj.r, min: -90, max: 90), z: self.sensorFusionGraph.scale(obj.y, min: 0, max: 360), w: self.sensorFusionGraph.scale(obj.h, min: 0, max: 360))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.p),\(obj.r),\(obj.y),\(obj.h)\n".data(using: String.Encoding.utf8)!)
                }
            }
        case 1:
            streamingEvents.insert(device.sensorFusion!.quaternion)
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.quaternion.startNotificationsAsync { (obj, error) in
                if let obj = obj {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0), w: self.sensorFusionGraph.scale(obj.w, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
        case 2:
            streamingEvents.insert(device.sensorFusion!.gravity)
            sensorFusionGraph.hasW = false
            task = device.sensorFusion!.gravity.startNotificationsAsync { (obj, error) in
                if let obj = obj {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
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
        sensorFusionStartLog.isEnabled = false
        sensorFusionStopLog.isEnabled = true
        sensorFusionStartStream.isEnabled = false
        sensorFusionStopStream.isEnabled = false
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
        case 0:
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.eulerAngle.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLEulerAngleData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.p, min: -180, max: 180), y: self.sensorFusionGraph.scale(obj.r, min: -90, max: 90), z: self.sensorFusionGraph.scale(obj.y, min: 0, max: 360), w: self.sensorFusionGraph.scale(obj.h, min: 0, max: 360))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.p),\(obj.r),\(obj.y),\(obj.h)\n".data(using: String.Encoding.utf8)!)
                }
            }
        case 1:
            sensorFusionGraph.hasW = true
            task = device.sensorFusion!.quaternion.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLQuaternionData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0), w: self.sensorFusionGraph.scale(obj.w, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.w),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
        case 2:
            sensorFusionGraph.hasW = false
            task = device.sensorFusion!.gravity.downloadLogAndStopLoggingAsync(true, progressHandler: hudProgress).success { array in
                for obj in array as! [MBLAccelerometerData] {
                    self.sensorFusionGraph.addX(self.sensorFusionGraph.scale(obj.x, min: -1.0, max: 1.0), y: self.sensorFusionGraph.scale(obj.y, min: -1.0, max: 1.0), z: self.sensorFusionGraph.scale(obj.z, min: -1.0, max: 1.0))
                    self.sensorFusionData.append("\(obj.timestamp.timeIntervalSince1970),\(obj.x),\(obj.y),\(obj.z)\n".data(using: String.Encoding.utf8)!)
                }
            }
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
    
    func select(_ peripheral:CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) -> Bool {
        return peripheral.identifier == device.identifier
    }
    
    func filterBy(hint dfuServiceUUID: CBUUID) -> [CBUUID]? {
        return nil
    }
}
