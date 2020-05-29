<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.user.UserDetails,
          com.extware.member.MemberClient,
          com.extware.member.MemberModerationComparator,
          com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.member.MemberProfile,
          com.extware.emailSender.EmailSender,
          java.util.ArrayList,
          java.util.Date,
          java.util.Collections,
          java.util.GregorianCalendar,
          java.util.Calendar
"
%>
<%!
   JspWriter out = null;
   int rowNum = 1;

   PropertyFile ddProps = new PropertyFile( "com.extware.properties.DropDowns" );
   boolean lastRowWasSeperator = false;

   void setOut(JspWriter out)
   {
     this.out = out;
   }

   void resetRowNum()
   {
     this.rowNum = 1;
     lastRowWasSeperator=false;
   }

   PropertyFile getddProps()
   {
     return ddProps;
   }


   void displayModRow ( String fieldNam, int modPValue, int curPValue, int modValue, int curValue, String ddGroup ) throws java.io.IOException
   {
      displayModRow( false, fieldNam, ddProps.getString( ddGroup + "." + modPValue + "." + modValue ), ddProps.getString( ddGroup + "." + curPValue + "." + curValue ) );
   }

   void displayModRow ( String fieldNam, int modValue, int curValue, String ddGroup ) throws java.io.IOException
   {
      displayModRow( false, fieldNam, ddProps.getString( ddGroup + "." + modValue ), ddProps.getString( ddGroup + "." + curValue ) );
   }

   void displayModRow ( String fieldNam, String[] modValues, String[] curValues ) throws java.io.IOException
   {
     String modValue = "<ul>";

     for( int i = 0 ; modValues!= null && i < modValues.length ; i++ )
     {
       modValue += "<li>" + modValues[ i ] + "</li>";
     }

     modValue += "</ul>";
     String curValue = "<ul>";

     for( int i = 0 ; curValues!= null && i < curValues.length ; i++ )
     {
       curValue += "<li>" + curValues[ i ] + "</li>";
     }

     curValue += "</ul>";

     displayModRow ( true, fieldNam, modValue, curValue );
   }

   void displayModRow ( String fieldNam, String modValue, String curValue ) throws java.io.IOException
   {
     displayModRow ( true, fieldNam, modValue, curValue );
   }


   void displayModRow ( boolean bold, String fieldNam, String modValue, String curValue ) throws java.io.IOException
   {
      modValue = StringUtils.nullReplace( modValue, "NONE" );
      curValue = StringUtils.nullReplace( curValue, "NONE" );

      if( !modValue.equals( curValue ) )
      {
        out.println( "<tr>" );
        out.println( "  <td class=\"listLine" + ( rowNum % 2 ) + "\">" + fieldNam + ":</td>" );
        out.println( "  <td width=\"270\" class=\"listLine" + ( rowNum % 2 ) + "\">" + (bold?"<b>":"") + modValue + (bold?"<b>":"") + "</td>" );
        out.println( "  <td width=\"270\" class=\"listLine" + ( rowNum % 2 ) + "\">" + curValue + "</td>" );
        out.println( "</tr>" );

        rowNum++;
        lastRowWasSeperator = false;

      }
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
int memberId = NumberUtils.parseInt( request.getParameter( "id" ), -1 );

if( mode.equals( "hold" ) )
{
  MemberClient.putMemberOnHold( memberId );
}

if( mode.equals( "pass" ) && !Member.isLoggedIn( memberId ) )
{
  MemberClient.moderatePassMemberDetails( memberId );

  //now send them an email
  Member member = MemberClient.loadFullMember( memberId );

  ArrayList replacerKeys = new ArrayList();
  ArrayList replacerVals = new ArrayList();

  replacerKeys.add( "&lt;ACTIONSSTILLREQUIREDHTML&gt;" );

  String theseActionsText = "Your account will be live as soon as all of the following actions have been performed";
  String actionsHtml = "";
  if( member.memberContact == null )
  {
    actionsHtml += "<b>&nbsp;* You must enter your contact details and await their moderation.</b><br /><br />\n";
  }

  if( member.memberProfile == null )
  {
    actionsHtml += "<b>&nbsp;* You must enter your profile details and await their moderation.</b><br /><br />\n";
  }

  if( member.lastPaymentDate == null )
  {
    actionsHtml += "<b>&nbsp;* You must make a payment against your account.</b><br /><br />\n";
  }

  if( !member.emailValidated )
  {
    actionsHtml += "<b>&nbsp;* You must validate your email address.</b><br />&nbsp;&nbsp;To do this, click the link below:<br />&nbsp;&nbsp;&lt;VALIDATEEMAILADDRESSLINK&gt;<br /><br />\n";
  }

  if( actionsHtml.length() > 0 )
  {
    actionsHtml = "Your account will be live as soon as all of the following actions have been performed:<br /><br />" + actionsHtml;
  }
  else
  {
    actionsHtml = "Your current account status is <b>Live!</b><br /><br />";
  }

  replacerVals.add( actionsHtml );

  EmailSender.sendMail( "memderdetailsmod", "Your Nextface membership details have been approved", member, replacerKeys, replacerVals );
}

if( mode.equals( "fail" ) && !Member.isLoggedIn( memberId ) )
{
  MemberClient.moderateFailMemberDetails( memberId );
}

ArrayList members = MemberClient.loadMembersRequiringModeration();

//the query does its best to sort these values, but just to tart it up a bit - we pass it through javas posh sorting algorithm with a stupidly complex comparator
Collections.sort( members, new MemberModerationComparator( 'd' ) );  //the constructor sets a now timestamp internally in that class for working out whether stuff is live or not. good eh?

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
  <td colspan="5" class="title">Member Details Moderation</td>
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
MemberContact modMemContact;
MemberContact memContact;
MemberProfile modMemProfile;
MemberProfile memProfile;
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

%><tr>
  <td colspan="3">&nbsp;<br /></td>
</tr>
<tr>
  <td colspan="3" class="listHead">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td class="listHead" style="text-align: right; padding: 1px;<%= loggedinStyleInsert %>">Member:</td>
        <td width="100%" class="listHeadLink" style="<%= loggedinStyleInsert %>"><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="/login.jsp?redirectto=/pages/accountManager.jsp&email=<%= member.email %>&passwd=<%= member.passwd %>" target="_blank"><%= displayMemContact.name %></a><%= isLoggedIn ? " (<a target=\"_blank\" href=\"/logout.jsp\">logout</a> if it's you!)" : "" %></td>
        <td colspan="2" class="listHead" style="<%= holdStyleInsert %>"><%= description %></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Email:</td>
        <td width="100%" class="listHeadLink"><a href="mailto:<%= member.email %>"><%= member.email %></a></td>
        <td class="listHead" class="listHead" <%= member.lastPaymentDate!=null ? ">PAID" : ">UNPAID" %></td>
        <td><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="memberdetails.jsp?mode=pass&id=<%= member.memberId %>"><img src="/art/admin/moderation/pass.gif" border="0"/></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Shortcut:</td>
        <td width="100%" class="listHeadLink"><a href="/<%= member.profileURL %>">/<%= member.profileURL %></a></td>
        <td class="listHead" class="listHead" <%= member.goLiveDate == null ? ">NOT_LIVE" : ( member.expiryDate.before( now ) ? ">LIVE!" : ">EXPIRED" ) %></td>
        <td><a href="memberdetails.jsp?mode=hold&id=<%= member.memberId %>"><img src="/art/admin/moderation/onhold.gif" border="0" /></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Password:</td>
        <td width="100%" class="listHead" style="padding: 1px;"><%= member.passwd %></td>
        <td class="listHead" <%=  "nowrap=\"nowrap\" " + "style=\"white-space: nowrap\" >" + ( member.moderationMemberContact == null ? member.moderationMemberProfile.lastUpdatedDate : ( member.moderationMemberProfile==null || member.moderationMemberProfile.lastUpdatedDate.after( member.moderationMemberContact.lastUpdatedDate ) ?  member.moderationMemberContact.lastUpdatedDate : member.moderationMemberProfile.lastUpdatedDate ) ) %></td>
        <td><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="memberdetails.jsp?mode=fail&id=<%= member.memberId %>"><img src="/art/admin/moderation/fail.gif" border="0"/></a></td>
      </tr>
    </table>
  </td>
</tr>
<tr>
  <td class="listHead">Field</td>
  <td class="listHead">To Be Moderated</td>
  <td class="listHead">Current Value</td>
</tr>
<%

  modMemContact   = member.moderationMemberContact;
  memContact      = member.memberContact == null           ? new MemberContact() : member.memberContact;  //this is null when they are a new member

  resetRowNum();

  if( modMemContact != null )
  {
    insertSeperator( 2 );
    displayModRow( "Organisation Name"      , modMemContact.name                , memContact.name                );
    insertSeperator();
    displayModRow( "Your Status"            , modMemContact.statusRef           , memContact.statusRef           , "statusref"   );
    displayModRow( "Other Status"           , modMemContact.statusOther         , memContact.statusOther         );
    insertSeperator();
    displayModRow( "Primary Category"       , modMemContact.primaryCategoryRef  , memContact.primaryCategoryRef  , "categoryref" );
    displayModRow( "Primary Discipline"     , modMemContact.primaryCategoryRef  , memContact.primaryCategoryRef  , modMemContact.primaryDisciplineRef  , memContact.primaryDisciplineRef  , "disciplineref" );
    displayModRow( "Secondary Category"     , modMemContact.secondaryCategoryRef, memContact.secondaryCategoryRef, "categoryref" );
    displayModRow( "Secondary Discipline"   , modMemContact.secondaryCategoryRef, memContact.secondaryCategoryRef, modMemContact.secondaryDisciplineRef, memContact.secondaryDisciplineRef, "disciplineref" );
    displayModRow( "Tertiary Category"      , modMemContact.tertiaryCategoryRef , memContact.tertiaryCategoryRef , "categoryref" );
    insertSeperator();
    displayModRow( "Address Line 1"         , modMemContact.address1            , memContact.address1            );
    displayModRow( "Address Line 2"         , modMemContact.address2            , memContact.address2            );
    displayModRow( "City"                   , modMemContact.city                , memContact.city                );
    displayModRow( "Postcode"               , modMemContact.postcode            , memContact.postcode            );
    displayModRow( "County"                 , modMemContact.regionRef           , memContact.regionRef           , modMemContact.countyRef             , memContact.countyRef             , "countyref"    );
    displayModRow( "UK Region"              , modMemContact.regionRef           , memContact.regionRef           , "ukregionref" );
    displayModRow( "Country"                , modMemContact.countryRef          , memContact.countryRef          , "countryref"  );
    insertSeperator();
    displayModRow( "Full Contact Name"      , modMemContact.contactTitleRef == -1 ? null : ( getddProps().getString( "contacttitleref." + modMemContact.contactTitleRef ) + " " + modMemContact.contactFirstName + " " + modMemContact.contactSurname ), memContact.contactTitleRef == -1 ? null : ( getddProps().getString( "contacttitleref." + memContact.contactTitleRef ) + " " + memContact.contactFirstName + " " + memContact.contactSurname ) );
    displayModRow( "Telephone Number"       , modMemContact.telephone           , memContact.telephone           );
    displayModRow( "Mobile Number"          , modMemContact.mobile              , memContact.mobile              );
    displayModRow( "Fax Number"             , modMemContact.fax                 , memContact.fax                 );
    modMemContact.webAddress = modMemContact.webAddress == null ? null : ( modMemContact.webAddress.toUpperCase().startsWith( "HTTP://" ) ? modMemContact.webAddress : "http://" + modMemContact.webAddress );
    displayModRow( "Web Address"            , ( modMemContact.webAddress == null || modMemContact.webAddress.length()==0 ) ? null : ( "<a target=\"_blank\" href=\"" + modMemContact.webAddress + "\">" + modMemContact.webAddress + "</a>" )         , memContact.webAddress        );
    insertSeperator();
    displayModRow( "Email Address"          , member.email                      , memContact == null ? null : member.email                   );
    displayModRow( "Password"               , member.passwd                     , memContact == null ? null : member.passwd                  );
    displayModRow( "Web Address Shortcut"   , member.profileURL                 , memContact == null ? null : member.profileURL              );
    insertSeperator();
    displayModRow( "Where Did You Hear"     , modMemContact.whereDidYouHearRef  , memContact.whereDidYouHearRef  , "wheredidyouhearref" );
    displayModRow( "Other Heard About"      , modMemContact.whereDidYouHearOther, memContact.whereDidYouHearOther );
    displayModRow( "Other Magazine"         , modMemContact.whereDidYouHearMagazine, memContact.whereDidYouHearMagazine );
  }

  //Member Profile Stuff
  modMemProfile   = member.moderationMemberProfile;
  memProfile      = member.memberProfile == null           ? new MemberProfile() : member.memberProfile;   //this is null when they are a new member

  if( modMemProfile != null )
  {
    insertSeperator(2);
    displayModRow( "Personal Statement"        , modMemProfile.personalStatement, memProfile.personalStatement );
    insertSeperator();
    displayModRow( "Specialisations" , modMemProfile.getSpecialisationList(), memProfile.getSpecialisationList() );
    insertSeperator();
    displayModRow( "Keywords"        , modMemProfile.getKeywordList(), memProfile.getKeywordList() );
  }

  insertSeperator(2);
}


if( members.size()==0 )
{

%><tr>
  <td colspan="5" class="listSubHead">No Member Details Requiring Moderation!!!!!!!</td>
</tr>
<%

}

%>
</table>
</body>
</html>