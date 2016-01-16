//
//  KeyboardListener.swift
//  DropDown
//
//Created by Mac on 07/01/16.
//  Copyright © 2015 Mac. All rights reserved.
//

import UIKit

internal final class KeyboardListener {
	
	static let sharedInstance = KeyboardListener()
	
	private(set) var isVisible = false
	private(set) var keyboardFrame = CGRectZero
	private var isListening = false
	
	deinit {
		stopListeningToKeyboard()
	}
	
}

//MARK: - Notifications

extension KeyboardListener {
	
	func startListeningToKeyboard() {
		if isListening {
			return
		}
		
		isListening = true
		
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: "keyboardDidShow:",
			name: UIKeyboardDidShowNotification,
			object: nil)
		NSNotificationCenter.defaultCenter().addObserver(
			self,
			selector: "keyboardDidHide:",
			name: UIKeyboardDidHideNotification,
			object: nil)
	}
	
	func stopListeningToKeyboard() {
		NSNotificationCenter.defaultCenter().removeObserver(self)
	}
	
	@objc
	private func keyboardDidShow(notification: NSNotification) {
		isVisible = true
		keyboardFrame = keyboardFrameFromNotification(notification)
	}
	
	@objc
	private func keyboardDidHide(notification: NSNotification) {
		isVisible = false
		keyboardFrame = keyboardFrameFromNotification(notification)
	}
	
	private func keyboardFrameFromNotification(notification: NSNotification) -> CGRect {
		return (notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.CGRectValue() ?? CGRectZero
	}
	
}