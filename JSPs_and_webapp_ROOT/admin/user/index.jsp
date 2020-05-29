<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection"
%><%

UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String errors  = StringUtils.nullString( (String)request.getAttribute( "errors" ) );
String message = StringUtils.nullString( (String)request.getAttribute( "message" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();

request.setAttribute( "conn", conn );

%><html>
<head>
  <title>User Search</title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
</head>
<body class="adminPane">
<form action="/servlet/AdminUserDetails" method="post">
<input type="hidden" name="mode" value="list"/>
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="3" class="title">User Search</td>
</tr>
<%

if( !errors.equals( "" ) )
{

%><tr>
  <td colspan="6" class="error"><%= errors %></td>
</tr>
<%

}

if( !message.equals( "" ) )
{

%><tr>
  <td colspan="6" class="message"><%= message %></td>
</tr>
<%

}

%>
<tr>
  <td class="listHead"></td>
  <td class="listHead">Filter</td>
  <td class="listHead">Show</td>
</tr>
<tr>
  <td class="formLabel">User Name</td>
  <td><input type="text" name="username"/></td>
</tr>
<tr>
  <td class="formLabel">Email</td>
  <td><input type="text" name="email"/></td>
  <td><input type="checkbox" name="viewEmail" value="t"/></td>
</tr>
<jsp:include page="/inc/objMetaForm.jsp" flush="true" >
  <jsp:param name="objTypeId" value="1"/>
  <jsp:param name="showCheckboxes" value="t"/>
  <jsp:param name="limitMultiesToSingles" value="t"/>
</jsp:include>
<tr>
  <td colspan="3" class="formButtons"><input type="reset" value="Clear" class="formButton"/> <input type="submit" value="Search" class="formButton"/></td>
</tr>
</table>
</form>
</body>
</html><%

conn.close();

%>