

import UIKit

class ResultsViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var resultEmojiLabel: UILabel!
    @IBOutlet var resultAnswerLabel: UILabel!
    @IBOutlet var resultDefinitionLabel: UILabel!
    @IBOutlet var definitionContainerView: UIView!
    
    // Trait bars outlets
    @IBOutlet var traitsContainerView: UIView!
    @IBOutlet var trait1Label: UILabel!
    @IBOutlet var trait1ProgressView: UIProgressView!
    @IBOutlet var trait1ValueLabel: UILabel!
    
    @IBOutlet var trait2Label: UILabel!
    @IBOutlet var trait2ProgressView: UIProgressView!
    @IBOutlet var trait2ValueLabel: UILabel!
    
    @IBOutlet var trait3Label: UILabel!
    @IBOutlet var trait3ProgressView: UIProgressView!
    @IBOutlet var trait3ValueLabel: UILabel!
    
    // MARK: - Properties
    var responses: [Answer] = []
    var quizType: QuestionViewController.QuizType = .major
    var totalTimeTaken: TimeInterval = 0
    private var gradientLayer: CAGradientLayer?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        navigationItem.hidesBackButton = true
        setupNavigationBar()
        styleContainerViews()
        calculatePersonalityResult()
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
        navigationController?.navigationBar.titleTextAttributes = [
            .foregroundColor: UIColor.white,
            .font: UIFont.systemFont(ofSize: 17, weight: .semibold)
        ]
        navigationController?.navigationBar.tintColor = .white
        
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        navigationController?.navigationBar.standardAppearance = appearance
        navigationController?.navigationBar.scrollEdgeAppearance = appearance
        
        navigationItem.title = "Results"
        
        // Add "Done" button to return to quiz selection
        let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneTapped))
        navigationItem.rightBarButtonItem = doneButton
    }
    
    @objc func doneTapped() {
        // Navigate back to quiz selection (root view controller)
        navigationController?.popToRootViewController(animated: true)
    }
    
    func styleContainerViews() {
        definitionContainerView?.backgroundColor = UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 0.4)
        definitionContainerView?.layer.cornerRadius = 20
        definitionContainerView?.clipsToBounds = true
        
        traitsContainerView?.backgroundColor = UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 0.4)
        traitsContainerView?.layer.cornerRadius = 20
        traitsContainerView?.clipsToBounds = true
    }
    
    // MARK: - Calculate Results
    func calculatePersonalityResult() {
        guard !responses.isEmpty else {
            resultEmojiLabel?.text = "❓"
            resultEmojiLabel?.font = UIFont.systemFont(ofSize: 100)
            resultAnswerLabel.text = "No answers provided"
            resultDefinitionLabel.text = "Please take the quiz again"
            return
        }
        
        switch quizType {
        case .major:
            calculateMajorResult()
        case .animal:
            calculateAnimalResult()
        }
    }
    
    func calculateMajorResult() {
        let majorTypes = responses.compactMap { $0.type.majorType }
        let frequencyOfAnswers = majorTypes.reduce(into: [:]) { counts, type in
            counts[type, default: 0] += 1
        }
        
        guard let mostCommonAnswer = frequencyOfAnswers.sorted(by: { $0.1 > $1.1 }).first?.key else {
            showError()
            return
        }
        
        // Display result
        resultEmojiLabel?.text = mostCommonAnswer.rawValue
        resultEmojiLabel?.font = UIFont.systemFont(ofSize: 100)
        resultAnswerLabel.text = "You should study \(mostCommonAnswer.fullName.components(separatedBy: " & ").first ?? "")!"
        resultDefinitionLabel.text = mostCommonAnswer.definition
        
        // Setup trait bars
        setupTraitBarsForMajor(mostCommonAnswer)
        
        // Save to history
        saveResultToHistory(
            quizIdentifier: "major-quiz",
            quizTitle: "What Should You Study?",
            result: mostCommonAnswer.fullName,
            emoji: mostCommonAnswer.rawValue,
            definition: mostCommonAnswer.definition
        )
    }
    
    func calculateAnimalResult() {
        let animalTypes = responses.compactMap { $0.type.animalType }
        let frequencyOfAnswers = animalTypes.reduce(into: [:]) { counts, type in
            counts[type, default: 0] += 1
        }
        
        guard let mostCommonAnswer = frequencyOfAnswers.sorted(by: { $0.1 > $1.1 }).first?.key else {
            showError()
            return
        }
        
        // Display result
        resultEmojiLabel?.text = String(mostCommonAnswer.rawValue)
        resultEmojiLabel?.font = UIFont.systemFont(ofSize: 100)
        resultAnswerLabel.text = "You are a \(mostCommonAnswer.fullName)!"
        resultDefinitionLabel.text = mostCommonAnswer.definition
        
        // Setup trait bars
        setupTraitBarsForAnimal(mostCommonAnswer)
        
        // Save to history
        saveResultToHistory(
            quizIdentifier: "animal-quiz",
            quizTitle: "Which Animal Are You?",
            result: mostCommonAnswer.fullName,
            emoji: String(mostCommonAnswer.rawValue),
            definition: mostCommonAnswer.definition
        )
    }
    
    func showError() {
        resultEmojiLabel?.text = "❓"
        resultEmojiLabel?.font = UIFont.systemFont(ofSize: 100)
        resultAnswerLabel.text = "Error calculating results"
        resultDefinitionLabel.text = "Please try again"
    }
    
    func saveResultToHistory(quizIdentifier: String, quizTitle: String, result: String, emoji: String, definition: String) {
        QuizHistoryManager.shared.saveQuizResult(
            quizIdentifier: quizIdentifier,
            quizTitle: quizTitle,
            result: result,
            resultEmoji: emoji,
            resultDescription: definition,
            timeTaken: totalTimeTaken
        )
    }
    
    // MARK: - Trait Bars
    func setupTraitBarsForMajor(_ majorType: MajorType) {
        guard trait1ProgressView != nil else { return }
        
        var traits: [(String, Float)] = []
        
        switch majorType {
        case .business:
            traits = [
                ("Leadership", 0.95),
                ("Communication", 0.92),
                ("Strategic Thinking", 0.88)
            ]
        case .engineering:
            traits = [
                ("Problem Solving", 0.96),
                ("Analytical Skills", 0.94),
                ("Technical Aptitude", 0.90)
            ]
        case .arts:
            traits = [
                ("Creativity", 0.98),
                ("Expression", 0.92),
                ("Imagination", 0.95)
            ]
        case .science:
            traits = [
                ("Research Skills", 0.96),
                ("Critical Thinking", 0.94),
                ("Curiosity", 0.97)
            ]
        }
        
        applyTraits(traits)
    }
    
    func setupTraitBarsForAnimal(_ animalType: AnimalType) {
        guard trait1ProgressView != nil else { return }
        
        var traits: [(String, Float)] = []
        
        switch animalType {
        case .lion:
            traits = [
                ("Energy", 0.95),
                ("Social", 0.98),
                ("Courage", 0.96)
            ]
        case .cat:
            traits = [
                ("Independence", 0.92),
                ("Curiosity", 0.88),
                ("Playfulness", 0.85)
            ]
        case .rabbit:
            traits = [
                ("Gentleness", 0.96),
                ("Energy", 0.94),
                ("Sociability", 0.88)
            ]
        case .turtle:
            traits = [
                ("Patience", 0.98),
                ("Wisdom", 0.95),
                ("Calmness", 0.92)
            ]
        }
        
        applyTraits(traits)
    }
    
    func applyTraits(_ traits: [(String, Float)]) {
        trait1Label?.text = traits[0].0
        trait1ProgressView?.progress = traits[0].1
        trait1ValueLabel?.text = "\(Int(traits[0].1 * 100))%"
        styleTraitBar(trait1ProgressView)
        
        trait2Label?.text = traits[1].0
        trait2ProgressView?.progress = traits[1].1
        trait2ValueLabel?.text = "\(Int(traits[1].1 * 100))%"
        styleTraitBar(trait2ProgressView)
        
        trait3Label?.text = traits[2].0
        trait3ProgressView?.progress = traits[2].1
        trait3ValueLabel?.text = "\(Int(traits[2].1 * 100))%"
        styleTraitBar(trait3ProgressView)
    }
    
    func styleTraitBar(_ progressView: UIProgressView?) {
        guard let progressView = progressView else { return }
        
        progressView.progressTintColor = UIColor(red: 102/255, green: 222/255, blue: 199/255, alpha: 1.0)
        progressView.trackTintColor = UIColor(white: 1.0, alpha: 0.2)
        progressView.layer.cornerRadius = 4
        progressView.clipsToBounds = true
    }
}
