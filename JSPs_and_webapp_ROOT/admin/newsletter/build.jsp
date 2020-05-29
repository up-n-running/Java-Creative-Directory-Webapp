<%@ page language="java" import="
  com.extware.newsletter.Newsletter,
  com.extware.newsletter.NewsletterBuilder,
  com.extware.utils.BooleanUtils,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.PropertyFile,
  com.extware.utils.SiteUtils,
  com.extware.utils.StringUtils,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet,
  java.util.ArrayList
" %><%

PropertyFile conf = new PropertyFile( "com.extware.properties.Newsletter" );

int newsletterId = NumberUtils.parseInt( request.getParameter( "newsletterId" ), -1 );

String root = getServletContext().getRealPath( "/" );
String mode = StringUtils.nullString( request.getParameter( "mode" ) );

Newsletter newsletter = (Newsletter)session.getAttribute( "newsletter" );

if( newsletter == null )
{
  if( newsletterId != -1 )
  {
    newsletter = Newsletter.load( newsletterId );
  }
  else
  {
    out.print( "Null newsletter with -1 ID" );
    return;
  }
}

boolean admin = !BooleanUtils.parseBoolean( request.getParameter( "preview" ) );

String format   = StringUtils.nullReplace( request.getParameter( "format" ), "h" );
String siteUrl  = SiteUtils.getUrl( request );
String buildUrl = request.getServletPath();

NewsletterBuilder build = new NewsletterBuilder( root, newsletter, format, buildUrl, siteUrl, admin );

int itemId = NumberUtils.parseInt( request.getParameter( "itemId" ), -1 );
int index  = NumberUtils.parseInt( request.getParameter( "index" ),  -1 );

String handle              = request.getParameter( "handle" );
String storyTemplateHandle = request.getParameter( "template" );

if( mode.equals( "save" ) )
{
  String redirect = "saveNewsletter.jsp";

%><jsp:forward page="<%= redirect %>" /><%

}
else if( mode.equals( "send" ) )
{
  String redirect = "sendNewsletter.jsp";

%><jsp:forward page="<%= redirect %>" /><%

}
else if( mode.equals( "selectstory" ) )
{
  String redirect = "selectstory.jsp";

%><jsp:forward page="<%= redirect %>" /><%

}
else if( mode.equals( "addstory" ) )
{
  build.addStory( handle, itemId, storyTemplateHandle );
}
else if( mode.equals( "removestory" ) )
{
  build.removeStory( handle, itemId, index );
}
else if( mode.equals( "storyup" ) )
{
  build.reorderStory( handle, index, -1 );
}
else if( mode.equals( "storydown" ) )
{
  build.reorderStory( handle, index, 1 );
}

newsletter.save();

session.setAttribute( "newsletter", newsletter );

%><%= build.generate() %>
