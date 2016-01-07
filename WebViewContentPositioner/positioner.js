const WebViewContentPositioner = WebViewContentPositioner || {};

(function($){

  const positionerEl = (function(){
    const el = document.createElement('wvcp_caret');
    el.style.display = 'inline-block';
    el.style.height = '1px';
    el.style.width = '0';
    return el;
  })();
  
  // XPath methods copied from https://github.com/firebug/firebug
  function getElementXPath(element) {
    if (element && element.id)
      return '//*[@id="' + element.id + '"]';
    
    return getElementTreeXPath(element);
  }

  function getElementTreeXPath(element) {
    const paths = [];
    for (; element && element.nodeType == Node.ELEMENT_NODE; element = element.parentNode) {
      var index = 0;
      for (var sibling = element.previousSibling; sibling; sibling = sibling.previousSibling) {
        if (sibling.nodeType == Node.DOCUMENT_TYPE_NODE)
          continue;

        if (sibling.nodeName == element.nodeName)
          ++index;
      }

      const tagName = element.nodeName.toLowerCase();
      const pathIndex = (index ? "[" + (index+1) + "]" : "");
      paths.splice(0, 0, tagName + pathIndex);
    }

    return paths.length ? "/" + paths.join("/") : null;
  }

  function getElementByXPath(xpath) {
    try {
      var result = document.evaluate(xpath, document, null, XPathResult.ANY_TYPE, null);
      return result.iterateNext();
    } catch (exc) {
      return null;
    }
  }

  function insertPositionerToRange(range) {
    const startNode = range.startContainer;
    var parentNode, beforeNode;
    if (startNode.nodeType == Node.TEXT_NODE) {
      parentNode = startNode.parentNode;
      beforeNode = startNode.splitText(range.startOffset);
    } else {
      parentNode = startNode;
      beforeNode = startNode.firstChild;
    }

    parentNode.insertBefore(positionerEl, beforeNode);
  }

  function removePositioner() {
    const parent = positionerEl.parentNode;
    if (!parent) return;
    parent.removeChild(positionerEl);
    parent.normalize();
  }

  function encodeRange(range) {
    const obj = {};
    const getContainerXPath = function(c) {
      var textNodePath = "";
      var el = c;
      if (c.nodeType == Node.TEXT_NODE) {
	el = c.parentNode;
	for (var i=0, cns = el.childNodes, len=cns.length; i<len; i++) {
	  if (cns[i] != c) continue;
	  // xpath offset start by 1
	  textNodePath = '/text()[' + (i + 1) + ']';
	  break;
	}
      }
      
      return getElementXPath(el) + textNodePath;
    }

    const pure = function(a) { return a; }
    
    for (propAndFunc of [
      ["startContainer", getContainerXPath],
      ["startOffset", pure],
      ["endContainer", getContainerXPath],
      ["endOffset", pure]
    ]){
      const prop = propAndFunc[0];
      const func = propAndFunc[1];
      obj[prop] = func(range[prop]);
    }

    insertPositionerToRange(range);
    obj["boundingClientTop"] = positionerEl.getBoundingClientRect().top;
    removePositioner();
    return obj;
  }

  function decodeRange(obj) {
    const range = document.createRange();
    const startNode = getElementByXPath(obj.startContainer);
    const endNode = getElementByXPath(obj.endContainer);
    range.setStart(startNode, obj.startOffset);
    range.setEnd(endNode, obj.endOffset);
    return range;
  }

  $.currentPosition = function() {
    const range = document.caretRangeFromPoint(0, 0).cloneRange();
    return encodeRange(range);
  }

  $.restorePosition = function () {
    const posObj = arguments && arguments.length && arguments[0];
    var range, prevClientTop;
    if (posObj) {
      range = decodeRange(posObj);
      prevClientTop = posObj["boundingClientTop"];
    } else {
      range = document.caretRangeFromPoint(0, 0).cloneRange();
    }

    insertPositionerToRange(range);
    prevClientTop = prevClientTop || positionerEl.getBoundingClientRect().top;
    setTimeout(function(){
      const curClientTop = positionerEl.getBoundingClientRect().top;
      scrollTo(0, pageYOffset + curClientTop - prevClientTop);
      removePositioner();
    }, 0);
  }
  
})(WebViewContentPositioner);
