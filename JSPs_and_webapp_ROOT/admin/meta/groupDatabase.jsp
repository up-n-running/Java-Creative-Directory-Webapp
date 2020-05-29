<%@ page language="java"
  import="com.extware.common.DataDictionary,
          com.extware.utils.DatabaseUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          com.extware.user.UserDetails,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet"
%><%

int typeId = NumberUtils.parseInt( request.getParameter( "objTypeId" ), -1 );

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

int groupId = NumberUtils.parseInt( request.getParameter( "groupId" ), -1 );

String insertGroupSql  = "INSERT INTO objMetaChoiceGroups( groupName, objTypeId ) VALUES( ?, ? )";
String getGroupIdSql   = "SELECT objMetaChoiceGroupId FROM objMetaChoiceGroups WHERE groupName=? AND objTypeId=? ORDER BY groupName DESC";
String insertChoiceSql = "INSERT INTO objMetaChoices( groupId, choiceValue, formOrder ) VALUES( ?, ?, ? )";

String function  = StringUtils.nullString( request.getParameter( "function" ) );
String passBack  = StringUtils.nullString( request.getParameter( "passBack" ) );
String groupName = StringUtils.nullString( request.getParameter( "groupName" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
ResultSet rs;

if( function.equals( "quickadd" ) && !groupName.equals( "" ) && groupId == -1 )
{
  ps = conn.prepareStatement( insertGroupSql );
  ps.setString( 1, groupName );
  ps.setInt(    2, typeId );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( getGroupIdSql );
  ps.setString( 1, groupName );
  ps.setInt(    2, typeId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    groupId = rs.getInt( "objMetaChoiceGroupId" );
  }

  rs.close();
  ps.close();

  String[] groupChoices = StringUtils.split( StringUtils.nullString( request.getParameter( "groupValues" ) ), "\r?\n" );
  ps = conn.prepareStatement( insertChoiceSql );
  ps.setInt( 1, groupId );

  int formOrder = 1;

  for( int i = 0 ; i < groupChoices.length ; i++ )
  {
    String choice = StringUtils.nullString( groupChoices[i] ).trim();

    if( !choice.equals( "" ) )
    {
      ps.setString( 2, choice );
      ps.setInt(    3, formOrder );
      ps.executeUpdate();
      formOrder++;
    }
  }

  ps.close();
}

conn.close();

%><html>
<head>
  <title>Add new Meta Data Group</title>
  <link rel="stylesheet" type="text/css" href="/style/admin.css">
<script type="text/javascript">
function passBack()
{
  <%= passBack %>( <%= groupId %>, "<%= groupName %>" );
  self.close();
}
</script>
</head>
<body onLoad="passBack()">
</body>
</html>