//
//  ProviderInfoVC.swift
//  GetAnExpert
//
//  Created by Muhammad Zubair on 06/07/2020.
//  Copyright © 2020 CodesBinary. All rights reserved.
//

import UIKit
import DropDown
import SwiftyJSON
import YPImagePicker
import CountryPickerView

class ProviderInfoVC: UIViewController {
    
    /* MARK:- Outlets */
    @IBOutlet weak var profileImageView : UIView!
    @IBOutlet weak var cameraBtnView    : UIView!
    @IBOutlet weak var nameView         : UIView!
    @IBOutlet weak var genderView       : UIView!
    @IBOutlet weak var dobView          : UIView!
    @IBOutlet weak var numberView       : UIView!
    @IBOutlet weak var emailView        : UIView!
    @IBOutlet weak var specialistView   : UIView!
    @IBOutlet weak var degreeView       : UIView!
    @IBOutlet weak var aboutView        : UIView!
    @IBOutlet weak var languageView     : UIView!
    
    @IBOutlet weak var profileImage     : UIImageView!
    
    @IBOutlet weak var nameTextfield         : UITextField!
    @IBOutlet weak var genderTextfield       : UITextField!
    @IBOutlet weak var languageTextfield     : UITextField!
    @IBOutlet weak var dobTextfield          : UITextField!
    @IBOutlet weak var numberTextfield       : UITextField!
    @IBOutlet weak var codeTextfield         : UITextField!
    @IBOutlet weak var emailTextfield        : UITextField!
    @IBOutlet weak var specialistTextField   : UITextField!
    @IBOutlet weak var degreeTextField       : UITextField!
    @IBOutlet weak var fbLinkTextfield       : UITextField!
    @IBOutlet weak var twitterLinkTextField  : UITextField!
    @IBOutlet weak var linkedInLinkTextField : UITextField!
    @IBOutlet weak var aboutTextView         : UITextView!
    
    @IBOutlet weak var saveButton       : UIButton!
    
    /* MARK:- Properties */
    var countryPickerView : CountryPickerView = CountryPickerView()
    let genderDropDown                        = DropDown()
    let languageDropDown                      = DropDown()
    let specialistDropDown                    = DropDown()
    let datePicker                            = UIDatePicker()
    
    ///For Update Api
    var pickedPhoto      : UIImage?
    var categories       : [CategoriesModel] = []
    var languages        : [LanguagesModel]  = []
    var selectedLanguage : String            = ""
    var selectedCategory : String            = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupVC()
    }
}

/* MARK:- Methods */
extension ProviderInfoVC {
    func setupVC() {
        setlayout()
        loadData()
        showDatePicker()
        apiCalls()
        // CountryPicker init
        countryPickerView.delegate     = self
        countryPickerView.dataSource   = self
        // Gender DropDown init
        genderDropDown.anchorView      = languageView
        genderDropDown.direction       = .bottom
        genderDropDown.dataSource      = ["Male", "Female", "Other"]
        // Language DropDown init
        languageDropDown.anchorView    = emailView
        languageDropDown.direction     = .bottom
        languageDropDown.dataSource    = []
        // Specialist DropDown init
        specialistDropDown.anchorView  = degreeView
        specialistDropDown.direction   = .bottom
        specialistDropDown.dataSource  = []
    }
    func setlayout() {
        DispatchQueue.main.async {
            self.profileImageView.layer.cornerRadius = self.profileImageView.bounds.height / 2
            self.cameraBtnView  .layer.cornerRadius = self.cameraBtnView .bounds.height / 2
            self.saveButton     .layer.cornerRadius = self.saveButton    .bounds.height / 10
            self.nameView       .layer.cornerRadius = self.nameView      .bounds.height / 10
            self.genderView     .layer.cornerRadius = self.genderView    .bounds.height / 10
            self.dobView        .layer.cornerRadius = self.dobView       .bounds.height / 10
            self.numberView     .layer.cornerRadius = self.numberView    .bounds.height / 10
            self.emailView      .layer.cornerRadius = self.emailView     .bounds.height / 10
            self.aboutView      .layer.cornerRadius = self.aboutView     .bounds.height / 10
            self.specialistView .layer.cornerRadius = self.specialistView.bounds.height / 10
            self.languageView   .layer.cornerRadius = self.languageView  .bounds.height / 10
            self.degreeView     .layer.cornerRadius = self.degreeView    .bounds.height / 10
        }
    }
    func loadData(){
        if let user = Constants.sharedInstance.USER {
            nameTextfield.text = user.name
            if user.gender != "" {
                genderTextfield.text = user.gender
            }
            if user.dob != "" {
                dobTextfield.text = user.dob
            }
            
            codeTextfield.text     = user.code
            numberTextfield.text   = user.phone
            emailTextfield.text    = user.email
            languageTextfield.text = user.language.name
            selectedLanguage       = user.language.id
            
            if user.category.name != "" {
                selectedCategory         = user.category.id
                specialistTextField.text = user.category.name
            }
            if user.providerInfo.degree != "" {
                degreeTextField.text = user.providerInfo.degree
            }
            if user.providerInfo.facebook != "" {
                fbLinkTextfield.text = user.providerInfo.facebook
            }
            if user.providerInfo.twitter != "" {
                twitterLinkTextField.text = user.providerInfo.twitter
            }
            if user.providerInfo.linkedIn != "" {
                linkedInLinkTextField.text = user.providerInfo.linkedIn
            }
            if user.isSocial {
                emailTextfield.isUserInteractionEnabled = false
            } else {
                emailTextfield.isUserInteractionEnabled = true
            }
            aboutTextView      .text = user.providerInfo.about
            
            Helper.setImage(isUser: true, imageView: profileImage, imageUrl: user.image)
        }
    }
    func showDatePicker(){
        //Formate Date
        datePicker.datePickerMode = .date
        //ToolBar
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: false)
        dobTextfield.inputAccessoryView = toolbar
        dobTextfield.inputView          = datePicker
        
    }
    func showPickerPhotos() {
        var config                          = YPImagePickerConfiguration()
        config.library.mediaType            = .photo
        config.shouldSaveNewPicturesToAlbum = false
        config.startOnScreen                = .photo
        config.screens                      = [.library]
        config.wordings.libraryTitle        = "Photos"
        config.usesFrontCamera              = true
        config.showsPhotoFilters            = false
        config.hidesStatusBar               = false
        config.hidesBottomBar               = false
        config.library.maxNumberOfItems     = 1
        config.library.onlySquare           = false
        
        let picker = YPImagePicker(configuration: config)
        picker.modalPresentationStyle = .fullScreen
        
        picker.didFinishPicking { [unowned picker] items, cancelled in
            if cancelled {
                print("Picker was canceled")
                picker.dismiss(animated: true, completion: nil)
                return
            }
            _ = items.map { print("🧀 \($0)") }
            
            if let firstItem = items.first {
                switch firstItem {
                case .photo(let photo):
                    self.pickedPhoto = photo.image
                    self.profileImage.image = photo.image
                    picker.dismiss(animated: true, completion: nil)
                default:
                    break
                }
            }
        }
        present(picker, animated: true, completion: nil)
    }
    func apiCalls(){
        getAllCategories()
        getAllLanguages()
    }
    @objc func donedatePicker(){
        
        let formatter        = DateFormatter()
        formatter.dateFormat = "dd/MM/yyyy"
        dobTextfield.text    = formatter.string(from: datePicker.date)
        self.view.endEditing(true)
    }
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
}

/* MARK:- Actions */
extension ProviderInfoVC {
    @IBAction func backAction           (_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func openCameraAction     (_ sender: UIButton){
        showPickerPhotos()
    }
    @IBAction func openCountryPicker    (_ sender: UIButton){
        countryPickerView.showCountriesList(from: self)
    }
    @IBAction func selectGenderAction   (_ sender: UIButton){
        genderDropDown.show()
        genderDropDown.selectionAction = { [unowned self] (index: Int,item: String) in
            self.genderTextfield.text  = item
        }
    }
    @IBAction func selectLanguageAction  (_ sender: UIButton){
        languageDropDown.show()
        languageDropDown.selectionAction = { [unowned self] (index: Int,item: String) in
            self.selectedLanguage        = languages[index].id
            self.languageTextfield.text  = item
        }
    }
    @IBAction func selectSpecialistAction(_ sender: UIButton){
        specialistDropDown.show()
        specialistDropDown.selectionAction = { [unowned self] (index: Int,item: String) in
            self.selectedCategory          = categories[index].id
            self.specialistTextField.text  = item
        }
    }
    @IBAction func saveProfileAction     (_ sender: UIButton){
        updateProfile()
    }
}

/* MARK:- Api Methods */
extension ProviderInfoVC {
    func updateProfile(){
        var parameters : [String : String] = [:]
        guard let name = nameTextfield.text, name != "" else {
            self.showAlert(message: "Name Field Can't be Empty")
            return
        }
        guard let phone = numberTextfield.text, phone != "" else {
            self.showAlert(message: "Number Field Can't be Empty")
            return
        }
        guard let code = codeTextfield.text, code != "" else {
            self.showAlert(message: "Country Code Field Can't be Empty")
            return
        }
        guard let email = emailTextfield.text, email != "" else {
            self.showAlert(message: "Email Field is required")
            return
        }
        guard let language = languageTextfield.text, language != "" else {
            self.showAlert(message: "Language Field is required")
            return
        }
        guard let specialization = specialistTextField.text, specialization != "" else {
            self.showAlert(message: "Please Select Specialization")
            return
        }
        guard let degree = degreeTextField.text, degree != "" else {
            self.showAlert(message: "Please enter your Degree first")
            return
        }
        guard let about = aboutTextView.text, about != "" else {
            self.showAlert(message: "Your about description is Missing")
            return
        }
        let lowerCaseEmail           = email.lowercased()
        parameters["name"]           = name
        parameters["phoneNumber"]    = phone
        parameters["phoneCode"]      = code
        parameters["email"]          = lowerCaseEmail
        parameters["language"]       = selectedLanguage
        parameters["dob"]            = self.dobTextfield.text
        parameters["gender"]         = self.genderTextfield.text 
        parameters["category"]       = selectedCategory
        parameters["about"]          = about
        parameters["degree"]         = degree
        parameters["facebook"]       = self.fbLinkTextfield.text
        parameters["twitter"]        = self.twitterLinkTextField.text
        parameters["linkedin"]       = self.linkedInLinkTextField.text
        
        self.showSpinner(onView: self.view, title: "Updating Profile...")
        NetworkManager.sharedInstance.updateProfileProvider(param: parameters, image: pickedPhoto) {
            (response) in
            self.removeSpinner()
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data = try JSON(data: response.data!)
                            if response.response?.statusCode == 200 {
                                Constants.sharedInstance.isGuestUser = false
                                let token = "Bearer \(data["data"]["token"].stringValue)"
                        
                                DEFAULTS.set(token, forKey: Constants.userDefaults.HTTP_HEADERS)
                                DEFAULTS.synchronize()
                                
                                let user  = UserModel(json: data["data"]["user"])
                                Constants.sharedInstance.USER = user
                                
                                if user.email == email {
                                    self.navigationController?.popViewController(animated: true)
                                } else {
                                    let validationVC = MAIN_STORYBOARD.instantiateViewController(
                                        withIdentifier: Constants.ViewControllers.VALIDATION_VC
                                    )
                                    self.navigationController?.pushViewController(validationVC, animated: true)
                                }
                            }
                        } catch {
                            self.showToast(message: error.localizedDescription)
                        }
                    } else {
                        self.showToast(message: "Something went wrong status code \(statusCode)")
                    }
                }
            case .failure(_):
                self.showToast(message: "Something went wrong with Servers")
            }
        }
    }
    func getAllLanguages(){
        NetworkManager.sharedInstance.getAllLanguages { [weak self] (response) in
            guard let self = self else { return }
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data        = try JSON(data: response.data!)
                            self.languages  = data["languages"].arrayValue.map({LanguagesModel(json: $0)})
                            
                            var languageDropDownDatasource: [String] = []
                            self.languages.forEach { (language) in
                                languageDropDownDatasource.append(language.name)
                            }
                            
                            self.languageDropDown.dataSource = languageDropDownDatasource
                        } catch {
                            Helper.debugLogs(any: error.localizedDescription, and: "Caught Error")
                        }
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }
            
        }
    }
    func getAllCategories(){
        NetworkManager.sharedInstance.getAllCategories { [weak self] (response) in
            guard let self = self else { return }
            
            switch response.result {
            case .success(_):
                if let statusCode = response.response?.statusCode {
                    if statusCode == 200 {
                        do {
                            let data        = try JSON(data: response.data!)
                            self.categories = data["categories"].arrayValue.map({CategoriesModel(json: $0)})
                            
                            var categoryDropDownDatasource: [String] = []
                            self.categories.forEach { (language) in
                                categoryDropDownDatasource.append(language.name)
                            }
                            
                            self.specialistDropDown.dataSource = categoryDropDownDatasource
                        } catch {
                            Helper.debugLogs(any: error.localizedDescription, and: "Caught Error")
                        }
                    } else {
                        Helper.debugLogs(any: statusCode, and: "Status Code")
                    }
                }
            case .failure(let error):
                Helper.debugLogs(any: error, and: "Faliure")
            }
            
        }
    }
}

/* MARK:- Country Picker Delegate */
extension ProviderInfoVC: CountryPickerViewDelegate, CountryPickerViewDataSource{
    
    func countryPickerView(_ countryPickerView: CountryPickerView, didSelectCountry country: Country) {
        codeTextfield.text = country.phoneCode
    }
    
}
