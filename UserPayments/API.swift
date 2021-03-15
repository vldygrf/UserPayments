//
//  NSApi.swift
//  UserPayments
//
//  Created by Vladislav Garifulin on 24.02.2021.
//
//  login=demo, password=12345

import Foundation

enum APIError: Error {
    case httpQueryError(code: Int, message: String)
}

final class API {
    static let shared = API()
    private var token: String?
    private let baseURL = URL(string: "http://82.202.204.94/api/")
    private let headerFields = ["app-key" : "12345", "v" : "1"]
    
    private func prepare(request: inout URLRequest) {
        for (key, value) in headerFields {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
    
    private func getAnswer(data: Data?, response: URLResponse?) -> (error: APIError?, response: AnyObject?) {
        if let response = response {
            print(response)
        }
        
        guard let data = data else {
            return (APIError.httpQueryError(code: 0, message: "the data is empty"), nil)
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: AnyObject] else {
            return (APIError.httpQueryError(code: 0, message: "JSONSerialization error"), nil)
        }
        
        if let error = json["error"] as? [String : Any], let code = error["error_code"] as? Int, let msg = error["error_msg"] as? String {
            return (APIError.httpQueryError(code: code, message: msg), nil)
        }
        
        if let success = json["success"] as? String, success == "true" {
            return (nil, json["response"])
        }
    
        return (APIError.httpQueryError(code: 0, message: "response parsing error"), nil)
    }
        
    func connect(login: String, password: String, completion: @escaping (_ error: Error?) -> Void) {
        disconnect()
        
        guard let url = URL(string: "login", relativeTo: baseURL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = "login=\(login)&password=\(password)".data(using: String.Encoding.utf8)
        prepare(request: &request)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            guard error == nil else {
                completion(error)
                return
            }
            
            let answer = self.getAnswer(data: data, response: response)
            if let error = answer.error {
                completion(error)
                return
            }
            
            if let token = answer.response?["token"] as? String {
                self.token = token
                completion(nil)
            } else {
                completion(APIError.httpQueryError(code: 0, message: "the token is not received"))
            }
        }.resume()
    }
    
    func payments(completion: @escaping (_ error: Error?,_ payments: Array<Dictionary<String, Any>>?) -> Void) {
        guard let token = token else {
            return
        }
        
        guard let url = URL(string: "payments?token=\(token)", relativeTo: baseURL) else {
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        prepare(request: &request)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let self = self else {
                return
            }
            
            guard error == nil else {
                completion(error, nil)
                return
            }
            
            let answer = self.getAnswer(data: data, response: response)
            if let error = answer.error {
                completion(error, nil)
                return
            }
            
            if let payments = answer.response as? Array<Dictionary<String, Any>> {
                completion(nil, payments)
            } else {
                completion(APIError.httpQueryError(code: 0, message: "the payments are not received"), nil)
            }
        }.resume()
    }
    
    func disconnect() {
        token = nil
    }
}
