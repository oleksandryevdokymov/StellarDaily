//
//  StellarDailyUITests.swift
//  StellarDailyUITests
//
//  Created by Oleksandr Yevdokymov on 14.02.2026.
//

import XCTest

final class StellarDailyUITests: XCTestCase {

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
    }

    func testAppLaunches_andTabBarExists() {
        let app = XCUIApplication()
        app.launch()

        // Tab bar must exist
        XCTAssertTrue(app.tabBars.firstMatch.waitForExistence(timeout: 6))

        // At least 2 tabs (your challenge required Tab Bar)
        XCTAssertGreaterThanOrEqual(app.tabBars.firstMatch.buttons.count, 2)
    }

    func testCanSwitchBetweenTabs_withoutCrashing() {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 6))

        // Tap first two tabs if they exist
        let first = tabBar.buttons.element(boundBy: 0)
        let second = tabBar.buttons.element(boundBy: 1)

        XCTAssertTrue(first.exists)
        XCTAssertTrue(second.exists)

        first.tap()
        second.tap()
        first.tap()

        // Sanity: UI still alive
        XCTAssertTrue(tabBar.exists)
    }

    func testBrowseTab_hasSomeInteractiveElement() {
        let app = XCUIApplication()
        app.launch()

        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 6))

        // Prefer a tab named "Browse" (if you used that title),
        // otherwise fall back to second tab.
        let browseButtonByName = tabBar.buttons["Browse"]
        if browseButtonByName.exists {
            browseButtonByName.tap()
        } else {
            tabBar.buttons.element(boundBy: 1).tap()
        }

        // We can't rely on your accessibility IDs. So we look for something interactive.
        // Best effort: a button, date picker, or text field.
        let anyButton = app.buttons.firstMatch
        let anyDatePicker = app.datePickers.firstMatch
        let anyTextField = app.textFields.firstMatch

        // Wait a bit for the screen to render.
        _ = anyButton.waitForExistence(timeout: 2)
        _ = anyDatePicker.waitForExistence(timeout: 2)
        _ = anyTextField.waitForExistence(timeout: 2)

        XCTAssertTrue(anyButton.exists || anyDatePicker.exists || anyTextField.exists,
                      "Expected Browse screen to contain a button, date picker, or text field.")
    }

    func testTapFirstButtonIfPresent_UIStaysResponsive() {
        let app = XCUIApplication()
        app.launch()

        // Tap second tab (Browse) if possible
        let tabBar = app.tabBars.firstMatch
        XCTAssertTrue(tabBar.waitForExistence(timeout: 6))
        if tabBar.buttons.count >= 2 {
            tabBar.buttons.element(boundBy: 1).tap()
        }

        // If there is a button, tap it (best-effort).
        // This might be "Load", "Pick date", etc.
        let button = app.buttons.firstMatch
        if button.exists && button.isHittable {
            button.tap()
        }

        // App should remain responsive: tab bar still exists
        XCTAssertTrue(tabBar.exists)
    }
}
