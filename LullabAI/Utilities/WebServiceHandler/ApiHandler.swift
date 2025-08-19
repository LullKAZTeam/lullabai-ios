//
//  ApiHandler.swift
//  LullabAI
//
//  Created by Keyur Hirani on 24/01/25.
//

import Foundation
import Alamofire
import MBProgressHUD

class ApiHandler {
    
    /// StatusCode
    enum StatusCode: Int {case success          = 200 // OK for success
        case error            = 400 // Bad request for wrong parameters
        case unauthorized     = 401 // Thrown due to token mismatch or expiration
        case tokenRefreshed   = -1  // When token expires nd token refresh is call, then in response this code will be sent.
        case noContent        = 204 // No content when everything goes right but there is no data to be shown.
        case resourceNotFound = 404 // When Resource is not found
        case codeError        = 500 // Where we(backend) have messed up the code
        case unsupportedMedia = 415 // Unsupported Media Type
        case timeOut          = -2  // Time out
        case requestCancelled = -3  // Request Cancelled
        case noStatusCode     = 0   // If any other above code is obtained
        case noInternet       = -4  // No internet available
    }
    
    enum statusType: String {
        case success = "success"
        case processing = "processing"
        case failed = "failed"
    }
    
    /// UrlType
    enum UrlType : String{
        case liveBaseURL = "https://lullabi-admin.vangoghlabs.com/" // for test application in development environment
        case stageBaseURL = "https://api-stage.magicshot.ai/" // for load terms,legal,or other pages in webView
    }
    
#warning("Check Api BaseURL Type before uploading")
    struct APIURL {
        
        static let BaseURL = UrlType.liveBaseURL.rawValue
    }
    
    struct ApiKeys {
        static let kData                = "data"
        static let kHeaderToken         = ""
    }
    
    /// MethodName
    enum MethodName: String {
//        Enter the api end Path
        case login                          = "api/login/"
        case register                       = "api/signup/"
        case verifyOTP                      = "api/verify-otp/"
        case getVoice                       = "api/voices/"
        case createVoice                    = "api/voice/create/"
        case refreshToken                   = "api/token/refresh/"
        case getCategoryList                = "api/categories/"
        case getHomeStory                   = "api/get_home_stories"
        case generateVoice                  = "api/generate_voiceover/"
        case getRandomStory                 = "api/random_story/"
        case getHistory                     = "api/history/"
        case deleteVoice                    = "api/delete_voice/"
        case deleteHistory                  = "api/delete_history/"
        case getStory                       = "api/stories/"
        case getPrivacyPolicy               = "api/get_terms_and_policy/"
        case bookmarkStory                  = "api/toogle_history_collection/"
        case getMookmarkList                = "api/get_collection_history/"
        case forgotPassword                 = "api/forgot-password/"
        case resetPassword                  = "api/reset-password/"
        case updateProfile                  = "api/user/update/"
        case deleteAccount                  = "api/disable-user/"
        case socialLogin                    = "api/social-login/"
    }

    enum HeaderType: String {
        case app_json = "application/json"
        case app_xForm_urlEncode = "application/x-www-form-urlencoded"
        
        func getHeader() -> HTTPHeaders {
            
            let BearerToken = UserDefaults.standard.object(forKey: "accesss_token") as? String ?? ""
            
            let header: HTTPHeaders = [HTTPHeader(name: "Content-Type", value: self.rawValue),
                                       HTTPHeader(name: "Authorization", value: BearerToken == "" ? "" : "Bearer " + BearerToken)]

            return header
        }
    }
    
    // Custom Type
    typealias WSResponseBlockReceipt = ((_ status: ApiHandler.StatusCode,_ json: [String : Any]?, _ error: String?) -> ())
    typealias WSResponseBlock = ((_ status: ApiHandler.statusType,_ json: [String : Any]?, _ error: String?) -> ())
    typealias WSDownlaodBlock = ((_ url: URL?, _ error: String?,_ resumData: Data?) -> ())
    typealias WSProgressBlock = ((_ progress: Double) -> ())
    
    // Variable(s) Declaratrion
    static  var shared : ApiHandler = ApiHandler()
    private var alamofireManager: Session!
    private var header : HTTPHeaders {
        let tempHeader: HTTPHeaders = [HTTPHeader(name: "Content-Type", value: "application/json")]
        return tempHeader
    }
    
    private init() {
        let configuration = URLSessionConfiguration.af.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        alamofireManager = Session(configuration: configuration)
    }
    
    static var unameMachine: String {
        var utsnameInstance = utsname()
        uname(&utsnameInstance)
        let optionalString: String? = withUnsafePointer(to: &utsnameInstance.machine) {
            $0.withMemoryRebound(to: CChar.self, capacity: 1) {
                ptr in String.init(validatingUTF8: ptr)
            }
        }
        return optionalString ?? "N/A"
    }
}

// MARK: Request Method
extension ApiHandler {
    
    func request(
            _ methodType: HTTPMethod = .post,
            for methodName: MethodName,
            param: [String: Any]? = nil,
            encoding: ParameterEncoding = JSONEncoding.default,
            headerParam: HeaderType = .app_json,
            showLoader: Bool = true,
            vc: UIViewController? = nil,
            completion: WSResponseBlock?
    ) -> DataRequest? {
        
        print("+++ +++ +++ \(methodName) +++ +++ +++")
        
        // Check internet connection
        guard isConnectedToInternet() else {
            completion?(.failed, nil, "No internet available!")
            return nil
        }
        
        if let vc = vc {
            DispatchQueue.main.async {
                MBProgressHUD.showAdded(to: vc.view, animated: true)
            }
        }
        
        let urlStr = APIURL.BaseURL + methodName.rawValue
        
        guard let url = URL(string: urlStr) else {
            completion?(.failed, nil, "Invalid URL")
            return nil
        }
        
        let header = headerParam.getHeader()
        
        print("URL: \(urlStr)")
        print("Header: \(header)")
        print("Params: \(param ?? [:])")
        
        alamofireManager.sessionConfiguration.timeoutIntervalForRequest = 60
        
        // Request
        return alamofireManager.request(url, method: methodType, parameters: param, encoding: encoding, headers: header, interceptor: nil).validate().response { responseData in
            
            // Hide loader on the main thread
            if let vc = vc {
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: vc.view, animated: true)
                }
            }
            
            let statusCode = responseData.response?.statusCode ?? 0
            let codeType = StatusCode(rawValue: statusCode) ?? .noStatusCode
            print("Status Code: \(statusCode) - \(codeType)")
            
            switch responseData.result {
            case .success(let value):
                if let data = value {
                    if let jsonData = nsdataToJSON(data: data) as? [String: Any] {
                        print("Success Response: \(jsonData)")
                        
                        // Print JSON string for debugging
                        if let theJSONData = try? JSONSerialization.data(withJSONObject: jsonData, options: []),
                           let theJSONText = String(data: theJSONData, encoding: .ascii) {
                            print("JSON string = \(theJSONText)")
                        }
                        
                        if methodName == .refreshToken {
                            completion?(.success, jsonData, nil)
                        }
                        let status = "\(jsonData["status"] ?? "")"
                        switch status {
                        case "1":
                            completion?(.success, jsonData, nil)
                        case "0":
                            completion?(.failed, jsonData, nil)
                        default:
                            completion?(.failed, jsonData, "")
                        }
                    } else {
                        completion?(.failed, [:], "Failed to parse response data.")
                    }
                } else {
                    completion?(.failed, [:], "No data received.")
                }
                
            case .failure(let fError):
                if fError.responseCode == NSURLErrorTimedOut || responseData.response?.statusCode == NSURLErrorTimedOut {
                    completion?(.failed, nil, "Request timed out.")
                } else if fError.isSessionTaskError {
                    completion?(.failed, nil, "Could not connect to the server.")
                } else if fError.isExplicitlyCancelledError {
                    completion?(.failed, nil, nil)
                } else {
                    print("Error ResponseCode: \(fError.responseCode ?? 0)")
                    
                    if fError.responseCode == 401 {
                        // _appDelegate.logOutUser() // Force log out user due to session/token expiration
                        self.refreshAccessToken { success in
                            if success {
                                _ = self.request(methodType, for: methodName, param: param, encoding: encoding, headerParam: headerParam, showLoader: showLoader, vc: vc) { status, json, error in
                                    completion?(status, json, error)
                                }
                            }
                            else {
                                //completion?(.failed, nil, fError.localizedDescription)
                            }
                        }
                    }
                    
                    if let jsonRawData = responseData.data {
                        do {
                            if let jsonData = nsdataToJSON(data: jsonRawData) as? [String: Any] {
                                print("Failure Response: \(jsonData)")
                                let errStr: String? = jsonData["message"] as? String ?? fError.localizedDescription
                                completion?(.failed, jsonData, errStr)
                            } else {
                                completion?(.failed, nil, "Failed to parse error response data.")
                            }
                        } catch let err {
                            print("Error: \(err.localizedDescription)")
                            completion?(.failed, nil, err.localizedDescription)
                        }
                    } else {
                        print("Error: \(fError)")
                        completion?(.failed, nil, fError.localizedDescription)
                    }
                }
            }
        }
    }
    
    func requestWith(methodName:MethodName,imageWithName:String,fileName:String,imageMIMEType:String, image:Data, param:[String: Any],vc:UIViewController!, completion: WSResponseBlock?) {
        
        let urlStr = APIURL.BaseURL + methodName.rawValue
        
        let headers:HTTPHeaders = [
            "Accept": "application/json",
            "Content-type": "multipart/form-data",
            "magishot-api-ios-agent-header" : ApiKeys.kHeaderToken
        ]

        if vc != nil {
            MBProgressHUD.showAdded(to: vc!.view, animated: true)
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            
            for (key, value) in param {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
            multipartFormData.append(image, withName: imageWithName, fileName: fileName, mimeType: imageMIMEType)
        },
                  to: urlStr, method: .post , headers: headers)
        .uploadProgress(closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseData(completionHandler: { (response) in
            
            if vc != nil {
                MBProgressHUD.hide(for: vc!.view, animated: true)
            }
            
            switch response.result {
            case .success(let value):
                let jsonData = nsdataToJSON(data: value)

                if jsonData != nil {
                    let jsonDict = jsonData as? [String : Any]
                    //AESHandler().decryptionResponceData(response: jsonData as! [String : Any])
                    if let theJSONData = try? JSONSerialization.data(
                        withJSONObject: jsonDict,
                        options: []) {
                        let theJSONText = String(data: theJSONData,
                                                 encoding: .ascii)
                        print("JSON string = \(theJSONText!)")
                    }
                    print("Success Response:  \(jsonDict)")
                    if "\(jsonDict?["status"] ?? "")" == "success" {
                        completion?(.success, jsonDict, nil)
                    }
                    else if "\(jsonDict?["status"] ?? "")" == "processing" {
                        completion?(.processing, jsonDict, nil)
                    }
                    else {
                        completion?(.failed, jsonDict, "")
                    }
                }
                else {
                    completion?(.failed, [:], "Something went wrong.")
                }
                break
            case .failure(let error):
                print(error.localizedDescription)
                
                let statusCode = error.responseCode
                print("Status Code : \(String(describing: statusCode))")
                
                switch error {
                    
                case .invalidURL(let url):
                    print("Invalid URL: \(url) - \(error.localizedDescription)")
                case .parameterEncodingFailed(let reason):
                    print("Parameter encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .multipartEncodingFailed(let reason):
                    print("Multipart encoding failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .responseValidationFailed(let reason):
                    print("Response validation failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .responseSerializationFailed(let reason):
                    print("Response serialization failed: \(error.localizedDescription)")
                    print("Failure Reason: \(reason)")
                case .createUploadableFailed(error: let error):
                    print("Response uploading failed: \(error.localizedDescription)")
                case .createURLRequestFailed(error: let error):
                    print("Response create URL failed: \(error.localizedDescription)")
                case .downloadedFileMoveFailed(error: let error, source: _, destination: _):
                    print("Response download file failed: \(error.localizedDescription)")
                case .explicitlyCancelled:
                    print("Response failed")
                case .parameterEncoderFailed(reason: _):
                    print("Response parameter encoding failed: \(error.localizedDescription)")
                case .requestAdaptationFailed(error: let error):
                    print("Response request Adaptation failed: \(error.localizedDescription)")
                case .requestRetryFailed(retryError: _, originalError: _):
                    print("Response retry failed: \(error.localizedDescription)")
                case .serverTrustEvaluationFailed(reason: _):
                    print("Response server trust failed: \(error.localizedDescription)")
                case .sessionDeinitialized:
                    print("Response session deni failed: \(error.localizedDescription)")
                case .sessionInvalidated(error: let error):
                    print("Response session invalid failed: \(String(describing: error?.localizedDescription))")
                case .sessionTaskFailed(error: let error):
                    print("Response session task failed: \(error.localizedDescription)")
                case .urlRequestValidationFailed(reason: _):
                    print("Response request validation failed: \(error.localizedDescription)")
                }
                print("Underlying error: \(String(describing: error.underlyingError))")
                
                completion?(.failed, nil, error.localizedDescription)
            }
        })
    }
    
    func requestWithAudio(_ methodType: HTTPMethod = .post, methodName:MethodName,param:[String:Any],imageWithName:String,fileName:String,imageMIMEType:String, image:Data,vc:UIViewController!, completion: WSResponseBlock?) {
        
        let urlStr = APIURL.BaseURL + methodName.rawValue
        let BearerToken = UserDefaults.standard.object(forKey: "accesss_token") as? String ?? ""
        
        let headers:HTTPHeaders = [
            "Accept": "application/json",
            "Content-type": "multipart/form-data",
            "Authorization": BearerToken == "" ? "" : "Bearer " + BearerToken
        ]
        
        print("URL: \(urlStr)")
        print("Header: \(header)")
        print("Params: \(param)")
        
        if vc != nil {
            MBProgressHUD.showAdded(to: vc!.view, animated: true)
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(image, withName: imageWithName, fileName: fileName, mimeType: imageMIMEType)
            for (key, value) in param {
                
                print(key)
                print(value)
                //let data = (value as! String).data(using: String.Encoding.utf8)!
                let data = (value as AnyObject).data(using: String.Encoding.utf8.rawValue)
                multipartFormData.append(data!, withName: key)
            }
        },
                  to: urlStr, method: .post , headers: headers)
        .uploadProgress(closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseData(completionHandler: { (responseData) in
            
            /// Check with our status code list
            let code: Int = responseData.response?.statusCode ?? 0
            let codeType: StatusCode = StatusCode(rawValue: code) ?? .noStatusCode
            print("Status Code: \(responseData.response?.statusCode ?? 0) - \(codeType)")
            
            if vc != nil {
                MBProgressHUD.hide(for: vc!.view, animated: true)
            }
            
            switch responseData.result {
            /// Success with json response
            case .success(let value):
                let jsonData = nsdataToJSON(data: value)

                if jsonData != nil {
                    let jsonDict = jsonData as? [String : Any]
                    //AESHandler().decryptionResponceData(response: jsonData as! [String : Any])
                    if let theJSONData = try? JSONSerialization.data(
                        withJSONObject: jsonDict,
                        options: []) {
                        let theJSONText = String(data: theJSONData,
                                                 encoding: .ascii)
                        print("JSON string = \(theJSONText!)")
                    }
                    print("Success Response:  \(jsonDict)")
                    if "\(jsonDict?["status"] ?? "")" == "1" {
                        completion?(.success, jsonDict, nil)
                    }
                    else if "\(jsonDict?["status"] ?? "")" == "0" {
                        completion?(.failed, jsonDict, nil)
                    }
                    else {
                        completion?(.failed, jsonDict, "")
                    }
                } else {
                    completion?(.failed, [:], "Something went wrong.")
                }
                break
                
            /// Failur with error
            case .failure(let fError):
                
                if fError.responseCode == NSURLErrorTimedOut || responseData.response?.statusCode  == NSURLErrorTimedOut {
                    completion?(.failed, nil, "Request Time out")
                } else if fError.isSessionTaskError {
                    completion?(.failed, nil, "Could not connect to the server")
                }  else if fError.isExplicitlyCancelledError {
                    completion?(.failed, nil, nil)
                } else {
                    print("Error ResponseCode: \(fError.responseCode ?? 0)")
                    
                    if fError.responseCode == 401 {
//                        _appDelegate.logOutUser() // Force LogOut User due to session/token expire
                    }
                    
                    /// if fails then check data from server
                    if let jsonRawData = responseData.data {
                        do {
                            /// If error data it is not json serialized
                            let jsonData = nsdataToJSON(data: jsonRawData)
                            let jsonDict = jsonData
                            //AESHandler().decryptionResponceData(response: jsonData as? [String : Any] ?? [:])
                            print("Failure Response: \(jsonDict)")
                            let errStr: String? = (jsonDict?["message"] as? String) ?? fError.localizedDescription
                            completion?(.failed, jsonDict as! [String : Any], errStr)
                        }
                        catch let err {
                            // then throm with error description
                            print("Error: \(err.localizedDescription)")
                            completion?(.failed, nil, err.localizedDescription)
                        }
                    } else {
                        print("Error : \(fError)")
                        print("Error Desc: \(fError.localizedDescription)")
                        completion?(.failed, nil, fError.localizedDescription)
                    }
                }
                break
            }
        })
    }
    
    func requestWithImage(_ methodType: HTTPMethod = .post, methodName:MethodName,param:[String:Any],imageWithName:String,fileName:String,imageMIMEType:String, image:Data,vc:UIViewController!, completion: WSResponseBlock?) {
        
        let urlStr = APIURL.BaseURL + methodName.rawValue
        let BearerToken = UserDefaults.standard.object(forKey: "accesss_token") as? String ?? ""
        
        let headers:HTTPHeaders = [
            "Accept": "application/json",
            "Content-type": "multipart/form-data",
            "Authorization": BearerToken == "" ? "" : "Bearer " + BearerToken
        ]
        
        print("URL: \(urlStr)")
        print("Header: \(header)")
        print("Params: \(param)")
        
        if vc != nil {
            MBProgressHUD.showAdded(to: vc!.view, animated: true)
        }
        
        AF.upload(multipartFormData: { multipartFormData in
            
            multipartFormData.append(image, withName: imageWithName, fileName: fileName, mimeType: imageMIMEType)
            for (key, value) in param {
                multipartFormData.append((value as! String).data(using: String.Encoding.utf8)!, withName: key)
            }
        },
                  to: urlStr, method: methodType , headers: headers)
        .uploadProgress(closure: { progress in
            print("Upload Progress: \(progress.fractionCompleted)")
        })
        .responseData(completionHandler: { (responseData) in
            
            /// Check with our status code list
            let code: Int = responseData.response?.statusCode ?? 0
            let codeType: StatusCode = StatusCode(rawValue: code) ?? .noStatusCode
            print("Status Code: \(responseData.response?.statusCode ?? 0) - \(codeType)")
            
            if vc != nil {
                MBProgressHUD.hide(for: vc!.view, animated: true)
            }
            
            switch responseData.result {
            /// Success with json response
            case .success(let value):
                let jsonData = nsdataToJSON(data: value)

                if jsonData != nil {
                    let jsonDict = jsonData as? [String : Any]
                    //AESHandler().decryptionResponceData(response: jsonData as! [String : Any])
                    if let theJSONData = try? JSONSerialization.data(
                        withJSONObject: jsonDict,
                        options: []) {
                        let theJSONText = String(data: theJSONData,
                                                 encoding: .ascii)
                        print("JSON string = \(theJSONText!)")
                    }
                    print("Success Response:  \(jsonDict)")
                    if "\(jsonDict?["status"] ?? "")" == "1" {
                        completion?(.success, jsonDict, nil)
                    }
                    else if "\(jsonDict?["status"] ?? "")" == "0" {
                        completion?(.failed, jsonDict, nil)
                    }
                    else {
                        completion?(.failed, jsonDict, "")
                    }
                } else {
                    completion?(.failed, [:], "Something went wrong.")
                }
                break
                
            /// Failur with error
            case .failure(let fError):
                
                if fError.responseCode == NSURLErrorTimedOut || responseData.response?.statusCode  == NSURLErrorTimedOut {
                    completion?(.failed, nil, "Request Time out")
                } else if fError.isSessionTaskError {
                    completion?(.failed, nil, "Could not connect to the server")
                }  else if fError.isExplicitlyCancelledError {
                    completion?(.failed, nil, nil)
                } else {
                    print("Error ResponseCode: \(fError.responseCode ?? 0)")
                    
                    if fError.responseCode == 401 {
//                        _appDelegate.logOutUser() // Force LogOut User due to session/token expire
                    }
                    
                    /// if fails then check data from server
                    if let jsonRawData = responseData.data {
                        do {
                            /// If error data it is not json serialized
                            let jsonData = nsdataToJSON(data: jsonRawData)
                            let jsonDict = jsonData
                            //AESHandler().decryptionResponceData(response: jsonData as? [String : Any] ?? [:])
                            print("Failure Response: \(jsonDict)")
                            let errStr: String? = (jsonDict?["message"] as? String) ?? fError.localizedDescription
                            completion?(.failed, jsonDict as! [String : Any], errStr)
                        }
                        catch let err {
                            // then throm with error description
                            print("Error: \(err.localizedDescription)")
                            completion?(.failed, nil, err.localizedDescription)
                        }
                    } else {
                        print("Error : \(fError)")
                        print("Error Desc: \(fError.localizedDescription)")
                        completion?(.failed, nil, fError.localizedDescription)
                    }
                }
                break
            }
        })
    }
    
    func isConnectedToInternet() -> Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
}

extension ApiHandler {
    
    private func refreshAccessToken(completionHandler: @escaping(_ success:Bool) -> ()) {
        
        let param = ["refresh": UserDefaults.standard.object(forKey: "refresh_token")!]
        _ = self.request(.post, for: .refreshToken, param: param, vc: nil) { status, json, error in
            
            switch status {
            case .success:
                if let token = json?["access"] as? String {
                    
                    UserDefaults.standard.setValue(token, forKey: "accesss_token")
                    UserDefaults.standard.synchronize()
                }
                completionHandler(true)
            case .processing:
                completionHandler(false)
            case .failed:
                completionHandler(false)
                UserDefaults.standard.removeObject(forKey: "userInfo")
                UserDefaults.standard.removeObject(forKey: "userId")
                UserDefaults.standard.removeObject(forKey: "isLogin")
                UserDefaults.standard.removeObject(forKey: "isSocial")
                UserDefaults.standard.removeObject(forKey: "accesss_token")
                VoiceHandler.shared.arrayVoices.removeAll()
                _appDelegate.makeRootView(rootVC: .Login)
                completionHandler(false)
            }
        }
    }
}
extension ApiHandler {
    
    func downloadFile(_ url: URL, id: String, progressBlock: WSProgressBlock? = nil, isToBeSaved: Bool = true, completion: @escaping WSDownlaodBlock) {
        // Define the file path
        let documentDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let filePath = documentDirectory.appendingPathComponent(id + url.lastPathComponent)
        
        // Check if file exists at path
        if UIApplication.shared.canOpenURL(filePath), FileManager.default.fileExists(atPath: filePath.path) {
            completion(filePath, nil, nil)
        } else {
            var destination: DownloadRequest.Destination? = nil
            if isToBeSaved {
                destination = { _, _ in
                    return (filePath, [])
                }
            }
            
            // Download the file using Alamofire
            alamofireManager.download(url, method: .get, encoding: JSONEncoding.default, to: destination).downloadProgress { progress in
                progressBlock?(progress.fractionCompleted)
            }.response { response in
                completion(response.fileURL, response.error?.localizedDescription, response.resumeData)
            }
        }
    }
    
    func downloadFile(_ resumeData: Data, progressBlock: WSProgressBlock? = nil, completion: @escaping WSDownlaodBlock) {
        
        alamofireManager.download(resumingWith: resumeData).downloadProgress(closure: { (progress) in
            
            progressBlock?(progress.fractionCompleted)
        }).response(completionHandler: { (response) in
            
            completion(response.fileURL, response.error?.localizedDescription, response.resumeData)
        })
    }
}

func nsdataToJSON(data: Data) -> AnyObject? {
    do {
        return try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as AnyObject
    } catch let myJSONError {
        print(myJSONError)
    }
    return nil
}

