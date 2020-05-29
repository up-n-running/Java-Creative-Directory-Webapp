<%@ page language="java"
         import="com.extware.member.Member,
                 com.extware.member.MemberClient,
                 com.extware.utils.SiteUtils"
%><%
String message        = null;
String passwordString = "";
String email          = request.getParameter( "email" );
String passwd         = request.getParameter( "passwd" );

if( request.getParameter( "redirectto" ) != null )
{
  Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

  if( loggedInMember != null )
  {
    loggedInMember.logout( request );
  }

  Member member = MemberClient.loadFullMember( email, passwd );

  if( member != null )
  {
    member.login( request );
    request.getSession().setMaxInactiveInterval( 3600 );
    response.sendRedirect( "http://" + SiteUtils.getUrl( request ) + request.getParameter( "redirectto" ) );

    return;
  }
}

for( int i = 0 ; passwd != null && i < passwd.length() ; i++ )
{
  passwordString += "*";
}

%>
<jsp:include page="/inc/pageHead.jsp" flush="true" />
<h1>Login Invalid, please try again</h1>
<h5>Login Details</h5>
<table width="100%" border="0" cellspacing="0" cellpadding="0" >
<tr>
  <td style="padding-bottom: 5px"><b>email:</b></td>
  <td width="100%">&nbsp;<%= email %></td>
</tr>
<tr>
  <td><b>password:</b></td>
  <td width="100%">&nbsp;<%= passwordString %></td>
</tr>
</table>
<br />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="login1"/>
</jsp:include>
<jsp:include page="/inc/pageFoot.jsp" flush="true" />