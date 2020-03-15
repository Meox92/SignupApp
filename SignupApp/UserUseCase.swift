//
//  ViewController.swift
//  SignupApp
//
//  Created by Maola Ma on 01/03/2020.
//  Copyright © 2020 Maola. All rights reserved.
//
import Cocoa

protocol UserServices {
    func signup(with mail: String, password: String, completion: @escaping(Result<User, Error>) -> Void)
    func validateCode(code: String, user: User, completion: @escaping(Result<User, Error>) -> Void)
}

struct User {
    let email: String
    let invitationCode: String?
}

class UserUseCase {
    private var userServices: UserServices
    
    init(userServices: UserServices) {
        self.userServices = userServices
    }
    
    func signupWithReferralCode(email: String, password: String, referral: String, completion: @escaping (User) -> Void) {
        userServices.signup(with: email, password: password) { result in
            switch result {
            case .success(let user):
                self.userServices.validateCode(code: referral, user: user) { result in
                   if let updatedUser = try? result.get() {
                       completion(updatedUser)
                   }
                }
            case .failure:
                break
            }

        }

    }
}




