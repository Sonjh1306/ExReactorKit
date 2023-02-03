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
        case setLoading(Bool)
    }
    
    struct State {
        var fetchJokeData: Result<Joke, NetworkError>?
        var isLoading: Bool = false
    }
    
    let initialState: State = .init()
}

extension JokeViewReactor {
    
    func mutate(action: Action) -> Observable<Mutation> {

        switch action {
        case .clickButton:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                FetchJokeData.shared.rx.fetch()
                    .asObservable()
                    .materialize()
                    .map({ event -> Event<Result<Joke, NetworkError>> in
                        switch event {
                        case .completed:
                            return .completed
                        case let .next(joke):
                            return .next(Result.success(joke))
                        case let .error(error):
                            return .next(Result.failure(error as! NetworkError))
                        }
                    })
                    .dematerialize()
                    .map(Mutation.fetchJokeData),
                Observable.just(Mutation.setLoading(false))
            ])
            
        case .viewDidAppear:
            return Observable.concat([
                Observable.just(Mutation.setLoading(true)),
                FetchJokeData.shared.rx.fetch()
                    .asObservable()
                    .materialize()
                    .map({ event -> Event<Result<Joke, NetworkError>> in
                        switch event {
                        case .completed:
                            return .completed
                        case let .next(joke):
                            return .next(Result.success(joke))
                        case let .error(error):
                            return .next(Result.failure(error as! NetworkError))
                        }
                    })
                    .dematerialize()
                    .map(Mutation.fetchJokeData),
                Observable.just(Mutation.setLoading(false))
            ])
        }
    }
    
    func reduce(state: State, mutation: Mutation) -> State {
        var newState = state
        
        switch mutation {
        case let .setLoading(isLoading):
            newState.isLoading = isLoading
            
        case let .fetchJokeData(result):
            newState.fetchJokeData = result
            
        }
        return newState
    }
}
