//
//  SignupAppTests.swift
//  SignupAppTests
//
//  Created by Maola Ma on 01/03/2020.
//  Copyright © 2020 Maola. All rights reserved.
//

import XCTest
@testable import SignupApp

class UserUseCaseTests: XCTestCase {
   
    func test_requestValidateCodeAfterUserCreation_onSignupWithReferral() {
        let (sut, userServices) = makeSUT()
        // 1: a variable that will hold the value of the user
        var captureUser: User?
        sut.signupWithReferralCode(email: anyMail(), password: anyPassword(), referral: anyReferral()) { user in
            // 2. Capture the user value
            captureUser = user
        }
        // 3. Create an user
        let expectedUserAfterSignup = User(email: "an mail", invitationCode: nil)
        // 4. Add the invitation code to the user
        let expectedUserAfterReferralValidation =  userServices.addInvitationCode(code: "A85awQ", to: expectedUserAfterSignup)

        // 5. Mock the completion of user signup with a user created in step 3
        userServices.complete(with: expectedUserAfterSignup, at: 0)
        // 6. Check that user invitationCode is nill
        XCTAssertEqual(expectedUserAfterSignup.invitationCode, nil)
        
        // 7. Mock the completion of code validation, pass the user with the invitation code
        userServices.complete(with: expectedUserAfterReferralValidation, at: 1)

        XCTAssertEqual(captureUser?.email, expectedUserAfterReferralValidation.email)
        XCTAssertEqual(captureUser?.invitationCode, expectedUserAfterReferralValidation.invitationCode)

        // 8. The previously created test if not working anymore, because we never complete. We can check the order here
        XCTAssertEqual(userServices.actions, [.signuped, .validatedCode])
    }
        
    
    /* MARK: Private helpers */
    private func makeSUT() -> (UserUseCase, UserServicesSpy) {
        let userServices = UserServicesSpy()
        let sut = UserUseCase(userServices: userServices)
        return (sut, userServices)
    }
    
    private func anyMail() -> String {
        return "validmail@gmail.com"
    }
    
    private func anyPassword() -> String {
        return "123456"
    }
    
    private func anyReferral() -> String {
        return "AAAAA"
    }
    
    enum SignupUseCases {
        case signuped
        case validatedCode
    }
    
    
    private class UserServicesSpy: UserServices {
        var actions = [SignupUseCases]()
        private var completions = [(Result<User, Error>) -> Void]()


        
        func signup(with mail: String, password: String, completion: @escaping (Result<User, Error>) -> Void) {
            actions.append(.signuped)
            completions.append(completion)
        }
        
        func validateCode(code: String, user: User, completion: @escaping (Result<User, Error>) -> Void) {
            actions.append(.validatedCode)
            completions.append(completion)
        }
        
        func complete(with user: User, at index: Int = 0) {
            completions[index](.success(user))
         }
         
         
         func addInvitationCode(code: String, to user: User) -> User{
             return User(email: user.email, invitationCode: code)
         }

    }


}

