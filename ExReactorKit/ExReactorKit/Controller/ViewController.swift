import UIKit
import SnapKit
import Moya
import Kingfisher
import ReactorKit

final class ViewController: UIViewController, View {
    
    private let iconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .green
        return imageView
    }()
    
    private let idLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let updateAtLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let urlLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private let valueLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.textColor = .black
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var changeButton: UIButton = {
        let button = UIButton()
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 10
        button.setTitle("CHANGE", for: .normal)
        button.backgroundColor = .blue
        return button
    }()
    
    private lazy var activityIndicator: UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 50, height: 50)
        activityIndicator.center = self.view.center
        activityIndicator.color = UIColor.red
        activityIndicator.hidesWhenStopped = true
        activityIndicator.style = UIActivityIndicatorView.Style.large
        activityIndicator.color = .black
        activityIndicator.stopAnimating()
        return activityIndicator
    }()
    
    var disposeBag = DisposeBag()
    let reactor = JokeViewReactor()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureConstraints()
        self.view.backgroundColor = .white
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bind(reactor: reactor)
        reactor.action.onNext(.viewDidAppear)
    }
    
    private func addSubViews() {
        self.view.addSubview(iconImageView)
        self.view.addSubview(idLabel)
        self.view.addSubview(updateAtLabel)
        self.view.addSubview(urlLabel)
        self.view.addSubview(valueLabel)
        self.view.addSubview(changeButton)
        self.view.addSubview(activityIndicator)
    }
    
    private func configureConstraints() {
        addSubViews()
        
        iconImageView.snp.makeConstraints {
            $0.top.equalToSuperview().inset(100)
            $0.centerX.equalToSuperview()
            $0.size.equalTo(50)
        }
        
        idLabel.snp.makeConstraints {
            $0.top.equalTo(iconImageView.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        updateAtLabel.snp.makeConstraints {
            $0.top.equalTo(idLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        urlLabel.snp.makeConstraints {
            $0.top.equalTo(updateAtLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        valueLabel.snp.makeConstraints {
            $0.top.equalTo(urlLabel.snp.bottom).offset(30)
            $0.leading.trailing.equalToSuperview().inset(30)
            $0.centerX.equalToSuperview()
        }
        
        changeButton.snp.makeConstraints {
            $0.top.equalTo(valueLabel.snp.bottom).offset(50)
            $0.centerX.equalToSuperview()
            $0.width.equalTo(100)
            $0.height.equalTo(50)
        }
    }
    
    func bind(reactor: JokeViewReactor)  {
        self.changeButton.rx.tap
            .map{ .clickButton }
            .bind(to: reactor.action)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.isLoading)
            .distinctUntilChanged()
            .bind(to: self.activityIndicator.rx.isAnimating)
            .disposed(by: disposeBag)
        
        reactor.state.map(\.fetchJokeData)
            .subscribe{ [weak self] (joke) in
                switch joke {
                case .next(.success(let joke)):
                    self?.configureJokeData(joke: joke)
                case .next(.failure(let error)):
                    switch error {
                    case .decodingError:
                        print("Decoding Error")
                    case .networkError:
                        print("Network Error")
                    case .urlError:
                        print("URL Error")
                    }
                default:
                    print("Unknown")
                }
            }.disposed(by: disposeBag)
    }
    
    private func configureJokeData(joke: Joke) {
        let imageUrl = URL(string: joke.iconURL)
        self.iconImageView.kf.setImage(with: imageUrl)
        
        self.idLabel.text = joke.id
        self.updateAtLabel.text = joke.updatedAt
        self.urlLabel.text = joke.url
        self.valueLabel.text = joke.value
    }
}

