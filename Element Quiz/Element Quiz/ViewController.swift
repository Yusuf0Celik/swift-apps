//
//  ViewController.swift
//  Element Quiz
//
//  Created by SD on 12/01/2023.
//

import UIKit
// enum = private variable
// Choose your playing mode
enum Mode {
    case flashCard
    case quiz
}
// Get your private variable states
enum State {
    case question
    case answer
    case score
}

class ViewController: UIViewController, UITextFieldDelegate {
    // Starting mode is flashcard
    var mode: Mode = .flashCard {
        didSet {
            // if mode is flashCard/quiz do the following function
            switch mode {
            case .flashCard:
                setupFlashCards()
            case .quiz:
                setupQuiz()
            }
            // Update the UI
            updateUI()
        }
    }
    var state: State = .question
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mode = .flashCard
    }
    // Declare Objects
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var answerLabel: UITextField!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var modeSelector: UISegmentedControl!
    @IBOutlet weak var showAnswerButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    // When pressing the showAnswerButton re
    @IBAction func showAnswer(_ sender: Any) {
        state = .answer
        updateUI()
    }
    // When pressing the nextButton get next random element
    @IBAction func next(_ sender: Any) {
        currentElementIndex += 1
        if currentElementIndex >= elementList.count
           {
            currentElementIndex = 0
            if mode == .quiz {
                state = .score
                updateUI()
                return
            }
        }
        state = .question
        updateUI()
    }
    
    // When pressing modeSelector switch from modes
    @IBAction func switchModes(_ sender: Any) {
        if modeSelector.selectedSegmentIndex == 0 {
            mode = .flashCard
        } else {
            mode = .quiz
        }
    }
    
    // Quiz-specific state
    var answerIsCorrect = false
    var correctAnswerCount = 0
    
    /// Make elementList
    let fixedElementList = ["Carbon", "Gold", "Chlorine", "Sodium"]
    /// Shuffle elementList
    var elementList: [String] = []
    var currentElementIndex = 0
    
    // Updates the app's UI in flash card mode.
    func updateFlashCardUI(elementName: String) {
        // Hide textField and show Buttons
        // Text field and keyboard
        textField.isHidden = true
        textField.resignFirstResponder()
        // Buttons
        showAnswerButton.isHidden = false
        nextButton.isHidden = false
        // When state is answer(showAnswer is clicked) nextButton is enabled
        switch state {
        case .question:
            nextButton.isEnabled = false
        case .answer:
            nextButton.isEnabled = true
        case .score:
            nextButton.isEnabled = false
        }
        // When state is answer Answer Label is the elementName
        if state == .answer {
            answerLabel.text = elementName
        } else {
            // When state is not answer Answer Label is "?"
            answerLabel.text = "?"
        }
        modeSelector.selectedSegmentIndex = 0
    }

    // Updates the app's UI in quiz mode.
    func updateQuizUI(elementName: String) {
        // Show TextField, hide showAnswerButton and disable nextButton
        // Text field and keyboard
        textField.isHidden = false
        nextButton.isEnabled = false
        showAnswerButton.isHidden = true
        // If Quiz is done show the score
        if currentElementIndex == elementList.count - 1 {
            nextButton.setTitle("Show Score", for: .normal)
        } else {
            nextButton.setTitle("Next Question", for: .normal)
        }
        switch state {
        // If you need to answer the question textfield is enabled
        case .question:
            textField.isEnabled = true
            textField.text = ""
            textField.becomeFirstResponder()
        // If the question is answered textField is disabled
        case .answer:
            textField.isEnabled = false
            textField.resignFirstResponder()
        // If quiz is done textField is hidden
        case .score:
            textField.isHidden = true
            textField.resignFirstResponder()
        }
        // Answer label
        switch state {
        // If you need to answer answerLable is empty
        case .question:
            answerLabel.text = ""
        // If you need have answered nextButton is enabled and show wether you're right or wrong
        case .answer:
            if answerIsCorrect {
                answerLabel.text = "Correct!"
                nextButton.isEnabled = true
            } else {
                answerLabel.text = "❌"
                nextButton.isEnabled = true
            }
        // In the terminal it shows how many you got correct
        case .score:
            answerLabel.text = ""
            print("Your score is \(correctAnswerCount) out of \(elementList.count).")
        }
        // If quiz ended it shows your score
        if state == .score {
            displayScoreAlert()
        }
        // If quiz ends you go back to flashcards
        modeSelector.selectedSegmentIndex = 1
    }
    
    // Updates the app's UI based on its mode and
    func updateUI() {
        let elementName = elementList[currentElementIndex]
        let image = UIImage(named: elementName)
        imageView.image = image
        switch mode {
        case .flashCard:
            updateFlashCardUI(elementName: elementName)
        case .quiz:
            updateQuizUI(elementName: elementName)
        }
    }
    // Runs after the user hits the Return key on the keyboard
    func textFieldShouldReturn(_ textField:UITextField) -> Bool {
        // Get the text from the text field
        let textFieldContents = textField.text!
        // Determine whether the user answered correctly and update appropriate quiz
        // state
        if textFieldContents.lowercased() == elementList[currentElementIndex].lowercased() {
            answerIsCorrect = true
            correctAnswerCount += 1
        } else {
            answerIsCorrect = false
        }
        // The app should now display the answer to the user
        state = .answer
        updateUI()
        return true
    }
    
    // Shows an iOS alert with the user's quiz score.
    func displayScoreAlert() {
        let alert = UIAlertController(title: "Quiz Score", message: "Your score is \(correctAnswerCount) out of \(elementList.count).", preferredStyle: .alert)
        let dismissAction = UIAlertAction(title: "OK", style: .default, handler:scoreAlertDismissed(_:))
        alert.addAction(dismissAction)
        present(alert, animated: true, completion: nil)
    }
    func scoreAlertDismissed(_ action: UIAlertAction) {
        mode = .flashCard
    }
    
    // Sets up a new flash card session.
    func setupFlashCards() {
        state = .question
        currentElementIndex = 0
        elementList = fixedElementList
    }
    // Sets up a new quiz.
    func setupQuiz() {
        state = .question
        currentElementIndex = 0
        answerIsCorrect = false
        correctAnswerCount = 0
        elementList = fixedElementList.shuffled()
    }
}
