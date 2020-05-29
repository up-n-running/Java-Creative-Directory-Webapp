<%@ page language="java"
  import="com.extware.utils.BooleanUtils,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet"
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

String errors        = StringUtils.nullString( request.getParameter( "errors" ) ).trim();
String message       = StringUtils.nullString( request.getParameter( "message" ) ).trim();

PropertyFile dd = PropertyFile.getDataDictionary();

%><html>
<head>
  <title>Chart Importer</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<form action="/servlet/ChartImport" method="post" enctype="multipart/form-data">
<table border="0" cellpadding="0" cellpadding="0">
<tr>
  <td colspan="2" class="title">Select Zip File To Import.</td>
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

%><tr>
  <td class="formLabel">File</td>
  <td><input type="file" name="file" class="formElement" size="30" /></td>
</tr>
<tr>
  <td>&nbsp;</td><td><input type="submit" value="Begin Import" class="formButton" /></td>
</tr>
</table>
</form>
</body>
</html>