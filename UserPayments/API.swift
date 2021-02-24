//
//  NSApi.swift
//  UserPayments
//
//  Created by Vladislav Garifulin on 24.02.2021.
//

import Foundation

enum APIError: Error {
    case httpQueryError(code: Int, message: String)
}

class API {
    static let shared = API()
    private var token: String?
    private let baseURL = URL(string: "http://82.202.204.94/api/")
    private let headerFields = ["app-key" : "12345", "v" : "1"]
    
    private func prepare(request: inout URLRequest) {
        for (key, value) in headerFields {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func getAnswer(data: Data?, response: URLResponse?) -> (error: Dictionary<String, Any>?, response: AnyObject?)? {
        if let httpResponse = response as? HTTPURLResponse {
            if (httpResponse.statusCode == 200) {
                if (data != nil) {
                    if let json: [String: AnyObject] = try? JSONSerialization.jsonObject(with: data!, options: .mutableContainers) as? [String: AnyObject] {
                        if let success = json["success"] as? String, success == "true" {
                            return (nil, json["response"])
                        }else {
                            return (json["error"] as? [String : Any], nil)
                        }
                    }
                }
            }
        }
        
        return nil
    }
        
    func connect(login: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        var request = URLRequest(url: URL(string: "login", relativeTo: baseURL)!)
        request.httpMethod = "POST"
        request.httpBody = "login=\(login)&password=\(password)".data(using: String.Encoding.utf8)
        prepare(request: &request)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            if (error == nil) {
                var errorBack: Dictionary<String, Any>?
                
                if let answer = self.getAnswer(data: data, response: response) {
                    if (answer.error == nil) {
                        self.token = answer.response?["token"] as? String
                    }else {
                        errorBack = answer.error
                    }
                }
                
                if (self.token != nil) {
                    completion(nil)
                }else {
                    if let eb = errorBack, let code = eb["error_code"] as? Int, let msg = eb["error_msg"] as? String {
                        completion(APIError.httpQueryError(code: code, message: msg))
                    }else {
                        completion(APIError.httpQueryError(code: 0, message: "the token is not received"))
                    }
                }
            }else {
                completion(error)
            }
        }
        
        task.resume()
    }
    
    func payments(completion: @escaping (_ error: Error?,_ payments: Array<Dictionary<String, Any>>?) -> Void) {
        guard (token != nil) else {
            completion(APIError.httpQueryError(code: 0, message: "the token is not received"), nil)
            return
        }
        var request = URLRequest(url: URL(string: "payments?token=\(self.token!)", relativeTo: baseURL)!)
        request.httpMethod = "GET"
        prepare(request: &request)
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            if let answer = self.getAnswer(data: data, response: response) {
                if (error == nil) {
                    if let payments: Array<Dictionary<String, Any>> = answer.response as? Array<Dictionary<String, Any>> {
                        completion(nil, payments)
                    }else {
                        completion(APIError.httpQueryError(code: 0, message: "the payments are not received"), nil)
                    }
                }else {
                    completion(error, nil)
                }
            }
        }
        task.resume()
    }
    
    func logout() {
        token = nil
    }
}
