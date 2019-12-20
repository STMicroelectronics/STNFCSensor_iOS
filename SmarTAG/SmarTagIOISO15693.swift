/*
 * Copyright (c) 2018  STMicroelectronics – All rights reserved
 * The STMicroelectronics corporate logo is a trademark of STMicroelectronics
 *
 * Redistribution and use in source and binary forms, with or without modification,
 * are permitted provided that the following conditions are met:
 *
 * - Redistributions of source code must retain the above copyright notice, this list of conditions
 * and the following disclaimer.
 *
 * - Redistributions in binary form must reproduce the above copyright notice, this list of
 * conditions and the following disclaimer in the documentation and/or other materials provided
 * with the distribution.
 *
 * - Neither the name nor trademarks of STMicroelectronics International N.V. nor any other
 * STMicroelectronics company nor the names of its contributors may be used to endorse or
 * promote products derived from this software without specific prior written permission.
 *
 * - All of the icons, pictures, logos and other images that are provided with the source code
 * in a directory whose title begins with st_images may only be used for internal purposes and
 * shall not be redistributed to any third party or modified in any way.
 *
 * - Any redistributions in binary form shall not include the capability to display any of the
 * icons, pictures, logos and other images that are provided with the source code in a directory
 * whose title begins with st_images.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND ANY EXPRESS OR
 * IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY
 * AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
 * OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 * THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR
 * OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY
 * OF SUCH DAMAGE.
 */

import Foundation
import CoreNFC
import SmarTagLib

@available(iOS 13, *)
class SmarTagIOISO15693 : SmarTagIO{
           
    private let mTag: NFCISO15693Tag
    
    init(_ tag:NFCISO15693Tag){
        self.mTag = tag
    }
    
    var id:Data?{
        get{
            return mTag.identifier
        }
    }
    
    private static let MAX_READ_BLOCK = 70
    private static let LAST_BASE_BLOCK = 255
    private static let MAX_BLOCK_WRITE = 4
    private static let BLOCK_SIZE = 4 //bytes
    
    func read(address: Int, onComplete:@escaping (IOResult) -> Void) {
        mTag.extendedReadSingleBlock(requestFlags: [.address, .highDataRate], blockNumber: address){ data, error in
            if let error = error as? NFCReaderError {
                print(error.localizedDescription)
                onComplete(IOResult.failure(error.toSmarTagIOError))
            }else{
                onComplete(IOResult.success(data))
            }
            
        }
    }
      
    private func readExtended(range: Range<Int>, onComplete:@escaping (IOResult) -> Void) {
        //print("ext read: \(range.lowerBound) -> \(range.upperBound)")
        var finalData = Data(capacity: range.count*SmarTagIOISO15693.BLOCK_SIZE)
        func internalRead(range:Range<Int>){
            self.mTag.extendedReadSingleBlock(requestFlags: [.address,.highDataRate], blockNumber: range.lowerBound){ data, error in
                if let error = error as? NFCReaderError {
               print(error)
               print(error.localizedDescription)
               onComplete(IOResult.failure(error.toSmarTagIOError))
            }else{
                finalData.append(data)
                if(range.count == 1) {
                    onComplete(Result.success(finalData))
                }else{
                    internalRead(range:range.dropFirst())
                }//if last
            }//if error
            }//readSingleBlock
            
        }
            
        internalRead(range: range)
    }
    
    private func splitMultipleRead(range: Range<Int>)->[NSRange]{
        let (nRead, remaining) = range.count.quotientAndRemainder(dividingBy: SmarTagIOISO15693.MAX_READ_BLOCK)
        var rangeRead = (0..<nRead).map{ readIndex in
            NSRange(location: range.lowerBound + readIndex*SmarTagIOISO15693.MAX_READ_BLOCK, length: SmarTagIOISO15693.MAX_READ_BLOCK)
        }
        if(remaining != 0){
            rangeRead.append(NSRange(location: range.lowerBound + nRead*SmarTagIOISO15693.MAX_READ_BLOCK, length: remaining))
        }
        return rangeRead
    }
    
    private func readBase(range: Range<Int>, onComplete:@escaping (IOResult) -> Void) {
        var finalData = Data(capacity: range.count*SmarTagIOISO15693.BLOCK_SIZE)
        let readOperation = splitMultipleRead(range: range)
        
        func internalRead(index:Int, reads:[NSRange]){
            self.mTag.readMultipleBlocks(requestFlags: [.address,.highDataRate], blockRange: reads[index]){ data, error in
                if let error = error as? NFCReaderError {
               print(error)
               print(error.localizedDescription)
               onComplete(IOResult.failure(error.toSmarTagIOError))
            }else{
                data.forEach{
                    finalData.append($0)
                }
                if(index+1 >= reads.count) {
                    onComplete(Result.success(finalData))
                }else{
                    internalRead(index:index+1,reads: reads)
                }//if last
            }//if error
            }//readSingleBlock
            
        }
        internalRead(index: 0, reads: readOperation)
    }
    
    func read(range: Range<Int>, onComplete: @escaping (IOResult) -> Void) {
        if(range.lowerBound >= SmarTagIOISO15693.LAST_BASE_BLOCK){
            readExtended(range: range, onComplete: onComplete)
            return
        }
        if(range.upperBound < SmarTagIOISO15693.LAST_BASE_BLOCK){
            readBase(range: range, onComplete: onComplete)
            return
        }
        let baseRange = range.lowerBound..<SmarTagIOISO15693.LAST_BASE_BLOCK
        let extendRange = SmarTagIOISO15693.LAST_BASE_BLOCK..<range.upperBound
        
        readBase(range: baseRange){ baseResult in
            switch baseResult{
            case .failure:
                onComplete(baseResult)
            case .success(let baseData):
                self.readExtended(range: extendRange){ extResult in
                    switch extResult{
                    case .failure:
                        onComplete(extResult)
                    case .success(let extData):
                        var resultData = Data(capacity: range.count*SmarTagIOISO15693.BLOCK_SIZE)
                        resultData.append(baseData)
                        resultData.append(extData)
                        onComplete(.success(resultData))
                    }//switch extResult
                }//read extreme
            }//switch baseResult
        }//readBase
        
    }
    
    private func writeBase(startAddress:Int, data:Data, onComplete:@escaping (SmarTagIOError?)->Void){
        let nDataBlock = data.count/SmarTagIOISO15693.BLOCK_SIZE
        let nBlock = min(nDataBlock, SmarTagIOISO15693.MAX_BLOCK_WRITE)
        let blockRange = NSRange(location: startAddress, length: nBlock)
        let dataBlock = SmarTagIOISO15693.splitDataIntoBlock(data: data.prefix(nBlock*SmarTagIOISO15693.BLOCK_SIZE))
        mTag.writeMultipleBlocks(requestFlags: [.address,.highDataRate], blockRange: blockRange, dataBlocks: dataBlock){ error in
            if let error = error as? NFCReaderError {
               print(error)
               print(error.localizedDescription)
                onComplete(error.toSmarTagIOError)
            }else{
                if(nDataBlock == nBlock){
                    onComplete(nil)
                }else{
                    let remainingData = Data(data[(nBlock*SmarTagIOISO15693.BLOCK_SIZE)...])
                    self.writeBase(startAddress: startAddress+nBlock, data:remainingData , onComplete: onComplete)
                }
            }
        }
    }
    
    private static func splitDataIntoBlock(data:Data) -> [Data]{
        return (0..<data.count/SmarTagIOISO15693.BLOCK_SIZE).map{ blockIndex in
            let blockRange = blockIndex*SmarTagIOISO15693.BLOCK_SIZE..<(blockIndex+1)*SmarTagIOISO15693.BLOCK_SIZE
            return data.subdata(in: blockRange)
        }
    }

    
    func write(startAddress:Int, data:Data, onComplete:@escaping (SmarTagIOError?)->Void){
        let writeRange = startAddress..<startAddress+data.count/SmarTagIOISO15693.BLOCK_SIZE
        
        if(writeRange.upperBound < SmarTagIOISO15693.LAST_BASE_BLOCK){
            writeBase(startAddress: startAddress, data: data, onComplete: onComplete)
            return
        }
        if(writeRange.lowerBound >= SmarTagIOISO15693.LAST_BASE_BLOCK){
            let dataBlock:[Data] =  SmarTagIOISO15693.splitDataIntoBlock(data: data)
            writeExtended(startAddress: startAddress, data: dataBlock, onComplete: onComplete)
            return
        }
        
        let baseRange = writeRange.lowerBound..<SmarTagIOISO15693.LAST_BASE_BLOCK
        let extendRange = SmarTagIOISO15693.LAST_BASE_BLOCK..<writeRange.upperBound
        
        let baseData = data[...(baseRange.count*SmarTagIOISO15693.BLOCK_SIZE)]
        let extData = data[(baseRange.count*SmarTagIOISO15693.BLOCK_SIZE)...]
        
        writeBase(startAddress: startAddress, data: baseData){ error in
            guard error != nil else{
                onComplete(error)
                return
            }
            self.writeExtended(startAddress: extendRange.lowerBound,
                          data: SmarTagIOISO15693.splitDataIntoBlock(data: extData),
                          onComplete: onComplete)
        }
        
    }
    
    private func writeExtended(startAddress:Int, data:[Data], onComplete:@escaping (SmarTagIOError?)->Void){
        guard let blockData = data.first else{
            onComplete(nil)
            return
        }
        mTag.extendedWriteSingleBlock(requestFlags: [.address,.highDataRate], blockNumber: startAddress, dataBlock: blockData){ error in
            if error == nil{
                self.writeExtended(startAddress: startAddress+1, data: Array(data[1...]), onComplete: onComplete)
            }else{
                if let error = error as? NFCReaderError {
                   print(error)
                   print(error.localizedDescription)
                    onComplete(error.toSmarTagIOError)
                }else{
                    fatalError()
                }
            }
        }
            
    }
     
}

extension NFCReaderError {
    var toSmarTagIOError : SmarTagIOError{
        switch self.code {
        case .readerTransceiveErrorTagConnectionLost:
            return .lostConnection
        case .readerTransceiveErrorTagResponseError:
            return .tagResponseError
        default:
            return .unknown
        }
    }
}
