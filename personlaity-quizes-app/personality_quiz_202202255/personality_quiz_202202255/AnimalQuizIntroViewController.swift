
import UIKit

class AnimalQuizIntroViewController: UIViewController {
    
    private var gradientLayer: CAGradientLayer?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupGradientBackground()
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        gradientLayer?.frame = view.bounds
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    func setupGradientBackground() {
        gradientLayer?.removeFromSuperlayer()
        
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        let topColor = UIColor(red: 255/255, green: 107/255, blue: 129/255, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 255/255, green: 87/255, blue: 109/255, alpha: 1.0).cgColor
        
        gradient.colors = [topColor, bottomColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let questionVC = segue.destination as? QuestionViewController {
            questionVC.quizType = .animal
        }
    }
    
    @IBAction func unwindToAnimalQuizIntroduction(segue: UIStoryboardSegue) {
        // This method allows unwinding back to the introduction screen
    }
}
