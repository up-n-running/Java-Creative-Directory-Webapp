<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberClient,
          com.extware.utils.NumberUtils,
          java.util.ArrayList"
%><%
int memberId = NumberUtils.parseInt( request.getParameter( "memberId" ), -1 );
int validationKey = NumberUtils.parseInt( request.getParameter( "validationKey" ), -1 );

boolean success = MemberClient.validateEmailAddress( memberId, validationKey );
boolean alreadyLoddedIn = true;

if( success && !Member.isLoggedIn( memberId ) )
{
  Member member = MemberClient.loadFullMember( memberId );
  member.login( request );
  alreadyLoddedIn = false;
}

String  includePage = success ? "validateY" : "validateN";

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="<%= includePage %>"/>
</jsp:include>
<%

if( success && !alreadyLoddedIn )
{

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a href="/pages/accountManager.jsp">Go to account manager to complete your registration</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}
else if( success && alreadyLoddedIn )
{

%>
<h4>If you have Nextface open in another browser, please close this browser window down and continue with your original Nextface session.</h4>
<%

}
else
{

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/contactUs.jsp">Contact us if you are stil having problems</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}

%>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />