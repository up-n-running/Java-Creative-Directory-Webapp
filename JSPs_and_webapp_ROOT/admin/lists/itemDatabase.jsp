<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PreparedStatementUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.net.URLEncoder,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.util.GregorianCalendar"
%><%!

GregorianCalendar getCalendar( HttpServletRequest request, String baseName )
{
  int day   = NumberUtils.parseInt( request.getParameter( baseName + "Day" ),   -1 );
  int month = NumberUtils.parseInt( request.getParameter( baseName + "Month" ), -1 );
  int year  = NumberUtils.parseInt( request.getParameter( baseName + "Year" ),  -1 );

  if( day != -1 && month != -1 && year != -1 )
  {
    return new GregorianCalendar( year, month - 1, day );
  }

  return null;
}

%><%

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

String SELECT_TYPE_INFO_SQL = "SELECT orderColumn, titleLabel FROM listTypes WHERE listTypeId=?";
String SELECT_ITEM_ID_SQL   = "SELECT MAX(listItemId) listItemId FROM listItems WHERE listTypeId=? AND title=?";
String SELECT_MAX_ORDER_SQL = "SELECT MAX(formOrder) maxFormOrder FROM listItems WHERE listTypeId=?";

String INSERT_ITEM_SQL      = "INSERT INTO listItems( listTypeId, title, standfirst, body, fromDate, toDate, liveDate, removeDate, formOrder ) VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ? )";
String UPDATE_ITEM_SQL      = "UPDATE listItems SET listTypeId=?, title=?, standfirst=?, body=?, fromDate=?, toDate=?, liveDate=?, removeDate=? WHERE listItemId=?";
String DELETE_ITEM_SQL      = "DELETE FROM listItems WHERE listItemId=?";

//adding the extrafielditems queries
String INSERT_EXTRAITEM_SQL = "INSERT INTO listItemExtraFields VALUES( ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
String UPDATE_EXTRAITEM_SQL = "UPDATE listItemExtraFields SET field1=?, field2=?, field3=?, field4=?, field5=?, field6=?, field7=?, field8=?, field9=?, field10=?, field11=?, field12=?, field13=?, field14=?, field15=?, numberfield1=?, numberfield2=?, numberfield3=?, numberfield4=?, numberfield5=? WHERE listItemId=?";
String DELETE_EXTRAITEM_SQL = "DELETE FROM listItemExtraFields WHERE listItemId=?";

String UPDATE_ORDER_SET_SQL = "UPDATE listItems SET formOrder=? WHERE listItemId=?";
String UPDATE_ORDER_SQL     = "UPDATE listItems SET formOrder=? WHERE listTypeId=? AND formOrder=?";
String UPDATE_ORDER_DEC_SQL = "UPDATE listItems SET formOrder=formOrder-1 WHERE listTypeId=? AND formOrder>?";          // Move Up To Fill Gap
String UPDATE_ORDER_INC_SQL = "UPDATE listItems SET formOrder=formOrder+1 WHERE listTypeId=? AND formOrder<?";          // Move Down to Make Room

int rowsChanged;
int rowsChangedExtra = 0;
int maxFormOrder = 0;
int listTypeId   = NumberUtils.parseInt( request.getParameter( "listTypeId" ), -1 );
int listItemId   = NumberUtils.parseInt( request.getParameter( "listItemId" ), -1 );
int formOrder    = NumberUtils.parseInt( request.getParameter( "formOrder" ),  -1 );

String errors      = "";
String message     = "";
String orderColumn = "";
String titleLabel  = "";
String mode        = StringUtils.nullString( request.getParameter( "mode" ) ).trim();
String title       = StringUtils.nullString( request.getParameter( "title" ) ).trim();
String standfirst  = StringUtils.nullString( request.getParameter( "standfirst" ) ).trim();
String body        = StringUtils.nullString( request.getParameter( "body" ) ).trim();

//getting extrafields values
String field1 = StringUtils.nullString( request.getParameter( "Field1" ) ).trim();
String field2 = StringUtils.nullString( request.getParameter( "Field2" ) ).trim();
String field3 = StringUtils.nullString( request.getParameter( "Field3" ) ).trim();
String field4 = StringUtils.nullString( request.getParameter( "Field4" ) ).trim();
String field5 = StringUtils.nullString( request.getParameter( "Field5" ) ).trim();
String field6 = StringUtils.nullString( request.getParameter( "Field6" ) ).trim();
String field7 = StringUtils.nullString( request.getParameter( "Field7" ) ).trim();
String field8 = StringUtils.nullString( request.getParameter( "Field8" ) ).trim();
String field9 = StringUtils.nullString( request.getParameter( "Field9" ) ).trim();
String field10 = StringUtils.nullString( request.getParameter( "Field10" ) ).trim();
String field11 = StringUtils.nullString( request.getParameter( "Field11" ) ).trim();
String field12 = StringUtils.nullString( request.getParameter( "Field12" ) ).trim();
String field13 = StringUtils.nullString( request.getParameter( "Field13" ) ).trim();
String field14 = StringUtils.nullString( request.getParameter( "Field14" ) ).trim();
String field15 = StringUtils.nullString( request.getParameter( "Field15" ) ).trim();
int numberfield1 = NumberUtils.parseInt( request.getParameter( "NumberField1" ) , 0 );
int numberfield2 = NumberUtils.parseInt( request.getParameter( "NumberField2" ) , 0 );
int numberfield3 = NumberUtils.parseInt( request.getParameter( "NumberField3" ) , 0 );
int numberfield4 = NumberUtils.parseInt( request.getParameter( "NumberField4" ) , 0 );
int numberfield5 = NumberUtils.parseInt( request.getParameter( "NumberField5" ) , 0 );


GregorianCalendar fromDate   = getCalendar( request, "fromDate" );
GregorianCalendar toDate     = getCalendar( request, "toDate" );
GregorianCalendar liveDate   = getCalendar( request, "liveDate" );
GregorianCalendar removeDate = getCalendar( request, "removeDate" );


Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
PreparedStatement psExtra;
ResultSet rs;
ResultSet rsExtra;

ps = conn.prepareStatement( SELECT_TYPE_INFO_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

if( rs.next() )
{
  orderColumn = rs.getString( "orderColumn" );
  titleLabel  = rs.getString( "titleLabel" );
}

rs.close();
ps.close();

if( orderColumn.equals( "" ) )
{
  orderColumn = "fromDate";
}

ps = conn.prepareStatement( SELECT_MAX_ORDER_SQL );
ps.setInt( 1, listTypeId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxFormOrder = rs.getInt( "maxFormOrder" );
}

rs.close();
ps.close();

if( mode.equals( "add" ) && listTypeId != -1 && listItemId == -1 )
{
  if( title.equals( "" ) )
  {
    errors += "You must complete the " + titleLabel + " field<br />";
  }
  else
  {
    ps = conn.prepareStatement( INSERT_ITEM_SQL );
    PreparedStatementUtils.setInt(       ps, 1, listTypeId );
    PreparedStatementUtils.setString(    ps, 2, title );
    PreparedStatementUtils.setString(    ps, 3, standfirst );
    PreparedStatementUtils.setString(    ps, 4, body );
    PreparedStatementUtils.setTimestamp( ps, 5, fromDate );
    PreparedStatementUtils.setTimestamp( ps, 6, toDate );
    PreparedStatementUtils.setTimestamp( ps, 7, liveDate );
    PreparedStatementUtils.setTimestamp( ps, 8, removeDate );
    PreparedStatementUtils.setInt(       ps, 9, maxFormOrder + 1 );

    rowsChanged = ps.executeUpdate();

   ps.close();
          
  //if it has been added before 
  if (rowsChanged !=0 )
  {

   //need to select the listItemId first
   ps = conn.prepareStatement( SELECT_ITEM_ID_SQL );
   PreparedStatementUtils.setInt(	ps, 1 , listTypeId);
   PreparedStatementUtils.setString(	ps, 2 , title);
   rs = ps.executeQuery();

   //fetch the listitemid
   if ( rs.next() ) 
   {
     listItemId = rs.getInt("listItemId");
   }
  
   rs.close();   
   ps.close();



    //adding the extrafields in the table
    psExtra = conn.prepareStatement( INSERT_EXTRAITEM_SQL );
    PreparedStatementUtils.setInt(     psExtra, 1, listItemId );
    PreparedStatementUtils.setString(  psExtra, 2, field1 );
    PreparedStatementUtils.setString(  psExtra, 3, field2 );
    PreparedStatementUtils.setString(  psExtra, 4, field3 );
    PreparedStatementUtils.setString(  psExtra, 5, field4 );
    PreparedStatementUtils.setString(  psExtra, 6, field5 );
    PreparedStatementUtils.setString(  psExtra, 7, field6 );
    PreparedStatementUtils.setString(  psExtra, 8, field7 );
    PreparedStatementUtils.setString(  psExtra, 9, field8 );
    PreparedStatementUtils.setString(  psExtra, 10, field9 );
    PreparedStatementUtils.setString(  psExtra, 11, field10 );
    PreparedStatementUtils.setString(  psExtra, 12, field11 );
    PreparedStatementUtils.setString(  psExtra, 13, field12 );
    PreparedStatementUtils.setString(  psExtra, 14, field13 );
    PreparedStatementUtils.setString(  psExtra, 15, field14 );
    PreparedStatementUtils.setString(  psExtra, 16, field15 );
    PreparedStatementUtils.setInt(  psExtra, 17, numberfield1 );
    PreparedStatementUtils.setInt(  psExtra, 18, numberfield2 );
    PreparedStatementUtils.setInt(  psExtra, 19, numberfield3 );
    PreparedStatementUtils.setInt(  psExtra, 20, numberfield4 );
    PreparedStatementUtils.setInt(  psExtra, 21, numberfield5 );


    rowsChangedExtra = psExtra.executeUpdate();
    psExtra.close();

} //end if rowschanged=0


 if( rowsChanged == 1 && rowsChangedExtra == 1)
    {
      message += "Item '" + title + "' added successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "Item '" + title + "' not added.<br />";
    }
    else
    {
      message += "Item '" + title + "' added with multiple results.<br />";
    }


  }
}

else if( mode.equals( "edit" ) && listTypeId != -1 && listItemId != -1 )
{
  if( title.equals( "" ) )
  {
    errors += "You must complete the " + titleLabel + " field<br />";
  }
  else
  {

//putting back the rowsextra to zero
rowsChangedExtra = 0;

  ps = conn.prepareStatement( UPDATE_ITEM_SQL );
  PreparedStatementUtils.setInt(       ps, 1, listTypeId );
  PreparedStatementUtils.setString(    ps, 2, title );
  PreparedStatementUtils.setString(    ps, 3, standfirst );
  PreparedStatementUtils.setString(    ps, 4, body );
  PreparedStatementUtils.setTimestamp( ps, 5, fromDate );
  PreparedStatementUtils.setTimestamp( ps, 6, toDate );
  PreparedStatementUtils.setTimestamp( ps, 7, liveDate );
  PreparedStatementUtils.setTimestamp( ps, 8, removeDate );
  PreparedStatementUtils.setInt(       ps, 9, listItemId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  //updating the extrafields now 
  psExtra = conn.prepareStatement( UPDATE_EXTRAITEM_SQL );
  PreparedStatementUtils.setString (psExtra, 1 , field1 );
  PreparedStatementUtils.setString (psExtra, 2 , field2 );
  PreparedStatementUtils.setString (psExtra, 3 , field3 );
  PreparedStatementUtils.setString (psExtra, 4 , field4 );
  PreparedStatementUtils.setString (psExtra, 5 , field5 );
  PreparedStatementUtils.setString (psExtra, 6 , field6 );
  PreparedStatementUtils.setString (psExtra, 7 , field7 );
  PreparedStatementUtils.setString (psExtra, 8 , field8 );
  PreparedStatementUtils.setString (psExtra, 9 , field9 );
  PreparedStatementUtils.setString (psExtra, 10 , field10 );
  PreparedStatementUtils.setString (psExtra, 11 , field11 );
  PreparedStatementUtils.setString ( psExtra, 12, field12 );
  PreparedStatementUtils.setString ( psExtra, 13, field13 );
  PreparedStatementUtils.setString ( psExtra, 14, field14 );
  PreparedStatementUtils.setString ( psExtra, 15, field15 );
  PreparedStatementUtils.setInt(  psExtra, 16, numberfield1 );
  PreparedStatementUtils.setInt(  psExtra, 17, numberfield2 );
  PreparedStatementUtils.setInt(  psExtra, 18, numberfield3 );
  PreparedStatementUtils.setInt(  psExtra, 19, numberfield4 );
  PreparedStatementUtils.setInt(  psExtra, 20, numberfield5 );
  PreparedStatementUtils.setInt    (psExtra, 21 , listItemId);

  rowsChangedExtra = psExtra.executeUpdate();
  psExtra.close();


/**
check if it has updated the row in both tables
**/

    if( rowsChanged == 1 && rowsChangedExtra == 1 )
    {
      message += "Item '" + title + "' updated successfully.<br />";
    }
    else if( rowsChanged == 0 )
    {
      errors += "Item '" + title + "' not updated.<br />";
    }
    else
    {
      message += "Item '" + title + "' updated with multiple results.<br />";
    }
  }
}


else if( mode.equals( "delete" ) && listTypeId != -1 && listItemId != -1 )
{

//first delete the row in the listitemextrafields table (because of the foreign key)
psExtra = conn.prepareStatement( DELETE_EXTRAITEM_SQL );
psExtra.setInt(1, listItemId);

rowsChangedExtra = psExtra.executeUpdate();
psExtra.close();

rowsChanged = 0;

//shouldnt do that if didnot delete ok before
//{

  ps = conn.prepareStatement( DELETE_ITEM_SQL );
  ps.setInt( 1, listItemId );

  rowsChanged = ps.executeUpdate();

  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_DEC_SQL );
  ps.setInt( 1, listTypeId );
  ps.setInt( 2, formOrder );

  ps.executeUpdate();

  ps.close();

//}

  if( rowsChanged == 1 && rowsChangedExtra == 1)
  {
    message += "Item '" + title + "' deleted successfully.<br />";
  }
  else if( rowsChanged == 0 )
  {
    errors += "Item '" + title + "' not deleted.<br />";
  }
  else
  {
    message += "Item '" + title + "' deleted with multiple results.<br />";
  }

}
else if( mode.equals( "bot" ) && listTypeId != -1 && listItemId != -1 && formOrder != -1 && formOrder < maxFormOrder )
{
  ps = conn.prepareStatement( UPDATE_ORDER_DEC_SQL );
  ps.setInt( 1, listTypeId );
  ps.setInt( 2, formOrder );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, maxFormOrder );
  ps.setInt( 2, listItemId );
  ps.executeUpdate();
  ps.close();
}
else if( mode.equals( "inc" ) && listTypeId != -1 && listItemId != -1 && formOrder != -1 && formOrder < maxFormOrder )
{
  ps = conn.prepareStatement( UPDATE_ORDER_SQL );
  ps.setInt( 1, formOrder );
  ps.setInt( 2, listTypeId );
  ps.setInt( 3, formOrder + 1 );
  ps.executeUpdate();
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, formOrder + 1 );
  ps.setInt( 2, listItemId );
  ps.executeUpdate();
  ps.close();
}
else if( mode.equals( "dec" ) && listTypeId != -1 && listItemId != -1 && formOrder > 1 )
{
  ps = conn.prepareStatement( UPDATE_ORDER_SQL );
  ps.setInt( 1, formOrder );
  ps.setInt( 2, listTypeId );
  ps.setInt( 3, formOrder - 1 );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, formOrder - 1 );
  ps.setInt( 2, listItemId );
  ps.executeUpdate();
  ps.close();
}
else if( mode.equals( "top" ) && listTypeId != -1 && listItemId != -1 && formOrder > 1 )
{
  ps = conn.prepareStatement( UPDATE_ORDER_INC_SQL );
  ps.setInt( 1, listTypeId );
  ps.setInt( 2, formOrder );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( UPDATE_ORDER_SET_SQL );
  ps.setInt( 1, 1 );
  ps.setInt( 2, listItemId );
  ps.executeUpdate();
  ps.close();
}
else
{
  errors += "Invalid Operation (mode='" + mode + "', listTypeId=" + listTypeId + ", listItemId=" + listItemId + ")";
}

conn.close();

if( mode.equals( "add" ) || mode.equals( "edit" ) )
{
  if( !errors.equals( "" ) )
  {

%><jsp:include page="editItem.jsp" flush="true" >
  <jsp:param name="errors" value="<%= errors %>"/>
  <jsp:param name="message" value="<%= message %>"/>
</jsp:include><%

  }
  else
  {
    response.sendRedirect( "items.jsp?listTypeId=" + listTypeId + "&message=" + URLEncoder.encode( message ) );
  }
}
else
{
  response.sendRedirect( "items.jsp?listTypeId=" + listTypeId + "&message=" + URLEncoder.encode( message ) + "&errors=" + URLEncoder.encode( errors ) );
}

%>