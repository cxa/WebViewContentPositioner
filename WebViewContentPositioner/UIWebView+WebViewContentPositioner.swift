//
//  UIWebView+WebViewContentPositioner.swift
//  WebViewContentPositioner
//
//  Created by CHEN Xian’an on 1/6/16.
//  Copyright © 2016 lazyapps. All rights reserved.
//

import UIKit
import JavaScriptCore

public typealias JSONString = String

public extension UIWebView {
  
  func currentPosition() -> JSONString? {
    return stringByEvaluatingJavaScriptFromString("JSON.stringify(WebViewContentPositioner.currentPosition())")
  }
  
  func restorePosition(position: JSONString) {
    stringByEvaluatingJavaScriptFromString("WebViewContentPositioner.restorePosition(\(position))")
  }
  
}

private extension UIWebView {
  
  var context: JSContext? {
    return valueForKeyPath("documentView.webView.mainFrame.javaScriptContext") as? JSContext
  }
  
  func evalJSIfNeeded() {
    guard
      context?.objectForKeyedSubscript("WebViewContentPositioner").isUndefined != false,
      let bundle = NSBundle(identifier: "com.lazyapps.WebViewContentPositioner"),
      let jsFileURL = bundle.URLForResource("positioner", withExtension: "js"),
      let script = try? NSString(contentsOfURL: jsFileURL, encoding: NSUTF8StringEncoding)
    else  { return }

    context?.evaluateScript(script as String)
  }
  
  @objc func WebViewContentPositioner_traitCollectionDidChange(previousTraitCollection: UITraitCollection?) {
    guard traitCollection != previousTraitCollection else { return }
    evalJSIfNeeded()
    // This method involve DOM modification, it's safe to call with `stringByEvaluatingJavaScriptFromString` but not `evaluateScript` of `JSContext`
    stringByEvaluatingJavaScriptFromString("WebViewContentPositioner.restorePosition()")
  }
  
}
