<%@ page language="java" import="
  com.extware.extsite.newsletter.NewsletterType,
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.StringUtils,
  com.extware.user.UserDetails,
  java.net.URLEncoder,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet,
  java.util.ArrayList
" %><%

UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

int count;

String errors  = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message = StringUtils.nullString( request.getParameter( "message" ) ).trim();

ArrayList newsletterTypes = NewsletterType.getNewsletterTypes();

NewsletterType newsletterType;

if( newsletterTypes.size() == 1 )
{
  newsletterType = (NewsletterType)newsletterTypes.get( 0 );
  response.sendRedirect( "saveNewsletter.jsp?newsletterTypeId=" + newsletterType.newsletterTypeId );
  return;
}

%><html>
<head>
  <title>Send a Newsletter</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="2" class="title">Send a Newsletter</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="2" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="2" class="message"><%= message %></td>
</tr>
<%

}

for( count = 0 ; count < newsletterTypes.size() ; count++ )
{
  newsletterType = (NewsletterType)newsletterTypes.get( count );

  if( count == 0 )
  {

%><tr>
  <td class="listHead">List Type Name</td>
  <td class="listHead"></td>
</tr>
<%

  }

%><tr>
  <td class="listLine<%= ( count % 2 ) %>"><%= newsletterType.newsletterTypeName %></td>
  <td class="listLine<%= ( count % 2 ) %>"><a href="saveNewsletter.jsp?newsletterTypeId=<%= newsletterType.newsletterTypeId %>">Send</a></td>
</tr>
<%

  count++;
}

if( count == 0 )
{

%><tr>
  <td colspan="2" class="listSubHead">No Newsletter Types Found</td>
</tr>
<%

}

if( user.isUltra() )
{

%>
<tr>
  <td colspan="2" class="formButtons"><a href="typeEdit.jsp">Add a Newsletter Type</a></td>
</tr>
<%

}

%>
</table>
</body>
</html>