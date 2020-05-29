<%@ page language="java"
  import="com.extware.user.UserDetails,
          com.extware.utils.PropertyFile"
%><%

PropertyFile adminProps = new PropertyFile( "com.extware.properties.Admin" );

UserDetails user = UserDetails.getUser( session, false );

if( user != null )
{
  response.sendRedirect( adminProps.getString( "menu.home.link" ) );
  return;
}

%><html>
<head>
  <title><%= adminProps.getString( "admin.appname" ) %> login</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
<script type="text/javascript">
function checkFrames()
{
  if( window == parent )
  {
    document.location.href='/admin/';
  }
  else if( typeof( parent.menu ) != "undefined" && typeof( parent.menu.loaded ) != "undefined" && parent.menu.loaded )
  {
    parent.menu.document.location.reload();
  }
}
</script>
</head>
<body onload="checkFrames();document.forms[0].username.focus()">
<div style="height: 50px"></div>
<form method="post" target="_top" action="/servlet/Login">
<input type="hidden" name="adminLogin" value="true" />
<table border="0">
<tr>
  <td class="formLabel">User Name</td>
  <td><input type="text" name="username" class="formElement"></td>
</tr>
<tr>
  <td class="formLabel">Password</td>
  <td><input type="password" name="password" class="formElement"></td>
</tr>
<tr>
 <td colspan="2" class="formButtons"><input type="submit" class="formButton" value="login"></td>
</tr>
</table>
</form>
</body>
</html>