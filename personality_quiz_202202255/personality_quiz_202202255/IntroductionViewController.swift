//

//

import UIKit

class IntroductionViewController: UIViewController {
    
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
        // Remove old gradient if exists
        gradientLayer?.removeFromSuperlayer()
        
        // Create purple gradient matching Figma design
        let gradient = CAGradientLayer()
        gradient.frame = view.bounds
        
        // Exact colors from Figma
        let topColor = UIColor(red: 108/255, green: 99/255, blue: 255/255, alpha: 1.0).cgColor
        let bottomColor = UIColor(red: 136/255, green: 84/255, blue: 255/255, alpha: 1.0).cgColor
        
        gradient.colors = [topColor, bottomColor]
        gradient.startPoint = CGPoint(x: 0.5, y: 0.0)
        gradient.endPoint = CGPoint(x: 0.5, y: 1.0)
        
        view.layer.insertSublayer(gradient, at: 0)
        gradientLayer = gradient
    }
    
    @IBAction func unwindToQuizIntroduction(segue: UIStoryboardSegue) {
        // This method allows unwinding back to the introduction screen
    }
}
