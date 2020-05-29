	xMousePos = 0; // Horizontal position of the mouse on the screen
	yMousePos = 0; // Vertical position of the mouse on the screen
	xMousePosMax = 0; // Width of the page
	yMousePosMax = 0; // Height of the page

	function captureMousePosition(e)
	{
		if (document.layers)
		{
			xMousePos = e.pageX;
			yMousePos = e.pageY;
			xMousePosMax = window.innerWidth+window.pageXOffset;
			yMousePosMax = window.innerHeight+window.pageYOffset;
		}
		else if (document.all)
		{
			xMousePos = window.event.x+document.body.scrollLeft;
			yMousePos = window.event.y+document.body.scrollTop;
			xMousePosMax = document.body.clientWidth+document.body.scrollLeft;
			yMousePosMax = document.body.clientHeight+document.body.scrollTop;
		}
		else if (document.getElementById)
		{
			xMousePos = e.pageX;
			yMousePos = e.pageY;
			xMousePosMax = window.innerWidth+window.pageXOffset;
			yMousePosMax = window.innerHeight+window.pageYOffset;
		}
		getMouseXY(e);
	}

	if (document.layers)
	{
		// Netscape
		document.captureEvents(Event.MOUSEMOVE);
		document.onmousemove = captureMousePosition;
	}
	else if (document.all)
	{
		// Internet Explorer
		document.onmousemove = captureMousePosition;
	}
	else if (document.getElementById)
	{
		// Netcsape 6
		document.onmousemove = captureMousePosition;
	}




	function showDisp(html)
	{
		document.getElementById('disp').innerHTML = html
		document.getElementById('dispCell').style.visibility = 'visible';
		moveDisp()
	}

	function moveDisp()
	{
		if (document.getElementById('dispCell').style.visibility == 'visible')
		{
			var msg = document.getElementById('dispCell')
			msg.style.left = xMousePos
			msg.style.top = yMousePos + 15

			while((parseInt(msg.style.left.replace('px','')) + parseInt(msg.offsetWidth)) > xMousePosMax)
			{
				msg.style.left = parseInt(msg.style.left) - 1;
			}
			while((parseInt(msg.style.top.replace('px','')) + parseInt(msg.offsetHeight)) > yMousePosMax)
			{
				msg.style.top = parseInt(msg.style.top) - 1;
			}

			window.setTimeout('moveDisp()', 10);
		}
	}

	function hideDisp()
	{
		document.getElementById('dispCell').style.visibility = 'hidden';
	}







  //these arrays are populated once and do not change
  var fileIds   = new Array();

  //these are prepopped and the prepopped stuf can not change, but stuff can be slapped on the end.
  var markedForRemoval = new Array();
  var fileNames = new Array();
  var files = new Array();
  var fileSizes = new Array();
  var fileDescriptions = new Array();
  var fileKeywords = new Array();
  var sizeTally = 0;   //only for new elements
  var storageAlreadyUsed;  //for non deleted existing elements
  var mainFile = -1;
  var firstUploadIndex;
  var maxSize;
  var currentlyActiveDiv = 0;

  var origPortraitDisplayName = '*NONE*';
  var origPortraitSize = 0;
  var newPortraitDisplayName = '*NONE*';
  var newPortraitSize = 0;
  var briefDescriptionText = '';
  var keywordText = '';

  function addFile()
  {
    if( currentlyActiveDiv==-1 )
    {
      alert( 'Sorry you may only upoad 20 files at a time. You must upload these files before continuing' );
      return false;
    }

    //get file name
    theForm = document.forms[ 'registerportfoliofiles' ];
    fName = document.getElementById('f' + currentlyActiveDiv ).value;

    //checks
    if( getPositionInArray( files, fName ) != -1 )
    {
      alert( 'That file is already marked for upload' );
      return;
    }
    if( theForm.portfoliofiledesc.value == briefDescriptionText || theForm.portfoliofiledesc.value == '' )
    {
      alert( 'Please type a brief description of the file' );
      return;
    }
    if( theForm.portfoliofilekeyword.value == keywordText || theForm.portfoliofilekeyword.value == '' )
    {
      alert( 'Please type a keyword for the file' );
      return;
    }

    activeSlot = currentlyActiveDiv + firstUploadIndex;

    files[ activeSlot ] = fName;

    //first file you upload defaults to main file
    if( files.length == 1 && mainFile == -1 )
    {
      mainFile = activeSlot;
    }

    if( typeof( axo ) != "undefined" )
    {
      fileSizes[ activeSlot ] = axo.getFile( fName ).size;
      adjustSizeTally( fileSizes[ activeSlot ] );
    }

    fileSplit = ( fName.replace( / /g, "_" ) ).split( '/' );
    fileSplit2 = fileSplit[ fileSplit.length-1 ].split( '\\' );
    fileNameNoPath = fileSplit2[ fileSplit2.length-1 ];
    if( fileNameNoPath.length > 45 )
      fileNameNoPath = '...' + fileNameNoPath.substr(fileNameNoPath.length-42, 42);
    fileNames[ activeSlot ] = fileNameNoPath;

    fileDescriptions[ activeSlot ] = theForm.portfoliofiledesc.value;

    fileKeywords[ activeSlot ] = theForm.portfoliofilekeyword.value;

    theForm.portfoliofiledesc.value = briefDescriptionText;
    theForm.portfoliofilekeyword.value = keywordText;
    updateFileTable();

    activeDivOn( false );
    currentlyActiveDiv = findFirstSlot();
    activeDivOn( true );

  }

  function updateFileTable()
  {
    ftHTML = '<table border="0" cellpadding="0" cellspacing="0" border="0" width="405">';
    ftHTML += '<tr><td width="205"><h5>Portfolio files</h5></td><td width="45"><h5>Size</h5></td><td width="90"><h5>Main image</h5></td><td width="65"><h5>Remove</h5></td></tr>';
    ftHTML += '<tr><td colspan="4" class="fileuploadtabsep"><img src="/art/fileuploadtabsep.gif" height="1" width="405"></td></tr>';
    for( i=0 ; i<firstUploadIndex ; i++ )
    {
        if( typeof( markedForRemoval[ i ] )=='undefined' || markedForRemoval[ i ] != true )
        {
          remCheckedInsert = '';
          remImInsert = 'src="/art/blank.gif"';
        }
        else
        {
          remCheckedInsert = 'checked = "checked" ';
          remImInsert = 'onmouseover="dispWarn( ' + i + ' );" onmouseout="hideDisp();" src="/art/warning.gif"';
        }
        if( i == mainFile )
          checkedInsert = 'checked = "checked" ';
        else
          checkedInsert = '';
        ftHTML += '<tr><td class="fileuploadtabtxt"><div width="205" style="overflow: hidden;" onmouseover="dispFile( ' + i + ' );" onmouseout="hideDisp();">' + fileNames[ i ] + '</div></td><td class="fileuploadtabtxt">' + prettyFileSize( fileSizes[ i ] ) + 'mb</td><td class="fileuploadtabtxt" style="text-align: center"><input type="radio" ' + checkedInsert + 'name="mainimg" onclick="mainFile=' + i + ';" value="' + i + '"></td><td class="fileuploadtabtxt" style="text-align: right; padding-top: 0px; padding-bottom: 0px"><span id="r' + i + '"><img width="19" height="17" ' + remImInsert +' /></span><input type="checkbox" ' + remCheckedInsert + 'name="rem" onclick="removeFile( ' + i + ', this );" value="f"><img height="1" width="25" src="/art/blank.gif" /></td></tr>\n';
        ftHTML += '<tr><td colspan="4" class="fileuploadtabsep"><img src="/art/fileuploadtabsep.gif" height="1" width="405"></td></tr>';
    }
    for( i=firstUploadIndex ; i<maxSize ; i++ )
    {
      if( typeof( files[ i ] )!='undefined' && files[ i ] != null && files[ i ] != '' )
      {
        if( i == mainFile )
          checkedInsert = 'checked = "checked" ';
        else
          checkedInsert = '';
        ftHTML += '<tr><td class="fileuploadtabtxtGrn"><div width="205" style="overflow: hidden;" onmouseover="dispFile( ' + i + ' );" onmouseout="hideDisp();">' + fileNames[ i ] + '</div></td><td class="fileuploadtabtxtGrn">' + prettyFileSize( fileSizes[ i ] ) + 'mb</td><td class="fileuploadtabtxt" style="text-align: center"><input type="radio" ' + checkedInsert + 'name="mainimg" onclick="mainFile=' + i + ';" value="' + i + '"></td><td class="fileuploadtabtxt" style="text-align: center"><a href="#" onclick="removeMarkedFile( ' + i + ' ); return false;">remove</a></td></tr>\n';
        ftHTML += '<tr><td colspan="4" class="fileuploadtabsep"><img src="/art/fileuploadtabsep.gif" height="1" width="405"></td></tr>';
      }
    }
    if( fileNames.length == 0 )
    {
      ftHTML += '<tr><td colspan="4" class="fileuploadtabtxt">None marked for upload</td></tr>';
      ftHTML += '<tr><td colspan="4" class="fileuploadtabsep"><img src="/art/fileuploadtabsep.gif" height="1" width="405"></td></tr>';
    }
    ftHTML +=  '</table>\n';
    document.getElementById('filetable').innerHTML = ftHTML;
    positionSeperatorBottoms();
  }

  function dispWarn( idx )
  {
    showDisp( "This file is already on our server.<br />Once deleted it can only be replaced<br />by being re-uploaded. If you're<br />sure you want to delete the file<br />it will be deleted once you click:<br /><br /><b>Amend my portfilio and continue</b>" );
  }

  function dispFile( idx )
  {
    onserverText = "";
    if( idx < firstUploadIndex )
      onserverText = "This file is already on our server.";
    else
      onserverText = "This file is marked for upload onto our server.";
    showDisp( onserverText + "<br /><br /><b>Description:</b> " + fileDescriptions[ idx ] + "<br /><b>Keywords:</b> " + fileKeywords[ idx ] );
  }

  function dispLogo( onServer )
  {
    onserverText = "";
    if( onServer )
      onserverText = "This file is already on our server.";
    else
      onserverText = "This file is marked for upload onto our server.";
    showDisp( onserverText );
  }

  function removeFile( idx, chkbx )
  {
    if( chkbx.checked )
    {
      writelayer( 'r'+idx, '<img onmouseover="dispWarn( ' + idx + ' );" onmouseout="hideDisp();" width="19" height="17" src="/art/warning.gif" />' );
      markForRemoval( idx, true );
      updatelinktextelt = getElt( 'submitlink' );
      updatelinktextelt.innerHTML = "Amend my portfolio and continue";
    }
    else
    {
      writelayer( 'r'+idx, '<img width="19" height="17" src="/art/blank.gif" />' );
      markForRemoval( idx, false );
    }
  }

  function markForRemoval( idx, remove )
  {
    //areYouSure = confirm( 'Are you sure you want to delete this file, it has already uploaded and will have to be re-uploaded if deleted in error' );
    if( remove )
    {
      adjustStorageAlreadyUsed( -1 * fileSizes[ idx ] );
      markedForRemoval[ idx ] = true;
      if( mainFile == idx )
      {
        mainFile = -1;
      }
      updateFileTable();
    }
    else
    {
      adjustStorageAlreadyUsed( fileSizes[ idx ] );
      markedForRemoval[ idx ] = false;
    }
  }


  function removeMarkedFile( idx )
  {
    adjustSizeTally( -1 * fileSizes[ idx ] );
    fileNames[idx] = '';
    files[idx] = '';
    fileSizes[idx] = '';
    fileDescriptions[idx] = '';
    fileKeywords[idx] = '';
    if( mainFile == idx )
    {
      mainFile = -1;
    }
    if( currentlyActiveDiv == -1 )  //if upload limit reached, thn allow furthe ruploads now one's been deleted.
    {
      activeDivOn( false );
      currentlyActiveDiv = findFirstSlot();
      activeDivOn( true );
    }
    updateFileTable();

  }



  function updatePortraitFileTable()
  {

    ftHTML = '<table border="0" cellpadding="0" cellspacing="0" border="0" width="405">';
    ftHTML +=  '<tr><td colspan="3" class="fileuploadtabsep"><img src="/art/fileuploadtabsep.gif" height="1" width="405"></td></tr>';
    ftHTML += '<tr><td width="205"><h5>Portrait/Logo</h5></td><td width="45"><h5>Size</h5></td><td width="155">&nbsp;</td></tr>';
    ftHTML += '<tr><td colspan="3" class="fileuploadtabsep"><img src="/art/fileuploadtabsep.gif" height="1" width="405"></td></tr>';
    portraitFileSelect = document.getElementById( 'companylogo' ).value;
    if( portraitFileSelect=='' )
    {
      if( origPortraitDisplayName == '*NONE*' )
      {
        ftHTML += '<tr><td colspan="2" class="fileuploadtabtxt">None marked for upload</td></tr>';
      }
      else
      {
        ftHTML += '<tr><td class="fileuploadtabtxt"><div width="205" style="overflow: hidden;" onmouseover="dispLogo( true );" onmouseout="hideDisp();">' + origPortraitDisplayName + '</div></td><td class="fileuploadtabtxt">' + prettyFileSize( origPortraitSize ) + 'mb</td></tr>';
      }
    }
    else
    {
      if( typeof( axo ) != "undefined" )
      {
        adjustSizeTally( -1 * newPortraitSize );   //is zero if this is first time going green
        newPortraitSize = axo.getFile( portraitFileSelect ).size;
        adjustSizeTally( newPortraitSize );
      }
      if( newPortraitDisplayName=='*NONE*' )
      {
        adjustStorageAlreadyUsed( -1 * origPortraitSize );
      }

      //create display file name and size
      fileSplit = ( portraitFileSelect.replace( / /g, "_" ) ).split( '/' );
      fileSplit2 = fileSplit[ fileSplit.length-1 ].split( '\\' );
      fileNameNoPath = fileSplit2[ fileSplit2.length-1 ];
      if( fileNameNoPath.length > 45 )
        fileNameNoPath = '...' + fileNameNoPath.substr(fileNameNoPath.length-42, 42);
      newPortraitDisplayName = fileNameNoPath;
      if( newPortraitSize != 0 )
      {
        size = prettyFileSize( newPortraitSize );
      }
      else
      {
        size='?';
      }
      ftHTML += '<tr><td class="fileuploadtabtxtGrn"><div width="205" style="overflow: hidden;" onmouseover="dispLogo( false );" onmouseout="hideDisp();">' + newPortraitDisplayName + '</div></td><td class="fileuploadtabtxtGrn">' + size + 'mb</td></tr>';
    }
    ftHTML +=  '<tr><td colspan="3" class="fileuploadtabsep"><img src="/art/fileuploadtabsep.gif" height="1" width="405"></td></tr>';
    ftHTML +=  '</table>\n';
    document.getElementById('portraitfiletable').innerHTML = ftHTML;
  }



  function activeDivOn( isOn )
  {
    fs = document.getElementById( 'fileSelect' + currentlyActiveDiv );
    if( fs == null )
    {
      return;
    }
    if( isOn )
    {
      if( fs.display )
      {
        fs.display="block";
      }
      else
      {
        fs.style.display="block";
      }
    }
    else
    {
      if( fs.display )
      {
        fs.display="none";
      }
      else
      {
        fs.style.display="none";
      }
    }
  }


  function findFirstSlot()
  {
    for( i = firstUploadIndex ; i < maxSize ; i++ )
    {
      if( typeof( files[ i ] ) == "undefined" || files[ i ] == null || files[ i ] == '' )
        return i - firstUploadIndex;
    }
    alert( 'Maximum number of simultaneous downloads reached' );
    return -1;
  }


//  function markForRemoval( idx )
//  {
//    areYouSure = confirm( 'Are you sure you want to delete this file, it has already uploaded and will have to be re-uploaded if deleted in error' );
//    if( areYouSure )
//    {
//      adjustStorageAlreadyUsed( -1 * fileSizes[ idx ] );
//      markedForRemoval[ idx ] = true;
//      if( mainFile == idx )
//      {
//        mainFile = -1;
//      }
//      updateFileTable();
//    }
//  }
//
//
//  function removeMarkedFile( idx )
//  {
//    adjustSizeTally( -1 * fileSizes[ idx ] );
//    //fileNames[idx] = '';
//    //files[idx] = '';
//    //fileSizes[idx] = '';
//    //fileDescriptions[idx] = '';
//    //fileKeywords[idx] = '';
//    if( mainFile == idx )
//    {
//      mainFile = -1;
//    }
//    if( currentlyActiveDiv == -1 )  //if upload limit reached, thn allow furthe ruploads now one's been deleted.
//    {
//      activeDivOn( false );
//      currentlyActiveDiv = findFirstSlot();
//      activeDivOn( true );
//    }
//    //updateFileTable();
//
//  }


  function getPositionInArray( array, element )
  {
    posn=-1;
    for( i=0; i<array.length; i++ )
    {
      if( array[ i ] == element )
      {
        posn=i;
        break;
      }
    }
    return posn;
  }


  function adjustSizeTally( ammount )
  {
    sizeTally += ammount;
    updateStorageRequiredDiv();
  }

  function adjustStorageAlreadyUsed( ammount )
  {
    storageAlreadyUsed += ammount;
    updateStorageAlreadyUsedDiv();
    updateStorageRequiredDiv();
  }

  function updateStorageAlreadyUsedDiv()
  {
    alreadyUsedText = "<h5>Storage already used: " + prettyFileSize( storageAlreadyUsed ) + "MB out of 20MB</h5>";
    elt = document.getElementById('alreadyused');
    elt.innerHTML = alreadyUsedText;
  }

  function updateStorageRequiredDiv()
  {
    if( typeof( axo ) != "undefined" )
    {
      sizeTallyText = '<table width="100%" cellpadding="0" cellspacing="0"><tr><td width="100%"><h5>Storage required this upload: ' + prettyFileSize( sizeTally ) + 'MB [Max ' + prettyFileSize( maxFileSizeMB*1024*1024 - storageAlreadyUsed ) + 'MB]</h5></td></tr></table>';
      document.getElementById('filesizetally').innerHTML = sizeTallyText;
    }
  }


  function prettyFileSize( sizeBytes )
  {
    if( typeof( sizeBytes )=='undefined' )
    {
      return '?'
    }
    if( sizeBytes<0 )
    {
      sizeBytes = 0;
    }
    sizeDisplay = Math.round( 100 * sizeBytes / (1024*1024) ) / 100;
    return sizeDisplay;
  }


  function populateHiddens()   //deleteids
  {
    filesTxt='';
    filedescriptionsTxt='';
    filekeywordsTxt='';
    deleteIdsTxt='';
    for( i=0 ; i<firstUploadIndex ; i++ )
    {
      if( typeof( markedForRemoval[ i ] )!='undefined' && markedForRemoval[ i ]==true )
        deleteIdsTxt += fileIds[ i ] + '\t~~\t';
    }
    for( i=firstUploadIndex ; i<maxSize ; i++ )
    {
      filesTxt += starString( files[ i ] ) + '\t~~\t';
      filedescriptionsTxt += starString( fileDescriptions[ i ] )+ '\t~~\t';
      filekeywordsTxt += starString( fileKeywords[ i ] ) + '\t~~\t';
    }
    theForm = document.forms[ 'registerportfoliofiles' ];
    theForm.files.value = filesTxt;
    theForm.filedescriptions.value = filedescriptionsTxt;
    theForm.filekeywords.value = filekeywordsTxt;
    theForm.deleteids.value = deleteIdsTxt;
    if( mainFile < firstUploadIndex )
    {
      theForm.mainfileid.value = fileIds[ mainFile ];
    }
    else
    {
      theForm.mainfileid.value = 'i_' + ( mainFile - firstUploadIndex );
    }
    theForm.portraitimage.value = document.getElementById( 'companylogo' ).value;
  }

  function starString( str )
  {
    if( typeof( str )=='undefined' || str==null || str=='' )
      return '*';
    else
      return str
  }

  function explainActiveX()
  {
    alert( "Due to the internet's strict security regulations, web browsers are not allowed access to file sizes. Browsers such as Internet Explorer that support ActiveX controls will allow this if you enable the use of ActiveX controls for this site." );
  }



//search anim gif layer
preloadImagePaths[ 2 ] = "/art/uploadAnim.gif";
preloadedImages[ 2 ] = new Image();
preloadImagePaths[ 3 ] = "/art/uploadInProgress.gif";
preloadedImages[ 3 ] = new Image();

function showUploadAnim()
{
  ux=getlayerleft( "portraitfiletable" );
  uy=getlayertop( "portraitfiletable" );
  uw=getlayerwidth( "portraitfiletable" );
  uh=getlayerheight( "portraitfiletable" ) + getlayerheight( "filetable" );

  //animLayer = getElt("uploadinganim");
  writelayer( 'uploadinganim', '<table cellpadding="0" cellspacing="0" width="' + uw + '" height="' + uh + '" style="background-color: #888888;"><tr><td width="50%"></td><td align="center" style="background-color: #888888; vertical-align: middle;"><table width="366" height="96" cellpadding="0" cellspacing="0" style="filter:alpha(opacity=100);-moz-opacity:1.0; background-color: #000000"><tr><td rowspan="2" width="96"><img id="fileUpAnimGif" width="96" height="96" src="' + preloadedImages[ 2 ].src + '" /></td><td width="270"><img width="270" height="38" src="' + preloadedImages[ 3 ].src + '" /></td></tr><tr><td style="background-color: #000000; text-align: center; font-size: 12px; color: #ffffff; padding-top: 6px" height="58"><b>We advise that you do not<br />cancel this operation once started.</b><br /><p style="font-weight: normal; color: #ffffff; padding-top: 3px; margin-bottom: 0px">Upload times depend on connection speed</p></td></tr></table></td><td width="50%"></td></tr></table>' );
  //getElt( 'fileUpAnimGif' ).src = preloadedImages[ 2 ].src;
  //sizelayer( 'searchinganim', uw, uh );
  movelayer( 'uploadinganim', ux, uy );
  //showlayer( 'uploadinganim' );
  getElt( 'uploadinganim' ).style.display = "block";
}

function hideUploadAnim()
{
  getElt( 'uploadinganim' ).style.display = "none";
}

function submituploadform()
{
populateHiddens();
document.forms[ 'registerportfoliofiles' ].submit();
showUploadAnim();
}