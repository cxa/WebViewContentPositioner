//
//  ViewController.swift
//  Demo
//
//  Created by CHEN Xian’an on 1/7/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

import UIKit
import WebViewContentPositioner

private let userDefaultsPositionKey = "userDefaultsPositionKey"

class ViewController: UIViewController {

  private lazy var webView: UIWebView = {
    let w = UIWebView(frame: CGRectZero)
    w.translatesAutoresizingMaskIntoConstraints = false
    w.delegate = self
    return w
  }()
  
  override func loadView() {
    super.loadView()
    view.addSubview(webView)
    _setupConstraintLayouts()
    _setupToolbarItems()
    guard let url = NSURL(string: "https://en.m.wikipedia.org/wiki/Native_Americans_in_the_United_States") else { fatalError("Fail to construct URL") }
    webView.loadRequest(NSURLRequest(URL: url))
  }

}

extension ViewController: UIWebViewDelegate {
  
  func webViewDidFinishLoad(webView: UIWebView) {
    toolbarItems?.forEach { $0.enabled = true }
  }
  
}

private extension ViewController {
  
  func _setupConstraintLayouts() {
    NSLayoutConstraint.activateConstraints([
      webView.leadingAnchor.constraintEqualToAnchor(view.leadingAnchor),
      webView.trailingAnchor.constraintEqualToAnchor(view.trailingAnchor),
      webView.topAnchor.constraintEqualToAnchor(view.topAnchor),
      webView.bottomAnchor.constraintEqualToAnchor(view.bottomAnchor)
    ])
  }
  
  func _setupToolbarItems() {
    let savePositionItem = UIBarButtonItem(title: "Save Position", style: .Plain, target: self, action: #selector(ViewController.saveCurrentPosition(_:)))
    let restorePositionItem = UIBarButtonItem(title: "Restore Position", style: .Plain, target: self, action: #selector(ViewController.restorePosition(_:)))
    let flexItem = UIBarButtonItem(barButtonSystemItem: .FlexibleSpace, target: nil, action: nil)
    toolbarItems = [savePositionItem, flexItem, restorePositionItem]
    toolbarItems?.forEach { $0.enabled = false }
  }
  
  func _showAlertWithTitle(title: String?, message: String?) {
    let ac = UIAlertController(title: title, message: message, preferredStyle: .Alert)
    ac.addAction(UIAlertAction(title: "Dismiss", style: .Cancel, handler: { _ in }))
    presentViewController(ac, animated: true, completion: nil)
  }
  
  @objc func saveCurrentPosition(sender: AnyObject?) {
    guard let jsonStr = webView.currentPosition() else { return }
    print(jsonStr)
    let ud = NSUserDefaults.standardUserDefaults()
    ud.setObject(jsonStr, forKey: userDefaultsPositionKey)
    ud.synchronize()
    _showAlertWithTitle("Position JSON String Saved to NSUserDefaults", message: "Relaunch app and tap “Restore Position” button to restore saved position.")
  }
  
  @objc func restorePosition(sender: AnyObject?) {
    guard let jsonStr = NSUserDefaults.standardUserDefaults().objectForKey(userDefaultsPositionKey) as? JSONString else {
      _showAlertWithTitle("No Saved Position", message: nil)
      return
    }
    
    webView.restorePosition(jsonStr)
  }
  
}
