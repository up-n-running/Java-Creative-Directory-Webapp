<%@ page language="java" import="
  com.extware.extsite.newsletter.NewsletterStatuses,
  com.extware.user.UserDetails,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.StringUtils,
  java.sql.Connection,
  java.sql.PreparedStatement,
  java.sql.ResultSet
" %><%

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

String SELECT_ITEMS_TO_SEND_SQL     = "SELECT i.listItemId FROM newsletterTypeListTypes n LEFT JOIN listTypes t ON n.listTypeId=t.listTypeId LEFT JOIN listItems i ON i.listTypeId=t.listTypeId WHERE n.newsletterTypeId=? AND i.title IS NOT NULL AND i.liveDate<=CURRENT_TIMESTAMP AND ( i.removeDate>=CURRENT_TIMESTAMP OR i.removeDate IS NULL ) ORDER BY i.liveDate DESC";
String INSERT_STORY_ITEM_SQL        = "INSERT INTO newsletterStories( newsletterId, listItemId, itemOrder, storyPresentation ) VALUES( ?, ?, ?, ? )";
String UPDATE_NEWSLETTER_STATUS_SQL = "UPDATE newsletters SET status=? WHERE newsletterId=?";
String DELETE_STORY_ITEM_SQL        = "DELETE FROM newsletterStories WHERE newsletterId=?";

String SELECT_MAX_ORDER_SQL = "SELECT MAX(itemOrder) maxItemOrder FROM newsletterStories WHERE newsletterId=?";
String UPDATE_ORDER_SET_SQL = "UPDATE newsletterStories SET itemOrder=? WHERE newsletterStoryId=?";
String UPDATE_ORDER_SQL     = "UPDATE newsletterStories SET itemOrder=? WHERE newsletterId=? AND itemOrder=?";
String UPDATE_ORDER_DEC_SQL = "UPDATE newsletterStories SET itemOrder=itemOrder-1 WHERE newsletterId=? AND itemOrder>?";	// Move Up To Fill Gap
String UPDATE_ORDER_INC_SQL = "UPDATE newsletterStories SET itemOrder=itemOrder+1 WHERE newsletterId=? AND itemOrder<?";	// Move Down to Make Room

int maxItemOrder      = 0;
int listItemId        = NumberUtils.parseInt( request.getParameter( "listItemId" ),        -1 );
int itemOrder         = NumberUtils.parseInt( request.getParameter( "itemOrder" ),         -1 );
int newsletterId      = NumberUtils.parseInt( request.getParameter( "newsletterId" ),      -1 );
int newsletterTypeId  = NumberUtils.parseInt( request.getParameter( "newsletterTypeId" ),  -1 );
int newsletterStoryId = NumberUtils.parseInt( request.getParameter( "newsletterStoryId" ), -1 );

String storyPresentation;
String mode              = StringUtils.nullString( request.getParameter( "mode" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
PreparedStatement ps1;
ResultSet rs;

ps = conn.prepareStatement( SELECT_MAX_ORDER_SQL );
ps.setInt( 1, newsletterId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxItemOrder = rs.getInt( "maxItemOrder" );
}

rs.close();
ps.close();

if( mode.equals( "save" ) && newsletterTypeId != -1 && newsletterId != -1 )
{
  ps = conn.prepareStatement( DELETE_STORY_ITEM_SQL );
  ps.setInt( 1, newsletterId );
  maxItemOrder -= ps.executeUpdate();
  ps.close();

  ps1 = conn.prepareStatement( INSERT_STORY_ITEM_SQL );
  ps1.setInt( 1, newsletterId );

  ps = conn.prepareStatement( SELECT_ITEMS_TO_SEND_SQL );
  ps.setInt( 1, newsletterTypeId );
  rs = ps.executeQuery();

  while( rs.next() )
  {
    listItemId = rs.getInt( "listItemId" );
    storyPresentation = StringUtils.nullString( request.getParameter( "item_" + listItemId ) );

    if( !storyPresentation.equals( "" ) )
    {
      ps1.setInt(    2, listItemId );
      ps1.setInt(    3, ++maxItemOrder );
      ps1.setString( 4, storyPresentation );
      ps1.executeUpdate();
    }
  }

  rs.close();
  ps.close();
  ps1.close();

  ps = conn.prepareStatement( UPDATE_NEWSLETTER_STATUS_SQL );
  ps.setString( 1, String.valueOf( NewsletterStatuses.NEWSLETTER_ORDERING ) );
  ps.setInt(    2, newsletterId );
  ps.executeUpdate();
  ps.close();
}
else if( mode.equals( "bot" ) && newsletterId != -1 && newsletterStoryId != -1 && itemOrder != -1 && itemOrder < maxItemOrder )
{
  ps = conn.prepareStatement( UPDATE_ORDER_DEC_SQL );
  ps.setInt( 1, newsletterId );
  ps.setInt( 2, itemOrder );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, maxItemOrder );
  ps.setInt( 2, newsletterStoryId );
  ps.executeUpdate();
  ps.close();
}
else if( mode.equals( "inc" ) && newsletterId != -1 && newsletterStoryId != -1 && itemOrder != -1 && itemOrder < maxItemOrder )
{
  ps = conn.prepareStatement( UPDATE_ORDER_SQL );
  ps.setInt( 1, itemOrder );
  ps.setInt( 2, newsletterId );
  ps.setInt( 3, itemOrder + 1 );
  ps.executeUpdate();
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, itemOrder + 1 );
  ps.setInt( 2, newsletterStoryId );
  ps.executeUpdate();
  ps.close();
}
else if( mode.equals( "dec" ) && newsletterId != -1 && newsletterStoryId != -1 && itemOrder > 1 )
{
  ps = conn.prepareStatement( UPDATE_ORDER_SQL );
  ps.setInt( 1, itemOrder );
  ps.setInt( 2, newsletterId );
  ps.setInt( 3, itemOrder - 1 );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, itemOrder - 1 );
  ps.setInt( 2, newsletterStoryId );
  ps.executeUpdate();
  ps.close();
}
else if( mode.equals( "top" ) && newsletterId != -1 && newsletterStoryId != -1 && itemOrder > 1 )
{
  ps = conn.prepareStatement( UPDATE_ORDER_INC_SQL );
  ps.setInt( 1, newsletterId );
  ps.setInt( 2, itemOrder );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, 1 );
  ps.setInt( 2, newsletterStoryId );
  ps.executeUpdate();
  ps.close();
}

conn.close();

response.sendRedirect( "orderStories.jsp?newsletterTypeId=" + newsletterTypeId + "&newsletterId=" + newsletterId );

%>