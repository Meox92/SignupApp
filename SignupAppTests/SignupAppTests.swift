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
    
    func test_requestSignup_onSignupWithReferral() {
        let (sut, userServices) = makeSUT()
        sut.signupWithReferralCode(email: anyMail(), password: anyPassword(), referral: anyReferral()) { _ in }
        
        XCTAssertEqual(userServices.signupCalledCount, 1)
    }
    
    func test_requestValidateCodeAfterUserCreation_onSignupWithReferral() {
        let (sut, userServices) = makeSUT()
        let exp = expectation(description: "Wait for user creation")
        sut.signupWithReferralCode(email: anyMail(), password: anyPassword(), referral: anyPassword()) { _ in
            exp.fulfill()
        }
        
        wait(for: [exp], timeout: 3.0)
        XCTAssertEqual(userServices.validateCodeCalledcount, 1)
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
    
    
    private class UserServicesSpy: UserServices {
        var signupCalledCount: Int = 0
        var validateCodeCalledcount: Int = 0
        var userServices: UserServices!
        
        func signup(with mail: String, password: String, completion: (Result<User, Error>) -> Void) {
            signupCalledCount += 1
            completion(.success(anyUser()))
        }
        
        func validateCode(code: String, user: User, completion: @escaping (Result<User, Error>) -> Void) {
            validateCodeCalledcount += 1
            completion(.success(anyUser()))
        }
        
        private func anyUser() -> User {
            return User(email: "a-valid-email@gmail.com", invitationCode: nil)
        }

    }


}

