<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.user.UserDetails,
          com.extware.member.MemberClient,
          com.extware.member.MemberModerationComparator,
          com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.member.MemberFile,
          com.extware.asset.Asset,
          java.util.ArrayList,
          java.util.Date,
          java.util.Collections,
          java.util.GregorianCalendar,
          java.util.Calendar,
          java.net.URLEncoder
"
%>
<%!
   JspWriter out = null;
   int rowNum = 0;
   PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
   boolean lastRowWasSeperator = false;

   void setOut(JspWriter out)
   {
     this.out = out;
   }

   void resetRowNum()
   {
     this.rowNum = 0;
     lastRowWasSeperator=false;
   }

   PropertyFile getddProps()
   {
     return ddProps;
   }

   void displayModRow ( String fieldNam, String[] modValues ) throws java.io.IOException
   {
     String modValue = "<ul>";

     for( int i = 0 ; modValues!= null && i < modValues.length ; i++ )
     {
       modValue += "<li>" + modValues[ i ] + "</li>";
     }

     modValue += "</ul>";

     displayModRow ( true, fieldNam, modValue );
   }

   void displayModRow ( String fieldNam, String modValue ) throws java.io.IOException
   {
     displayModRow ( true, fieldNam, modValue );
   }


   void displayModRow ( boolean bold, String fieldNam, String value ) throws java.io.IOException
   {
      value = StringUtils.nullReplace( value, "NONE" );

      out.println( "<tr>" );
      out.println( "  <td class=\"listLine" + ( rowNum % 2 ) + "\">" + fieldNam + ":</td>" );
      out.println( "  <td width=\"540\" class=\"listLine" + ( rowNum % 2 ) + "\">" + (bold?"<b>":"") + value + (bold?"<b>":"") + "</td>" );
      out.println( "</tr>" );

      rowNum++;
      lastRowWasSeperator = false;
   }

   void insertSeperator() throws java.io.IOException
   {
     insertSeperator( 1 );
   }

   void insertSeperator( int height ) throws java.io.IOException
   {
     if( lastRowWasSeperator )
     {
       height--;
     }

     if( height > 0 )
     {
       out.println( "<tr><td colspan=\"3\" style=\"height: " + height + "px; background: #000000;\"></td></tr>" );
       lastRowWasSeperator = true;
     }
   }

%>
<%
   // sets the out jspWriter in the method tag to the proper out jspWriter
   setOut(out);
%>

<%

UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String errors     = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message    = StringUtils.nullString( request.getParameter( "message" ) ).trim();

// if coming back to this form, we must make the change required
String mode = StringUtils.nullString( request.getParameter( "mode" ) );
int memberId = NumberUtils.parseInt( request.getParameter( "memberid" ), -1 );
int memberFileId = NumberUtils.parseInt( request.getParameter( "memberfileid" ), -1 );
int assetId = NumberUtils.parseInt( request.getParameter( "assetid" ), -1 );

if( mode.equals( "hold" ) )
{
  MemberClient.putMemberOnHold( memberId );
}
else if( mode.equals( "pass" ) && !Member.isLoggedIn( memberId ) )
{
  MemberClient.moderatePassMemberFile( memberFileId );
}
else if( mode.equals( "fail" ) && !Member.isLoggedIn( memberId ) )
{
  //this deletes asset file and asset row and memberFile row
  MemberFile tempMemFile = new MemberFile();
  tempMemFile.assetId = assetId;
  tempMemFile.deleteMe();    //due to integrity constraints memberfile row will be deleted too, magic.
}

ArrayList members = MemberClient.getFilesForModeration();
//the query does its best to sort these values, but just to tart it up a bit - we pass it through javas posh sorting algorithm with a stupidly complex comparator
Collections.sort( members, new MemberModerationComparator( 'f' ) );  //the constructor sets a now timestamp internally in that class for working out whether stuff is live or not. good eh?

Date now = new Date();  //to find out if stuff is live yet.

%><html>
<head>
<title>Moderation</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<%

if( ( mode.equals( "pass" ) || mode.equals( "fail" ) ) && Member.isLoggedIn( memberId ) )
{

%><script type="text/javascript">
  alert( 'Since you last loaded this page, the member you just tried to moderate has logged in!! - their member details have not been moderated. If it was you who logged in as them, please use the link in the red bar to logout then refresh this page. Otherwise you will have to wait unfortunately.' );
</script>
<%

}

%><table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title">Member Files Moderation</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="5" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="5" class="message"><%= message %></td>
</tr>
<%

}

Member member = null;
MemberContact displayMemContact;
String description;
String holdStyleInsert;
String loggedinStyleInsert;
boolean isLoggedIn;
Calendar wentOnHoldCal;
Calendar nowCal;

for( int i = 0 ; i < members.size() ; i++ )
{
  member = (Member)members.get( i );
  displayMemContact = member.memberContact == null ? member.moderationMemberContact : member.memberContact;

  //display logic
  description = "NEW_CHANGE";
  holdStyleInsert = "";
  loggedinStyleInsert = "";
  isLoggedIn = false;

  if( member.onModerationHold )
  {
    holdStyleInsert = " background-color: yellow";
    description = "ON_HOLD";

    wentOnHoldCal = new GregorianCalendar();
    wentOnHoldCal.setTime( member.wentOnHoldDate );
    nowCal = new GregorianCalendar();
    nowCal.setTime( now );

    if( wentOnHoldCal.get( Calendar.YEAR ) == nowCal.get( Calendar.YEAR ) && wentOnHoldCal.get( Calendar.DAY_OF_YEAR ) == nowCal.get( Calendar.DAY_OF_YEAR ) )
    {
      holdStyleInsert = " background-color: #11ffff";
      description     = "NEW_HOLD";
    }
  }

  if( Member.isLoggedIn( member.memberId ) )
  {
    loggedinStyleInsert=" background-color: red";
    description = "LOGGED_IN/" + description;
    isLoggedIn = true;
  }

%>
<tr>
  <td colspan="2" class="listHead">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td class="listHead" style="text-align: right; padding: 1px;<%= loggedinStyleInsert %>">Member:</td>
        <td width="100%" class="listHeadLink" style="<%= loggedinStyleInsert %>"><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="/login.jsp?redirectto=/pages/accountManager.jsp&email=<%= member.email %>&passwd=<%= member.passwd %>" target="_blank">Member Id <%= member.memberId %></a><%= isLoggedIn ? " (<a target=\"_blank\" href=\"/logout.jsp\">logout</a> if it's you!)" : "" %></td>
        <td colspan="2" class="listHead" style="<%= holdStyleInsert %>"><%= description %></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Email:</td>
        <td width="100%" class="listHeadLink"><a href="mailto:<%= member.email %>"><%= member.email %></a></td>
        <td class="listHead" <%= member.lastPaymentDate!=null ? ">PAID" : ">UNPAID" %></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Shortcut:</td>
        <td width="100%" class="listHeadLink"><a href="/<%= member.profileURL %>">/<%= member.profileURL %></a></td>
        <td class="listHead" <%= member.goLiveDate == null ? ">NOT_LIVE" : ( member.expiryDate.before( now ) ? ">LIVE!" : ">EXPIRED" ) %></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Password:</td>
        <td width="100%" class="listHead" style="padding: 1px;"><%= member.passwd %></td>
        <td class="listHead" style="text-align: right;"><a href="memberfiles.jsp?mode=hold&memberid=<%= member.memberId %>"><img src="/art/admin/moderation/onhold.gif" border="0" /></a></td>
      </tr>
    </table>
  </td>
</tr>
<%

  resetRowNum();
  insertSeperator(2);

  MemberFile memFile;
  String filePreview;

  for( int j = 0 ; j < member.moderationMemberFiles.size() ; j++ )
  {
    memFile = (MemberFile)member.moderationMemberFiles.get( j );
    memFile.asset = new Asset( memFile.assetId );

%><tr>
  <td colspan="2" class="listHead">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td class="listHeadModerationLable" nowrap="nowrap" style="white-space: nowrap;">Member File Upload Page:</td>
        <td width="100%" class="listHeadLink"><a href="/login.jsp?email=<%= member.email %>&passwd=<%= member.passwd %>&redirectto=<%= URLEncoder.encode( "/pages/registerPortfolioFiles.jsp?divertto=accountman" ) %>" target="_blank"><%= memFile.displayFileName %></a></td>
        <td class="listHead" style="text-align: right;" ><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="memberfiles.jsp?mode=pass&memberfileid=<%= memFile.memberFileId %>&memberid=<%= member.memberId %>"><img src="/art/admin/moderation/pass.gif" border="0"/></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Shortcut:</td>
        <td width="100%" class="listHeadLink"><a href="/<%= member.profileURL %>">File Id <%= memFile.memberFileId %></a></td>
        <td class="listHead" style="text-align: right;" ><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="memberfiles.jsp?mode=fail&assetid=<%= memFile.assetId %>&memberid=<%= member.memberId %>"><img src="/art/admin/moderation/fail.gif" border="0"/></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable" nowrap="nowrap" style="white-space: nowrap;">Original File:</td>
        <td width="100%" class="listHeadLink"><a href="<%= memFile.getHtmlFileName() %>"><%= memFile.displayFileName %></a></td>
        <td class="listHead"  nowrap="nowrap" style="white-space: nowrap"><%= memFile.uploadDate %></td>
      </tr>
    </table>
  </td>
</tr>
<tr>
  <td class="listHead">Field</td>
  <td class="listHead">To Be Moderated</td>
</tr>
<%

    resetRowNum();
    insertSeperator( 2 );

    displayModRow( "Type"       , memFile.portraitImage?"Portrait Image":"Portfolio File"                );
    displayModRow( "Description", memFile.description    );
    displayModRow( "Keywords"   , memFile.getKeywordList()    );
    insertSeperator();

    filePreview = "Not an Image, no preview available";

    if( memFile.isImage && !memFile.portraitImage )
    {
      filePreview =  memFile.getPostProcessAssetHtml( "ProfilePageMainImage" );
    }
    else if( memFile.isImage && memFile.portraitImage )
    {
      filePreview =  memFile.getPostProcessAssetHtml( "ProfilePageLogoImage" );
    }

    displayModRow( "File Preview", filePreview );
    insertSeperator(2);
  }

%><tr>
  <td colspan="3" height="40" >&nbsp;<br /></td>
</tr>
<%

}

if( members.size()==0 )
{

%><tr>
  <td colspan="5" class="listSubHead">No Member Files Requiring Moderation!!!!!!!</td>
</tr>
<%

}

%>
</table>
</body>
</html>