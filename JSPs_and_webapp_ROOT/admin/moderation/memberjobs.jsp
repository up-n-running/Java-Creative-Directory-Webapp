<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.user.UserDetails,
          com.extware.member.MemberClient,
          com.extware.member.MemberModerationComparator,
          com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.member.MemberJob,
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
int memberJobId = NumberUtils.parseInt( request.getParameter( "memberjobid" ), -1 );
int memberId = NumberUtils.parseInt( request.getParameter( "memberid" ), -1 );
if( mode.equals( "hold" ) )
{
  MemberClient.putMemberOnHold( memberId );
}
if( mode.equals( "pass" ) && !Member.isLoggedIn( memberId ) )
{
  MemberClient.moderatePassMemberJob( memberJobId );
}
if( mode.equals( "fail" ) && !Member.isLoggedIn( memberId ) )
{
  MemberClient.moderateFailMemberJob( memberJobId );
}

ArrayList members = MemberClient.getJobsForModeration();
//the query does its best to sort these values, but just to tart it up a bit - we pass it through javas posh sorting algorithm with a stupidly complex comparator
Collections.sort( members, new MemberModerationComparator( 'j' ) );  //the constructor sets a now timestamp internally in that class for working out whether stuff is live or not. good eh?

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
  <td colspan="5" class="title">Member Jobs Moderation</td>
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

Member member;
String description;
String holdStyleInsert;
String loggedinStyleInsert;
boolean isLoggedIn;
Calendar wentOnHoldCal;
Calendar nowCal;


for( int i = 0 ; i < members.size() ; i++ )
{
  member = (Member)members.get( i );
  MemberContact displayMemContact = member.memberContact == null ? member.moderationMemberContact : member.memberContact;

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
  <td colspan="3" class="listHead">
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
        <td class="listHead" style="text-align: right;"><a href="memberjobs.jsp?mode=hold&memberid=<%= member.memberId %>"><img src="/art/admin/moderation/onhold.gif" border="0" /></a></td>
      </tr>
    </table>
  </td>
</tr>
<%

  resetRowNum();
  insertSeperator(2);

  MemberJob[] memberJobArr;
  MemberJob displayMemberJob;

  for( int j = 0 ; j < member.memberJobs.size() ; j++ )
  {
    memberJobArr = (MemberJob[])member.memberJobs.get( j );
    displayMemberJob = memberJobArr[ 0 ] !=null ? memberJobArr[ 0 ] : memberJobArr[ 1 ];

%><tr>
  <td colspan="3" class="listHead">
    <table border="0" cellpadding="0" cellspacing="0" width="100%">
      <tr>
        <td class="listHeadModerationLable">Job:</td>
        <td width="100%" class="listHeadLink"><a href="/login.jsp?email=<%= member.email %>&passwd=<%= member.passwd %>&redirectto=<%= URLEncoder.encode( "/servlet/MemberJobs?form=jobsearch&divertto=&mode=edit&jobselect=" + memberJobArr[ 1 ].memberJobId ) %>" target="_blank"><%= displayMemberJob.referenceNo %>: <%= displayMemberJob.title %></a></td>
        <td class="listHead" style="text-align: right;" ><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="memberjobs.jsp?mode=pass&memberjobid=<%= memberJobArr[ 1 ].memberJobId %>&memberid=<%= member.memberId %>"><img src="/art/admin/moderation/pass.gif" border="0"/></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Email:</td>
        <td width="100%" class="listHeadLink"><a href="mailto:<%= memberJobArr[ 1 ].email  %>"><%= memberJobArr[ 1 ].email %></a></td>
        <td class="listHead" style="text-align: right;" ><a <%= isLoggedIn ? "onclick=\"alert( 'You may not pass or fail a user while they are logged in, the resulting data if you and they change their details simultaneously can be invalid' ); return false; \"" : "" %>href="memberjobs.jsp?mode=fail&memberjobid=<%= memberJobArr[ 1 ].memberJobId %>&memberid=<%= member.memberId %>"><img src="/art/admin/moderation/fail.gif" border="0"/></a></td>
      </tr>
      <tr>
        <td class="listHeadModerationLable">Shortcut:</td>
        <td width="100%" class="listHeadLink"><a href="/<%= member.profileURL %>">Job Id <%= memberJobArr[ 1 ].memberJobId %></a></td>
        <td class="listHead" nowrap="nowrap" style="white-space: nowrap"><%= memberJobArr[ 1 ].lastUpdatedDate %></td>

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

    MemberJob     modMemJob   = memberJobArr[ 1 ];
    MemberJob     memJob      = memberJobArr[ 0 ] == null ? new MemberJob() : memberJobArr[ 0 ];  //this is null when they are a new member
    resetRowNum();

    insertSeperator( 2 );
    displayModRow( "Reference Number"   , modMemJob.referenceNo      , memJob.referenceNo      );
    displayModRow( "Job Title"          , modMemJob.title            , memJob.title            );
    insertSeperator( 1 );
    displayModRow( "Job Category"       , modMemJob.mainCategoryRef  , memJob.mainCategoryRef  , "categoryref" );
    displayModRow( "Job Discipline"     , modMemJob.mainCategoryRef  , memJob.mainCategoryRef  , modMemJob.disciplineRef , memJob.disciplineRef  , "disciplineref" );
    insertSeperator( 1 );
    displayModRow( "Type Of Work"       , modMemJob.typeOfWorkRef    , memJob.typeOfWorkRef    , "typeofworkref" );
    displayModRow( "Salary"             , modMemJob.salary           , memJob.salary           );
    insertSeperator( 1 );
    displayModRow( "City"               , modMemJob.city             , memJob.city             );
    displayModRow( "County"             , modMemJob.ukRegionRef      , memJob.ukRegionRef      , modMemJob.countyRef     , memJob.countyRef      , "countyref"    );
    displayModRow( "UK Region"          , modMemJob.ukRegionRef      , memJob.ukRegionRef      , "ukregionref" );
    displayModRow( "Country"            , modMemJob.countryRef       , memJob.countryRef       , "countryref"  );
    insertSeperator( 1 );
    displayModRow( "Telephone Number"   , modMemJob.telephone        , memJob.telephone        );
    displayModRow( "Email Address"      , modMemJob.email            , memJob.email            );
    displayModRow( "Contact Name"       , modMemJob.contactName      , memJob.contactName      );
    insertSeperator( 1 );
    displayModRow( "Contact Name"       , modMemJob.description      , memJob.description      );

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
  <td colspan="5" class="listSubHead">No Member Jobs Requiring Moderation!!!!!!!</td>
</tr>
<%

}

%>
</table>
</body>
</html>