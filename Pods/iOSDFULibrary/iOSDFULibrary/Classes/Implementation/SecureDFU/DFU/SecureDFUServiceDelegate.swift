/*
* Copyright (c) 2016, Nordic Semiconductor
* All rights reserved.
*
* Redistribution and use in source and binary forms, with or without modification, are permitted provided that the following conditions are met:
*
* 1. Redistributions of source code must retain the above copyright notice, this list of conditions and the following disclaimer.
*
* 2. Redistributions in binary form must reproduce the above copyright notice, this list of conditions and the following disclaimer in the
* documentation and/or other materials provided with the distribution.
*
* 3. Neither the name of the copyright holder nor the names of its contributors may be used to endorse or promote products derived from this
* software without specific prior written permission.
*
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
* LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
* HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
* LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
* ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE
* USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
*/

public enum SecureDFUError : Int {
    case invalidCode                    = 0
    case success                        = 1
    case opCodeNotSupported             = 2
    case invalidParameter               = 3
    case insufficientResources          = 4
    case invalidObject                  = 5
    case signatureMismatch              = 6
    case unsupportedType                = 7
    case operationNotpermitted          = 8
    case operationFailed                = 10
    case extendedError                  = 11
    
    /// Providing the DFUFirmware is required.
    case fileNotSpecified               = 101
    /// Given firmware file is not supported.
    case fileInvalid                    = 102
    /// Since SDK 7.0.0 the DFU Bootloader requires the extended Init Packet. For more details, see:
    /// http://infocenter.nordicsemi.com/topic/com.nordic.infocenter.sdk5.v11.0.0/bledfu_example_init.html?cp=4_0_0_4_2_1_1_3
    case extendedInitPacketRequired     = 103
    /// Before SDK 7.0.0 the init packet could have contained only 2-byte CRC value, and was optional.
    /// Providing an extended one instead would cause CRC error during validation (the bootloader assumes that the 2 first bytes
    /// of the init packet are the firmware CRC).
    case initPacketRequired             = 104
    
    case failedToConnect                = 201
    case deviceDisconnected             = 202
    
    case serviceDiscoveryFailed         = 301
    case deviceNotSupported             = 302
    case readingVersionFailed           = 303
    case enablingControlPointFailed     = 304
    case writingCharacteristicFailed    = 305
    case receivingNotificationFailed    = 306
    case unsupportedResponse            = 307
    /// Error called during upload when the number of bytes sent is not equal to number of bytes confirmed in Packet Receipt Notification.
    case bytesLost                      = 308
    case characteristicDiscoveryFailed  = 309
    
    var description:String {
        switch self {
            case .invalidCode:                  return "Invalid code"
            case .success:                      return "Success"
            case .opCodeNotSupported:           return "OpCode not supported"
            case .invalidParameter:             return "Invalid parameter"
            case .insufficientResources:        return "Insufficient resources"
            case .invalidObject:                return "Invalid object"
            case .signatureMismatch:            return "signature mismatch"
            case .unsupportedType:              return "Unsupported type"
            case .operationNotpermitted:        return "Operation not permitted"
            case .operationFailed:              return "Operation failed"
            case .extendedError:                return "Extended error"
            case .fileNotSpecified:             return "File not specified"
            case .fileInvalid:                  return "File invalid"
            case .extendedInitPacketRequired:   return "Extended init packet required"
            case .initPacketRequired:           return "Init packet required"
            case .failedToConnect:              return "Failed to connect"
            case .deviceDisconnected:           return "Devices disconnected"
            case .serviceDiscoveryFailed:       return "Service discovery failed"
            case .deviceNotSupported:           return "Device not supported"
            case .readingVersionFailed:         return "Reading version failed"
            case .enablingControlPointFailed:   return "Enabling control point failed"
            case .writingCharacteristicFailed:  return "Writing characteristic failed"
            case .receivingNotificationFailed:  return "Receiving notification failed"
            case .unsupportedResponse:          return "Unsupported response"
            case .bytesLost:                    return "Bytes lost"
            case .characteristicDiscoveryFailed:return "Characteristic discovery failed"
        }
    }
}

/**
 *  The progress delegates may be used to notify user about progress updates.
 *  The only method of the delegate is only called when the service is in the Uploading state.
 */
public protocol SecureDFUProgressDelegate : class {
    /**
     Callback called in the `State.Uploading` state. Gives detailed information about the progress
     and speed of transmission. This method is always called at least two times (for 0% and 100%)
     if upload has started and did not fail.
     
     This method is called in the main thread and is safe to update any UI.
     
     - parameter part: number of part that is currently being transmitted. Parts start from 1
     and may have value either 1 or 2. Part 2 is used only when there were Soft Device and/or
     Bootloader AND an Application in the Distribution Packet and the DFU target does not
     support sending all files in a single connection. First the SD and/or BL will be sent, then
     the service will disconnect, reconnect again to the (new) bootloader and send the Application.
     - parameter totalParts: total number of parts that are to be send (this is always equal to 1 or 2).
     - parameter progress: the current progress of uploading the current part in percentage (values 0-100).
     Each value will be called at most once - in case of a large file a value e.g. 3% will be called only once,
     despite that it will take more than one packet to reach 4%. In case of a small firmware file
     some values may be ommited. For example, if firmware file would be only 20 bytes you would get
     a callback 0% (called always) and then 100% when done.
     - parameter currentSpeedBytesPerSecond: the current speed in bytes per second
     - parameter avgSpeedBytesPerSecond: the average speed in bytes per second
     */
    func onUploadProgress(_ part:Int, totalParts:Int, progress:Int,
        currentSpeedBytesPerSecond:Double, avgSpeedBytesPerSecond:Double)
}

/**
 *  The service delegate reports about state changes and errors.
 */
public protocol SecureDFUServiceDelegate : class {
    /**
     Callback called when state of the DFU Service has changed.
     
     This method is called in the main thread and is safe to update any UI.
     
     - parameter state: the new state fo the service
     */
    func didStateChangedTo(_ state:DFUState)
    
    /**
     Called after an error occurred.
     The device will be disconnected and DFU operation has been aborted.
     
     This method is called in the main thread and is safe to update any UI.
     
     - parameter error:   the error code
     - parameter message: error description
     */
    func OnErrorOccured(withError anError : SecureDFUError, andMessage aMessage:String)
}
