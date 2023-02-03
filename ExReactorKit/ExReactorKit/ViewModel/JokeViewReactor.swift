import Foundation
import RxSwift
import RxCocoa
import ReactorKit

class JokeViewReactor: Reactor {
    
    enum Action {
        case viewDidAppear
        case clickButton
    }
    
    enum Mutation {
        case fetchJokeData(Result<Joke, NetworkError>)
    }
    
    struct State {
        var fetchJokeData: Result<Joke, NetworkError>?
        
        var displayIcon: String? {
            return fetchJokeData.flatMap { (result) in
                switch result {
                case let .success(joke):
                    return "\(joke.iconURL)"
                default:
                    return nil
                }
            }
        }

        var displayId: String? {
            return fetchJokeData.flatMap { (result) in
                switch result {
                case let .success(joke):
                    return "\(joke.id)"
                default:
                    return nil
                }
            }
        }

        var displayUpdateAt: String? {
            return fetchJokeData.flatMap { (result) in
                switch result {
                case let .success(joke):
                    return "\(joke.updatedAt)"
                default:
                    return nil
                }
            }
        }

        var displayUrl: String? {
            return fetchJokeData.flatMap { (result) in
                switch result {
                case let .success(joke):
                    return "\(joke.url)"
                default:
                    return nil
                }
            }
        }

        var displayValue: String? {
            return fetchJokeData.flatMap { (result) in
                switch result {
                case let .success(joke):
                    return "\(joke.value)"
                default:
                    return nil
                }
            }
        }
        
        var jokeData: Joke? {
            return fetchJokeData.flatMap { (result) in
                switch result {
                case let .success(joke):
                    return joke
                default:
                    return nil
                }
            }
        }
        
        var isLoading: Bool = false
    }
    
    let initialState: State = .init()
}

extension JokeViewReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {
        switch action {
        case .clickButton:
            return FetchJokeData.shared.rx.fetch()
                .asObservable()
                .materialize()
                .map({ event -> Event<Result<Joke, NetworkError>> in
                    switch event {
                    case .completed:
                        return .completed
                    case let .error(error):
                        return .next(Result.failure(error as! NetworkError))
                    case let .next(joke):
                        return .next(Result.success(joke))
                    }
                })
                .dematerialize()
                .map(Mutation.fetchJokeData)
        case .viewDidAppear:
            return FetchJokeData.shared.rx.fetch()
                .asObservable()
                .materialize()
                .map({ event -> Event<Result<Joke, NetworkError>> in
                    switch event {
                    case .completed:
                        return .completed
                    case let .error(error):
                        return .next(Result.failure(error as! NetworkError))
                    case let .next(joke):
                        return .next(Result.success(joke))
                    }
                })
                .dematerialize()
                .map(Mutation.fetchJokeData)
        }
    }

    // 이전 State와 다음 Mutation을 파라미터로 받아 다음 State를 반환
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case .fetchJokeData(let result):
            newState.fetchJokeData = result
        }
        return newState
    }
}
