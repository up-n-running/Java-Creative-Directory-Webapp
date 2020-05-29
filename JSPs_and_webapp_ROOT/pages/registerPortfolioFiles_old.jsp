<%@ page language="java"
  import=""
%><%
String breifDescriptionText = "Type a brief descrition here to go with the file (max 20 words)";
String keywordText = "Type in a keyword which accurately defines the content of this file";
int    maxFileSizeMB = 10;

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regfile1"/>
</jsp:include>
<span style="text-align:left"><h6><a href="/pages/accountManager.jsp?moderation=false">Save what i've entered so far and I'll come back later</a></h6>
<script language="javascript">
  //these arrays are populated once and do not change
  var fileIds   = new Array();
  var markedForRemoval=new Array();

  //these are prepopped and the prepopped stuf can not change, but stuff can be slapped on the end.
  var fileNames = new Array();
  var files = new Array();
  var fileSizes = new Array();
  var fileDescriptions = new Array();
  var fileKeywords = new Array();
  var sizeTally = 0;
</script>
<script language="javascript">
  var axo = new ActiveXObject("Scripting.FileSystemObject");
</script>
<script language="javascript">
  function addFile()
  {
    //get file name
    theForm = document.forms[ 0 ];
    fName = document.getElementById('f' + (files.length - fileIds.length + 1 ) ).value;

    //checks
    if( getPositionInArray( files, fName ) != -1 )
    {
      alert( 'That File is Already Marked For Upload' );
      return;
    }
    if( theForm.portfoliofiledesc.value == '<%= breifDescriptionText %>' )
    {
      alert( 'Please type a brief description of the file' );
      return;
    }
    if( theForm.portfoliofilekeyword.value == '<%= keywordText %>' )
    {
      alert( 'Please type a keyword for the file' );
      return;
    }

    files[ files.length ] = fName;

    if( typeof( axo ) != "undefined" )
    {
      fileSizes[ fileSizes.length ] = axo.getFile( fName ).size;
      adjustSizeTally( fileSizes[ fileSizes.length - 1 ] );
    }

    fileSplit = ( fName.replace( / /g, "_" ) ).split( '/' );
    fileSplit2 = fileSplit[ fileSplit.length-1 ].split( '\\' );
    fileNameNoPath = fileSplit2[ fileSplit2.length-1 ];
    if( fileNameNoPath.length > 45 )
      fileNameNoPath = '...' + fileNameNoPath.substr( fileNameNoPath.length-42, 42 );
    fileNames[ fileNames.length ] = fileNameNoPath;

    fileDescriptions[ fileDescriptions.length ] = theForm.portfoliofiledesc.value;

    fileKeywords[ fileKeywords.length ] = theForm.portfoliofilekeyword.value;

    theForm.portfoliofiledesc.value='<%= breifDescriptionText %>';
    theForm.portfoliofilekeyword.value='<%= keywordText %>';
    updateFileTable();

    fileNumber = files.length - fileIds.length;
    fsOff = document.getElementById('fileSelect' + fileNumber);
    if( fsOff.visibility )
    {
      fsOff.visibility="hidden";
      fsOff.height=0;
    }
    else
    {
      fsOff.style.visibility="hidden";
      fsOff.style.height=0;
    }
    fsOn = document.getElementById('fileSelect' + ( fileNumber+1 ) )
    if( fsOn.visibility )
    {
      fsOn.visibility="visible";
    }
    else
    {
      fsOn.style.visibility="visible";
    }
  }
</script>
<script language="javascript">
  function updateFileTable()
  {
    ftHTML =  '<table cellpadding="0" cellspacing="0" border="0" width="100%">';
    ftHTML += '<tr><td width="300"><b>File</b></td><td><b>Main Image?</b></td><td><b>Remove?</b></td></tr>\n';
    for( i=0 ; i<fileIds.length ; i++ )
    {
      if( typeof( markedForRemoval[ i ] )=='undefined' || markedForRemoval[ i ] != true )
        ftHTML += '<tr><td width="300"><font color="#ff0000">' + fileNames[ i ] + '</font></td><td><input type="radio" name="mainimg" value="' + i + '"></td><td><a href="#" onclick="markForRemoval( ' + i + ' ); return false;">remove</a></td></tr>\n';
    }
    for( i=fileIds.length ; i<fileNames.length ; i++ )
    {
      ftHTML += '<tr><td style="width: 300px;"><font color="#449944;">' + fileNames[ i ] + '</font></td><td><input type="radio" name="mainimg" value="' + i + '"></td><td><a href="#" onclick="removeMarkedFile( ' + i + ' ); return false;">remove</a></td></tr>\n';
    }
    if( fileNames.length == 0 )
    {
      ftHTML += '<tr><td colspan="3" align="center"><font color="#449944;">No files Marked For Upload</font></td><td></td><td></td></tr>\n';
      //ftHTML += '<input type="hidden" name="file" value="' + files[ i ] + '" />\n';
    }
    ftHTML +=  '</table>\n';
    document.getElementById('filetable').innerHTML = ftHTML;
  }
</script>

<script language="javascript">
  function markForRemoval( idx )
  {
    areYouSure = confirm( 'Are you sure you want to delete this file, it has already uploaded and will have to be re-uploaded if deleted in error' );
    if( areYouSure )
    {
      if( typeof( axo ) != "undefined" )
      {
        adjustSizeTally( -1 * fileSizes[ idx ] );
      }
      markedForRemoval[ idx ] == true;
      updateFileTable();
    }
  }

  function removeMarkedFile( idx )
  {
    adjustSizeTally( -1 * fileSizes[ idx ] );
    fileNames.splice( idx, 1);
    files.splice( idx, 1);
    fileSizes.splice( idx, 1);
    fileDescriptions.splice( idx, 1);
    fileKeywords.splice( idx, 1);
    updateFileTable();
  }

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
    sizeDisplay = ( sizeTally / (1024*1024) ).toString();
    if ( sizeDisplay < 0 )
      sizeDisplay=0;
    if( sizeDisplay.indexOf( '.' ) != -1 )
    {
      sizeDisplay = sizeDisplay.substring( 0, sizeDisplay.indexOf( '.' ) + 2 );
    }
    sizeTallyText = "<b>Storage Required this Upload: " + sizeDisplay + "MB [Max <%= maxFileSizeMB - 0.4252%>MB]</b>";
    document.getElementById('filesizetally').innerHTML = sizeTallyText;
  }

  function populateHiddens()
  {
    filesTxt='';
    filedescriptionsTxt='';
    filekeywordsTxt='';
    for( i=fileIds.length ; i<fileNames.length ; i++ )
    {
      filesTxt += files[ i ] + '\t';
      filedescriptionsTxt += fileDescriptions[ i ] + '\t';
      filekeywordsTxt += fileKeywords[ i ] + '\t';
    }
    theForm = document.forms[ 0 ];
    theForm.files.value = filesTxt;
    theForm.filedescriptions.value = filedescriptionsTxt;
    theForm.filekeywords.value = filekeywordsTxt;
  }

  function explainActiveX()
  {
    alert( "Due to the internet's strict security regulations, web browsers are not allowed access to file sizes. Browsers such as Internet Explorer that support ActiveX controls will allow this if you enable the use of ActiveX controls for this site." );
  }
</script>


<form name="registerportfoliofiles" onsubmit="populateHiddens();" action="/servlet/MemberFiles" method="post" enctype="multipart/form-data">
  <input type="hidden" name="mode" value="edit" />
  <input type="hidden" name="files" value="" />
  <input type="hidden" name="filedescriptions" value="" />
  <input type="hidden" name="filekeywords" value="" />
  <input type="hidden" name="deleteids" value="" />
  Portrait image or company logo...
  <table>
  <tr>
    <td class="formElementCell"><input class="formElement" type="file" name="companylogo" /></td>
  </tr>
  </table>
  Rest of files...
  <table>
  <tr>
    <td class="formElementCell">
    <div id="fileSelect1" style="visibility: visible; height: 0px;"><input id="f1" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect2" style="visibility: hidden; height: 0px;"><input id="f2" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect3" style="visibility: hidden; height: 0px;"><input id="f3" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect4" style="visibility: hidden; height: 0px;"><input id="f4" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect5" style="visibility: hidden; height: 0px;"><input id="f5" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect6" style="visibility: hidden; height: 0px;"><input id="f6" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect7" style="visibility: hidden; height: 0px;"><input id="f7" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect8" style="visibility: hidden; height: 0px;"><input id="f8" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect9" style="visibility: hidden; height: 0px;"><input id="f9" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect10" style="visibility: hidden; height: 0px;"><input id="f10" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect11" style="visibility: hidden; height: 0px;"><input id="f11" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect12" style="visibility: hidden; height: 0px;"><input id="f12" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect13" style="visibility: hidden; height: 0px;"><input id="f13" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect14" style="visibility: hidden; height: 0px;"><input id="f14" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect15" style="visibility: hidden; height: 0px;"><input id="f15" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect16" style="visibility: hidden; height: 0px;"><input id="f16" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect17" style="visibility: hidden; height: 0px;"><input id="f17" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect18" style="visibility: hidden; height: 0px;"><input id="f18" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect19" style="visibility: hidden; height: 0px;"><input id="f19" class="formElement" type="file" name="portfoliofileselect" /></div>
    <div id="fileSelect20" style="visibility: hidden; height: 20px;"><input id="f20" class="formElement" type="file" name="portfoliofileselect" /></div>
    </td>
  </tr>
  <tr>
    <td class="formElementCell"><input class="formElement" type="text" onfocus="this.value='';" name="portfoliofiledesc" value="<%= breifDescriptionText %>" /></td>
  </tr>
  <tr>
    <td class="formElementCell"><input class="formElement" type="text" onfocus="this.value='';" name="portfoliofilekeyword" value="<%= keywordText %>" /></td>
  </tr>

  <tr>
    <td align="right" class="formElementCell"><input class="formElement" style="width: 100px; background-color: #449944;" type="button" name="add" value="add" onclick="addFile();" /></td>
  </tr>

  </table>
  Files waiting to be uploaded...<br />
  <br />
  <div id="filetable"></div>
  <br />

  <!--<textarea readonly="readonly" class="formElement" name="fileswaiting" rows="9" ></textarea><br />-->
  <script language="javascript">
    updateFileTable();
  </script>
  <div><b>Storage Already Used</b> TO BE IMPLEMENTED</div>
  <div id="filesizetally"><b>Storage Required this Upload: UNKNOWN.</b> <font size="small"><a href="#" onclick="explainActiveX(); return false;">Tell me why?</a></font></div>
  </tr>
  <!--
  <tr>
    <td class="formButtons" style="text-align: right"><input type="submit" value="Upload" class="formButton" /></td>
  </tr>
  -->
  </table>
  <input type="submit" />
</form>




<jsp:include page="/inc/pageFoot.jsp" flush="true" />