<%@ page language="java"
    import="com.extware.utils.NumberUtils,
            com.extware.member.Member,
            com.extware.member.MemberJob,
            com.extware.member.MemberClient,
            java.net.URLEncoder"
%><%

int memberJobId = NumberUtils.parseInt( request.getParameter( "memberJobId" ), -1 );

MemberJob memberJob = MemberClient.getMemberJob( memberJobId );

%><jsp:include page="/inc/pageHead.jsp" flush="true"/>
<h1>Job vacancy Details</h1>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td><img src="/art/blank.gif" width="1" height="9" </td>
</tr>
<tr>
  <td width="90"><h4 class="mainJobDetail">Job title:</h4></td>
  <td><h4 class="mainJobDetail"><%= memberJob.title %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">Salary:</h4></td>
  <td><h4 class="mainJobDetail"><%= memberJob.salary %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">Reference:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.referenceNo %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">Job type:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.getTypeOfWorkDesc() %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">Location:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.city %>, <%= memberJob.countryRef==1 ? memberJob.getCountyDesc() + ", " + memberJob.getRegionDesc() : "" %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">Country:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.getCountryDesc() %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">Contact:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.contactName %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">Telephone:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.telephone %></h4></td>
</tr>
<tr>
  <td width="80"><h4 class="mainJobDetail">E-mail:</h4></td>
  <td><h4 class="jobDetail"><%= memberJob.email %></h4></td>
</tr>
<tr>
  <td colspan="2" style="padding-top: 4px; margin-bottom: 2px; color: #000000;"><%= memberJob.description %></td>
</tr>
<tr>
  <td nowrap="nowrap" style="padding-bottom: 4px" colspan="2" class="srchLinkNDivider" ><a href="/pages/profileDetails.jsp?memberId=<%= memberJob.memberId %>&returnTo=<%= URLEncoder.encode( "/pages/jobDetails.jsp?memberJobId=" + memberJobId ) %>&backtodesc=job+vacancy+details">View company profile</td>
</tr>
</table>
<br />
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a target="_parent" onclick=" return true;window.history.go( -1 ); return false;" href="/pages/srchResultsMemberJobs.jsp">Back to job vacancy listings</a></h6></td>
  <td nowrap="nowrap" class="linkAnnotation" width="100%">...Back to previous page</td>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true"/>