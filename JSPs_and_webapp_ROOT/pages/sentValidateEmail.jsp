<%@ page language="java"
  import="com.extware.emailSender.EmailSender,
          com.extware.member.Member,
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

boolean addressOk =  EmailSender.sendMail( "emailrevalidate", "Please validate your Nextface email address", member, new ArrayList(), new ArrayList() );

%><jsp:include page="/inc/pageHead.jsp" flush="true" />

<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="sentvalidatemail"/>
</jsp:include>
<br />
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6><a href="/pages/accountManager.jsp">Back to account manager</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />