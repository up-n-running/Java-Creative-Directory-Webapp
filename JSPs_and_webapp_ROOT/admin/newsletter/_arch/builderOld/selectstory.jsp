<%@ page language="java" import="
  com.extware.newsletter.Newsletter,
  com.extware.newsletter.NewsletterBuilder,
  com.extware.newsletter.NewsletterStoryTemplate,
  com.extware.newsletter.NewsletterTypeSection,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.SiteUtils,
  com.extware.utils.StringUtils,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet,
  java.util.ArrayList
" %><%

String selectItemsSql = "SELECT i.listItemId, i.title, t.listName FROM newsletterTypeListTypes n LEFT JOIN listTypes t ON n.listTypeId=t.listTypeId LEFT JOIN listItems i ON i.listTypeId=t.listTypeId WHERE n.newsletterTypeId=? AND i.title IS NOT NULL AND i.liveDate<=CURRENT_TIMESTAMP AND ( i.removeDate>=CURRENT_TIMESTAMP OR i.removeDate IS NULL ) ORDER BY t.listName, i.title";

boolean admin = true;

int listItemId;

String title;
String listName;
String oldListName = "";
String format      = "h";
String siteUrl     = SiteUtils.getUrl( request );
String root        = getServletContext().getRealPath( "/" );
String handle      = StringUtils.nullString( request.getParameter( "handle" ) );
String buildUrl    = StringUtils.nullString( request.getParameter( "buildUrl" ) );

Newsletter newsletter = (Newsletter)session.getAttribute( "newsletter" );

NewsletterBuilder build = new NewsletterBuilder( root, newsletter, format, buildUrl, siteUrl, admin );

ArrayList sections  = build.getNewsletterSections();
ArrayList templates = build.getStoryTemplateTypes();

NewsletterTypeSection section = null;
NewsletterStoryTemplate template;

for( int i = 0 ; i < sections.size() ; i++ )
{
  section = (NewsletterTypeSection)sections.get( i );

  if( section.sectionHandle.equals( handle ) )
  {
    break;
  }

  section = null;
}

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps = conn.prepareStatement( selectItemsSql );

ps.setInt( 1, 3 );

ResultSet rs = ps.executeQuery();

%><html>
<head>
  <title>Send a Newsletter</title>
  <link rel="stylesheet" href="/style/admin.css" type="text/css">
</head>
<body class="adminPane">
<table border="0" cellpadding="0" cellspacing="0">
<tr>
  <td colspan="4" class="title">Choose Newsletter Content</td>
</tr>
<%

while( rs.next() )
{
  listItemId = rs.getInt(    "listItemId" );
  title      = rs.getString( "title" );
  listName   = rs.getString( "listName" );

  if( !section.canUseItemType( listName ) )
  {
    continue;
  }

  if( !listName.equals( oldListName ) )
  {

%>
<tr>
  <td colspan="4" class="subhead"><%= listName %></td>
</tr>
<%

    oldListName = listName;
  }

%><tr>
  <td><%= title %></td>
<%

  for( int i = 0 ; i < templates.size() ; i++ )
  {
    template = (NewsletterStoryTemplate)templates.get( i );

    if( section.canUseTemplate( template.storyTemplateHandle ) )
    {

%>  <td><a href="<%= buildUrl %>?mode=addstory&itemId=<%= listItemId %>&handle=<%= handle %>&template=<%= template.storyTemplateHandle %>"><%= StringUtils.titleCase( template.storyTemplateHandle ) %></a></td>
<%
    }
  }

%></tr>
<%

}

rs.close();
ps.close();

conn.close();

%>
<tr>
  <td colspan="4" class="formButtons"><a href="#" onclick="document.location.href='<%= buildUrl %>';return false">Cancel</a></td>
</tr>
</table>
</body>
</html>