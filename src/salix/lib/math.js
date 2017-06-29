/**
 * Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
 * All rights reserved.
 *
 * This file is licensed under the BSD 2-Clause License, which accompanies this project
 * and is available under https://opensource.org/licenses/BSD-2-Clause.
 * 
 * Contributors:
 *  - Tijs van der Storm - storm@cwi.nl - CWI
 *  
 */

/*
observer.disconnect();
*/

function registerMath(salix) {
	/*
	var start0 = salix.start;
	salix.start = function () {
		start0();
		var target = document.getElementsByTagName('div');
		var observer = new MutationObserver(function(mutations) {
	    // alert("changed:"+mutations.length);
	    var found = false;
			    mutations.forEach(function(mutation) {
				var id = mutation.target.getAttribute('id');
				if (id!=null) alert(id);
			    var nodeType = mutation.target.nodeType;
				var className = mutation.target.className;
				if (nodeType==Node.ELEMENT_NODE) {
			    	// alert(mutation.target.tagName);
			    	found = true;
			    }
			    if (nodeType==Node.TEXT_NODE) {
			    	alert(mutation.target.textContent);
			    	found = true;
			    }
			  }); 
			  if (found) alert(found);
			  if (found) MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
			});
		var config = {attributes: true, childList: true, characterData: true
				,subtree:true};
		observer.observe(target[0], config);
	}
	*/
	
	/* Old  Code not Neeeded
	 function val2result(x) {
		if (typeof x === 'undefined') {
			return {type: 'nothing'};
		}
		if (typeof x === 'string') {
			return {type: 'string', value: x}
		}
		if (typeof x === 'number') {
			return {type: 'integer', value: x};
		}
		if (typeof x === 'boolean') {
			return {type: 'boolean', value: x};
		}
	}
		
	salix.Subscriptions.timeOnce = function (h, args) {
				var timer = setTimeout(function() {
					var data = {type: 'integer', value: (new Date().getTime() / 1000) | 0};
					var handler = salix.getNativeHandler(h);
					handler(data); 		
				}, args.interval);
				return function () { clearTimeout(timer); };
			
	};
	
	*/
	
	function nothing() {
		return {type: 'nothing'};
	}
	salix.Commands.rerun = function (args) {
		// alert("rerun:"+args["id"]+":"+args["txt"]);
		var math = document.getElementById("a"+args["id"]);	
		MathJax.Hub.Queue(["Typeset",MathJax.Hub, math]);	
		return nothing();
	};
	
};