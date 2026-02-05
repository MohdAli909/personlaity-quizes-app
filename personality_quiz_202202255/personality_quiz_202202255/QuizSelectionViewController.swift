//
//  QuizSelectionViewController.swift
//  PersonalityQuiz
//

import UIKit

class QuizSelectionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var quizCollectionView: UICollectionView!
    @IBOutlet var historyButton: UIBarButtonItem!
    
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Quiz Data
    struct Quiz {
        let title: String
        let emoji: String
        let description: String
        let color: UIColor
        let identifier: String
    }
    
    let quizzes: [Quiz] = [
        Quiz(
            title: "What Should You Study?",
            emoji: "🎓",
            description: "Discover your ideal college major based on your personality",
            color: UIColor(red: 108/255, green: 99/255, blue: 255/255, alpha: 1.0),
            identifier: "major-quiz"
        ),
        Quiz(
            title: "Which Animal Are You?",
            emoji: "🦁",
            description: "Find out which animal best matches your personality",
            color: UIColor(red: 255/255, green: 107/255, blue: 129/255, alpha: 1.0),
            identifier: "animal-quiz"
        )
    ]
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupNavigationBar()
        setupCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        quizCollectionView.reloadData()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    // MARK: - Setup Methods
    func setupGradientBackground() {
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        let topColor = UIColor(red: 108/255, green: 99/255, blue: 255/255, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 136/255, green: 84/255, blue: 255/255, alpha: 1.0).cgColor
        
        gradient.colors = [topColor, bottomColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    func setupNavigationBar() {
        navigationController?.navigationBar.prefersLargeTitles = false
        navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        navigationController?.navigationBar.shadowImage = UIImage()
        navigationController?.navigationBar.isTranslucent = true
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
    }
    
    func setupCollectionView() {
        quizCollectionView.delegate = self
        quizCollectionView.dataSource = self
        quizCollectionView.backgroundColor = .clear
        
        // Register cell
        quizCollectionView.register(QuizCell.self, forCellWithReuseIdentifier: "QuizCell")
        
        // Setup layout
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.minimumLineSpacing = 20
        layout.minimumInteritemSpacing = 16
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 20, right: 20)
        
        quizCollectionView.collectionViewLayout = layout
    }
    
    // MARK: - Actions
    @IBAction func showHistoryTapped(_ sender: Any) {
        performSegue(withIdentifier: "showHistory", sender: nil)
    }
}

// MARK: - UICollectionView DataSource & Delegate
extension QuizSelectionViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return quizzes.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "QuizCell", for: indexPath) as! QuizCell
        let quiz = quizzes[indexPath.item]
        
        // Check if quiz has been completed
        let hasCompleted = QuizHistoryManager.shared.hasCompletedQuiz(identifier: quiz.identifier)
        
        cell.configure(with: quiz, isCompleted: hasCompleted)
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let padding: CGFloat = 40 // 20 on each side
        let availableWidth = collectionView.frame.width - padding - 16 // 16 for spacing
        let cellWidth = availableWidth / 2
        return CGSize(width: cellWidth, height: cellWidth * 1.3)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let quiz = quizzes[indexPath.item]
        
        if quiz.identifier == "major-quiz" {
            performSegue(withIdentifier: "showMajorQuiz", sender: nil)
        } else if quiz.identifier == "animal-quiz" {
            performSegue(withIdentifier: "showAnimalQuiz", sender: nil)
        }
    }
}

// MARK: - QuizCell
class QuizCell: UICollectionViewCell {
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 60)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(white: 1.0, alpha: 0.8)
        label.textAlignment = .center
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let completedBadge: UILabel = {
        let label = UILabel()
        label.text = "✓"
        label.font = UIFont.systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
        label.backgroundColor = UIColor(red: 76/255, green: 217/255, blue: 100/255, alpha: 1.0)
        label.textAlignment = .center
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        label.isHidden = true
        return label
    }()
    
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 20
        view.clipsToBounds = true
        return view
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        contentView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(titleLabel)
        containerView.addSubview(descriptionLabel)
        containerView.addSubview(completedBadge)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            completedBadge.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 10),
            completedBadge.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -10),
            completedBadge.widthAnchor.constraint(equalToConstant: 24),
            completedBadge.heightAnchor.constraint(equalToConstant: 24),
            
            emojiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 20),
            emojiLabel.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            emojiLabel.heightAnchor.constraint(equalToConstant: 70),
            
            titleLabel.topAnchor.constraint(equalTo: emojiLabel.bottomAnchor, constant: 12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            descriptionLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            descriptionLabel.bottomAnchor.constraint(lessThanOrEqualTo: containerView.bottomAnchor, constant: -12)
        ])
    }
    
    func configure(with quiz: QuizSelectionViewController.Quiz, isCompleted: Bool) {
        emojiLabel.text = quiz.emoji
        titleLabel.text = quiz.title
        descriptionLabel.text = quiz.description
        
        // Glass effect with quiz color
        containerView.backgroundColor = quiz.color.withAlphaComponent(0.4)
        
        // Add subtle border
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.white.withAlphaComponent(0.2).cgColor
        
        // Show completed badge if quiz has been completed
        completedBadge.isHidden = !isCompleted
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        emojiLabel.text = nil
        titleLabel.text = nil
        descriptionLabel.text = nil
        completedBadge.isHidden = true
    }
}
