import Foundation
import Moya

enum JokeAPI {
    case getJoke
}

extension JokeAPI: TargetType {
    var baseURL: URL {
        switch self {
        case .getJoke: return URL(string: "https://api.chucknorris.io")!
        }
    }
    
    var path: String {
        switch self {
        case .getJoke: return "/jokes/random"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .getJoke: return .get
        }
    }
    
    var task: Moya.Task {
        switch self {
        case .getJoke: return .requestPlain
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .getJoke: return ["Content-Type": "application/json"]
        }
    }
    
    var validationType: ValidationType {
        return .successCodes
    }
}
