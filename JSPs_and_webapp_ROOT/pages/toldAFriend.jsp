<%@ page language="java"
  import="com.extware.member.Member,
          com.extware.member.MemberContact,
          com.extware.utils.StringUtils,
          java.util.ArrayList,
          com.extware.emailSender.EmailSender"
%><%

Member loggedInMember = (Member)request.getSession().getAttribute( "member" );

//if there is no member (you do not need to be logged in to pay for an advert), then we create a template member with just enough information in to get by.
ArrayList extraReplacerKeys = new ArrayList();
ArrayList extraReplacerVals = new ArrayList();

if( loggedInMember == null )
{
  loggedInMember = new Member();
  extraReplacerKeys.add( "&lt;RECOMMENDERSNAME&gt;" );
  extraReplacerVals.add( "a customer of the Nextface online creative directory" );
}
else
{
  extraReplacerKeys.add( "&lt;RECOMMENDERSNAME&gt;" );
  extraReplacerVals.add( "&lt;USERNAME&gt;" );  //replacing a replacer with a replacer, briliant if i do say so myself.
}

boolean backToHomepage = !StringUtils.nullString( request.getParameter( "redirectto" ) ).equals( "accountman" );
int emailNo = 1;
String emailAddressTemp;

while( request.getParameter( "email" + emailNo ) != null )
{
  emailAddressTemp = request.getParameter( "email" + emailNo++ );
  if( emailAddressTemp.indexOf( "." ) != -1 && emailAddressTemp.indexOf( "@" ) != -1 )  //cos even if you don't type owt in, it'll pabe set to sumert like 'type email address here'
  {
    EmailSender.sendMail( "emailtellafriend", "You have been recommended for the Nextface online creative directory by &lt;RECOMMENDERSNAME&gt;", loggedInMember, extraReplacerKeys, extraReplacerVals, loggedInMember.email, emailAddressTemp );
  }
}

%><jsp:include page="/inc/pageHead.jsp" flush="true" />
<jsp:include page="/text/text.jsp" flush="true" >
  <jsp:param name="t" value="toldafriend"/>
</jsp:include>
<%

if( !backToHomepage )
{

%>
<table cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td nowrap="nowrap"><h6 class="burgundyh6"><a href="/pages/accountManager.jsp">Go back to my account manager</a></h6></td>
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