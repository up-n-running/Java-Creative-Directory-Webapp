<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.member.MemberFile,
          com.extware.member.MemberClient,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          java.util.ArrayList,
          java.net.URLEncoder"
%><%
ArrayList members;

boolean fromBrowseForm = request.getParameter( "formname" ) != null && request.getParameter( "formname" ).equals( "browse" );
members = (ArrayList)request.getSession().getAttribute( "searchResults" );

//used in browse mode
char nameFirstLetter = StringUtils.nullReplace( request.getParameter( "namefirstletter" ), "A" ).charAt( 0 );
try
{
  if( members != null && members.size() > 0 )
  {
    Member temp = (Member)members.get( 0 );
  }
}
catch( ClassCastException ex)
{
  members = null;
}

%>
<jsp:include page="/inc/pageHead.jsp" flush="true" />
<%

if( members==null )
{

%>
<div class="h1style">Search session expired</div>
<p>To speed up your browsing, your search results were stored on our server for a limited period. Unfortunately, because you have been inactive for a long period of time, your session has expired and this data has been lost, please click 'search' again on the search form on the left hand side of this page to recalculate your search results.</p>
<%

}
else
{
  PropertyFile dataDictionary = PropertyFile.getDataDictionary();
  int maxNoOfSearchResults = NumberUtils.parseInt( dataDictionary.getString( "search.maxNoOfResults" ), -1 );

  boolean dataTruncated = members.size() >= maxNoOfSearchResults;

  int startIdx = NumberUtils.parseInt( request.getParameter( "startIdx" ), 0 );
  int noToShow = 10;
  int endIdx = startIdx + noToShow;

  MemberClient.populateMemberFiles( members, startIdx, endIdx );

  String resultsPageHTML = "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";
  resultsPageHTML += "<tr><td>\n";

  if( fromBrowseForm )
  {
    resultsPageHTML += "<h4 style=\"padding-bottom: 4px; margin-bottom: 0px; border-bottom-width:1px; border-bottom-color:#8d8d8d; border-bottom-style:solid;\" ><span class=\"orange\">";

    for( char letter = 'A' ; letter <= 'Z' ; letter ++ )
    {
      resultsPageHTML += " ";
      if( letter == nameFirstLetter )
      {
        resultsPageHTML += "<span class=\"lightBlue\">" + String.valueOf( letter ) + "</span>";
      }
      else
      {
        resultsPageHTML += "<a href=\"/servlet/Search?&categoryval=" + request.getParameter( "categoryval" ) + "&disciplineval=" + request.getParameter( "disciplineval" ) + "&formname=" + URLEncoder.encode( StringUtils.nullString( request.getParameter( "formname" ) ) ) + "&namefirstletter=" + letter + "\">" + letter + "</a>";
      }
    }

    resultsPageHTML += " ";

    if( nameFirstLetter == '_' )
    {
      resultsPageHTML += "<span class=\"lightBlue\">Other</span>";
    }
    else
    {
      resultsPageHTML += "<a href=\"/servlet/Search?&categoryval=" + request.getParameter( "categoryval" ) + "&disciplineval=" + request.getParameter( "disciplineval" ) + "&formname=" + URLEncoder.encode( StringUtils.nullString( request.getParameter( "formname" ) ) ) + "&namefirstletter=_\">Other</a>";
    }

    resultsPageHTML += "</span></h4>\n";
  }

  if( members.size() == 0 && fromBrowseForm )
  {
    resultsPageHTML += "<h4 style=\"padding-top: 5px\">There are no profiles matching your browse criteria that " + ( nameFirstLetter == '_' ? "do not begin with a letter" : "begin with the letter '" + nameFirstLetter + "'" ) + "</h4>";
    resultsPageHTML += "</td></tr></table>\n";
  }
  else
  {
    resultsPageHTML += "<table cellpadding=\"0\" cellspacing=\"0\"><tr><td><h4 style=\"padding-top: 3px; margin-bottom: 1px;\">Listing " + (startIdx+1) + " - ";
    resultsPageHTML += ( endIdx < members.size() ) ? ( endIdx+"" ) : ( members.size()+"" );
    resultsPageHTML += " of " + members.size() + ( dataTruncated ? "+" : "" ) + " profiles</h4></td>";
    resultsPageHTML += ( dataTruncated ? ( "<td style=\"padding-top: 5px; color: #000000\">&nbsp;(Only first " + members.size() + " shown)</td>" ) : "" );
    resultsPageHTML += "</tr></table></td>\n</tr>\n<tr>\n  <td>";
    resultsPageHTML += "<table cellpadding=\"0\" cellspacing=\"0\"><tr><td><h4>Page:</h4></td><td><td style=\"padding-top: 2px; color: #000000\">&nbsp;";
    int pageNo = 1;

    for( int i = 0 ; i < members.size() ; i+=noToShow )
    {
      resultsPageHTML += " ";
      if( i == startIdx )
      {
        resultsPageHTML += (pageNo++);
      }
      else
      {
        resultsPageHTML += "<a href=\"/pages/srchResultsMembers.jsp?startIdx=" + i + "&searchtype=" + request.getParameter( "searchtype" ) + "&compsizeval=" + request.getParameter( "compsizeval" ) + "&jobtypeval=" + request.getParameter( "jobtypeval" ) + "&filetypeval=" + request.getParameter( "filetypeval" ) + "&categoryval=" + request.getParameter( "categoryval" ) + "&disciplineval=" + request.getParameter( "disciplineval" ) + "&countryval=" + request.getParameter( "countryval" ) + "&regionval=" + request.getParameter( "regionval" ) + "&countyval=" + request.getParameter( "countyval" ) + "&keyword=" + URLEncoder.encode( StringUtils.nullString( request.getParameter( "keyword" ) ) ) + "&formname=" + URLEncoder.encode( request.getParameter( "formname" ) ) + ( request.getParameter( "namefirstletter" )==null ? "" : "&namefirstletter=" + request.getParameter( "namefirstletter" ) ) + "\">" + (pageNo++) + "</a>";
      }
    }

    resultsPageHTML += "</td></tr></table>\n";
    resultsPageHTML += "  </td>\n";
    resultsPageHTML += "</tr>\n";
    resultsPageHTML += "<tr><td height=\"1\" width=\"100%\" class=\"seperator\"></td></tr>\n";
    resultsPageHTML += "</table>\n";
  }

%><h1 style="margin-bottom: 0px;">Profiles from your <%= fromBrowseForm ? "browse" : "search" %> criteria</h1>
<%

  if( members.size() == 0 && !fromBrowseForm )
  {

%>
<br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="nosearchresults"/>
</jsp:include>
<br />
<%
  }
  else
  {

%>
<%= resultsPageHTML %>
<%

    Member member;
    MemberContact memberContact;
    for( int i = startIdx ; i < members.size() && i < endIdx ; i++ )
    {
      member = (Member)members.get( i );
      memberContact = member.memberContact;
%>
<table border="0" cellpadding="0" cellspacing="0" width="406">
<tr>
  <td width="60" colspan="5" height="6"><img src="/art/blank.gif" width="1" height="9" /></td>
</tr>
<tr>
  <td width="60" rowspan="2"><%= ( member.memberFiles.size() > 0 ) ? ( (MemberFile)(member.memberFiles.get( 0 ) ) ).getPostProcessAssetHtml( "SrchResults" ) : "<img border=\"0\" class=\"thumbNail\" width=\"54\" height=\"54\" src=\"/art/placeholders/imageSrchResults.gif\" />" %><img width="6" height="1" src="/art/blank.gif"></td>
  <td width="4" rowspan="2"><img width="4" height="1" src="/art/blank.gif"></td>
  <td width="227"  rowspan="2">
    <table border="0" cellpadding="0" cellspacing="0" width="227" height="54">
    <tr>
      <td style="font-size: 13px; font-weight: bold; color: #000000; width: 227px; padding-bottom: 1px;"><div style="width: 225; overflow: none;"><%= memberContact.name %></div></td>
    </tr>
    <tr>
      <td class="emphasiseColor"><img width="10" height="10" class="srchResultTextBullet" src="/art/textdecor/smallTextBullet.gif" /><%= memberContact.getPrimaryDisciplineDesc() %></td>
    </tr>
<%
      if( memberContact.getSecondaryDisciplineDesc() != null )
      {

%>    <tr>
      <td class="emphasiseColor"><img width="10" height="10" class="srchResultTextBullet" src="/art/textdecor/smallTextBullet.gif" /><%= memberContact.getSecondaryDisciplineDesc() %></td>
    </tr>
<%

      }
      if( memberContact.getTertiaryDisciplineDesc() != null )
      {

%>    <tr>
      <td class="emphasiseColor"><img width="10" height="10" class="srchResultTextBullet" src="/art/textdecor/smallTextBullet.gif" /><%= memberContact.getTertiaryDisciplineDesc() %></td>
    </tr>
<%

      }
%>    <tr>
      <td style="color: #000000; padding-top: 1px"><%= memberContact.getStatusDesc() %></td>
    </tr>
    <tr>
      <td style="color: #000000; padding-top: 1px"><%= memberContact.getCountyDesc() != null ? ( memberContact.getCountyDesc() + ", " + memberContact.getRegionDesc() ) : memberContact.getCountryDesc() %></td>
    </tr>
    </table>
  </td>
  <td width="58" style="text-align: right;"><%= ( member.memberFiles.size() > 1 ) ? ( (MemberFile)(member.memberFiles.get( 1 ) ) ).getPostProcessAssetHtml( "SrchResults" ) : "<img border=\"0\" class=\"thumbNail\" width=\"54\" height=\"54\" src=\"/art/placeholders/imageSrchResults.gif\" />" %></td>
  <td width="58" style="text-align: right;"><%= ( member.memberFiles.size() > 2 ) ? ( (MemberFile)(member.memberFiles.get( 2 ) ) ).getPostProcessAssetHtml( "SrchResults" ) : "<img border=\"0\" class=\"thumbNail\" width=\"54\" height=\"54\" src=\"/art/placeholders/imageSrchResults.gif\" />" %></td>
</tr>
<tr>
  <td colspan="2" style="vertical-align: bottom;" nowrap="nowrap"><h6 class="orangeh6" style="margin-bottom:0px;"><a href="/pages/profileDetails.jsp?memberId=<%= member.memberId %>">Full profile</a></h6></td>
</tr>
<tr>
  <td><img src="/art/blank.gif" width="1" height="9" /></td>
</tr>
<tr>
  <td height="1" width="100%" colspan="5" class="seperator"></td>
</tr>
</table>
<%

    }

    if( members.size() > 0  )
    {
      out.println( resultsPageHTML );
    }
  }
}

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap" style="padding-top: 8px"><h6><a href="/index.jsp">Exit to homepage</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true"/>