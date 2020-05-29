// Cross-Browser Rich Text Editor
// http://www.kevinroth.com/rte/demo.htm
// Written by Kevin Roth (kevin@NOSPAMkevinroth.com - remove NOSPAM)

//init variables
var isRichText = false;
var rng;
var currentRTE;
var allRTEs = "";

var isIE;
var isGecko;
var isSafari;

var imagesPath;
var includesPath;
var cssFile;

var showViewSourceCheckbox;


function initRTE(imgPath, incPath, css, viewSrc) {
	//set browser vars
	var ua = navigator.userAgent.toLowerCase();
	isIE = ((ua.indexOf("msie") != -1) && (ua.indexOf("opera") == -1) && (ua.indexOf("webtv") == -1));
	isGecko = (ua.indexOf("gecko") != -1);
	isSafari = (ua.indexOf("safari") != -1);

	//check to see if designMode mode is available
	if (document.getElementById && document.designMode && !isSafari) {
		isRichText = true;
	}

	//set paths vars
	imagesPath = imgPath;
	includesPath = incPath;
	cssFile = css;

	showViewSourceCheckbox = viewSrc;

	//for testing standard textarea, uncomment the following line
	//isRichText = false;
}

function writeRichText(rte, html, width, height, buttons, readOnly) {
	if (isRichText) {
		if (allRTEs.length > 0) allRTEs += ";";
		allRTEs += rte;
		writeRTE(rte, html, width, height, buttons, readOnly);
	} else {
		writeDefault(rte, html, width, height, buttons, readOnly);
	}
}

function writeDefault(rte, html, width, height, buttons, readOnly) {
	if (!readOnly) {
		document.writeln('<textarea name="' + rte + '" id="' + rte + '" style="width: ' + width + 'px; height: ' + height + 'px;">' + html + '</textarea>');
	} else {
		document.writeln('<textarea name="' + rte + '" id="' + rte + '" style="width: ' + width + 'px; height: ' + height + 'px;" readonly>' + html + '</textarea>');
	}
}

function writeRTE(rte, html, width, height, buttons, readOnly) {
	if (readOnly) buttons = false;
	if (buttons == true) {
		document.writeln('<style type="text/css">');
		document.writeln('.btnImage {cursor: pointer; cursor: hand;}');
		document.writeln('</style>');
		document.writeln('<table border="0" cellpadding="0" cellspacing="0">');
		document.writeln('<tr><td valign="bottom">');
		document.writeln('<table id="Buttons1_' + rte + '">');
		document.writeln('	<tr>');
		document.writeln('		<td>');
		document.writeln('			<select id="formatblock_' + rte + '" onchange="Select(\'' + rte + '\', this.id);">');
		document.writeln('				<option value="##">Text Style...</option>');
                for( format=0; format < formatDropDownSelectHtmlList.length; format++ )
                {
			document.writeln('				' + formatDropDownSelectHtmlList[format] );
		}
		                                 //document.writeln('				<option value="<h2>">Heading 2 <h2></option>');
		                                 //document.writeln('				<option value="<h3>">Heading 3 <h3></option>');
		                                 //document.writeln('				<option value="<h4>">Heading 4 <h4></option>');
		                                 //document.writeln('				<option value="<h5>">Heading 5 <h5></option>');
		                                 //document.writeln('				<option value="<h6>">Heading 6 <h6></option>');
		                                 document.writeln('			</select>');
		                                 document.writeln('		</td>');
		                                 document.writeln('	</tr>');
		                                 document.writeln('</table>');
		                                 document.writeln('</td><td>');
		                                 document.writeln('<table id="Buttons2_' + rte + '" cellpadding="1" cellspacing="0">');
		                                 document.writeln('	<tr>');
		if (btn_insertHyperlink)         document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'hyperlink.gif" width="25" height="24" alt="Insert Link" title="Insert Link" onClick="FormatText(\'' + rte + '\', \'createlink\')"></td>');
		if (isIE && btn_cutCopyAndPaste )document.writeln('		<td>&nbsp;</td>');
		if (isIE && btn_cutCopyAndPaste )document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'cut.gif" width="25" height="24" alt="Cut" title="Cut" onClick="FormatText(\'' + rte + '\', \'cut\')"></td>');
		if (isIE && btn_cutCopyAndPaste )document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'copy.gif" width="25" height="24" alt="Copy" title="Copy" onClick="FormatText(\'' + rte + '\', \'copy\')"></td>');
		if (isIE && btn_cutCopyAndPaste )document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'paste.gif" width="25" height="24" alt="Paste" title="Paste" onClick="FormatText(\'' + rte + '\', \'paste\')"></td>');
		if (btn_textAlignAndJustify)     document.writeln('		<td>&nbsp;</td>');
		if (btn_textAlignAndJustify)     document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'left_just.gif" width="25" height="24" alt="Align Left" title="Align Left" onClick="FormatText(\'' + rte + '\', \'justifyleft\', \'\')"></td>');
		if (btn_textAlignAndJustify)     document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'centre.gif" width="25" height="24" alt="Center" title="Center" onClick="FormatText(\'' + rte + '\', \'justifycenter\', \'\')"></td>');
		if (btn_textAlignAndJustify)     document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'right_just.gif" width="25" height="24" alt="Align Right" title="Align Right" onClick="FormatText(\'' + rte + '\', \'justifyright\', \'\')"></td>');
		if (btn_textAlignAndJustify)     document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'justifyfull.gif" width="25" height="24" alt="Justify Full" title="Justify Full" onclick="FormatText(\'' + rte + '\', \'justifyfull\', \'\')"></td>');
		if (btn_undoAndRedo)             document.writeln('		<td>&nbsp;</td>');
		if (btn_undoAndRedo)             document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'undo.gif" width="25" height="24" alt="Undo" title="Undo" onClick="FormatText(\'' + rte + '\', \'undo\')"></td>');
		if (btn_undoAndRedo)             document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'redo.gif" width="25" height="24" alt="Redo" title="Redo" onClick="FormatText(\'' + rte + '\', \'redo\')"></td>');
		                                 document.writeln('		<td>&nbsp;</td>');
//		                                 document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'image.gif" width="25" height="24" alt="Add Image" title="Add Image" onClick="alignImage(\'' + rte + '\')"></td>');
	        if (isIE && btn_spellCheck)      document.writeln('		<td><img class="btnImage" src="' + imagesPath + 'spellcheck.gif" width="25" height="24" alt="Spell Check" title="Spell Check" onClick="checkspell()"></td>');
		document.writeln('	</tr>');
		document.writeln('</table>');
		document.writeln('</td></tr>');
		document.writeln('</table>');
	}
	document.writeln('<iframe id="' + rte + '" name="' + rte + '" width="' + width + 'px" height="' + height + 'px"></iframe>');
	if (!readOnly && showViewSourceCheckbox)
	  document.writeln('<br /><input type="checkbox" id="chkSrc' + rte + '" onclick="toggleHTMLSrc(\'' + rte + '\');" />&nbsp;View Source');

	document.writeln('<iframe width="254" height="174" id="cp' + rte + '" src="' + includesPath + 'palette.htm" marginwidth="0" marginheight="0" scrolling="no" style="visibility:hidden; display: none; position: absolute;"></iframe>');
	document.writeln('<input type="hidden" id="hdn' + rte + '" name="' + rte + '" value="">');
	document.getElementById('hdn' + rte).value = html;
	enableDesignMode(rte, html, readOnly);
}

function enableDesignMode(rte, html, readOnly) {
	var frameHtml = "<html id=\"" + rte + "\">\n";
	frameHtml += "<head>\n";
	//to reference your stylesheet, set href property below to your stylesheet path and uncomment
	if (cssFile.length > 0) {
		frameHtml += "<link media=\"all\" type=\"text/css\" href=\"" + cssFile + "\" rel=\"stylesheet\">\n";
	}
	frameHtml += "<style>\n";
	frameHtml += "body {\n";
	frameHtml += "	background: #FFFFFF;\n";
	frameHtml += "	margin: 0px;\n";
	frameHtml += "	padding: 0px;\n";
	frameHtml += "}\n";
	frameHtml += "</style>\n";
	frameHtml += "</head>\n";
	frameHtml += "<body>\n";
	frameHtml += html + "\n";
	frameHtml += "</body>\n";
	frameHtml += "</html>";

	if (document.all) {
		var oRTE = frames[rte].document;
		oRTE.open();
		oRTE.write(frameHtml);
		oRTE.close();
		if (!readOnly) oRTE.designMode = "On";
	} else {
		try {
			if (!readOnly) document.getElementById(rte).contentDocument.designMode = "on";
			try {
				var oRTE = document.getElementById(rte).contentWindow.document;
				oRTE.open();
				oRTE.write(frameHtml);
				oRTE.close();
				//oRTE.addEventListener("blur", updateRTE(rte), true);
				if (isGecko && !readOnly) {
					//attach a keyboard handler for gecko browsers to make keyboard shortcuts work
					oRTE.addEventListener("keypress", kb_handler, true);
				}
			} catch (e) {
				alert("Error preloading content.");
			}
		} catch (e) {
			//gecko may take some time to enable design mode.
			//Keep looping until able to set.
			if (isGecko) {
				setTimeout("enableDesignMode('" + rte + "', '" + html + "');", 10);
			} else {
				return false;
			}
		}
	}
}

function updateRTEs() {
	var vRTEs = allRTEs.split(";");
	for (var i = 0; i < vRTEs.length; i++) {
		updateRTE(vRTEs[i]);
	}
}

function updateRTE(rte) {
	//set message value
	var oHdnMessage = document.getElementById('hdn' + rte);
	var oRTE = document.getElementById(rte);
	var readOnly = false;

	//check for readOnly mode
	if (document.all) {
		if (frames[rte].document.designMode != "On") readOnly = true;
	} else {
		if (document.getElementById(rte).contentDocument.designMode != "on") readOnly = true;
	}

	if (isRichText && !readOnly) {
		//if viewing source, switch back to design view
		//alert( typeof( document.getElementById("chkSrc" + rte) ) );
		if ( showViewSourceCheckbox  ) {
		  if( document.getElementById("chkSrc" + rte).checked) {
			  document.getElementById("chkSrc" + rte).checked = false;
			  toggleHTMLSrc(rte);
			}
		}

		if (oHdnMessage.value == null) oHdnMessage.value = "";
		if (document.all) {
			oHdnMessage.value = frames[rte].document.body.innerHTML;
		} else {
			oHdnMessage.value = oRTE.contentWindow.document.body.innerHTML;
		}
		//if there is no content (other than formatting) set value to nothing
		if (stripHTML(oHdnMessage.value.replace("&nbsp;", " ")) == "") oHdnMessage.value = "";
		//fix for gecko
		if (escape(oHdnMessage.value) == "%3Cbr%3E%0D%0A%0D%0A%0D%0A") oHdnMessage.value = "";
	}
}

function toggleHTMLSrc(rte) {
	//contributed by Bob Hutzel (thanks Bob!)
	var oRTE;
	if (document.all) {
		oRTE = frames[rte].document;
	} else {
		oRTE = document.getElementById(rte).contentWindow.document;
	}

	if (document.getElementById("chkSrc" + rte).checked) {
		document.getElementById("Buttons1_" + rte).style.visibility = "hidden";
		document.getElementById("Buttons2_" + rte).style.visibility = "hidden";
		if (document.all) {
			oRTE.body.innerText = oRTE.body.innerHTML;
		} else {
			var htmlSrc = oRTE.createTextNode(oRTE.body.innerHTML);
			oRTE.body.innerHTML = "";
			oRTE.body.appendChild(htmlSrc);
		}
	} else {
		document.getElementById("Buttons1_" + rte).style.visibility = "visible";
		document.getElementById("Buttons2_" + rte).style.visibility = "visible";
		if (document.all) {
			oRTE.body.innerHTML = oRTE.body.innerText;
		} else {
			var htmlSrc = oRTE.body.ownerDocument.createRange();
			htmlSrc.selectNodeContents(oRTE.body);
			oRTE.body.innerHTML = htmlSrc.toString();
		}
	}
}

//Function to format text in the text box
function FormatText(rte, command, option) {
	var oRTE;
	if (document.all) {
		oRTE = frames[rte];

		//get current selected range
		var selection = oRTE.document.selection;
		if (selection != null) {
			rng = selection.createRange();
		}
	} else {
		oRTE = document.getElementById(rte).contentWindow;

		//get currently selected range
		var selection = oRTE.getSelection();
		rng = selection.getRangeAt(selection.rangeCount - 1).cloneRange();
	}

	try {
		if ((command == "forecolor") || (command == "hilitecolor")) {
			//save current values
			parent.command = command;
			currentRTE = rte;

			//position and show color palette
			buttonElement = document.getElementById(command + '_' + rte);
			document.getElementById('cp' + rte).style.left = getOffsetLeft(buttonElement) + "px";
			document.getElementById('cp' + rte).style.top = (getOffsetTop(buttonElement) + buttonElement.offsetHeight) + "px";
			if (document.getElementById('cp' + rte).style.visibility == "hidden") {
				document.getElementById('cp' + rte).style.visibility = "visible";
				document.getElementById('cp' + rte).style.display = "inline";
			} else {
				document.getElementById('cp' + rte).style.visibility = "hidden";
				document.getElementById('cp' + rte).style.display = "none";
			}
		} else if (command == "createlink") {
			var szURL = prompt("Enter a URL:", "");
			try {
				//ignore error for blank urls
				oRTE.document.execCommand("Unlink", false, null);
				oRTE.document.execCommand("CreateLink", false, szURL);
			} catch (e) {
				//do nothing
			}
		} else {
			//oRTE.focus();
		  	oRTE.document.execCommand(command, false, option);
			//oRTE.focus();
		}
	} catch (e) {
		alert(e);
	}
}

//Function to set color
function setColor(color) {
	var rte = currentRTE;
	var oRTE;
	if (document.all) {
		oRTE = frames[rte];
	} else {
		oRTE = document.getElementById(rte).contentWindow;
	}

	var parentCommand = parent.command;
	if (document.all) {
		//retrieve selected range
		var sel = oRTE.document.selection;
		if (parentCommand == "hilitecolor") parentCommand = "backcolor";
		if (sel != null) {
			var newRng = sel.createRange();
			newRng = rng;
			newRng.select();
		}
	} else {
		//oRTE.focus();
	}
	oRTE.document.execCommand(parentCommand, false, color);
	//oRTE.focus();
	document.getElementById('cp' + rte).style.visibility = "hidden";
	document.getElementById('cp' + rte).style.display = "none";
}

//Function to add image
function AddImage( rte, imageURL, alignText ) {
	var oRTE;
	if (document.all) {
		oRTE = frames[rte];

		//get current selected range
		var selection = oRTE.document.selection;
		if (selection != null) {
			rng = selection.createRange();
		}
	} else {
		oRTE = document.getElementById(rte).contentWindow;

		//get currently selected range
		var selection = oRTE.getSelection();
		rng = selection.getRangeAt(selection.rangeCount - 1).cloneRange();
	}
        if( typeof( imageURL )=='undefined' )
        {
	  imagePath = prompt('Enter Image URL:', 'http://');
	}
	else
	{
	  imagePath = imageURL;
	}
	if ((imagePath != null) && (imagePath != "")) {
		//oRTE.focus();
		//oRTE.document.execCommand( 'JustifyLeft' );
		oRTE.document.execCommand('InsertImage', false, imagePath);
	}
	alignImage( rte, imagePath, alignText );
	//oRTE.focus();
}

//I MADE THIS - john
function alignImage( rte, url, alignText ) {
	rgxp = '';
	replaceWith = '';
	if( isIE )
	{
	  rgxp = '<IMG src="' + url + '">';
	  replaceWith = '<IMG align=' + alignText + ' src="' + url + '">';
        }
        else
        {
	  rgxp = '<img src="' + url + '">';
	  replaceWith = '<img align=' + alignText + ' src="' + url + '">';
        }
	re = new RegExp( rgxp );
	var stuff = frames[rte].document.body.innerHTML;
	stuff = stuff.replace( re, replaceWith );
	frames[rte].document.body.innerHTML = stuff;
}

//function to perform spell check
function checkspell() {
	try {
		var tmpis = new ActiveXObject("ieSpell.ieSpellExtension");
		tmpis.CheckAllLinkedDocuments(document);
	}
	catch(exception) {
		if(exception.number==-2146827859) {
			if (confirm("ieSpell not detected.  Click Ok to go to download page."))
				window.open("http://www.iespell.com/download.php","DownLoad");
		} else {
			alert("Error Loading ieSpell: Exception " + exception.number);
		}
	}
}

function getOffsetTop(elm) {
	var mOffsetTop = elm.offsetTop;
	var mOffsetParent = elm.offsetParent;

	while(mOffsetParent){
		mOffsetTop += mOffsetParent.offsetTop;
		mOffsetParent = mOffsetParent.offsetParent;
	}

	return mOffsetTop;
}

function getOffsetLeft(elm) {
	var mOffsetLeft = elm.offsetLeft;
	var mOffsetParent = elm.offsetParent;

	while(mOffsetParent) {
		mOffsetLeft += mOffsetParent.offsetLeft;
		mOffsetParent = mOffsetParent.offsetParent;
	}

	return mOffsetLeft;
}

function Select(rte, selectname) {
	var oRTE;

	//FIND SELECTED RANGE (i.e. text highlited by cursos)
	if (document.all) {
		oRTE = frames[rte];

		//get current selected range
		var selection = oRTE.document.selection;
		if (selection != null) {
			rng = selection.createRange();
		}
	} else {
		oRTE = document.getElementById(rte).contentWindow;

		//get currently selected range
		var selection = oRTE.getSelection();
		rng = selection.getRangeAt(selection.rangeCount - 1).cloneRange();
	}

	var idx = document.getElementById(selectname).selectedIndex;
	// First one is always a label
	if (idx != 0) {
		var selected = document.getElementById(selectname).options[idx].value;
		var cmd = selectname.replace('_' + rte, '');
		oRTE.document.execCommand(cmd, false, selected);
		document.getElementById(selectname).selectedIndex = 0;
	}
	//oRTE.focus();
}

function kb_handler(evt) {
	var rte = evt.target.id;

	//contributed by Anti Veeranna (thanks Anti!)
	if (evt.ctrlKey) {
		var key = String.fromCharCode(evt.charCode).toLowerCase();
		var cmd = '';
		//alert( 'hello' );
		switch (key) {
			case 'z': cmd = "undo"; break;
			case 'y': cmd = "redo"; break;
		};

//                if ( !isIE ) {
//                        switch (key) {
//				case 'x': cmd = "cut"; break;
//				case 'c': cmd = "copy"; break;
//				case 'v': cmd = "paste"; break;
//			}
//		}

		if (cmd) {
			FormatText(rte, cmd, true);
			//evt.target.ownerDocument.execCommand(cmd, false, true);
			// stop the event bubble
			evt.preventDefault();
			evt.stopPropagation();
		}
 	}
}

function docChanged (evt) {
	alert('changed');
}

function stripHTML(oldString) {
	var newString = oldString.replace(/(<([^>]+)>)/ig,"");

	//replace carriage returns and line feeds
	newString = escape(newString);
	newString = newString.replace("%0D%0A"," ");
	newString = newString.replace("%0A"," ");
	newString = newString.replace("%0D"," ");
	newString = unescape(newString);

	//trim string
	newString = trim(newString);

	return newString;
}

function trim(inputString) {
   // Removes leading and trailing spaces from the passed string. Also removes
   // consecutive spaces and replaces it with one space. If something besides
   // a string is passed in (null, custom object, etc.) then return the input.
   if (typeof inputString != "string") return inputString;
   var retValue = inputString;
   var ch = retValue.substring(0, 1);

   while (ch == " ") { // Check for spaces at the beginning of the string
      retValue = retValue.substring(1, retValue.length);
      ch = retValue.substring(0, 1);
   }
   ch = retValue.substring(retValue.length-1, retValue.length);

   while (ch == " ") { // Check for spaces at the end of the string
      retValue = retValue.substring(0, retValue.length-1);
      ch = retValue.substring(retValue.length-1, retValue.length);
   }

	// Note that there are two spaces in the string - look for multiple spaces within the string
   while (retValue.indexOf("  ") != -1) {
		// Again, there are two spaces in each of the strings
      retValue = retValue.substring(0, retValue.indexOf("  ")) + retValue.substring(retValue.indexOf("  ")+1, retValue.length);
   }
   return retValue; // Return the trimmed string back to the user
}
