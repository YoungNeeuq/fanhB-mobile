import XCTest

// MARK: - AuthFlowUITests (MO-P1-018)
// Stub-based XCUITest for the authentication flow.
// Uses launch arguments to activate the stub API client so no real network
// requests are made during the test run.

final class AuthFlowUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments += ["--uitesting", "--stub-auth"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    // MARK: - Landing

    func testAuthLandingViewIsShownAfterOnboarding() throws {
        skipOnboarding()
        XCTAssertTrue(app.staticTexts["Every drawing tells your story"].waitForExistence(timeout: 5))
    }

    func testTapContinueWithEmailShowsSignUpForm() throws {
        skipOnboarding()
        app.buttons["Continue with Email"].tap()
        XCTAssertTrue(app.staticTexts["Create account"].waitForExistence(timeout: 3))
    }

    func testTapSignInLinkShowsLoginForm() throws {
        skipOnboarding()
        app.buttons["Sign in"].tap()
        XCTAssertTrue(app.staticTexts["Welcome back"].waitForExistence(timeout: 3))
    }

    // MARK: - Email sign-up

    func testEmailSignUpValidatesEmptyFields() throws {
        skipOnboarding()
        navigateToSignUp()

        app.buttons["Create Account"].tap()

        XCTAssertTrue(app.staticTexts["Email is required."].waitForExistence(timeout: 2))
        XCTAssertTrue(app.staticTexts["Password is required."].waitForExistence(timeout: 2))
    }

    func testEmailSignUpValidatesPasswordLength() throws {
        skipOnboarding()
        navigateToSignUp()

        app.textFields.matching(identifier: "you@example.com").firstMatch.tap()
        app.textFields.matching(identifier: "you@example.com").firstMatch.typeText("test@example.com")

        app.secureTextFields.firstMatch.tap()
        app.secureTextFields.firstMatch.typeText("short")

        app.buttons["Create Account"].tap()

        XCTAssertTrue(
            app.staticTexts["Password must be at least 8 characters."].waitForExistence(timeout: 2)
        )
    }

    func testEmailSignUpSuccessWithStub() throws {
        skipOnboarding()
        navigateToSignUp()

        app.textFields.matching(identifier: "Your name").firstMatch.tap()
        app.textFields.matching(identifier: "Your name").firstMatch.typeText("Test User")

        app.textFields.matching(identifier: "you@example.com").firstMatch.tap()
        app.textFields.matching(identifier: "you@example.com").firstMatch.typeText("test@example.com")

        app.secureTextFields.firstMatch.tap()
        app.secureTextFields.firstMatch.typeText("password123")

        app.buttons["Create Account"].tap()

        // With stub, expect profile setup or main content
        let profileHeader = app.staticTexts["Set up your profile"]
        let mainContent = app.staticTexts["FanhB"]
        let appeared = profileHeader.waitForExistence(timeout: 5) || mainContent.waitForExistence(timeout: 5)
        XCTAssertTrue(appeared)
    }

    // MARK: - Email sign-in

    func testEmailSignInSuccessWithStub() throws {
        skipOnboarding()
        navigateToSignIn()

        app.textFields.matching(identifier: "you@example.com").firstMatch.tap()
        app.textFields.matching(identifier: "you@example.com").firstMatch.typeText("test@example.com")

        app.secureTextFields.firstMatch.tap()
        app.secureTextFields.firstMatch.typeText("password123")

        app.buttons["Sign In"].tap()

        XCTAssertTrue(app.staticTexts["FanhB"].waitForExistence(timeout: 5))
    }

    // MARK: - OTP

    func testOTPScreenShowsEmailAddress() throws {
        skipOnboarding()
        navigateToSignIn()

        app.buttons["Forgot password?"].tap()

        let emailField = app.textFields["you@example.com"]
        emailField.tap()
        emailField.typeText("test@example.com")

        app.buttons["Send reset code"].tap()

        XCTAssertTrue(app.staticTexts["Check your email"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.staticTexts["test@example.com"].waitForExistence(timeout: 2))
    }

    // MARK: - Helpers

    private func skipOnboarding() {
        // If onboarding is shown, navigate through it quickly.
        // In CI the `--stub-auth` flag sets `hasCompletedOnboarding = true`
        // via UserDefaults so this may be a no-op.
        let skipButton = app.buttons["Skip"]
        if skipButton.waitForExistence(timeout: 2) {
            skipButton.tap()
        }
    }

    private func navigateToSignUp() {
        app.buttons["Continue with Email"].tap()
    }

    private func navigateToSignIn() {
        app.buttons["Sign in"].tap()
    }
}
