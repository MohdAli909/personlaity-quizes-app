

import UIKit

class QuizHistoryViewController: UIViewController {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var emptyStateLabel: UILabel!
    @IBOutlet var statsView: UIView!
    @IBOutlet var totalQuizzesLabel: UILabel!
    @IBOutlet var totalTimeLabel: UILabel!
    
    private var gradientLayer: CAGradientLayer?
    private var history: [QuizHistoryManager.QuizResult] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        setupNavigationBar()
        setupTableView()
        loadHistory()
        setupStatsView()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
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
        title = "Quiz History"
        
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.tintColor = .white
        
        // Add clear history button
        let clearButton = UIBarButtonItem(title: "Clear All", style: .plain, target: self, action: #selector(clearHistoryTapped))
        navigationItem.rightBarButtonItem = clearButton
    }
    
    func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.register(HistoryCell.self, forCellReuseIdentifier: "HistoryCell")
    }
    
    func setupStatsView() {
        statsView?.backgroundColor = UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 0.4)
        statsView?.layer.cornerRadius = 16
        statsView?.clipsToBounds = true
    }
    
    func loadHistory() {
        history = QuizHistoryManager.shared.getHistory()
        
        // Update UI
        emptyStateLabel?.isHidden = !history.isEmpty
        tableView.isHidden = history.isEmpty
        statsView?.isHidden = history.isEmpty
        
        // Update stats
        let stats = QuizHistoryManager.shared.getStatistics()
        totalQuizzesLabel?.text = "\(stats.totalQuizzes) Quizzes Completed"
        
        let minutes = Int(stats.totalTime) / 60
        totalTimeLabel?.text = "Total Time: \(minutes) min"
        
        tableView.reloadData()
    }
    
    @objc func clearHistoryTapped() {
        let alert = UIAlertController(
            title: "Clear All History?",
            message: "This will permanently delete all your quiz results.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        alert.addAction(UIAlertAction(title: "Clear", style: .destructive) { [weak self] _ in
            QuizHistoryManager.shared.clearHistory()
            self?.loadHistory()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableView DataSource & Delegate
extension QuizHistoryViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return history.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "HistoryCell", for: indexPath) as! HistoryCell
        let result = history[indexPath.row]
        cell.configure(with: result)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            QuizHistoryManager.shared.deleteResult(at: indexPath.row)
            loadHistory()
        }
    }
}

// MARK: - HistoryCell
class HistoryCell: UITableViewCell {
    
    private let containerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 0.4)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let emojiLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 50)
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let quizTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14, weight: .medium)
        label.textColor = UIColor(white: 1.0, alpha: 0.7)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let resultLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        label.textColor = .white
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 13, weight: .regular)
        label.textColor = UIColor(white: 1.0, alpha: 0.6)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupCell()
    }
    
    private func setupCell() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(emojiLabel)
        containerView.addSubview(quizTitleLabel)
        containerView.addSubview(resultLabel)
        containerView.addSubview(dateLabel)
        containerView.addSubview(timeLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            emojiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            emojiLabel.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            emojiLabel.widthAnchor.constraint(equalToConstant: 60),
            
            quizTitleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            quizTitleLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            quizTitleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            resultLabel.topAnchor.constraint(equalTo: quizTitleLabel.bottomAnchor, constant: 4),
            resultLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            resultLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
            
            dateLabel.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 8),
            dateLabel.leadingAnchor.constraint(equalTo: emojiLabel.trailingAnchor, constant: 12),
            
            timeLabel.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12)
        ])
    }
    
    func configure(with result: QuizHistoryManager.QuizResult) {
        emojiLabel.text = result.resultEmoji
        quizTitleLabel.text = result.quizTitle
        resultLabel.text = result.result
        dateLabel.text = result.formattedDate
        timeLabel.text = "⏱ \(result.formattedTime)"
    }
}
