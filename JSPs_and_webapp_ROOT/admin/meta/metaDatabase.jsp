<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.SQLException,
          java.sql.Types,
          java.util.Date"
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

String defaultPageSql      = " AND objMetaPageId IS NULL";
String pageIdSql           = " AND objMetaPageId=?";
String getMaxTypeOrderSql  = "SELECT MAX(formOrder) maxFormOrder FROM objMetaTypes WHERE objTypeId=?";
String getMetaTypeIdSql    = "SELECT objMetaTypeId FROM objMetaTypes WHERE objTypeId=? AND UPPER(typeName)=UPPER(?) ORDER BY objMetaTypeId DESC";
String insertTypeSql       = "INSERT INTO objMetaTypes( objTypeId, typeName, formOrder, objMetaPageId, hidden, required, minUserLevel ) VALUES( ?, ?, ?, ?, ?, ?, ? )";
String setTypeNameSql      = "UPDATE objMetaTypes SET typeName=?, objMetaPageId=?, hidden=?, required=?, minUserLevel=? WHERE objMetaTypeId=?";
String setGroupRefSql      = "UPDATE objMetaTypes SET metaGroupId=?, groupType=? WHERE objMetaTypeId=?";
String setTypeOrderByIdSql = "UPDATE objMetaTypes SET formOrder=? WHERE objMetaTypeId=?";
String setPageIdSql        = "UPDATE objMetaTypes SET objMetaPageId=?, formOrder=? WHERE objMetaTypeId=?";
String setTypeOrderSql     = "UPDATE objMetaTypes SET formOrder=? WHERE objTypeId=? AND formOrder=?";
String closeOrderSql       = "UPDATE objMetaTypes SET formOrder=formOrder-1 WHERE objTypeId=? AND formOrder>?";
String deleteTypeSql       = "DELETE FROM objMetaTypes WHERE objMetaTypeId=?";

boolean hidden   = StringUtils.nullString( request.getParameter( "hidden" )   ).equals( DataDictionary.DB_TRUE_CHAR );
boolean required = StringUtils.nullString( request.getParameter( "required" ) ).equals( DataDictionary.DB_TRUE_CHAR );

int maxFormOrder  = 0;
int metaTypeId    = NumberUtils.parseInt( request.getParameter( "metaTypeId" ),    -1 );
int metaGroupId   = NumberUtils.parseInt( request.getParameter( "metaGroupId" ),   -1 );
int formOrder     = NumberUtils.parseInt( request.getParameter( "formOrder" ),     -1 );
int objMetaPageId = NumberUtils.parseInt( request.getParameter( "objMetaPageId" ), -1 );
int oldMetaPageId = NumberUtils.parseInt( request.getParameter( "oldMetaPageId" ), -1 );
int minUserLevel  = NumberUtils.parseInt( request.getParameter( "minUserLevel" ),  -1 );

String errorDesc     = "";
String function      = StringUtils.nullString( request.getParameter( "function" ) );
String metaTypeName  = StringUtils.nullString( request.getParameter( "metaTypeName" ) );
String metaGroupType = StringUtils.nullString( request.getParameter( "metaGroupType" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( objMetaPageId == -1 )
{
  ps = conn.prepareStatement( getMaxTypeOrderSql + defaultPageSql );
}
else
{
  ps = conn.prepareStatement( getMaxTypeOrderSql + pageIdSql );
  ps.setInt( 2, objMetaPageId );
}

ps.setInt( 1, typeId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxFormOrder = rs.getInt( "maxFormOrder" );
}

rs.close();
ps.close();

if( function.equals( "add" ) && !metaTypeName.equals( "" ) && metaTypeId == -1 )
{
  formOrder = maxFormOrder + 1;

  ps = conn.prepareStatement( getMetaTypeIdSql );
  ps.setInt(    1, typeId );
  ps.setString( 2, metaTypeName );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    errorDesc = "alreadyexists";
  }

  rs.close();
  ps.close();

  if( errorDesc.equals( "" ) )
  {
    ps = conn.prepareStatement( insertTypeSql );
    ps.setInt(    1, typeId );
    ps.setString( 2, metaTypeName );
    ps.setInt(    3, formOrder );
    ps.setString( 5, ( ( hidden )   ? DataDictionary.DB_TRUE_CHAR : DataDictionary.DB_FALSE_CHAR ) );
    ps.setString( 6, ( ( required ) ? DataDictionary.DB_TRUE_CHAR : DataDictionary.DB_FALSE_CHAR ) );
    ps.setInt(    7, minUserLevel );

    if( objMetaPageId == -1 )
    {
      ps.setNull( 4, Types.INTEGER );
    }
    else
    {
      ps.setInt( 4, objMetaPageId );
    }

    ps.executeUpdate();
    ps.close();

    ps = conn.prepareStatement( getMetaTypeIdSql );
    ps.setInt(    1, typeId );
    ps.setString( 2, metaTypeName );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      metaTypeId = rs.getInt( "objMetaTypeId" );
    }

    rs.close();
    ps.close();

    try
    {
      ps = conn.prepareStatement( setGroupRefSql );

      if( metaGroupId == -1 )
      {
        ps.setNull( 1, Types.INTEGER );
      }
      else
      {
        ps.setInt( 1, metaGroupId );
      }

      ps.setString( 2, metaGroupType );
      ps.setInt(    3, metaTypeId );
      ps.executeUpdate();
      ps.close();
    }
    catch( SQLException e )
    {
      System.out.println( "extSell: admin: metaDatabase: SqlException: " + e + ": " + metaTypeId + " - " + metaGroupId + " - " + metaGroupType );
    }
  }
}
else if( function.equals( "edit" ) && !metaTypeName.equals( "" ) && metaTypeId != -1 )
{
  ps = conn.prepareStatement( setTypeNameSql );
  ps.setString( 1, metaTypeName );

  if( objMetaPageId == -1 )
  {
    ps.setNull( 2, Types.INTEGER );
  }
  else
  {
    ps.setInt( 2, objMetaPageId );
  }

  ps.setString( 3, ( ( hidden   ) ? DataDictionary.DB_TRUE_CHAR : DataDictionary.DB_FALSE_CHAR ) );
  ps.setString( 4, ( ( required ) ? DataDictionary.DB_TRUE_CHAR : DataDictionary.DB_FALSE_CHAR ) );
  ps.setInt(    5, minUserLevel );
  ps.setInt(    6, metaTypeId );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setGroupRefSql );

  if( metaGroupId != -1 )
  {
    ps.setInt( 1, metaGroupId );
  }
  else
  {
    ps.setNull( 1, Types.INTEGER );
  }

  ps.setString( 2, metaGroupType );
  ps.setInt(    3, metaTypeId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "inc" ) && metaTypeId != -1 && formOrder != -1 && formOrder < maxFormOrder )
{
  if( objMetaPageId == -1 )
  {
    ps = conn.prepareStatement( setTypeOrderSql + defaultPageSql );
  }
  else
  {
    ps = conn.prepareStatement( setTypeOrderSql + pageIdSql );
    ps.setInt( 4, objMetaPageId );
  }

  ps.setInt( 1, formOrder );
  ps.setInt( 2, typeId );
  ps.setInt( 3, formOrder + 1 );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setTypeOrderByIdSql );

  ps.setInt( 1, formOrder + 1 );
  ps.setInt( 2, metaTypeId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "dec" ) && metaTypeId != -1 && formOrder > 1 )
{
  if( objMetaPageId == -1 )
  {
    ps = conn.prepareStatement( setTypeOrderSql + defaultPageSql );
  }
  else
  {
    ps = conn.prepareStatement( setTypeOrderSql + pageIdSql );
    ps.setInt( 4, objMetaPageId );
  }

  ps.setInt( 1, formOrder );
  ps.setInt( 2, typeId );
  ps.setInt( 3, formOrder - 1 );
  ps.executeUpdate();
  ps.close();

  if( objMetaPageId == -1 )
  {
    ps = conn.prepareStatement( setTypeOrderByIdSql + defaultPageSql );
  }
  else
  {
    ps = conn.prepareStatement( setTypeOrderByIdSql + pageIdSql );
    ps.setInt( 3, objMetaPageId );
  }

  ps.setInt( 1, formOrder - 1 );
  ps.setInt( 2, metaTypeId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "setPage" ) && metaTypeId != -1 )
{
  ps = conn.prepareStatement( setPageIdSql );

  if( objMetaPageId != -1 )
  {
    ps.setInt( 1, objMetaPageId );
  }
  else
  {
    ps.setNull( 1, Types.INTEGER );
  }

  ps.setInt( 2, maxFormOrder + 1 );
  ps.setInt( 3, metaTypeId );
  ps.executeUpdate();
  ps.close();

  if( oldMetaPageId == -1 )
  {
    ps = conn.prepareStatement( closeOrderSql + defaultPageSql );
  }
  else
  {
    ps = conn.prepareStatement( closeOrderSql + pageIdSql );
    ps.setInt( 3, oldMetaPageId );
  }

  ps.setInt( 1, typeId );
  ps.setInt( 2, formOrder );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "delete" ) && metaTypeId != -1 )
{
  ps = conn.prepareStatement( deleteTypeSql );
  ps.setInt( 1, metaTypeId );
  ps.executeUpdate();
  ps.close();

  if( objMetaPageId == -1 )
  {
    ps = conn.prepareStatement( closeOrderSql + defaultPageSql );
  }
  else
  {
    ps = conn.prepareStatement( closeOrderSql + pageIdSql );
    ps.setInt( 3, objMetaPageId );
  }

  ps.setInt( 1, typeId );
  ps.setInt( 2, formOrder );
  ps.executeUpdate();
  ps.close();
}

conn.close();

if( errorDesc.equals( "" ) )
{
  response.sendRedirect( "metaList.jsp?typeId="  + typeId + "&cacheBuster=" + new Date().getTime() );
}
else
{
  response.sendRedirect( "metaEditForm.jsp?errorDesc=" + errorDesc + "&typeId="  + typeId + "&metaTypeName="  + metaTypeName + "&metaGroupId="   + metaGroupId + "&metaGroupType=" + metaGroupType );
}

%>