<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberProfile,
          java.util.ArrayList"
%><%
//Get logged in user if there is a user logged in
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

//if not logged in, sack them off
if( loggedInMember==null )
{
  %><jsp:forward page="/loggedOut.jsp" /><%
  return;
}

//where are we going to redirect to on form submission - default to portfolio files form
boolean firstTimeRegistering = true;
String redirectTo = "/pages/registerPortfolioFiles.jsp";

if( request.getParameter( "divertto" )!=null )
{
  if( request.getParameter( "divertto" ).equals( "accountman" ) )
  {
    redirectTo = "/pages/accountManager.jsp";
  }
  else
  {
    redirectTo = request.getParameter( "divertto" );
  }

  firstTimeRegistering = false;
}

//hold the details of the objects used to populate the form.
Member formPopulateMember = null;
MemberProfile formPopulateMemberProfile = null;

ArrayList errorsToReport = (ArrayList)request.getAttribute( "errors" );

if( errorsToReport != null && errorsToReport.size() > 0 )
{
  formPopulateMember = (Member)request.getAttribute( "formmember" );
  formPopulateMemberProfile = (MemberProfile)request.getAttribute( "formmemberprofile" );
}
else
{
  //if not returning from servlet to fix errors, then we just populate the form with the logged in users details so they can edit their details.
  formPopulateMember = loggedInMember;
  formPopulateMemberProfile = loggedInMember.moderationMemberProfile!=null ? loggedInMember.moderationMemberProfile : loggedInMember.memberProfile;
}

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regprofile1"/>
</jsp:include>
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
<br />
<%

//if we are returning from reg servlet with errors
if( errorsToReport != null )
{

%>
<p>There were some problems with the data you entered, please address the issues listed below and try again.<p>
<%

  for( int i=0; i<errorsToReport.size(); i++ )
  {

%><p class="error"><%= (String)errorsToReport.get( i ) %></p>
<%

  }
}

%>
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regprofile2"/>
</jsp:include>
<br />
<form name="registerprofiledetails" method="post" action="/servlet/MemberDetails">
  <input type="hidden" name="form" value="registerprofiledetails">
  <input type="hidden" name="mode" value="<%= request.getParameter( "mode" )==null ? "edit" : request.getParameter( "mode" ) %>">
  <input type="hidden" name="redirectto" value="<%= redirectTo %>">

  <textarea class="bigFormElement" name="personalstatement" maxlength="2000" rows="4"><%= formPopulateMemberProfile==null ? "" : formPopulateMemberProfile.personalStatement %></textarea><br />
  <br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regprofile3"/>
</jsp:include>
  <textarea class="bigFormElement" name="specialisations" maxlength="2000" rows="4"><%= formPopulateMemberProfile==null ? "" : formPopulateMemberProfile.specialisations %></textarea><br />
  <br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="regprofile4"/>
</jsp:include>
  <textarea class="bigFormElement" name="keywords" maxlength="2000" rows="4"><%= formPopulateMemberProfile==null ? "" : formPopulateMemberProfile.keywords %></textarea><br />
  <br />
<jsp:include page="/inc/tasteAndTermsInclude.jsp" flush="true" />
  <br />
  <table cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td nowrap="nowrap"><h6><a onclick="if( tAndTCheck() ) { document.forms['registerprofiledetails'].submit(); } return false;" href="">Submit this data and continue</a></h6></td>
    <td width="100%"></td>
  </tr>
  </table>
</form>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />
