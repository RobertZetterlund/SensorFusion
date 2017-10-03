//
//  DevicesTableViewController.swift
//  MetaWearApiTest
//
//  Created by Stephen Schiffli on 11/2/16.
//  Copyright © 2016 MbientLab. All rights reserved.
//

import UIKit
import MetaWear
import MBProgressHUD
import iOSDFULibrary

class DevicesTableViewController: UITableViewController, DFUServiceDelegate, DFUProgressDelegate, LoggerDelegate, DFUPeripheralSelectorDelegate {
    var devices: [MBLMetaWear]?
    var activity: UIActivityIndicatorView!
    var hud: MBProgressHUD?
    var selected: MBLMetaWear?
    var initiator: DFUServiceInitiator?
    var dfuController: DFUServiceController?

    @IBOutlet weak var scanningSwitch: UISwitch!
    @IBOutlet weak var metaBootSwitch: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        activity = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        activity.center = CGPoint(x: 95, y: 138)
        tableView.addSubview(activity)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        setScanning(scanningSwitch.isOn)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        setScanning(false)
    }
    
    func setScanning(_ on: Bool) {
        if on {
            activity.startAnimating()
            if metaBootSwitch.isOn {
                MBLMetaWearManager.shared().startScan(forMetaBootsAllowDuplicates: true, handler: { array in
                    self.devices = array
                    self.tableView.reloadData()
                })
            } else {
                MBLMetaWearManager.shared().startScan(forMetaWearsAllowDuplicates: true, handler: { array in
                    self.devices = array
                    self.tableView.reloadData()
                })
            }
        } else {
            activity.stopAnimating()
            MBLMetaWearManager.shared().stopScan()
        }
    }

    @IBAction func scanningSwitchPressed(_ sender: UISwitch) {
         setScanning(sender.isOn)
    }
    
    @IBAction func metaBootSwitchPressed(_ sender: Any) {
        MBLMetaWearManager.shared().stopScan()
        // Wait a split second for any final callbacks to fire before starting up scanning again
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.devices = nil
            self.tableView.reloadData()
            self.setScanning(self.scanningSwitch.isOn)
        }
    }
    
    // MARK: - Table view data source
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return devices?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        let cur = devices![indexPath.row]
        
        let uuid = cell.viewWithTag(1) as! UILabel
        uuid.text = cur.identifier.uuidString
        
        let rssi = cell.viewWithTag(2) as! UILabel
        rssi.text = cur.discoveryTimeRSSI?.stringValue
        
        let connected = cell.viewWithTag(3) as! UILabel
        if cur.state == .connected {
            connected.isHidden = false
        } else {
            connected.isHidden = true
        }
        
        let name = cell.viewWithTag(4) as! UILabel
        name.text = cur.name
        
        let signal = cell.viewWithTag(5) as! UIImageView
        if let averageRSSI = cur.averageRSSI {
            let movingAverage = averageRSSI.doubleValue
            if movingAverage < -80.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d1")
            } else if movingAverage < -70.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d2")
            } else if movingAverage < -60.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d3")
            } else if movingAverage < -50.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d4")
            } else if movingAverage < -40.0 {
                signal.image = #imageLiteral(resourceName: "wifi_d5")
            } else {
                signal.image = #imageLiteral(resourceName: "wifi_d6")
            }
        } else {
            signal.image = #imageLiteral(resourceName: "wifi_not_connected")
        }
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Devices"
    }
    
    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        selected = devices![indexPath.row]
        if (metaBootSwitch.isOn) {
            scanningSwitch.setOn(false, animated: true)
            metaBootSwitch.setOn(false, animated: true)
            metaBootSwitchPressed(metaBootSwitch)
            
            // Pause the screen while update is going on
            hud = MBProgressHUD.showAdded(to: view, animated: true)
            hud?.mode = .determinateHorizontalBar
            hud?.label.text = "Updating..."
            
            MBLMetaWearManager.shared().logLevel = .info
            selected?.prepareForFirmwareUpdateAsync().success { result in
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
                let alertController = UIAlertController(title: "Update Error", message: "Please re-connect and try again, if you can't connect, try MetaBoot Mode to recover.\nError: \(error.localizedDescription)", preferredStyle: .alert)
                alertController.addAction(UIAlertAction(title: "Okay", style: .default, handler: nil))
                self.present(alertController, animated: true, completion: nil)
                self.hud?.hide(animated: true)
            }
            
        } else {
            performSegue(withIdentifier: "DeviceDetails", sender: nil)
        }
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destination = segue.destination as! DeviceDetailViewController
        destination.device = selected
    }
    
    
    // MARK: - DFU Service delegate methods
    
    func dfuStateDidChange(to state: DFUState) {
        if state == .completed {
            hud?.mode = .text
            hud?.label.text = "Success!"
            hud?.hide(animated: true, afterDelay: 2.0)
            MBLMetaWearManager.shared().clearDiscoveredDevices()
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
            print("\(level): \(message)")
        }
    }
    func select(_ peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber, hint name: String?) -> Bool {
        return peripheral.identifier == selected?.identifier
    }
    
    func filterBy(hint dfuServiceUUID: CBUUID) -> [CBUUID]? {
        return nil
    }
}
