<%@ page language="java" import="
  com.extware.extsite.newsletter.NewsletterStatuses,
  com.extware.utils.DatabaseUtils,
  com.extware.utils.NumberUtils,
  com.extware.utils.PreparedStatementUtils,
  com.extware.utils.StringUtils,
  com.extware.user.UserDetails,
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

String SELECT_NEWSLETTER_ID_SQL = "SELECT newsletterId FROM newsletters WHERE newsletterTypeId=? ORDER BY newsletterId DESC";
String INSERT_RECIPIENTS_SQL    = "INSERT INTO newsletterRecipients( newsletterId, userId, newsletterFormat, status ) SELECT #ID#, userId, newsletterFormat, #STATUS# FROM newsletterSubs WHERE newsletterTypeId=?";
String CREATE_NEWSLETTER_SQL    = "INSERT INTO newsletters( newsletterTypeId, newsletterName, createDate, lastUpdate, fromAddress, htmlHeader, textHeader, htmlFooter, textFooter, status ) SELECT newsletterTypeId, newsletterTypeName, CURRENT_TIMESTAMP, CURRENT_TIMESTAMP, fromAddress, htmlHeader, textHeader, htmlFooter, textFooter, #STATUS# FROM newsletterTypes WHERE newsletterTypeId=?";
String UPDATE_NEWSLETTER_SQL    = "UPDATE newsletters SET newsletterName=?, lastUpdate=CURRENT_TIMESTAMP, fromAddress=?, htmlHeader=?, textHeader=?, htmlFooter=?, textFooter=?, status=? WHERE newsletterId=?";
String DELETE_RECIPIENTS_SQL    = "DELETE FROM newsletterRecipients WHERE newsletterId=?";

int rowsAffected;
int newsletterId     = NumberUtils.parseInt( request.getParameter( "newsletterId" ),     -1);
int newsletterTypeId = NumberUtils.parseInt( request.getParameter( "newsletterTypeId" ), -1 );

String responsePage   = "/error/error";
String newsletterName = StringUtils.nullString( request.getParameter( "newsletterName" ) );
String fromAddress    = StringUtils.nullString( request.getParameter( "fromAddress" ) );
String htmlHeader     = StringUtils.nullString( request.getParameter( "htmlHeader" ) );
String textHeader     = StringUtils.nullString( request.getParameter( "textHeader" ) );
String htmlFooter     = StringUtils.nullString( request.getParameter( "htmlFooter" ) );
String textFooter     = StringUtils.nullString( request.getParameter( "textFooter" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( newsletterId == -1 )
{
  ps = conn.prepareStatement( StringUtils.replace( CREATE_NEWSLETTER_SQL, "#STATUS#", "'" + NewsletterStatuses.NEWSLETTER_NEW + "'" ) );
  PreparedStatementUtils.setInt(    ps, 1, newsletterTypeId );
  rowsAffected = ps.executeUpdate();
  ps.close();

  if( rowsAffected == 1 )
  {
    ps = conn.prepareStatement( SELECT_NEWSLETTER_ID_SQL );
    PreparedStatementUtils.setInt( ps, 1, newsletterTypeId );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      newsletterId = rs.getInt( "newsletterId" );
    }

    rs.close();
    ps.close();

    if( newsletterId != -1 )
    {
      responsePage = "editNewsletter";
    }
  }
}
else
{
  ps = conn.prepareStatement( UPDATE_NEWSLETTER_SQL );
  PreparedStatementUtils.setString( ps, 1, newsletterName );
  PreparedStatementUtils.setString( ps, 2, fromAddress );
  PreparedStatementUtils.setString( ps, 3, htmlHeader );
  PreparedStatementUtils.setString( ps, 4, textHeader );
  PreparedStatementUtils.setString( ps, 5, htmlFooter );
  PreparedStatementUtils.setString( ps, 6, textFooter );
  PreparedStatementUtils.setString( ps, 7, NewsletterStatuses.NEWSLETTER_EDITED );
  PreparedStatementUtils.setInt(    ps, 8, newsletterId );
  rowsAffected = ps.executeUpdate();
  ps.close();

  if( rowsAffected == 1 )
  {
    ps = conn.prepareStatement( DELETE_RECIPIENTS_SQL );
    PreparedStatementUtils.setInt( ps, 1, newsletterId );
    rowsAffected = ps.executeUpdate();
    ps.close();

    ps = conn.prepareStatement( StringUtils.replace( StringUtils.replace( INSERT_RECIPIENTS_SQL, "#STATUS#", "'" + NewsletterStatuses.RECIPIENT_UNSENT + "'" ), "#ID#", String.valueOf( newsletterId ) ) );
    PreparedStatementUtils.setInt( ps, 1, newsletterTypeId );
    rowsAffected = ps.executeUpdate();
    ps.close();

    responsePage = "build";
  }
}

conn.close();

response.sendRedirect( responsePage + ".jsp?newsletterTypeId=" + newsletterTypeId + "&newsletterId=" + newsletterId + "&reciptsAdded=" + rowsAffected );

%>