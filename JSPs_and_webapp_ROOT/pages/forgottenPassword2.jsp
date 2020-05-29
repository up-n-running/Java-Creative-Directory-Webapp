<%@ page language="java"
  import="com.extware.member.MemberClient,
          com.extware.member.Member,
          com.extware.utils.StringUtils,
          java.util.ArrayList,
          com.extware.emailSender.EmailSender"
%><%

String email = StringUtils.nullString( request.getParameter( "email" ) );
Member member = MemberClient.loadFullMember( email, null );
boolean success = ( member != null );

if( success )
{
  EmailSender.sendMail( "emailsendpasswd", "Your Nextface password", member, new ArrayList(), new ArrayList() );
}

String  includePage = success ? "forgotpass2Y" : "forgotpass2N";

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="<%= includePage %>"/>
</jsp:include>
<%

if( !success )
{

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/forgottenPassword.jsp?email=<%= email %>">Go back and change the email address</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<%

}

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a href="/index.jsp">Go back to homepage</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />