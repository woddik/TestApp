//
//  NetworkService.swift
//  TestMovieProject
//
//  Created by Woddi on 17.01.2021.
//

import Foundation
import Combine

struct Parameters {
    
    // MARK: - Constants
    
    private enum Keys: String {
        case apiKey = "api_key"
        case language
        case page
    }
    
    let value: [String: Any]
    
    init(dict: [String: Any] = [:], page: Int? = nil) {
        var tmpResult: [String: Any] = [Keys.apiKey.rawValue: "1cc33b07c9aa5466f88834f7042c9258",
                                        Keys.language.rawValue: "ru"]
        if let page = page {
            tmpResult[Keys.page.rawValue] = page
        }
        dict.keys.forEach({ tmpResult[$0] = dict[$0] })
        value = tmpResult
    }
}

protocol Requstable {
    
    typealias Headers = [String: String]

    var baseURL: String { get }
    
    var path: String { get }
    
    var headers: Headers? { get }
    
    var method: HttpMethod { get }
    
    var parameters: Parameters? { get }

    var isURLConvertible: Bool { get }
    
}

extension Requstable {
    
    var baseURL: String {
        return NetworkService.Defaults.baseURL
    }

    var headers: Headers? {
        return NetworkService.Defaults.headers
    }
    
    var method: HttpMethod {
        return .get
    }

    var isURLConvertible: Bool {
        return method.isURLConvertible
    }

    var parameters: Parameters? {
        return Parameters()
    }

}

struct ArrayDecodableItem<T: Decodable>: Decodable {
    enum CodingKeys: String, CodingKey {
        case array = "results"
    }
    
    let array: [T]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        array = try container.decodeIfPresent([T].self, forKey: .array) ?? []
    }
}

final class NetworkService {
    
    struct Defaults {
        
        static let imageBaseURL = "https://image.tmdb.org/t/p/original"

        fileprivate static let baseURL = "https://api.themoviedb.org/3/"
        
        fileprivate static var headers: [String: String] {
            return ["Accept": "application/json",
                    "Content-Type": "application/json; charset=UTF-8"]
        }
    }
    

    
    private let session: URLSession = .shared
    private var cancellables = Set<AnyCancellable>()
    
    func run<T: Decodable>(requestable: Requstable,
                           success: @escaping (T) -> Void,
                           failure: ((NetworkError) -> Void)? = nil) {
        switch prepareRequest(from: requestable) {
        case .success(let request):
            run(request: request)
                .sink(receiveCompletion: { error in
                    switch error {
                    case .finished: print("🏁 finished")
                    case .failure(let error):
                        failure?(error)
                    }
                }, receiveValue: success)
                .store(in: &cancellables)
        case .failure(let error):
            failure?(error)
        }
    }
    
    func run<T: Decodable>(request: URLRequest,
                           with decoder: JSONDecoder = JSONDecoder()) -> AnyPublisher<T, NetworkError> {
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)

        return session
            .dataTaskPublisher(for: request)
            .tryMap { [request] result -> T in
                NetworkService.printDataResponse(result.response, request: request, data: result.data)
                return try decoder.decode(T.self, from: result.data)
            }
            .receive(on: DispatchQueue.main)
            .mapError({ NetworkError(error: $0) })
            .eraseToAnyPublisher()
    }
    
    func cancelAll() {
        cancellables.forEach({ $0.cancel() })
    }
}

// MARK: - Private methods

private extension NetworkService {
    
    func prepareRequest(from item: Requstable) -> Result<URLRequest, NetworkError> {
        let urlPath = item.baseURL + item.path
        guard var url = URL(string: urlPath) else {
            return .failure(.badRequest)
        }
        if item.isURLConvertible {
            if let newURL = url.appending(parameters: item.parameters?.value) {
                url = newURL
            } else {
                return .failure(.badRequest)
            }
        }
        var request = URLRequest(url: url)
        request.httpMethod = item.method.rawValue
        if let headers = item.headers {
            request.setHeadersForHTTPHeaderField(headers)
        }
        if let params = item.parameters ,!item.isURLConvertible {
            do {
                request.httpBody = try JSONSerialization.data(withJSONObject: params, options: .prettyPrinted)
            } catch {
                return .failure(.badRequest)
            }
        }
        return .success(request)
    }
    
    static func printDataResponse(_ dataResponse: URLResponse?, request: URLRequest?, data: Data?) {
        #if DEBUG
            var printString = "\n\n-------------------------------------------------------------\n"
            
            if let urlDataResponse = dataResponse as? HTTPURLResponse {
                let statusCode = urlDataResponse.statusCode
                printString += "\(statusCode == 200 ? "SUCCESS" : "ERROR") \(statusCode)\n"
            }
            
            var responceArray: [[String: Any]] = []
            // REQUEST
            if let request = request {
                var requestArray: [[String: Any]] = []
                
                // URL
                requestArray.append(["!!!<URL>!!!": request.url?.absoluteString ?? ""])
                
                // HEADERS
                if let headers = request.allHTTPHeaderFields {
                    requestArray.append(["!!!<HEADERS>!!!": headers])
                } else {
                    requestArray.append(["!!!<HEADERS>!!!": ["SYSTEM PRINT": "No Headers"]])
                }
                
                // PARAMETERS
                if let httpBody = request.httpBody {
                    do {
                        let temDictData = try JSONSerialization.jsonObject(with: httpBody, options: .allowFragments)
                        requestArray.append(["!!!<PARAMETERS>!!!": temDictData])
                    } catch {
                        requestArray.append(["!!!<PARAMETERS>!!!": ["SYSTEM PRINT": "Throw error: \(error)"]])
                    }
                }
                
                responceArray.append(["!!!<REQUEST>!!!": requestArray])
            } else {
                responceArray.append(["!!!<REQUEST>!!!": [["SYSTEM PRINT": "No Request"]]])
            }
            
            // RESPONSE
            do {
                if let data = data {
                    let temDictData = try JSONSerialization.jsonObject(with: data, options: .allowFragments)
                    responceArray.append(["!!!<RESPONSE>!!!": temDictData])
                } else {
                    responceArray.append(["!!!<RESPONSE>!!!": ["SYSTEM PRINT": "No Data"]])
                }
                
            } catch {
                responceArray.append(["!!!<RESPONSE>!!!": ["SYSTEM PRINT": "Throw error: \(error)"]])
            }
            
            // Print
            do {
                var httpMethod = request?.httpMethod ?? ""
                if !httpMethod.isEmpty {
                    httpMethod += "\n"
                }
                
                let data = try JSONSerialization.data(withJSONObject: ["!!!<RESTAPIMANAGER>!!!": responceArray], options: .prettyPrinted)
                var responceString = String.init(data: data, encoding: .utf8) ?? ""
                responceString = responceString.replacingOccurrences(of: "\"!!!<RESTAPIMANAGER>!!!\" :", with: "")
                responceString = responceString.replacingOccurrences(of: "{\n   [\n    {\n      \"!!!<REQUEST>!!!\" : ", with: "\n\(httpMethod)REQUEST:")
                responceString = responceString.replacingOccurrences(of: "[\n        {\n          \"!!!<URL>!!!\" : ", with: "\n\tURL: \n\t\t  ")
                responceString = responceString.replacingOccurrences(of: "        },\n        {\n          \"!!!<HEADERS>!!!\" : ", with: "\tHEADERS: \n\t\t  ")
                responceString = responceString.replacingOccurrences(of: "\n        },\n        {\n          \"!!!<PARAMETERS>!!!\" : ", with: "\n\tPARAMETERS:\n\t\t  ")
                responceString = responceString.replacingOccurrences(of: "\n        }\n      ]\n    },\n    {\n      \"!!!<RESPONSE>!!!\" : ", with: "\nRESPONSE:\n\t  ")
                responceString = responceString.replacingOccurrences(of: "\\/", with: "/")
                if responceString.count > 12 {
                    responceString.removeLast(12) // "\n    }\n  ]\n}"
                }
                
                if responceString.isEmpty {
                    responceString = "Can't create string from responce"
                }
                
                printString += responceString + "\n"
            } catch {
                printString += "ERROR PRINTING RESPONCE\n"
            }
            
            printString += "-------------------------------------------------------------\n\n"
            
            print(printString)
        #endif
    }
}

fileprivate extension URLRequest {
    
    mutating func setHeadersForHTTPHeaderField(_ headers: Requstable.Headers) {
        headers.keys.forEach({
            setValue(headers[$0], forHTTPHeaderField: $0)
        })
    }
    
    func setParameters(_ params: [String: Any], isURLConvertible: Bool) {
        if isURLConvertible {
            
        }
    }
}

fileprivate extension URL {

    func appending(parameters: [String: Any]?) -> URL? {
        guard let parameters = parameters else {
            return self
        }
        let queryItems: [URLQueryItem] = parameters.keys.compactMap({
            if let param = parameters[$0] {
                return URLQueryItem(name: $0, value: "\(param)")
            }
            return nil
        })
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            return nil
        }
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems

        return urlComponents.url
    }
}
