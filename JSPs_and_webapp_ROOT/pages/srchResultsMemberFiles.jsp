<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberFile,
          com.extware.member.MemberClient,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          java.util.ArrayList,
          java.net.URLEncoder"
%><%

ArrayList members = (ArrayList)request.getSession().getAttribute( "searchResults" );

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

  //generate paging through results html
  String resultsPageHTML = "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";
  resultsPageHTML += "<tr><td>\n";
  resultsPageHTML += "<table cellpadding=\"0\" cellspacing=\"0\"><tr><td><h4 style=\"padding-top: 3px; margin-bottom: 1px;\">Listing " + (startIdx+1) + " - ";
  resultsPageHTML += ( endIdx < members.size() ) ? ( endIdx+"" ) : ( members.size()+"" );
  resultsPageHTML += " of " + members.size() + ( dataTruncated ? "+" : "" ) + " files</h4></td>";
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
      resultsPageHTML += "<a href=\"/pages/srchResultsMemberFiles.jsp?startIdx=" + i + (  request.getParameter( "searchtype" ) == null  ?  ""  :  "&searchtype=" + request.getParameter( "searchtype" ) + "&compsizeval=" + request.getParameter( "compsizeval" ) + "&jobtypeval=" + request.getParameter( "jobtypeval" ) + "&filetypeval=" + request.getParameter( "filetypeval" ) + "&categoryval=" + request.getParameter( "categoryval" ) + "&disciplineval=" + request.getParameter( "disciplineval" ) + "&countryval=" + request.getParameter( "countryval" ) + "&regionval=" + request.getParameter( "regionval" ) + "&countyval=" + request.getParameter( "countyval" ) + "&keyword=" + URLEncoder.encode( StringUtils.nullString( request.getParameter( "keyword" ) ) )  ) + "\">" + (pageNo++) + "</a>";
    }
  }

  resultsPageHTML += "</td></tr></table>\n";
  resultsPageHTML += "  </td>\n";
  resultsPageHTML += "</tr>\n";
  resultsPageHTML += "<tr><td height=\"1\" width=\"100%\" class=\"seperator\"></td></tr>\n";
  resultsPageHTML += "</table>\n";

%><h1 style="margin-bottom: 0px;">Files from your search criteria</h1>
<%

  if( members.size() == 0 )
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

    MemberFile memberFile;
    Member member;

    for( int i = startIdx ; i < members.size() && i < endIdx ; i++ )
    {
      member = (Member)members.get( i );
      memberFile = (MemberFile)member.memberFiles.get( 0 );

%>
<table border="0" cellpadding="0" cellspacing="0" width="406">
<tr>
  <td><img src="/art/blank.gif" width="1" height="13" /></td>
</tr>
<tr>
  <td width="60" height="54" nowrap="nowrap" style="white-space: nowrap;">
    <%= memberFile.getPostProcessAssetHtml( "SrchResults" ) %><img src="/art/blank.gif" width="6" height="1" />
  </td>
  <td width="100%">
    <table border="0" cellpadding="0" cellspacing="0" width="100%" height="56">
    <tr>
      <td><h4 style="margin-bottom: 0px;"><%= member.memberContact.name %></h4></td>
    </tr>
    <tr>
      <td valign="top" height="100%" style="margin-bottom: 0px; color: #000000;"><%= memberFile.description %></h4></td>
    </tr>
    <tr>
      <td valign="bottom" nowrap="nowrap"><h6 class="orangeh6" style="margin-bottom: 0px"><a href="/pages/profileDetails.jsp?memberId=<%= member.memberId %>&mainfileId=<%= memberFile.memberFileId %>&returnTo=<%= URLEncoder.encode( "/pages/srchResultsMemberFiles.jsp?startIdx=" + startIdx ) %>&backtodesc=file+list">Show full profile</a></td>
    </tr>
    </table>
  </td>
</tr>
<tr>
  <td><img src="/art/blank.gif" width="1" height="8" /></td>
</tr>
<tr>
  <td height="1" width="100%" colspan="2" class="seperator"></td>
</tr>
</table>
<%
    }

%>
<%= resultsPageHTML %>
<%

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