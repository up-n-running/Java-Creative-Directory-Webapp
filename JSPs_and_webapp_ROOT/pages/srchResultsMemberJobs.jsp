<%@ page language="java"
  import="com.extware.member.MemberJob,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          java.util.ArrayList,
          java.net.URLEncoder"
%><%
ArrayList memberJobs = (ArrayList)request.getSession().getAttribute( "searchResults" );

try
{
  if( memberJobs != null && memberJobs.size() > 0 )
  {
    MemberJob temp = (MemberJob)memberJobs.get( 0 );
  }
}
catch( ClassCastException ex)
{
  memberJobs = null;
}

%>
<jsp:include page="/inc/pageHead.jsp" flush="true" />
<%

if( memberJobs==null )
{

%>
<div class="h1style">Search session expired</div>
<p>To speed up your browsing, your search results were stored on our server for a limited period. Unfortunately, because you have been inactive for a long period of time, your session has expired and this data has been lost, please click 'search' again on the search form on the left hand side of this page to recalculate your search results.</p>
<%

}
else
{

  PropertyFile dataDictionary = PropertyFile.getDataDictionary();
  int maxNoOfSearchResults = NumberUtils.parseInt( dataDictionary.getString( "search.jobs.maxNoOfResults" ), -1 );

  boolean dataTruncated = memberJobs.size() >= maxNoOfSearchResults;

  int startIdx = NumberUtils.parseInt( request.getParameter( "startIdx" ), 0 );
  int noToShow = 5;
  int endIdx = startIdx + noToShow;

  //generate paging through results html
  String resultsPageHTML = "<table border=\"0\" cellpadding=\"0\" cellspacing=\"0\" width=\"100%\">\n";
  resultsPageHTML += "<tr><td>\n";
  resultsPageHTML += "<table cellpadding=\"0\" cellspacing=\"0\"><tr><td><h4 style=\"padding-top: 3px; margin-bottom: 1px;\">Listing " + (startIdx+1) + " - ";
  resultsPageHTML += ( endIdx < memberJobs.size() ) ? ( endIdx+"" ) : ( memberJobs.size()+"" );
  resultsPageHTML += " of " + memberJobs.size() + ( dataTruncated ? "+" : "" ) + " profiles</h4></td>";
  resultsPageHTML += ( dataTruncated ? ( "<td style=\"padding-top: 5px; color: #000000\">&nbsp;(Only first " + memberJobs.size() + " shown)</td>" ) : "" );
  resultsPageHTML += "</tr></table></td>\n</tr>\n<tr>\n  <td>";
  resultsPageHTML += "<table cellpadding=\"0\" cellspacing=\"0\"><tr><td><h4>Page:</h4></td><td><td style=\"padding-top: 2px; color: #000000\">&nbsp;";
  int pageNo = 1;

  for( int i = 0 ; i < memberJobs.size() ; i+=noToShow )
  {
    resultsPageHTML += " ";
    if( i == startIdx )
    {
      resultsPageHTML += (pageNo++);
    }
    else
    {
      resultsPageHTML += "<a href=\"/pages/srchResultsMemberJobs.jsp?startIdx=" + i + "&searchtype=" + request.getParameter( "searchtype" ) + "&compsizeval=" + request.getParameter( "compsizeval" ) + "&jobtypeval=" + request.getParameter( "jobtypeval" ) + "&filetypeval=" + request.getParameter( "filetypeval" ) + "&categoryval=" + request.getParameter( "categoryval" ) + "&disciplineval=" + request.getParameter( "disciplineval" ) + "&countryval=" + request.getParameter( "countryval" ) + "&regionval=" + request.getParameter( "regionval" ) + "&countyval=" + request.getParameter( "countyval" ) + "&keyword=" + URLEncoder.encode( StringUtils.nullString( request.getParameter( "keyword" ) ) ) + "\">" + (pageNo++) + "</a>";
    }
  }

  resultsPageHTML += "</td></tr></table>\n";
  resultsPageHTML += "  </td>\n";
  resultsPageHTML += "</tr>\n";
  resultsPageHTML += "<tr><td height=\"1\" width=\"100%\" class=\"seperator\"></td></tr>\n";
  resultsPageHTML += "</table>\n";

%><h1 style="margin-bottom: 0px;">Job vacancies from your search criteria</h1>
<%

  if( memberJobs.size() == 0 )
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

    MemberJob memberJob;
    for( int i = startIdx ; i < memberJobs.size() && i < endIdx ; i++ )
    {
      memberJob = (MemberJob)memberJobs.get( i );
%>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td colspan="2"><img src="/art/blank.gif" width="1" height="10" /></td>
</tr>
<tr>
  <td width="85"><h4 class="mainJobDetail">Job title:</h4></td>
  <td><h4 class="mainJobDetail"><%= memberJob.title %></h4></td>
</tr>
<tr>
  <td width="85"><h4 class="mainJobDetail">Salary:</h4></td>
  <td><h4 class="mainJobDetail"><%= memberJob.salary %></h4></td>
</tr>
<tr>
  <td width="85"><h4 class="mainJobDetail">Job type:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.getTypeOfWorkDesc() %></h4></td>
</tr>
<tr>
  <td width="85"><h4 class="mainJobDetail">Location:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.city %>, <%= memberJob.countryRef==1 ? memberJob.getCountyDesc() + ", " + memberJob.getRegionDesc() : "" %></h4></td>
</tr>
<tr>
  <td width="85"><h4 class="mainJobDetail">Country:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.getCountryDesc() %></h4></td>
</tr>
<tr>
  <td width="85"><h4 class="mainJobDetail">Contact:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.contactName %></h4></td>
</tr>
<tr>
  <td colspan="2" style="padding-top: 4px; margin-bottom: 2px;"><div width="100%" style="height: 41px; color: #000000; overflow: hidden;"><%= memberJob.description %></div></td>
</tr>
<tr>
  <td colspan="2" style="vertical-align: bottom;" nowrap="nowrap"><h6 class="orangeh6" style="margin-bottom:0px;"><a href="/pages/jobDetails.jsp?memberJobId=<%= memberJob.memberJobId %>">Tell me more</a></h6></td>
</tr>
<tr>
  <td colspan="2"><img src="/art/blank.gif" width="1" height="9" /></td>
</tr>
<tr>
  <td colspan="1" height="1" width="85" class="seperator"><img src="/art/blank.gif" width="85" height="1" /></td><td colspan="1" height="1" width="321" class="seperator"><img src="/art/blank.gif" width="321" height="1" /></td>
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