<%@ page language="java"
  import="com.extware.user.UserDetails,
          com.extware.utils.PropertyFile"
%><%

PropertyFile adminProps = new PropertyFile( "com.extware.properties.Admin" );

UserDetails user = UserDetails.getUser( session, false );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

%><html>
<head>
  <title>Welcome to the <%= adminProps.getString( "admin.appname" ) %> administration suite</title>
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
<body onload="checkFrames()">
<table width="100%" height="100%">
<tr>
  <td class="welcomeMessage"><p>Welcome to the</p>
    <p class="welcomeProduct"><%= adminProps.getString( "admin.appname" ) %></p>
    <p>administration suite</p></td>
</tr>
<tr>
  <td class="welcomeNotes">Please use the menu on the left to manage your site content</td>
</tr>
</table>
</body>
</html>