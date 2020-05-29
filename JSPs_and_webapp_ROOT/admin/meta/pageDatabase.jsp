<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.Hashtable"
%><%

int typeId = NumberUtils.parseInt( request.getParameter( "typeId" ), -1 );

UserDetails user = UserDetails.getUser( session );

if( user == null )
{
  response.sendRedirect( "/admin/login.jsp" );
  return;
}

if( !user.isUltra() )
{
  response.sendRedirect( "/admin/blank.html" );
  return;
}

String getMaxPageOrderSql    = "SELECT MAX(formOrder) maxFormOrder FROM objMetaPages WHERE objTypeId=?";
String setPageOrderByIdSql   = "UPDATE objMetaPages SET formOrder=? WHERE objMetaPageId=?";
String setPageOrderSql       = "UPDATE objMetaPages SET formOrder=? WHERE objTypeId=? AND formOrder=?";
String shufflePageOrderSql   = "UPDATE objMetaPages SET formOrder=formOrder-1 WHERE objTypeId=? AND formOrder>?";
String addMetaPageSql        = "INSERT INTO objMetaPages( objTypeId, metaPageName, shortPageName, metaPageHandle, formOrder, canStartChain, mustStartChain, canBeInChain ) VALUES( ?, ?, ?, ?, ?, ?, ?, ? )";
String updateMetaPageSql     = "UPDATE objMetaPages SET objTypeId=?, metaPageName=?, shortPageName=?, metaPageHandle=?, canStartChain=?, mustStartChain=?, canBeInChain=? WHERE objMetaPageId=?";
String deleteMetaPageSql     = "DELETE FROM objMetaPages WHERE objMetaPageId=?";
String getDefPageMaxOrderSql = "SELECT MAX(formOrder) maxFormOrder FROM objMetaTypes WHERE objTypeId=? AND objMetaPageId IS NULL";
String setOrderHigherSql     = "UPDATE objMetaTypes SET formOrder=formOrder+? WHERE objMetaPageId=?";

int maxFormOrder  = -1;
int formOrder     = NumberUtils.parseInt( request.getParameter( "formOrder" ), -1 );
int objMetaPageId = NumberUtils.parseInt( request.getParameter( "objMetaPageId" ), -1 );

String function       = StringUtils.nullString( request.getParameter( "function" ) );
String errorDesc      = StringUtils.nullString( request.getParameter( "errorDesc" ) );
String metaPageName   = StringUtils.nullString( request.getParameter( "metaPageName" ) );
String shortPageName  = StringUtils.nullString( request.getParameter( "shortPageName" ) );
String metaPageHandle = StringUtils.nullString( request.getParameter( "metaPageHandle" ) );

String canStartChain  = StringUtils.nullString( request.getParameter( "canStartChain" ) );
String mustStartChain = StringUtils.nullString( request.getParameter( "mustStartChain" ) );
String canBeInChain   = StringUtils.nullString( request.getParameter( "canBeInChain" ) );

String backTo         = StringUtils.nullReplace( request.getParameter( "backTo" ), "pageList" );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

ps = conn.prepareStatement( getMaxPageOrderSql );
ps.setInt( 1, typeId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxFormOrder = rs.getInt( "maxFormOrder" );
}

rs.close();
ps.close();

if( function.equals( "add" ) && !metaPageName.equals( "" ) && objMetaPageId == -1 )
{
  ps = conn.prepareStatement( addMetaPageSql );
  ps.setInt(    1, typeId );
  ps.setString( 2, metaPageName );
  ps.setString( 3, shortPageName );
  ps.setString( 4, metaPageHandle );
  ps.setInt(    5, maxFormOrder );
  ps.setString( 6, canStartChain );
  ps.setString( 7, mustStartChain );
  ps.setString( 8, canBeInChain );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "edit" ) && !metaPageName.equals( "" ) && objMetaPageId != -1 )
{
  ps = conn.prepareStatement( updateMetaPageSql );
  ps.setInt(    1, typeId );
  ps.setString( 2, metaPageName );
  ps.setString( 3, shortPageName );
  ps.setString( 4, metaPageHandle );
  ps.setString( 5, canStartChain );
  ps.setString( 6, mustStartChain );
  ps.setString( 7, canBeInChain );
  ps.setInt(    8, objMetaPageId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "inc" ) && objMetaPageId != -1 && formOrder != -1 && formOrder < maxFormOrder )
{
  ps = conn.prepareStatement( setPageOrderSql );
  ps.setInt( 1, formOrder );
  ps.setInt( 2, typeId );
  ps.setInt( 3, formOrder + 1 );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setPageOrderByIdSql );
  ps.setInt( 1, formOrder + 1 );
  ps.setInt( 2, objMetaPageId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "dec" ) && objMetaPageId != -1 && formOrder > 1 )
{
  ps = conn.prepareStatement( setPageOrderSql );
  ps.setInt( 1, formOrder );
  ps.setInt( 2, typeId );
  ps.setInt( 3, formOrder - 1 );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setPageOrderByIdSql );
  ps.setInt( 1, formOrder - 1 );
  ps.setInt( 2, objMetaPageId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "delete" ) && objMetaPageId != -1 )
{
  ps = conn.prepareStatement( getDefPageMaxOrderSql );
  ps.setInt( 1, typeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    maxFormOrder = rs.getInt( "maxFormOrder" );
  }

  rs.close();
  ps.close();

  ps = conn.prepareStatement( setOrderHigherSql );
  ps.setInt( 1, maxFormOrder );
  ps.setInt( 2, objMetaPageId );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( deleteMetaPageSql );
  ps.setInt( 1, objMetaPageId );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( shufflePageOrderSql );
  ps.setInt( 1, typeId );
  ps.setInt( 2, formOrder );
  ps.executeUpdate();
  ps.close();
}

conn.close();

response.sendRedirect( backTo + ".jsp?typeId=" + typeId );

%>