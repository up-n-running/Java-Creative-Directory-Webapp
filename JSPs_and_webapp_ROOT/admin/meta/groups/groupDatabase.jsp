<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.Types"
%><%

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

String getGroupIdSql  = "SELECT objMetaChoiceGroupId FROM objMetaChoiceGroups WHERE UPPER(groupName)=UPPER(?)";
String addGroupSql    = "INSERT INTO objMetaChoiceGroups( groupName, objTypeId ) VALUES( ?, ? )";
String editGroupSql   = "UPDATE objMetaChoiceGroups SET groupName=?, objTypeId=? WHERE objMetaChoiceGroupId=?";
String deleteGroupSql = "DELETE FROM objMetaChoiceGroups WHERE objMetaChoiceGroupId=?";

int typeId    = NumberUtils.parseInt( request.getParameter( "typeId" ),    -1 );
int groupId   = NumberUtils.parseInt( request.getParameter( "groupId" ),   -1 );
int objTypeId = NumberUtils.parseInt( request.getParameter( "objTypeId" ), -1 );

String errorDesc = "";
String function  = StringUtils.nullString( request.getParameter( "function" ) );
String groupName = StringUtils.nullString( request.getParameter( "groupName" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( function.equals( "add" ) && !groupName.equals( "" ) && groupId == -1 )
{
  ps = conn.prepareStatement( getGroupIdSql );
  ps.setString( 1, groupName );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    errorDesc = "alreadyexists";
  }

  rs.close();
  ps.close();

  if( errorDesc.equals( "" ) )
  {
    ps = conn.prepareStatement( addGroupSql );
    ps.setString( 1, groupName );

    if( objTypeId != -1 )
    {
      ps.setInt( 2, objTypeId );
    }
    else
    {
      ps.setNull( 2, Types.INTEGER );
    }

    ps.executeUpdate();

    ps = conn.prepareStatement( getGroupIdSql );
    ps.setString( 1, groupName );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      groupId = rs.getInt( "objMetaChoiceGroupId" );
    }

    rs.close();
    ps.close();
  }
}
else if( function.equals( "edit" ) && groupId != -1 )
{
  ps = conn.prepareStatement( editGroupSql );
  ps.setString( 1, groupName );

  if( objTypeId != -1 )
  {
    ps.setInt( 2, objTypeId );
  }
  else
  {
    ps.setNull( 2, Types.INTEGER );
  }

  ps.setInt( 3, groupId );
  ps.executeUpdate();
}
else if( function.equals( "delete" ) && groupId != -1 )
{
  ps = conn.prepareStatement( deleteGroupSql );
  ps.setInt( 1, groupId );
  ps.executeUpdate();
}

if( errorDesc.equals( "" ) )
{
  if( function.equals( "add" ) )
  {
    response.sendRedirect( "choiceEditForm.jsp?groupId=" + groupId + "&typeId=" + typeId );
  }
  else
  {
    response.sendRedirect( "index.jsp?typeId=" + typeId );
  }
}
else
{
  response.sendRedirect( "groupEditForm.jsp?errorDesc=" + errorDesc + "&groupId="  + groupId + "&groupName="  + groupName + "&objTypeId="  + objTypeId + "&typeId=" + typeId );
}

%>