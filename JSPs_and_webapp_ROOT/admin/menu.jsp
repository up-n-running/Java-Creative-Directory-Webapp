<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.SQLException,
          java.util.ArrayList"
%><%

//instead of this, include a jsp file to check if user can access the page
//<jsp:include page="/inc/securityUser.jsp" flush="true" />

UserDetails user = UserDetails.getUser( session );

if( user == null || !user.isAdmin() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

PropertyFile adminProps = new PropertyFile( "com.extware.properties.Admin" );
PropertyFile defaultMenuProps = new PropertyFile( adminProps.getString( "menu." + adminProps.getInt( "menu.default" ) ) );

ArrayList menus = new ArrayList();

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

%><html>
<head>
  <title>Menu</title>
  <link rel="stylesheet" type="text/css" href="/style/extWareMenu.css" />
<script type="text/javascript" src="/js/layer.js"></script>
<script type="text/javascript" src="/js/menuCollapse.js"></script>
<script type="text/javascript" src="/js/menuSwitch.js"></script>
<script type="text/javascript">
var loaded=false;
currentMenu = "<%= defaultMenuProps.getString( "menu.name" ) %>";
</script>
</head>
<body class="<%= defaultMenuProps.getString( "menu.name" ) %>Menu">

<div class="<%= defaultMenuProps.getString( "menu.name" ) %>MenuHead" id="menuHead"></div>

<div class="menuGroup" id="menuGreet">
  <div class="menuGreetTop" id="menuGreetTitle">Hello</div>
  <div class="menuGreetMid" id="menuGreetBody">
<%

if( user.isUltra() )
{

%>
    You are Ultra Admin
<%

}

%>
    <a class="menuLogoutLink" href="<%= adminProps.getString( "menu.logout.link" ) %>" target="<%= adminProps.getString( "menu.logout.target" ) %>"><img class="menuLogoutImg" src="/art/admin/menu/logout.gif" /></a>
  </div>
</div>
<%

int menuCount = 1;

while( adminProps.getString( "menu." + menuCount ) != null )
{
  PropertyFile menuProps = new PropertyFile( adminProps.getString( "menu." + menuCount ) );

  if( !user.isMemberOf( StringUtils.nullReplace( menuProps.getString( "menu.group" ), adminProps.getString( "admin.login.group" ) ) ) )
  {
    menuCount++;
    continue;
  }

  menus.add( menuProps );

%>
<div class="menuMenu" id="<%= menuProps.getString( "menu.name" ) %>Menu" style="display: <%= ( ( menuProps.getString( "menu.name" ).equals( defaultMenuProps.getString( "menu.name" ) ) ) ? "block" : "none" ) %>">
<%

  int orderCount = 1;

  while( menuProps.getString( "menu.order." + orderCount ) != null )
  {
    boolean useMenuGroup = false;

    int groupCount = menuProps.getInt( "menu.order." + orderCount );
    int linkCount = 1;

    while( menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".title" ) != null )
    {
      if( user.isMemberOf( StringUtils.nullString( menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".group" ) ) ) )
      {
        useMenuGroup = true;
      }

      linkCount++;
    }

    if( menuProps.getString( "menu.group." + groupCount + ".area.N.title" ) != null )
    {
      if( user.isMemberOf( StringUtils.nullString( menuProps.getString( "menu.group." + groupCount + ".area.N.group" ) ) ) )
      {
        useMenuGroup = true;
      }
    }

    if( useMenuGroup )
    {

%>
  <div class="menuGroup" id="menu<%= menuCount %>group<%= groupCount %>">
    <a href="#" class="menuGroupCollapser" id="menu<%= menuCount %>group<%= groupCount %>collapser" title="Toggle Menu Block"><div class="menuGroupTitleO" id="menu<%= menuCount %>group<%= groupCount %>title"><%= menuProps.getString( "menu.group." + groupCount + ".title" ) %></div></a>
    <div class="menuGroupLinks" id="menu<%= menuCount %>group<%= groupCount %>links">
<%

      linkCount = 1;

      while( menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".title" ) != null )
      {
        String helpText = menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".helptext" );
        String target   = StringUtils.nullReplace( menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".target" ), "main" );

        if( user.isMemberOf( StringUtils.nullString( menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".group" ) ) ) )
        {

%>
      <a class="menuGroupLink" id="menu<%= menuCount %>group<%= groupCount %>link<%= linkCount %>" href="<%= menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".link" ) %>" target="<%= target %>"<%= ( ( helpText != null ) ? " title=\"" + helpText + "\"" : "" ) %>><%= menuProps.getString( "menu.group." + groupCount + ".area." + linkCount + ".title" ) %></a>
<%

        }

        linkCount++;
      }

      if( menuProps.getString( "menu.group." + groupCount + ".area.N.sql" ) != null && user.isMemberOf( StringUtils.nullString( menuProps.getString( "menu.group." + groupCount + ".area.N.group" ) ) ) )
      {
        ps = conn.prepareStatement( menuProps.getString( "menu.group." + groupCount + ".area.N.sql" ) );
        rs = ps.executeQuery();

        while( rs.next() )
        {
          String id   = rs.getString( "id" );
          String name = rs.getString( "name" );

          String text     = menuProps.getString( "menu.group." + groupCount + ".area.N.title" );
          String link     = menuProps.getString( "menu.group." + groupCount + ".area.N.link" );
          String helpText = menuProps.getString( "menu.group." + groupCount + ".area.N.helptext" );
          String target   = StringUtils.nullReplace( menuProps.getString( "menu.group." + groupCount + ".area.N.target" ), "main" );

          text     = StringUtils.replace( StringUtils.replace( text,     "#id#", id ), "#name#", name );
          link     = StringUtils.replace( StringUtils.replace( link,     "#id#", id ), "#name#", name );
          helpText = StringUtils.replace( StringUtils.replace( helpText, "#id#", id ), "#name#", name );

%>
      <a class="menuGroupLink" id="menu<%= menuCount %>group<%= groupCount %>link<%= linkCount %>" href="<%= link %>" target="<%= target %>"<%= ( ( helpText != null ) ? " title=\"" + helpText + "\"" : "" ) %>><%= text %></a>
<%

          linkCount++;
        }

        rs.close();
        ps.close();
      }

%>
    </div>
  </div>
<%

    }

    orderCount++;
  }

%>
</div>
<%

  menuCount++;
}

%>
<div class="menuGroup" id="menuTail">
    <a href="#" class="menuGroupCollapser" id="menutailcollapser" title="Toggle Menu Block"><div class="menuGroupTitleO" id="menutailtitle">Standard</div></a>
  <div class="menuGroupLinks" id="menutaillinks">
<%

int linkCount = 1;

if( menus.size() > 1 )
{
  for( int i = 0 ; i < menus.size() ; i++ )
  {
    PropertyFile menuProps = (PropertyFile)menus.get( i );

%>
    <a class="menuGroupLink" id="menuTailLink<%= linkCount %>" href="#" onclick="setMenu('<%= menuProps.getString( "menu.name" ) %>')" title="<%= menuProps.getString( "menu.helptext" ) %>"><%= menuProps.getString( "menu.title" ) %></a>
<%

    linkCount++;
  }
}

linkCount = 1;

while( adminProps.getString( "menu.group.s.area." + linkCount + ".title" ) != null )
{
  String helpText = adminProps.getString( "menu.group.s.area." + linkCount + ".helptext" );

  if( user.isMemberOf( StringUtils.nullString( adminProps.getString( "menu.group.s.area." + linkCount + ".group" ) ) ) )
  {
%>
      <a class="menuGroupLink" id="menuTailLink<%= linkCount %>" href="<%= adminProps.getString( "menu.group.s.area." + linkCount + ".link" ) %>" target="main"<%= ( ( helpText != null ) ? " title=\"" + helpText + "\"" : "" ) %>><%= adminProps.getString( "menu.group.s.area." + linkCount + ".title" ) %></a>
<%

  }

  linkCount++;
}

%>
    <a class="menuGroupLink" id="menuTailLink<%= ++linkCount %>" href="<%= adminProps.getString( "menu.home.link" ) %>" title="<%= adminProps.getString( "menu.home.title" ) %>" target="main">Home</a>
  </div>
</div>
</body>
</html><%

conn.close();

%>