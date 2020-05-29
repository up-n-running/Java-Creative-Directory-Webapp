<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails"
%><%

PropertyFile adminProps = new PropertyFile( "com.extware.properties.Admin" );

String mainFrame = "/admin/login.jsp";
String menuFrame = "blank.html";

UserDetails user = UserDetails.getUser( session );

if( user != null )
{
  if( !user.isAdmin() )
  {
    mainFrame = "/admin/login.jsp";
  }
  else
  {
    mainFrame = adminProps.getString( "menu.home.link" );
  }

  menuFrame = "menu.jsp";
}

%>
<html>
<head>
  <title><%= adminProps.getString( "admin.appname" ) %> - extSite admin</title>
  <script type="text/javascript" src="/js/lorem.js"></script>
</head>
<frameset rows="60,*" border="0" frameborder="no" framespacing="0">
  <frame name="head" src="/admin/header.jsp" marginheight="0" marginwidth="0" scrolling="no" noresize="noresize">

  <frameset cols="150,*" border="0" frameborder="no" framespacing="0">
    <frame name="menu" src="/admin/<%= menuFrame %>" marginheight="0" marginwidth="0" scrolling="no" noresize="noresize">
    <frame name="main" src="<%= mainFrame %>" marginheight="0" marginwidth="0" scrolling="yes" noresize="noresize">
  </frameset>

</frameset>

<noframes>
<body>
  <p>This page contains frames. You need a web browser that supports frames.</p>
</body>
</noframes>
</html>
