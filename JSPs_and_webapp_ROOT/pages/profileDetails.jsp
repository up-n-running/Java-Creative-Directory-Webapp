<%@ page language="java"
    import="com.extware.user.UserDetails,
            com.extware.utils.NumberUtils,
            com.extware.utils.StringUtils,
            com.extware.framework.DropDownOption,
            com.extware.member.Member,
            com.extware.member.MemberContact,
            com.extware.member.MemberProfile,
            com.extware.member.MemberFile,
            com.extware.member.MemberClient,
            java.util.ArrayList,
            java.net.URLEncoder"
%><%

UserDetails user = UserDetails.getUser( session );
boolean previewing = StringUtils.nullString( request.getParameter( "preview" ) ).equals( "true" );

int memberId = NumberUtils.parseInt( request.getParameter( "memberId" ), -1 );

//if they are previewing they must be logged in and they can only preview their own profile
if( previewing )
{
  //Get logged in user if there is a user logged in
  Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

  //if not logged in, sack them off
  if( loggedInMember==null )
  {
    %><jsp:forward page="/loggedOut.jsp" /><%
    return;
  }

  memberId = loggedInMember.memberId;
}

Member member = MemberClient.loadFullMember( memberId );

if( previewing )
{
  //copy moderation data across to moderated data on temporary member object got from database
  member.memberContact = member.moderationMemberContact == null ? member.memberContact : member.moderationMemberContact;
  member.memberProfile = member.moderationMemberProfile == null ? member.memberProfile : member.moderationMemberProfile;
  MemberFile tmpFile;
  for( int i = 0 ; i < member.moderationMemberFiles.size() ; i++ )
  {
    tmpFile = (MemberFile)member.moderationMemberFiles.get( i );
    tmpFile.forModeration = false;
    member.memberFiles.add( tmpFile );
  }
}

MemberContact memberContact = member.memberContact;
MemberProfile memberProfile = member.memberProfile;
MemberFile mainImage = member.mainFile;

if( mainImage != null && mainImage.forModeration )
{
  mainImage = null;
}

if( mainImage==null && member.memberFiles.size() > 0 )
{
  mainImage = (MemberFile)member.memberFiles.get( 0 );

  if( mainImage != null && mainImage.portraitImage && member.memberFiles.size() > 1 )
  {
    mainImage = (MemberFile)member.memberFiles.get( 1 );
  }
}

MemberFile portraitImage = member.portraitImage;

if( portraitImage==null && mainImage!= null )
{
  portraitImage = mainImage;
}

if( portraitImage!=null && portraitImage.forModeration )
{
  portraitImage = null;
}

int mainFileIdx = NumberUtils.parseInt( request.getParameter( "mainFileIdx" ), -1 );

if( mainFileIdx != -1 )
{
  mainImage = (MemberFile)member.memberFiles.get( mainFileIdx );
}

int mainFileId = NumberUtils.parseInt( request.getParameter( "mainfileId" ), -1 );

if( mainFileId != -1 )
{
  mainImage = (MemberFile)member.memberFiles.get( member.getModeratedMemberFileIndexById( mainFileId ) );
}

if( mainImage != null )
{
  mainFileIdx = member.getModeratedMemberFileIndexById( mainImage.memberFileId );
}

String webAddress = memberContact.webAddress;

if( webAddress != null && !webAddress.toUpperCase().startsWith( "HTTP://" ) )
{
  webAddress = "http://" + webAddress;
}

String returnTo = "/pages/srchResultsMembers.jsp";

if( request.getParameter( "returnTo" ) != null )
{
  returnTo = request.getParameter( "returnTo" );
}

String backToDesc = StringUtils.nullReplace( request.getParameter( "backtodesc" ), "profile listings" );

String metaKeywords = "Nextface, creative, directory, " + memberContact.name +
                       ( memberContact.getPrimaryDisciplineDesc() == null ? "" : ", " + memberContact.getPrimaryDisciplineDesc() ) +
                       ( memberContact.getSecondaryDisciplineDesc() == null ? "" : ", " + memberContact.getSecondaryDisciplineDesc() ) +
                       ( memberContact.getTertiaryDisciplineDesc() == null ? "" : ", " + memberContact.getTertiaryDisciplineDesc() ) +
                       ( memberContact.getStatusDesc() == null ? "" : ", " + memberContact.getStatusDesc() ) +
                       ( memberContact.getCountyDesc() == null ? "" : ", " + memberContact.getCountyDesc() ) +
                       ( memberContact.city == null ? "" : ", " + memberContact.city ) +
                       ( memberContact.getCountryDesc() == null ? "" : ", " + memberContact.getCountryDesc() );

String[] profileKeywordArray = memberProfile==null ? null : memberProfile.getKeywordList();

for( int i = 0 ; profileKeywordArray != null && i < profileKeywordArray.length ; i ++ )
{
  metaKeywords += ", " + profileKeywordArray[ i ];
}

String[] profileSpecialisationsArray = memberProfile==null ? null : memberProfile.getSpecialisationList();

for( int i = 0 ; profileSpecialisationsArray != null && i < profileSpecialisationsArray.length ; i ++ )
{
  metaKeywords += ", " + profileSpecialisationsArray[ i ];
}

String pageTitleBarTitle = memberContact.name + " - company profile - Nextface";

%><jsp:include page="/inc/pageHead.jsp" flush="true">
  <jsp:param name="pgtitle" value="<%= URLEncoder.encode( pageTitleBarTitle ) %>"/>
  <jsp:param name="metakeywords" value="<%= URLEncoder.encode( metaKeywords ) %>"/>
</jsp:include>

<%

if( user!= null && user.isAdmin() )
{
  String memberWeek = StringUtils.nullString( request.getParameter( "memberweek" ) );
  String description = StringUtils.nullString( request.getParameter( "description" ) );

  if( memberWeek.length() > 0 && !memberWeek.equals( "none" ) )
  {
    MemberClient.setMemberOfWeek( memberWeek, memberId, description );
  }

  ArrayList memberOfWeekList = Member.getMemberOfWeekDropDown( memberId );
  boolean thisMemberIsAMemberOfWeek = false;
  DropDownOption option;

  for( int i = 0 ; i < memberOfWeekList.size() ; i++ )
  {
    option = (DropDownOption)memberOfWeekList.get( i );

    if( option.selected )
    {
      thisMemberIsAMemberOfWeek = true;
      break;
    }
  }

%>
<h4>Administrator functionality</h4>
  <form onsubmit="if( this.memberweek.value=='none' ) { alert( 'Please select a week' ); return false; } if( this.description.value=='' ) { alert( 'Please type a description for your reference' ); return false; } return confirm( 'Are you sure you want to set this member to be the work of the selected week, any previous setting for this week will be deleted?' ); "name="registercontactdetails" method="post" action="/pages/profileDetails.jsp">
    <input type="hidden" name="memberId" value="<%= memberId %>">
    <input type="hidden" name="mainFileIdx" value="<%= mainFileIdx %>">
    <input type="hidden" name="mainfileId" value="<%= mainFileId %>">
    <input type="hidden" name="returnTo" value="<%= URLEncoder.encode( StringUtils.nullString( returnTo ) )  %>">

    <table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
    <tr>
      <td class="formLabel">Set As Work Of Week..</td>
      <td class="formElementCell">
        <select class="formElement" name="memberweek">
          <option <%= thisMemberIsAMemberOfWeek ? "" : "selected=\"selected\" " %>value="none">Please Choose Week</option>
<%

  for( int i = 0 ; i < memberOfWeekList.size() ; i++ )
  {
    option = (DropDownOption)memberOfWeekList.get( i );

%>        <option <%= option.selected ? "selected=\"selected\" " : "" %>value="<%= option.id %>"><%= option.desc %></option>
<%

  }

%>      </select>
      </td>
    </tr>
    <tr>
      <td class="formLabel">Description For Reference</td>
      <td class="formElementCell"><input class="formElement" name="description" type="text" value="" maxlength="100"></td>
    </tr>
    <tr>
      <td class="formLabel"></td>
      <td class="formElementCell"><input class="formElement" style="background-color: #CCCCCC;"name="submit" type="submit" value="Set This Member As Work Of Week"></td>
    </tr>
    </table>
<%

  if( Member.isLoggedIn( member.memberId ) )
  {

%>    <table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6>This member is logged in</h6></td><td width="100%"></td></tr></table>
<%

  }
  else
  {

%>    <table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6><a href="/login.jsp?redirectto=/pages/accountManager.jsp&email=<%= member.email %>&passwd=<%= member.passwd %>" target="_blank">Login to Account Manager as this member</a></h6></td><td width="100%"></td></tr></table>
<%

  }

%>
<h4>___________________</h4>
<%

}

%>
<h1>Profile of <%= memberContact.name %></h1>
<table border="0"cellpadding="0" cellspacing="0" width="100%">
<tr>
   <%= portraitImage==null ? "" : "<td rowspan=\"100\" width=\"120\">" + portraitImage.getPostProcessAssetHtml( "ProfilePageLogoImage" ) + "</td>" %>
  <td valign="top">
   <table cellpadding="0" cellspacing="0" width="100%">
   <tr><td class="featName"><%= memberContact.name %></td></tr>
   <tr><td class="featPlace" style="padding-top: 4px"><%= memberContact.getPrimaryDisciplineDesc() %></td></tr><%
%><%= memberContact.getSecondaryDisciplineDesc()==null ? "" : "    <tr><td class=\"featPlace\">" + memberContact.getSecondaryDisciplineDesc() + "</td></tr>\n" %><%
%><%= memberContact.getTertiaryDisciplineDesc()==null  ? "" : "    <tr><td class=\"featPlace\">" + memberContact.getTertiaryDisciplineDesc()  + "</td></tr>\n" %><%
%>    <tr><td class="featPlace" style="padding-top: 6px"><%= memberContact.city %></td></tr><%
%><%= memberContact.getRegionDesc()==null ? "" : "    <tr><td class=\"featPlace\">" + memberContact.getRegionDesc() + "</td></tr>\n" %><%
%>    <tr><td class="featPlace"><%= memberContact.getCountryDesc() %></td></tr>
   </table>
  </td>
</tr>
</table>
<br />
<table border="0" cellpadding="7" cellspacing="0">
<tr>
<%

int fileNo = 1;
int noOfFilesInARow = 6;
MemberFile tempFile;
String cellHTML = "";

for( int i = 0 ; i < member.memberFiles.size() ; i++ )
{
  tempFile = (MemberFile)member.memberFiles.get( i );

  if( tempFile.portraitImage )
  {
    continue;
  }

  cellHTML = "<a href=\"/pages/profileDetails.jsp?memberId=" + memberId + "&mainFileIdx=" + i + "&returnTo=" + URLEncoder.encode( StringUtils.nullString( returnTo ) ) + "&backtodesc=" + backToDesc + "&preview=" + previewing + "\">" + tempFile.getPostProcessAssetHtml( "SrchResults" ) + "</a>";

  if( i == mainFileIdx )
  {
    //make this cell not a link
    cellHTML = tempFile.getPostProcessAssetHtml( "SrchResults" );
  }

  if( fileNo % noOfFilesInARow == 1 )
  {
    out.println( "</tr>\n<tr>\n" );
  }

%>  <td width="56" height="56" <%= fileNo % noOfFilesInARow == 1 ? "style=\"padding-left: 0px\"" : "" %><%= fileNo % noOfFilesInARow == 0 ? "style=\"padding-right: 0px\"" : "" %>><%= cellHTML %></a></td>
<%

  fileNo++;
}

%>
</tr>
</table>
<%

if( mainImage != null )
{

%>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td width="406" style="padding-top: 7px"><%= mainImage.getPostProcessAssetHtml( "ProfilePageMainImage" ) %></td>
</tr>
<tr>
  <td class="smallBulletLine"><%= mainImage.description %></td>
</tr>
<tr>
  <td class="2" style="padding-top: 6px"><table border="0" cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6><a target="_blank" href="<%= mainImage.getHtmlFileName() %>"><%= mainImage.isImage ? "View full size image" : ( mainImage.mimeType.toUpperCase().startsWith( "AUDIO/" ) ? "Play audio file" : ( mainImage.mimeType.toUpperCase().startsWith( "VIDEO/" ) ? "Play movie file" : "View file" ) ) %></a></h6></td><td width="100%" style="text-align: right"></td></tr></table></td>
</tr>
</table>
<%

}

if( memberProfile != null )
{

%>
<h4>Statement/synopsis</h4>
<p><%= memberProfile.personalStatement %></p>
<h4>Specialisations</h4>
<%

  String specs[] = memberProfile.getSpecialisationList();
  String specsHTML = "<table cellpadding=\"0\" cellspacing=\"0\">";
  for( int i = 0 ; specs != null && i < specs.length ; i++ )
  {
    if( specs[ i ].trim().length() > 0 )
    {
      specsHTML += "<tr><td class=\"smallBulletLine\" style=\"padding-bottom: 2px;\">" + specs[ i ] + "</td><tr>";
    }
  }
  specsHTML += "</table>";
  out.println( specsHTML );

}

%>
<br />
<h4>Contact details</h4>

   <table cellpadding="0" cellspacing="0" width="100%">
   <tr><td class="featPlaceLeft"><%= memberContact.contactFirstName %> <%= memberContact.contactSurname %></td></tr>
    <tr><td class="featPlaceLeft" style="padding-top: 6px"><%= memberContact.address1 %></td></tr><%
%><%= memberContact.address2==null || memberContact.address2.length()==0 ? "" : "    <tr><td class=\"featPlaceLeft\">" + memberContact.address2 + "</td></tr>\n" %><%
%>    <tr><td class="featPlaceLeft"><%= memberContact.city %></td></tr><%
%><%= memberContact.getCountyDesc()==null ? "" : "    <tr><td class=\"featPlaceLeft\">" + memberContact.getCountyDesc() + "</td></tr>\n" %><%
%>    <tr><td class="featPlaceLeft"><%= memberContact.getCountryDesc() %></td></tr><%
%>    <tr><td class="featPlaceLeft"><%= memberContact.postcode %></td></tr>
    <tr><td class="featPlaceLeft" style="padding-top: 6px">Tel: <%= memberContact.telephone %></td></tr><%
%><%= memberContact.fax==null || memberContact.fax.length()==0 ? "" : "    <tr><td class=\"featPlaceLeft\">Fax: " + memberContact.fax + "</td></tr>\n" %><%
%><%= webAddress==null || webAddress.length()==0 || webAddress.toUpperCase().equals( "HTTP://" )? "" : "    <tr><td class=\"featNameLeft\" style=\"padding-top: 4px\"><a target=\"_blank\" href=\"" + webAddress + "\">" + memberContact.webAddress + "</a></td></tr>\n" %>
<tr><td class="featNameLeft" <%= webAddress==null || webAddress.length()==0 ? "style=\"padding-top: 4px\"" : "" %> ><a href="mailto:<%= member.email %>?subject=Enquiry from Nextface website"><%= member.email %></a></td></tr>
   </table>

<br />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a href="<%= returnTo %>">Back to <%= backToDesc %></a></h6></td>
  <td nowrap="nowrap" class="linkAnnotation" width="100%">...Back to previous page</td>
</tr>
</table>
<table border="0" cellpadding="0" cellspacing="0" >
<tr>
  <td width="100%" colspan="4">
    <br  />
    <h4>Free media player download sites*</h4>
  </td>
</tr>
<tr>
<td class="mediaPlayerLogo"><a href="http://www.microsoft.com/DOWNLOADS/results.aspx?displaylang=en&freeText=windows+media+player" target="_blank"><img src="/art/MediaPlayerLogos/WinMediaPlayerLogo.gif" width="68" height="56" /></a></td>
<td class="mediaPlayerLogo"><a href="http://www.apple.com/quicktime/download/" target="_blank"><img src="/art/MediaPlayerLogos/quicktimelogo.gif" width="68" height="56" /></a></td>
<td class="mediaPlayerLogo"><a href="http://www.macromedia.com/downloads/" target="_blank"><img src="/art/MediaPlayerLogos/flash.gif" width="68" height="56" /></a></td>
<td class="mediaPlayerLogo" width="100%"><a href="http://www.macromedia.com/downloads/" target="_blank"><img src="/art/MediaPlayerLogos/shockwave.gif" width="68" height="56" /></a></td>
</tr>
<tr>
  <td colspan="4"><br /><p class="smallPrint">* Any software obtained via these links is installed at your own risk. If you are in any doubt, please seek professioanl advice on the installation and use of 3rd party software</p></td>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true"/>
