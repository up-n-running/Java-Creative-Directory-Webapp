<%@ page language="java"
  import="com.extware.utils.FileUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.SiteUtils,
          com.extware.utils.StringUtils"
%><%

int listItemId = NumberUtils.parseInt( request.getParameter( "i" ), -1 );

String contentPage = "/home.jsp";
String content     = StringUtils.nullString( request.getParameter( "c" ) );
String listHandle  = StringUtils.nullString( request.getParameter( "l" ) );
String pageHandle  = StringUtils.nullString( request.getParameter( "t" ) );
String system      = StringUtils.nullString( (String)request.getAttribute( "system" ) );
String subsys      = StringUtils.nullString( (String)request.getAttribute( "subsystem" ) );

if( !content.equals( "" ) )
{
  contentPage = "/" + content;
}
else if( listItemId != -1 )
{
  contentPage = "/items/item.jsp";
}
else if( !listHandle.equals( "" ) )
{
  contentPage = "/lists/list.jsp";
}
else if( !pageHandle.equals( "" ) )
{
  contentPage = "/text/text.jsp";
}
else if( !system.equals( "" ) || !subsys.equals( "" ) )
{
  contentPage = ( ( system.equals( "" ) ) ?  "" : "/" + system ) + "/" + ( ( subsys.equals( "" ) ) ? "index" : subsys ) + ".jsp";
}

if( contentPage.endsWith( "/" ) )
{
  contentPage += "index.jsp";
}

if( contentPage.equals( "/index.jsp" ) )
{
  contentPage = "/home.jsp";
}

%><jsp:include page="<%= contentPage %>" flush="true" />