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
import UIKit
import CoreNFC
import SmarTagLib

public class SmarTagMainViewController : UIViewController{
    
    private static let NFC_READ_MESSAGE = {
        return  NSLocalizedString("You can scan NFC-tags by holding them behind the top of your iPhone.",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagMainViewController.self),
                                  value: "You can scan NFC-tags by holding them behind the top of your iPhone.",
                                  comment: "You can scan NFC-tags by holding them behind the top of your iPhone.");
    }()

    private static let INVALID_NFC_TITLE = {
        return  NSLocalizedString("Error reading the tag",
                                  tableName: nil,
                                  bundle: Bundle(for: SmarTagMainViewController.self),
                                  value: "Error reading the tag",
                                  comment: "Error reading the tag");
    }()
        
    private static let SHOW_CONTENT_SEGUE = "SmarTag_showTagContent"
    
    private var readerSession:NFCReaderSession?
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.isNavigationBarHidden=true
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.isNavigationBarHidden=false
    }
       
    @IBAction func onReadNfcButtonClicked(_ sender: UIButton) {
      /*
         let data = generateFakeSmartTagData()
         self.performSegue(withIdentifier: SmarTagMainViewController.SHOW_CONTENT_SEGUE, sender: data)
      */
        #if targetEnvironment(simulator)
            let data = generateFakeSmartTagData()
            self.performSegue(withIdentifier: SmarTagMainViewController.SHOW_CONTENT_SEGUE, sender: data)
        #else
        if #available(iOS 13, *){
            startReadTag()
        }else{
            startReadNDef()
        }
        #endif
    }
            
    public override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if var contentViewController = segue.destination as? SmarTagObjectWithTag,
            let data = sender as? SmarTagData{
            contentViewController.tagContent = data;
        }
    }
    
    fileprivate func onNfcTagRead(session:NFCReaderSession, result:Result<SmarTagData,SmarTagIOError>){
        switch result {
        case .failure(let error):
            if #available(iOS 13, *){
                session.invalidate(errorMessage: error.localizedDescription)
            }else{
                DispatchQueue.main.async {
                    self.showErrorMessage(title: SmarTagMainViewController.INVALID_NFC_TITLE, message: error.localizedDescription)
                }
                session.invalidate()
            }
            return
        case .success(let data):
            session.invalidate()
            DispatchQueue.main.async {
                self.performSegue(withIdentifier: SmarTagMainViewController.SHOW_CONTENT_SEGUE, sender: data)
            }// dispatch main
        }//switch
    }
}

 extension SmarTagMainViewController : NFCNDEFReaderSessionDelegate {
    
    fileprivate func startReadNDef(){
        readerSession = NFCNDEFReaderSession(delegate: self,queue: nil,invalidateAfterFirstRead: true)
        readerSession?.alertMessage = SmarTagMainViewController.NFC_READ_MESSAGE
        readerSession?.begin()
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        guard let readerError = error as? NFCReaderError else {
            return
        }
        switch readerError.code {
            case .readerSessionInvalidationErrorFirstNDEFTagRead, .readerSessionInvalidationErrorUserCanceled:
                break
            default:
                self.onNfcTagRead(session: session, result: Result.failure(readerError.toSmarTagIOError))
            
        }
    
        print("Error Reading Tag",error.localizedDescription)
    }
    
    private func findSmarTagPayload(messages: [NFCNDEFMessage]) -> NFCNDEFPayload?{
        return  messages.first?.records.first{ rec in
            let type = String(data: rec.type, encoding: .utf8)
            return rec.typeNameFormat == .nfcExternal && type == "st.com:smartag"
        }
    }
    
    public func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        guard let smarTagPayload = findSmarTagPayload(messages: messages) else {
            self.onNfcTagRead(session: session,result: .failure(.malformedNDef))
            return
        }
        
        let parser = SmarTagV1NDefParser(identifier: smarTagPayload.identifier, rawData: smarTagPayload.payload)
        parser.readContent{ result in
            self.onNfcTagRead(session: session,result: result)
        }
    }
 }

 @available(iOS 13, *)
 extension SmarTagMainViewController : NFCTagReaderSessionDelegate {
    
    fileprivate func startReadTag(){
        readerSession = NFCTagReaderSession(pollingOption: .iso15693, delegate: self)
        readerSession?.alertMessage = SmarTagMainViewController.NFC_READ_MESSAGE
        readerSession?.begin()
     }
    
    public func tagReaderSessionDidBecomeActive(_ session: NFCTagReaderSession) {
        NSLog("Session Activated")
    }
        
    public func tagReaderSession(_ session: NFCTagReaderSession, didInvalidateWithError error: Error) {
        print(error.localizedDescription)
        NSLog("Error")
        guard let readerError = error as? NFCReaderError else {
            return
        }
        switch readerError.code {
        case .readerSessionInvalidationErrorUserCanceled,
             .readerSessionInvalidationErrorSessionTimeout : 
            break
        default:
            self.onNfcTagRead(session: session, result: .failure(readerError.toSmarTagIOError))
        }
    }
    
    public func tagReaderSession(_ session: NFCTagReaderSession, didDetect tags: [NFCTag]) {
        guard let tag = tags.first, case let NFCTag.iso15693(type5Tag) = tag else{
            return
        }
    
        session.connect(to: tag){ error in
            guard error == nil else{
                session.invalidate(errorMessage: error!.localizedDescription)
                return
            }
            let parser = SmartTagIso15693Parser(tagIO: SmarTagIOISO15693(type5Tag))
            parser.readContent{ result in
                self.onNfcTagRead(session: session,result: result)
            }
        }
    }
        
 }
