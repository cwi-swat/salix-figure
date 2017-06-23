/**
 * Copyright (c) Tijs van der Storm <Centrum Wiskunde & Informatica>.
 * All rights reserved.
 *
 * This file is licensed under the BSD 2-Clause License, which accompanies this project
 * and is available under https://opensource.org/licenses/BSD-2-Clause.
 * 
 * Contributors:
 *  - Tijs van der Storm - storm@cwi.nl - CWI
 */

function registerMath(salix) {
	
	
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
	
	function nothing() {
		return {type: 'nothing'};
	}
	
	salix.Commands.rerun = function (args) {
		alert("rerun");
		MathJax.Hub.Queue(["Typeset",MathJax.Hub]);
		return nothing();
	};

	
	
};