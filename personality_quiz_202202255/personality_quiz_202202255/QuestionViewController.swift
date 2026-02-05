//
//  QuestionViewController.swift
//  PersonalityQuiz
//

import UIKit

class QuestionViewController: UIViewController {
    
    // MARK: - Outlets
    @IBOutlet var questionLabel: UILabel!
    @IBOutlet var questionProgressView: UIProgressView!
    @IBOutlet var timerLabel: UILabel!
    
    // Single answer outlets
    @IBOutlet var singleStackView: UIStackView!
    @IBOutlet var singleButton1: UIButton!
    @IBOutlet var singleButton2: UIButton!
    @IBOutlet var singleButton3: UIButton!
    @IBOutlet var singleButton4: UIButton!
    
    // Multiple answer outlets
    @IBOutlet var multipleStackView: UIStackView!
    @IBOutlet var multiLabel1: UILabel!
    @IBOutlet var multiLabel2: UILabel!
    @IBOutlet var multiLabel3: UILabel!
    @IBOutlet var multiLabel4: UILabel!
    @IBOutlet var multiSwitch1: UISwitch!
    @IBOutlet var multiSwitch2: UISwitch!
    @IBOutlet var multiSwitch3: UISwitch!
    @IBOutlet var multiSwitch4: UISwitch!
    @IBOutlet var multiSubmitButton: UIButton!
    
    // Ranged answer outlets
    @IBOutlet var rangedStackView: UIStackView!
    @IBOutlet var rangedLabel1: UILabel!
    @IBOutlet var rangedLabel2: UILabel!
    @IBOutlet var rangedSlider: UISlider!
    @IBOutlet var rangedSubmitButton: UIButton!
    @IBOutlet var rangedContainerView: UIView!
    
    // MARK: - Properties
    var questionIndex = 0
    var answersChosen: [Answer] = []
    private var gradientLayer: CAGradientLayer?
    var quizType: QuizType = .major // Set by previous view controller
    
    // Timer properties
    private var questionTimer: Timer?
    private var timeRemaining: Int = 30 // 30 seconds per question
    private var quizStartTime: Date?
    
    // Original questions storage (before shuffling)
    private var shuffledQuestions: [Question] = []
    
    // Questions will be set based on quiz type
    var questions: [Question] = []
    
    enum QuizType {
        case major
        case animal
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        quizStartTime = Date()
        loadQuestionsForQuizType()
        randomizeQuestions()
        
        setupGradientBackground()
        setupNavigationBar()
        setupProgressBar()
        styleButtons()
        styleSwitches()
        styleSlider()
        styleContainerViews()
        fixRangedQuestionLayout()
        setupMultipleAnswerTapGestures()
        setupSwitchChangeHandlers()
        setupTimerLabel()
        updateUI()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopTimer()
    }
    
    // MARK: - Quiz Setup
    func loadQuestionsForQuizType() {
        switch quizType {
        case .major:
            questions = getMajorQuestions()
        case .animal:
            questions = getAnimalQuestions()
        }
    }
    
    func randomizeQuestions() {
        // Shuffle questions
        shuffledQuestions = questions.shuffled()
        
        // Shuffle answers within each question
        shuffledQuestions = shuffledQuestions.map { question in
            var newQuestion = question
            newQuestion.answers = question.answers.shuffled()
            return newQuestion
        }
        
        // Use shuffled questions
        questions = shuffledQuestions
    }
    
    // MARK: - Timer Setup
    func setupTimerLabel() {
        timerLabel?.textColor = .white
        timerLabel?.font = UIFont.monospacedDigitSystemFont(ofSize: 20, weight: .bold)
    }
    
    func startTimer() {
        timeRemaining = 30
        updateTimerLabel()
        
        questionTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.timerTick()
        }
    }
    
    func stopTimer() {
        questionTimer?.invalidate()
        questionTimer = nil
    }
    
    func timerTick() {
        timeRemaining -= 1
        updateTimerLabel()
        
        if timeRemaining <= 0 {
            stopTimer()
            handleTimeOut()
        } else if timeRemaining <= 10 {
            // Flash red when time is running out
            UIView.animate(withDuration: 0.5) {
                self.timerLabel?.textColor = UIColor(red: 255/255, green: 59/255, blue: 48/255, alpha: 1.0)
            }
        }
    }
    
    func updateTimerLabel() {
        timerLabel?.text = "⏱ \(timeRemaining)s"
    }
    
    func handleTimeOut() {
        // Auto-select random answer when time runs out
        let currentQuestion = questions[questionIndex]
        let randomAnswer = currentQuestion.answers.randomElement()!
        
        answersChosen.append(randomAnswer)
        
        // Show timeout alert
        let alert = UIAlertController(title: "Time's Up! ⏰", message: "A random answer was selected.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Continue", style: .default) { [weak self] _ in
            self?.nextQuestion()
        })
        present(alert, animated: true)
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
    }
    
    func setupProgressBar() {
        questionProgressView.progressTintColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
        questionProgressView.trackTintColor = UIColor(white: 1.0, alpha: 0.3)
        questionProgressView.layer.cornerRadius = 2
        questionProgressView.clipsToBounds = true
    }
    
    func styleButtons() {
        let singleButtons = [singleButton1, singleButton2, singleButton3, singleButton4]
        for button in singleButtons {
            guard let button = button else { continue }
            button.backgroundColor = UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 0.4)
            button.setTitleColor(.white, for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .medium)
            button.contentHorizontalAlignment = .left
            button.contentEdgeInsets = UIEdgeInsets(top: 16, left: 20, bottom: 16, right: 20)
            button.layer.cornerRadius = 16
            button.clipsToBounds = true
        }
        
        let submitButtons = [multiSubmitButton, rangedSubmitButton]
        for button in submitButtons {
            guard let button = button else { continue }
            button.backgroundColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
            button.setTitleColor(UIColor(red: 51/255, green: 51/255, blue: 51/255, alpha: 1.0), for: .normal)
            button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .semibold)
            button.layer.cornerRadius = 24
            button.clipsToBounds = true
        }
    }
    
    func styleSwitches() {
        let switches = [multiSwitch1, multiSwitch2, multiSwitch3, multiSwitch4]
        for toggle in switches {
            guard let toggle = toggle else { continue }
            toggle.onTintColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
            toggle.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        }
    }
    
    func styleSlider() {
        guard let slider = rangedSlider else { return }
        slider.minimumTrackTintColor = UIColor(red: 255/255, green: 193/255, blue: 7/255, alpha: 1.0)
        slider.maximumTrackTintColor = UIColor(white: 1.0, alpha: 0.3)
        slider.thumbTintColor = .white
    }
    
    func styleContainerViews() {
        if let container = rangedContainerView {
            container.backgroundColor = UIColor(red: 119/255, green: 102/255, blue: 204/255, alpha: 0.4)
            container.layer.cornerRadius = 20
            container.clipsToBounds = true
        }
    }
    
    func fixRangedQuestionLayout() {
        guard let container = rangedContainerView,
              let stack = rangedStackView,
              let slider = rangedSlider,
              let label1 = rangedLabel1,
              let label2 = rangedLabel2 else {
            return
        }
        
        stack.spacing = 24
        stack.distribution = .fill
        stack.alignment = .fill
        
        slider.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            slider.heightAnchor.constraint(equalToConstant: 40)
        ])
        
        label1.font = UIFont.systemFont(ofSize: 17)
        label1.textColor = .white
        label1.textAlignment = .left
        label1.numberOfLines = 0
        
        label2.font = UIFont.systemFont(ofSize: 17)
        label2.textColor = .white
        label2.textAlignment = .right
        label2.numberOfLines = 0
        
        container.layoutMargins = UIEdgeInsets(top: 32, left: 24, bottom: 32, right: 24)
    }
    
    func setupMultipleAnswerTapGestures() {
        let labels = [multiLabel1, multiLabel2, multiLabel3, multiLabel4]
        
        for (index, label) in labels.enumerated() {
            guard let label = label else { continue }
            label.isUserInteractionEnabled = true
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(multiLabelTapped(_:)))
            tapGesture.numberOfTapsRequired = 1
            label.tag = index
            label.addGestureRecognizer(tapGesture)
        }
    }
    
    func setupSwitchChangeHandlers() {
        multiSwitch1?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        multiSwitch2?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        multiSwitch3?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        multiSwitch4?.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }
    
    @objc func switchValueChanged() {
        guard let switch1 = multiSwitch1,
              let switch2 = multiSwitch2,
              let switch3 = multiSwitch3,
              let switch4 = multiSwitch4,
              let submitButton = multiSubmitButton else {
            return
        }
        
        let anySwitchOn = switch1.isOn || switch2.isOn || switch3.isOn || switch4.isOn
        submitButton.isEnabled = anySwitchOn
        submitButton.alpha = anySwitchOn ? 1.0 : 0.5
    }
    
    @objc func multiLabelTapped(_ sender: UITapGestureRecognizer) {
        guard let label = sender.view as? UILabel else { return }
        let index = label.tag
        
        let switches = [multiSwitch1, multiSwitch2, multiSwitch3, multiSwitch4]
        if index < switches.count, let targetSwitch = switches[index] {
            targetSwitch.setOn(!targetSwitch.isOn, animated: true)
            switchValueChanged()
        }
    }
    
    // MARK: - UI Update Methods
    func updateUI() {
        stopTimer()
        
        singleStackView.isHidden = true
        multipleStackView.isHidden = true
        rangedStackView.isHidden = true
        rangedContainerView?.isHidden = true
        
        let currentQuestion = questions[questionIndex]
        let currentAnswers = currentQuestion.answers
        let totalProgress = Float(questionIndex) / Float(questions.count)
        
        navigationItem.title = "Question \(questionIndex + 1)/\(questions.count)"
        questionLabel.text = currentQuestion.text
        questionProgressView.setProgress(totalProgress, animated: true)
        
        // Reset timer color and start
        timerLabel?.textColor = .white
        startTimer()
        
        switch currentQuestion.type {
        case .single:
            updateSingleStack(using: currentAnswers)
        case .multiple:
            updateMultipleStack(using: currentAnswers)
        case .ranged:
            updateRangedStack(using: currentAnswers)
        }
    }
    
    func updateSingleStack(using answers: [Answer]) {
        singleStackView.isHidden = false
        singleButton1.setTitle(answers[0].text, for: .normal)
        singleButton2.setTitle(answers[1].text, for: .normal)
        singleButton3.setTitle(answers[2].text, for: .normal)
        singleButton4.setTitle(answers[3].text, for: .normal)
    }
    
    func updateMultipleStack(using answers: [Answer]) {
        multipleStackView.isHidden = false
        multiSwitch1.isOn = false
        multiSwitch2.isOn = false
        multiSwitch3.isOn = false
        multiSwitch4.isOn = false
        multiLabel1.text = answers[0].text
        multiLabel2.text = answers[1].text
        multiLabel3.text = answers[2].text
        multiLabel4.text = answers[3].text
        
        multiSubmitButton?.isEnabled = false
        multiSubmitButton?.alpha = 0.5
    }
    
    func updateRangedStack(using answers: [Answer]) {
        rangedStackView.isHidden = false
        rangedContainerView?.isHidden = false
        rangedSlider.setValue(0.5, animated: false)
        rangedLabel1.text = answers.first?.text
        rangedLabel2.text = answers.last?.text
    }
    
    // MARK: - Navigation
    func nextQuestion() {
        questionIndex += 1
        
        if questionIndex < questions.count {
            updateUI()
        } else {
            stopTimer()
            performSegue(withIdentifier: "Results", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "Results" {
            let resultsVC = segue.destination as! ResultsViewController
            resultsVC.responses = answersChosen
            resultsVC.quizType = quizType
            
            // Calculate total time taken
            if let startTime = quizStartTime {
                resultsVC.totalTimeTaken = Date().timeIntervalSince(startTime)
            }
        }
    }
    
    // MARK: - Actions
    @IBAction func singleAnswerButtonPressed(_ sender: UIButton) {
        let currentAnswers = questions[questionIndex].answers
        
        switch sender {
        case singleButton1:
            answersChosen.append(currentAnswers[0])
        case singleButton2:
            answersChosen.append(currentAnswers[1])
        case singleButton3:
            answersChosen.append(currentAnswers[2])
        case singleButton4:
            answersChosen.append(currentAnswers[3])
        default:
            break
        }
        
        nextQuestion()
    }
    
    @IBAction func multipleAnswerButtonPressed() {
        let currentAnswers = questions[questionIndex].answers
        
        if multiSwitch1.isOn {
            answersChosen.append(currentAnswers[0])
        }
        if multiSwitch2.isOn {
            answersChosen.append(currentAnswers[1])
        }
        if multiSwitch3.isOn {
            answersChosen.append(currentAnswers[2])
        }
        if multiSwitch4.isOn {
            answersChosen.append(currentAnswers[3])
        }
        
        nextQuestion()
    }
    
    @IBAction func rangedAnswerButtonPressed() {
        let currentAnswers = questions[questionIndex].answers
        let index = Int(round(rangedSlider.value * Float(currentAnswers.count - 1)))
        
        answersChosen.append(currentAnswers[index])
        
        nextQuestion()
    }
}

// MARK: - Question Data
extension QuestionViewController {
    
    func getMajorQuestions() -> [Question] {
        return [
            Question(
                text: "How do you prefer to spend your free time? 🎯",
                type: .single,
                answers: [
                    Answer(text: "💼 Networking events or leadership activities", type: .business),
                    Answer(text: "⚙️ Building or fixing things", type: .engineering),
                    Answer(text: "🎨 Creating art or writing", type: .arts),
                    Answer(text: "🔬 Reading about discoveries or experimenting", type: .science)
                ]
            ),
            Question(
                text: "Which activities sound most appealing to you? 😊",
                type: .multiple,
                answers: [
                    Answer(text: "📊 Analyzing data and trends", type: .business),
                    Answer(text: "🛠️ Designing and prototyping", type: .engineering),
                    Answer(text: "🎭 Performing or presenting creative work", type: .arts),
                    Answer(text: "🧪 Conducting experiments", type: .science)
                ]
            ),
            Question(
                text: "How do you approach problem-solving? 🤔",
                type: .ranged,
                answers: [
                    Answer(text: "Focus on people and collaboration", type: .business),
                    Answer(text: "Use logical systems and processes", type: .engineering),
                    Answer(text: "Think creatively and unconventionally", type: .arts),
                    Answer(text: "Research and test hypotheses", type: .science)
                ]
            ),
            Question(
                text: "What's your ideal work environment? 🌟",
                type: .single,
                answers: [
                    Answer(text: "🏢 Corporate office or startup", type: .business),
                    Answer(text: "🏭 Lab or workshop with tools", type: .engineering),
                    Answer(text: "🎨 Creative studio or flexible space", type: .arts),
                    Answer(text: "🔬 Research facility or university", type: .science)
                ]
            ),
            Question(
                text: "What motivates you most? 💫",
                type: .multiple,
                answers: [
                    Answer(text: "💰 Financial success and influence", type: .business),
                    Answer(text: "🚀 Innovation and efficiency", type: .engineering),
                    Answer(text: "✨ Self-expression and impact", type: .arts),
                    Answer(text: "🌍 Discovery and understanding", type: .science)
                ]
            ),
            Question(
                text: "How structured do you like your day to be? 📅",
                type: .ranged,
                answers: [
                    Answer(text: "Very structured with clear goals", type: .business),
                    Answer(text: "Structured but with room for problem-solving", type: .engineering),
                    Answer(text: "Flexible and spontaneous", type: .arts),
                    Answer(text: "Organized around research objectives", type: .science)
                ]
            ),
            Question(
                text: "Which class sounds most interesting? 📚",
                type: .single,
                answers: [
                    Answer(text: "📈 Economics or Marketing", type: .business),
                    Answer(text: "💻 Computer Science or Physics", type: .engineering),
                    Answer(text: "🎬 Film Studies or Literature", type: .arts),
                    Answer(text: "🧬 Biology or Chemistry", type: .science)
                ]
            ),
            Question(
                text: "What are your strongest skills? 💪",
                type: .multiple,
                answers: [
                    Answer(text: "👥 Leadership and communication", type: .business),
                    Answer(text: "🔧 Technical and analytical thinking", type: .engineering),
                    Answer(text: "🎨 Creativity and imagination", type: .arts),
                    Answer(text: "📊 Research and critical thinking", type: .science)
                ]
            )
        ]
    }
    
    func getAnimalQuestions() -> [Question] {
        return [
            Question(
                text: "Which food do you like the most? 🍽️",
                type: .single,
                answers: [
                    Answer(text: "🥩 Steak", type: .lion),
                    Answer(text: "🐟 Fish", type: .cat),
                    Answer(text: "🥕 Carrots", type: .rabbit),
                    Answer(text: "🌽 Corn", type: .turtle)
                ]
            ),
            Question(
                text: "Which activities do you enjoy? 😊",
                type: .multiple,
                answers: [
                    Answer(text: "🏊 Swimming", type: .turtle),
                    Answer(text: "😴 Sleeping", type: .cat),
                    Answer(text: "🏃 Running", type: .rabbit),
                    Answer(text: "🍔 Eating", type: .lion)
                ]
            ),
            Question(
                text: "How much do you enjoy car rides? 🚗",
                type: .ranged,
                answers: [
                    Answer(text: "Hate them", type: .cat),
                    Answer(text: "I get a little nervous", type: .rabbit),
                    Answer(text: "I barely notice them", type: .turtle),
                    Answer(text: "Love them", type: .lion)
                ]
            ),
            Question(
                text: "What's your ideal weekend? 🌟",
                type: .single,
                answers: [
                    Answer(text: "🎉 Big party with friends", type: .lion),
                    Answer(text: "📚 Quiet reading at home", type: .cat),
                    Answer(text: "🌳 Nature walk or picnic", type: .rabbit),
                    Answer(text: "🧘 Meditation and relaxation", type: .turtle)
                ]
            ),
            Question(
                text: "What traits describe you best? 💫",
                type: .multiple,
                answers: [
                    Answer(text: "🎯 Adventurous", type: .lion),
                    Answer(text: "🎨 Creative", type: .cat),
                    Answer(text: "❤️ Compassionate", type: .rabbit),
                    Answer(text: "🧠 Thoughtful", type: .turtle)
                ]
            )
        ]
    }
}
