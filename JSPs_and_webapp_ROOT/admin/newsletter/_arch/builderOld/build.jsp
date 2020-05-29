<%@ page language="java" import="
  com.extware.asset.AssetTypePostProcess,
  com.extware.extsite.lists.ListItem,
  com.extware.extsite.lists.ListItemFile,
  com.extware.extsite.lists.ListType,
  com.extware.newsletter.Newsletter,
  com.extware.newsletter.NewsletterBuilder,
  com.extware.newsletter.NewsletterStory,
  com.extware.newsletter.NewsletterStoryTemplate,
  com.extware.newsletter.NewsletterType,
  com.extware.newsletter.NewsletterTypeSection,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.FileUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.PropertyFile,
  com.extware.utils.SiteUtils,
  com.extware.utils.StringUtils,
  java.sql.Connection,
  java.sql.SQLException,
  java.text.SimpleDateFormat,
  java.util.ArrayList,
  java.util.Enumeration,
  java.util.Hashtable,
  org.apache.regexp.RE,
  org.apache.regexp.RESyntaxException
" %><%

PropertyFile conf = new PropertyFile( "com.extware.properties.Newsletter" );

String root = getServletContext().getRealPath( "/" );
String mode = StringUtils.nullString( request.getParameter( "mode" ) );

Newsletter newsletter = (Newsletter)session.getAttribute( "newsletter" );

if( newsletter == null || mode.equals( "new" ) )
{
  String tps = request.getParameter( "newsletter" );

  Connection conn = DatabaseUtils.getDatabaseConnection();
  NewsletterType tp = NewsletterType.getNewsletterType( conn, tps );
  conn.close();

  int tpId = ( ( tp != null ) ? tp.newsletterTypeId : -1 );

  String tpName   = ( ( tp != null ) ? tp.newsletterTypeName   : "" );
  String tpHandle = ( ( tp != null ) ? tp.newsletterTypeHandle : "" );

  newsletter = new Newsletter( -1, tpId, tpHandle, tpName, "n", "daryl@eleventeenth.com", new ArrayList(), "htmlHeader", "htmlFooter", "textHeader", "textFooter" );
}

boolean admin = true;

String format   = "h";
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

session.setAttribute( "newsletter", newsletter );

%><%= build.generate() %>
