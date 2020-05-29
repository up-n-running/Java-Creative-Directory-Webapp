<%@ page language="java"
         import="com.extware.member.Member"
%><%
Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

if( loggedInMember != null )
{
  loggedInMember.logout( request );
}

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="logout1"/>
</jsp:include>
<table border="0" cellspacing="0" cellpadding="0">
<tr>
  <td nowrap="nowrap"><h6 style="text-align: left;"><a href="/index.jsp">Back to homepage</a></h6></td>
  <td width="100%"></td>
</tr>
</table>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />