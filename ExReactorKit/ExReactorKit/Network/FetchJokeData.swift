import Foundation
import Moya
import RxSwift

enum NetworkError: Error {
    case urlError
    case networkError
    case decodingError
}

class FetchJokeData: ReactiveCompatible {
    
    static var shared = FetchJokeData()
    let provider: MoyaProvider<JokeAPI> = MoyaProvider<JokeAPI>()
    
    private init() {}
    
    func fetchJokeData(completion: @escaping (Result<Joke, NetworkError>) -> Void) {
        
        self.provider.request(.getJoke) { result in
            switch result {
            case let .success(response):
                do {
                    let result = try response.map(Joke.self)
                    completion(.success(result))
                } catch {
                    print(error.localizedDescription)
                    completion(.failure(.decodingError))
                }
            case let .failure(error):
                print(error.localizedDescription)
                completion(.failure(.networkError))
            }
        }
    }
}

extension Reactive where Base == FetchJokeData {
    func fetch() -> Single<Joke> {
        return Single.create { (single) in
            
            self.base.fetchJokeData { (result) in
                switch result {
                case let .success(joke):
                    single(.success(joke))
                case let .failure(error):
                    single(.failure(error))
                }
            }
            return Disposables.create()
        }
    }
}
