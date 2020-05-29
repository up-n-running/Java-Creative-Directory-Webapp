<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberClient,
          com.extware.member.MemberFile,
          com.extware.utils.PropertyFile,
          java.util.ArrayList"
%><%
//globals for this jsp.
String briefDescriptionText = "Type a brief descrition here";
String keywordText = "Type keywords here";
int    maxFileSizeMB = 20;

boolean firstTimeRegistering = true;
String redirectTo = "/pages/registerPayment.jsp?first=true";

if( request.getParameter( "redirectto" )!=null )
{
  redirectTo = request.getParameter( "redirectto" );
  firstTimeRegistering = false;
}

if( request.getParameter( "divertto" )!=null && request.getParameter( "divertto" ).equals( "accountman" ) )
{
  redirectTo = "/pages/accountManager.jsp";
  firstTimeRegistering = false;
}

//Get logged in user if there is a user logged in
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

//if not logged in, sack them off
if( loggedInMember==null )
{
  %><jsp:forward page="/loggedOut.jsp" /><%
  return;
}

PropertyFile dataDictionary = PropertyFile.getDataDictionary();
if( MemberClient.findUnpaidPortfolioFileSpaceMB() >= dataDictionary.getInt( "portfolioFile.maxUnpaidStorageMegaBytes" ) )
{
  %><jsp:forward page="/pages/infoPage.jsp?page=cannotupload" /><%
  return;
}

//fetch list of files already uploaded
ArrayList allFiles = new ArrayList();
allFiles.addAll( loggedInMember.memberFiles );
allFiles.addAll( loggedInMember.moderationMemberFiles );

//if there are errors to report.
ArrayList errorsToReport = (ArrayList)request.getAttribute( "errors" );

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<script type="text/javascript">
  var axo = new ActiveXObject("Scripting.FileSystemObject");
</script>
<script type="text/javascript" language="javascript" src="/js/fileUpload.js"></script>
<script type="text/javascript">
  function populateGlobalsOnInit()
  {
<%

long fileSizeTally = 0;
int mainFile = -1;
MemberFile file;

for( int i = 0 ; i < allFiles.size() ; i++ )
{
  file = (MemberFile)allFiles.get( i );

  if( file.portraitImage )
  {

%>    origPortraitDisplayName="<%= file.displayFileName %>"; origPortraitSize = <%= file.fileByteSize %>;
<%

    fileSizeTally += file.fileByteSize;
    allFiles.remove( i ); //remove this from arraylist and go onto next one

    if( i < allFiles.size() )
    {
      file = (MemberFile)allFiles.get( i );
    }
    else
    {
      continue;
    }
  }

%>    fileIds[<%= i %>] = <%= file.memberFileId %>; markedForRemoval[<%= i %>] = false; fileNames[<%= i %>] = "<%= file.displayFileName %>"; files[<%= i %>] = "*"; fileSizes[<%= i %>] = <%= file.fileByteSize %>; fileDescriptions[<%= i %>] = "<%= file.description %>"; fileKeywords[<%= i %>] = "<%= file.keywords %>";
<%

  fileSizeTally += file.fileByteSize;

  if( file.mainFile )
  {
    mainFile = i;
  }
}

long storageTempLong = 10*fileSizeTally/(1024*1024);

String storageTemp = ( storageTempLong == 0 ) ? "00" : String.valueOf( storageTempLong );
String storageAlreadyUsed = storageTemp.substring( 0, storageTemp.length() - 1 ) + "." + storageTemp.substring( storageTemp.length() - 1 );

%>    firstUploadIndex = <%= allFiles.size() %>;
    maxSize = firstUploadIndex + 21;
    storageAlreadyUsed = <%= fileSizeTally %>;
    sizeTally = 0;
    mainFile = <%= mainFile %>;
    maxFileSizeMB = <%= maxFileSizeMB %>;
    briefDescriptionText = '<%= briefDescriptionText %>';
    keywordText = '<%= keywordText %>';
  }

  populateGlobalsOnInit();
</script>

<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regfile1"/>
</jsp:include>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr>
  <td nowrap="nowrap" width="130" class="portFileCell1">Images</td>
  <td nowrap="nowrap" class="portFileCell1">...GIF, JPEG, PNG</td>
</tr>
<tr>
  <td nowrap="nowrap" width="130" class="portFileCell1">Movies</td>
  <td nowrap="nowrap" class="portFileCell1">...MPEG, AVI</td>
</tr>
<tr>
  <td nowrap="nowrap" width="130" class="portFileCell1">Audio</td>
  <td nowrap="nowrap" class="portFileCell1">...MP3, WAV, WMA</td>
</tr>
<tr>
  <td nowrap="nowrap" width="130" class="portFileCell1">Text/Mixed</td>
  <td nowrap="nowrap" class="portFileCell1">...TXT, PDF, DOC and more!</td>
</tr>
</table>
<br />
<%

if( firstTimeRegistering )
{

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/accountManager.jsp">Save what I've entered so far an i'll come back later</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="linkNoTarget">Or proceed below...</h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}
else
{

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/accountManager.jsp">Go back to account manager, i'll come back later</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="linkNoTarget">Or proceed below...</h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}

%>
<table cellpadding="0" cellspacing="0" border="0" width="100%">
<tr>
  <td nowrap="nowrap" class="portFileCell2">File upload area:</td>
  <td width="100%" align="right"><img width="112" height="87" src="/art/fileUpload.gif" /></td>
</tr>
</table>
<%

//if we are returning from reg servlet with errors
if( errorsToReport != null )
{

%>
<p>There were some problems with the files uploaded...<p>
<%

  for( int i=0; i<errorsToReport.size(); i++ )
  {
%><p class="error"><%= (String)errorsToReport.get( i ) %></p>
<%

  }
}

%>
<h4 style="margin-bottom: 0px;">Browse to your portrait image or company logo</h4>
<p>This image will appear next to your name on your profile.</p>

<form name="registerportfoliofiles" onsubmit="" action="/servlet/MemberFiles" method="post" enctype="multipart/form-data">
  <input type="hidden" name="files" value="" />
  <input type="hidden" name="mainfileid" value="" />
  <input type="hidden" name="filedescriptions" value="" />
  <input type="hidden" name="filekeywords" value="" />
  <input type="hidden" name="deleteids" value="" />
  <input type="hidden" name="portraitimage" value="" />
  <input type="hidden" name="redirectto" value="<%= redirectTo %>">

  <table cellpadding="0" cellspacing="0">
  <tr>
    <td><input class="bigFormElement" id="companylogo" size="50" type="file" name="companylogo" onfocus="updatePortraitFileTable();" onblur="updatePortraitFileTable();" /><br /></td>
  </tr>
  </table>
  <br />
  <h4>Browse to your portfolio files</h4>
  <p class="emphasiseColor"><img src="/art/textdecor/h4Dot.gif" /><span class="stepText">Step 1:</span> Use the 'Browse' button below to select a file from your computer.</li></p>
  <p class="emphasiseColor"><img src="/art/textdecor/h4Dot.gif" /><span class="stepText">Step 2:</span> Add a brief description and keywords for the file in the spaces provided below.</li></p>
  <p class="emphasiseColor"><img src="/art/textdecor/h4Dot.gif" /><span class="stepText" style="margin-bottom: 2px;">Step 3:</span> Click the add button to add the file to the upload list.</li></p>
  <table cellpadding="0" cellspacing="0">
  <tr>
    <td class="formElementCell" height="25" id="fileselecthanger">
    <div id="fileSelect0" style="display: block;"><input class="bigFormElement" id="f0"  type="file" name="pfo0"  size="50" /></div>
    <div id="fileSelect1"><input class="bigFormElement" id="f1"  type="file" name="pfo1"  size="50" /></div>
    <div id="fileSelect2"><input class="bigFormElement" id="f2"  type="file" name="pfo2"  size="50" /></div>
    <div id="fileSelect3"><input class="bigFormElement" id="f3"  type="file" name="pfo3"  size="50" /></div>
    <div id="fileSelect4"><input class="bigFormElement" id="f4"  type="file" name="pfo4"  size="50" /></div>
    <div id="fileSelect5"><input class="bigFormElement" id="f5"  type="file" name="pfo5"  size="50" /></div>
    <div id="fileSelect6"><input class="bigFormElement" id="f6"  type="file" name="pfo6"  size="50" /></div>
    <div id="fileSelect7"><input class="bigFormElement" id="f7"  type="file" name="pfo7"  size="50" /></div>
    <div id="fileSelect8"><input class="bigFormElement" id="f8"  type="file" name="pfo8"  size="50" /></div>
    <div id="fileSelect9"><input class="bigFormElement" id="f9"  type="file" name="pfo9"  size="50" /></div>
    <div id="fileSelect10"><input class="bigFormElement" id="f10" type="file" name="pfo10" size="50" /></div>
    <div id="fileSelect11"><input class="bigFormElement" id="f11" type="file" name="pfo11" size="50" /></div>
    <div id="fileSelect12"><input class="bigFormElement" id="f12" type="file" name="pfo12" size="50" /></div>
    <div id="fileSelect13"><input class="bigFormElement" id="f13" type="file" name="pfo13" size="50" /></div>
    <div id="fileSelect14"><input class="bigFormElement" id="f14" type="file" name="pfo14" size="50" /></div>
    <div id="fileSelect15"><input class="bigFormElement" id="f15" type="file" name="pfo15" size="50" /></div>
    <div id="fileSelect16"><input class="bigFormElement" id="f16" type="file" name="pfo16" size="50" /></div>
    <div id="fileSelect17"><input class="bigFormElement" id="f17" type="file" name="pfo17" size="50" /></div>
    <div id="fileSelect18"><input class="bigFormElement" id="f18" type="file" name="pfo18" size="50" /></div>
    <div id="fileSelect19"><input class="bigFormElement" id="f19" type="file" name="pfo19" size="50" /></div>
    <div id="fileSelect20"><input class="bigFormElement" id="f20" type="file" name="pfo20" size="50" /></div>
    <div id="maxExceeded" >SORRY YOU MAY ONLY UPLOAD 20 FILES AT A TIME</div>
    </td>
  </tr>
  <tr>
    <td>Type a brief description here to go with the file (max 20 words)</td>
  </tr>
  <tr>
    <td style="padding-bottom: 5px"><input class="bigFormElement" type="text" onfocus="if( this.value=='<%= briefDescriptionText %>' ) { this.value=''; }" name="portfoliofiledesc" value="<%= briefDescriptionText %>" /></td>
  </tr>
  <tr>
    <td>Type in a comma separated list of keywords for this file</td>
  </tr>
  <tr>
    <td style="padding-bottom: 5px"><input class="bigFormElement" type="text" onfocus="if(this.value=='<%= keywordText %>' ) { this.value=''; }" name="portfoliofilekeyword" value="<%= keywordText %>" /></td>
  </tr>
  </table>

  <table cellpadding="0" cellspacing="0">
  <tr>
    <td width="100%">Now click 'add' to add this file to the list below<br />Note: Files listed in black are already loaded onto our servers. Hover cursor over file name for description.</td>
    <td><a href="javascript: addFile();"><img src="/art/addButton.gif" border="0" /></a></td>
  </tr>
  </table>

  <br />
  <h4 style="padding-bottom: 2px;">Files waiting to be uploaded...</h4>
  <br />
    <div id="portraitfiletable"></div>
    <div id="filetable"></div>
  <br />
  <div id="alreadyused"><h5>Storage already used: <%= storageAlreadyUsed %>MB</h5></div>
  <div id="filesizetally"><table width="100%" cellpadding="0" cellspacing="0"><tr><td width="100%" nowrap="nowrap"><h5>Storage required this upload: UNKNOWN.</h5></td><td nowrap="nowrap"><p class="orangeh6" nowrap="nowrap" style="background: none; white-space: nowrap"><a href="#" onclick="explainActiveX(); return false;">Tell me why?</a></p></td></tr></table></div>
<script type="text/javascript">
  updateFileTable();
  updateStorageAlreadyUsedDiv();
  updateStorageRequiredDiv();
  updatePortraitFileTable();
</script>
  <br />
  <jsp:include page="/inc/tasteAndTermsInclude.jsp" flush="true" />
  <br />
  <table cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td nowrap="nowrap"><a onclick="if( tAndTCheck() ) { submituploadform(); } return false;" href="#"><h6 id="submitlink">Upload these files and continue</h6></a></td>
    <td width="100%"></td>
  </tr>
  </table>
</form>

<div id="uploadinganim">
</div>

<span id="dispCell" style="position: absolute; visibility: hidden; display: block; height:12; color:#FF5555; z-index: 0;">
  <table style="filter:alpha(opacity=85);-moz-opacity:0.9; z-index: 0;" bgcolor="#000000" cellspacing="0" cellpadding="1" width="100px">
  <tr>
    <td>
      <table style="z-index: 0;" bgcolor="#F3F3F3" width="100px">
      <tr>
        <td valign="top" nowrap="nowrap"><p id="disp"></p></td>
      </tr>
      </table>
    </td>
  </tr>
  </table>
</span>

<jsp:include page="/inc/pageFoot.jsp" flush="true" />