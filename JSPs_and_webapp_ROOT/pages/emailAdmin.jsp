<%@ page language="java"
  import="com.extware.utils.StringUtils,
          com.extware.member.Member,
          com.extware.member.MemberClient,
          java.util.ArrayList"
%><%

//Get logged in user
Member member = (Member)request.getSession().getAttribute( "member" );

//if not logged in, sack them off
   if( member==null )
   {
     %><jsp:forward page="/loggedOut.jsp" /><%
     return;
   }

//if email not validated, check they havent validated since last logging in
if( !member.emailValidated )
{
  MemberClient.checkIfValidatedYet( member );   //this will update object if thay have just validated their email
}

//where are we going to redirect to on form submission - default to profile form
String redirectTo = "/pages/accountManager.jsp";

if( request.getParameter( "divertto" )!=null && request.getParameter( "divertto" ).equals( "accountman" ) )
{
  redirectTo = "/pages/accountManager.jsp";
}

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<%

if( !member.emailValidated )
{

%>
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="sendnewvalidate"/>
</jsp:include>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a href="/pages/sentValidateEmail.jsp">Send me a new validation email.</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<br />
<%

}

%>
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="changeemail"/>
</jsp:include>
<br />
<%

//if we are returning from reg servlet with errors
ArrayList errorsToReport = (ArrayList)request.getAttribute( "errors" );

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
<form name="changeemailaddress" method="post" action="/servlet/MemberDetails" />
  <input type="hidden" name="form" value="changeemailaddress" />
  <input type="hidden" name="mode" value="edit" />
  <input type="hidden" name="redirectto" value="/pages/sentValidateEmail.jsp" />

  <table width="100%" border="0" cellspacing="0" cellpadding="0" class="formTable">
  <tr>
    <td class="formLabel">New email address*</td>
    <td class="formElementCell"><input class="formElement" name="newemail" type="text" value="<%= request.getParameter( "newemail" )==null ? "" : request.getParameter( "newemail" ) %>" maxlength="200"></td>
  </tr>
  <tr>
    <td class="formLabel">Confirm new email address*</td>
    <td class="formElementCell"><input class="formElement" name="confirmnewemail" type="text" value="<%= request.getParameter( "confirmnewemail" )==null ? "" : request.getParameter( "confirmnewemail" ) %>" maxlength="200"></td>
  </tr>
  </table>
  <table cellpadding="0" cellspacing="0" width="100%">
  <tr>
    <td nowrap="nowrap"><h6><a onclick="document.forms[ 'changeemailaddress' ].submit(); return false;" href="">Change my email address</a></h6></td>
    <td width="100%"></td>
  </tr>
  </table>
</form>
<br />
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="orangeh6"><a href="/pages/accountManager.jsp">Go back to account manager</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />