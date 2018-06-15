//
//  ViewController.swift
//  WhatsMyMeal
//
//  Created by Mokhamad Valid Kazimi on 06.06.2018.
//  Copyright © 2018 Mokhamad Valid Kazimi. All rights reserved.
//

import UIKit
import GoogleSignIn
import GoogleAPIClientForREST

enum DayOfTheWeek: String {
    case monday = "Monday"
    case tuesday = "Tuesday"
    case wednesday = "Wednesday"
    case thursday = "Thursday"
    case friday = "Friday"
    case saturday = "Saturday"
    case sunday = "Sunday"
}

class ViewController: UIViewController {
    // MARK: - Properties
    private let scopes = [kGTLRAuthScopeSheetsSpreadsheetsReadonly]
    private let service = GTLRSheetsService()
    let textOutput = UITextView()
    
    // We use calendarIndex to eventually get the day of the week in viewDidLoad()
    let calendarIndex = Calendar.current.component(.weekday, from: Date())
    var dayOfTheWeek: DayOfTheWeek!
    
    // We use these variables to store user's specific food of choice
    var usersSalad: String?
    var usersSoup: String?
    var usersMainMeal: String?
    var usersGarnish: String?
    
    // We use these variables to store the food values from the spreadsheet
    var usersSalad1: String?
    var usersSalad2: String?
    var usersSalad3: String?
    var usersSoup1: String?
    var usersSoup2: String?
    var usersSoup3: String?
    var usersMainMeal1: String?
    var usersMainMeal2: String?
    var usersMainMeal3: String?
    var usersGarnish1: String?
    var usersGarnish2: String?
    var usersGarnish3: String?
    
    // We use the UIActivityIndicatorView show progress
    var spinner: UIActivityIndicatorView!
    
    // We use UserDefaults to store and obtain the user's full name
    private var userFullName: String? {
        get {
            return UserDefaults.standard.value(forKey: USER_FULL_NAME) as? String
        }
        set {
            UserDefaults.standard.set(newValue, forKey: USER_FULL_NAME)
        }
    }
    
    // MARK: - Outlets
    @IBOutlet weak var welcomeLbl: UILabel!
    @IBOutlet weak var signInBtn: GIDSignInButton!
    @IBOutlet weak var enterNameView: UIView!
    @IBOutlet weak var fullNameTexField: UITextField!
    @IBOutlet weak var findFoodBtn: UIButton!
    @IBOutlet weak var additionalInfoLbl: UILabel!
    @IBOutlet weak var foodMenuView: UIView!
    @IBOutlet weak var dayOfTheWeekLbl: UILabel!
    @IBOutlet weak var foodLblStackView: UIStackView!
    @IBOutlet weak var firstFoodInStack: UILabel!
    @IBOutlet weak var secondFoodInStack: UILabel!
    @IBOutlet weak var thirdFoodInStack: UILabel!
    @IBOutlet weak var fourthFoodInStack: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var signOutBtn: UIButton!
    
    // MARK: - Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // We convert the weekdaySymbols from String to DayOfTheWeek type
        dayOfTheWeek = DayOfTheWeek(rawValue: Calendar.current.weekdaySymbols[calendarIndex - 1])
        
        // Configure Google Sign-in
        GIDSignIn.sharedInstance().delegate = self
        GIDSignIn.sharedInstance().uiDelegate = self
        GIDSignIn.sharedInstance().scopes = scopes
        
        configureView()
        checkIfUserIsAuthorized()
    }
    
    func configureView() {
        // Making the button more rounded
        findFoodBtn.layer.cornerRadius = 3
        
        // Initially hiding view elements
        signInBtn.isHidden = true
        welcomeLbl.isHidden = true
        additionalInfoLbl.isHidden = true
        dayOfTheWeekLbl.isHidden = true
        
        // Setting the day of the week label
        switch dayOfTheWeek! {
        case .monday:
            dayOfTheWeekLbl.text = "Понедельник"
        case .tuesday:
            dayOfTheWeekLbl.text = "Вторник"
        case .wednesday:
            dayOfTheWeekLbl.text = "Среда"
        case .thursday:
            dayOfTheWeekLbl.text = "Четверг"
        case .friday:
            dayOfTheWeekLbl.text = "Пятница"
        default:
            dayOfTheWeekLbl.isHidden = false
            userNameLbl.isHidden = false
            signOutBtn.isHidden = false
            dayOfTheWeekLbl.text = "Сегодня выходной!"
            firstFoodInStack.text = "Отличная возможность пообедать дома 😁"
        }
        
        // Setting the user name lbl
        if userFullName != nil {
            userNameLbl.text = userFullName
        }
        
        spinner = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
        spinner.color = UIColor.black
        spinner.hidesWhenStopped = true
        spinner.frame = CGRect(x: view.center.x - 15, y: view.center.y - 15, width: 30, height: 30)
        foodMenuView.addSubview(spinner)
    }
    
    // Check if the user has authorized before
    func checkIfUserIsAuthorized() {
        if GIDSignIn.sharedInstance().hasAuthInKeychain() {
            GIDSignIn.sharedInstance().signInSilently()
            checkIfUserNameIsStored()
        } else {
            welcomeLbl.isHidden = false
            signInBtn.isHidden = false
            additionalInfoLbl.isHidden = false
        }
    }
    
    // Check if the user name is stored in UserDefaults
    func checkIfUserNameIsStored() {
        if userFullName == nil {
            enterNameView.isHidden = false
            fullNameTexField.becomeFirstResponder()
        } else {
            getSpreadsheetData()
            foodMenuView.isHidden = false
            if foodMenuView.isHidden {
                spinner.startAnimating()
            } else {
                spinner.stopAnimating()
            }
        }
    }
    
    // Create and execute the query to obtain the spreadsheets values
    func getSpreadsheetData() {
        let spreadsheetId = "1NrPDjp80_7venKB0OsIqZLrq47jbx9c-lrWILYJPS88"
        
        // The day of the week here should be optimized
        var range = ""
        
        switch dayOfTheWeek! {
        case .monday:
            range = "Понедельник !A2:M"
        case .tuesday:
            range = "Вторник!A2:M"
        case .wednesday:
            range = "Среда !A2:M"
        case .thursday:
            range = "Четверг !A2:M"
        case .friday:
            range = "Пятница !A2:M"
        default :
            dayOfTheWeekLbl.isHidden = false
            userNameLbl.isHidden = false
            signOutBtn.isHidden = false
            dayOfTheWeekLbl.text = "Сегодня выходной!"
            firstFoodInStack.text = "Отличная возможность пообедать дома 😁"
            return
        }
        
        let query = GTLRSheetsQuery_SpreadsheetsValuesGet.query(withSpreadsheetId: spreadsheetId, range: range)
        service.executeQuery(query, delegate: self, didFinish: #selector(displayResult(_:finishedWithObject:error:)))
    }
    
    // Process the response and dispaly output
    @objc func displayResult(_ ticket: GTLRServiceTicket, finishedWithObject result: GTLRSheets_ValueRange, error: NSError?) {
        if let error = error {
            print("This is an error: \(error.localizedDescription)")
            return
        }
        
        var foodCounter = 0
        let rows = result.values!
        
        if rows.isEmpty {
            textOutput.text = "No data found."
            return
        }
        
        // Storing all possible food variations into variables
        usersSalad1 = rows[0][1] as? String
        usersSalad2 = rows[0][2] as? String
        usersSalad3 = rows[0][3] as? String
        usersSoup1 = rows[0][4] as? String
        usersSoup2 = rows[0][5] as? String
        usersSoup3 = rows[0][6] as? String
        usersMainMeal1 = rows[0][7] as? String
        usersMainMeal2 = rows[0][8] as? String
        usersMainMeal3 = rows[0][9] as? String
        usersGarnish1 = rows[0][10] as? String
        usersGarnish2 = rows[0][11] as? String
        usersGarnish3 = rows[0][12] as? String
        
        for row in rows {
            let rowCount = row.count
            let rowFullName = row[0] as! String
            
            if rowFullName == userFullName {
                for i in 1..<rowCount {
                    let rowMeal = row[i] as! String
                    
                    if rowMeal != "" {
                        switch i {
                        case 1:
                            usersSalad = usersSalad1!
                            foodCounter += 1
                        case 2:
                            usersSalad = usersSalad2!
                            foodCounter += 1
                        case 3:
                            usersSalad = usersSalad3!
                            foodCounter += 1
                        case 4:
                            usersSoup = usersSoup1!
                            foodCounter += 1
                        case 5:
                            usersSoup = usersSoup2!
                            foodCounter += 1
                        case 6:
                            usersSoup = usersSoup3!
                            foodCounter += 1
                        case 7:
                            usersMainMeal = usersMainMeal1!
                            foodCounter += 1
                        case 8:
                            usersMainMeal = usersMainMeal2!
                            foodCounter += 1
                        case 9:
                            usersMainMeal = usersMainMeal3!
                            foodCounter = 1
                        case 10:
                            usersGarnish = usersGarnish1!
                            foodCounter += 1
                        case 11:
                            usersGarnish = usersGarnish2!
                            foodCounter += 1
                        case 12:
                            usersGarnish = usersGarnish3!
                            foodCounter += 1
                        default:
                            break
                        }
                    }
                }
            }
        }
        
        let foodLblArray = [usersSalad, usersSoup, usersMainMeal, usersGarnish]
        
        for food in foodLblArray {
            if let food = food {
                if firstFoodInStack.text == "" {
                    firstFoodInStack.text = food
                } else if secondFoodInStack.text == "" {
                    secondFoodInStack.text = food
                } else if thirdFoodInStack.text == "" {
                    thirdFoodInStack.text = food
                } else if fourthFoodInStack.text == "" {
                    fourthFoodInStack.text = food
                }
            }
        }
        
        // We show the result view and show its subviews
        dayOfTheWeekLbl.isHidden = false
        userNameLbl.isHidden = false
        signOutBtn.isHidden = false
        
        // Stop animating UIActivityIndicator because the progress is complete
        spinner.stopAnimating()
    }
    
    // This method clears local properties of user name and the food menu of the user
    func clearInfoAfterSignOut() {
        UserDefaults.standard.removeObject(forKey: USER_FULL_NAME)
        firstFoodInStack.text = ""
        secondFoodInStack.text = ""
        thirdFoodInStack.text = ""
        fourthFoodInStack.text = ""
    }
    
    // MARK:- Actions
    @IBAction func findFoodBtnPressed(_ sender: Any) {
        if fullNameTexField.text != "" {
            view.endEditing(true)
            userFullName = fullNameTexField.text!
            userNameLbl.text = fullNameTexField.text!
            enterNameView.isHidden = true
            foodMenuView.isHidden = false
            getSpreadsheetData()
        } else {
            let alert = UIAlertController(title: "No name was typed.", message: "Please, be sure to type your name before proceeding.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func signOutBtnPressed(_ sender: Any) {
        GIDSignIn.sharedInstance().signOut()
        clearInfoAfterSignOut()
        welcomeLbl.isHidden = false
        signInBtn.isHidden = false
        additionalInfoLbl.isHidden = false
        foodMenuView.isHidden = true
        dayOfTheWeekLbl.isHidden = true
        userNameLbl.isHidden = true
        signOutBtn.isHidden = true
    }
    
}

extension ViewController: GIDSignInDelegate, GIDSignInUIDelegate {
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            let alert = UIAlertController(title: "Whoops...", message: "It seems that we have an Authentication error :( \n Please try again.", preferredStyle: .alert)
            let action = UIAlertAction(title: "Ok", style: .cancel, handler: nil)
            alert.addAction(action)
            present(alert, animated: true, completion: nil)
            print("This is cancel error \(error)")
            self.service.authorizer = nil
        } else {
            welcomeLbl.isHidden = true
            signInBtn.isHidden = true
            additionalInfoLbl.isHidden = true
            service.authorizer = user.authentication.fetcherAuthorizer()
            checkIfUserNameIsStored()
            spinner.startAnimating()
            
            // By using user.profile.name we are able to get the user's name without having to ask him to provide it in the application
//            let fullName = user.profile.name
//            print("This is users full name: \(fullName!)")
        }
    }
}
