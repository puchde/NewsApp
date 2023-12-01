//
//  APIManager.swift
//  ColorBarTesting
//
//  Created by ZHIWEI XU on 2023/4/3.
//

import Foundation

struct APIManager {
    static var shared = APIManager()
    let semaphore = DispatchSemaphore (value: 10)
    var requests: [URLRequest: URLSessionDataTask] = [:]

    
    static func DataRequest<T:Decodable>(router: APIClientConfig, completion: @escaping (Result<T, Error>)->Void) {
        var request = URLRequest(url: URL(string: router.path)!)
        request.httpMethod = router.httpMethod
        if let query = router.queryParameter {
            let filterQuery = query.filter { item in
                !item.value!.isEmpty
            }
            request.url?.append(queryItems: filterQuery)
        }
        
        // 檢查是否已經有相同的 request 正在進行
        if self.shared.requests[request] != nil {
             print("Request in progress: \(router.path)")
             self.shared.semaphore.signal()
             return
         }
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            defer {
                shared.semaphore.signal()
                shared.requests.removeValue(forKey: request)
             }
            guard let data = data else {
              print(String(describing: error))
              return
            }
            print(String(data: data, encoding: .utf8)!)
            var apiResponse: Result<T, Error> {
                return Result {
                    do {
                        let result = try JSONDecoder().decode(T.self, from: data)
                        return result
                    } catch {
                        print(error)
                        throw error
                    }
                }
            }
            DispatchQueue.main.async {
                completion(apiResponse)
            }
        }
        print("Url: \(String(describing: request.url)), qeuery: \(router.queryParameter)")
        task.resume()
        shared.requests[request] = task
        shared.semaphore.wait()
    }
}

extension APIManager {
    static func topHeadlines(country: String, category: String, completion: @escaping (Result<NewsAPIResponse, Error>) -> Void) {
        APIManager.DataRequest(router: NewsRouter.topHeadlines(type: "topics", country: country, category: category), completion: completion)
    }
    
    static func searchNews(query: String, language: String, completion: @escaping (Result<NewsAPIResponse, Error>) -> Void) {
        let searchDate = newsSettingManager.getSearchDate()
        let language = newsSettingManager.getSearchLanguage().rawValue
        APIManager.DataRequest(router: NewsRouter.searchNews(type: "search", query: query, language: language), completion: completion)
    }
}

enum NewsRouter: APIClientConfig {
    case searchNews(type: String, query: String, language: String)
    case topHeadlines(type: String,country: String, category: String)
    
    static var apiDomain: APIDomainEnum = .prod
    
    var httpMethod: String {
        switch self {
        default: return "GET"
        }
    }
    
    var schema: String {
        switch NewsRouter.apiDomain {
        case .prod:
            return "https"
        case .debug:
            return "http"
        }
    }
    
    var host: String {
        switch NewsRouter.apiDomain {
        case .prod:
            return "gnapi-servicer.onrender.com"
        case .debug:
            return "127.0.0.1:8080"
        }
    }
    
    var urlPrefix: String {
        switch self {
        default:
            return "/googlenews"
        }
    }
    
    var path: String {
        switch self {
        default:
            return "\(schema)://\(host)\(urlPrefix)"
        }
    }
    
    var queryParameter: [URLQueryItem]? {
        switch self {
        case .searchNews(let type, let query, let language):
            let queryItems = [URLQueryItem(name: QueryKey.type, value: type),
                              URLQueryItem(name: QueryKey.q, value: query),
                              URLQueryItem(name: QueryKey.country, value: language)]
            return queryItems
            
        case .topHeadlines(let type, country: let country, let category):
            let queryItems = [URLQueryItem(name: QueryKey.type, value: type),
                              URLQueryItem(name: QueryKey.country, value: country),
                              URLQueryItem(name: QueryKey.category, value: category)]
            return queryItems
        }
    }
}


struct QueryKey {
    static let q = "q"
    static let apiKey = "apiKey"
    static let searchIn = "searchIn"
    static let from = "from"
    static let to = "to"
    static let language = "language"
    static let pageSize = "pageSize"
    static let page = "page"
    static let sortBy = "sortBy"
    static let country = "country"
    static let category = "category"
    static let type = "type"
}

protocol APIClientConfig {
    var httpMethod: String {get}
    var path: String {get}
    var queryParameter: [URLQueryItem]? {get}
}
