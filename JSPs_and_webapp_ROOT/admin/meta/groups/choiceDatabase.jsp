<%@ page language="java"
  import="com.extware.utils.DatabaseUtils,
          com.extware.utils.FileUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.utils.UploadUtils,
          com.extware.user.UserDetails,
          java.io.File,
          java.io.FileNotFoundException,
          java.io.IOException,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.Types"
%><%

int imageNumber = -1;

if( request.getContentType() != null && request.getContentType().toLowerCase().indexOf( "multipart/form-data" ) == 0 )
{
  request     = new UploadUtils( config, request, response );
  imageNumber = ( (UploadUtils)request ).getFileNumber( "choiceImage" );
}

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

String getMaxFormOrderSql  = "SELECT MAX(formOrder) maxFormOrder FROM objMetaChoices WHERE groupId=?";
String getChoiceIdSql      = "SELECT objMetaChoiceId FROM objMetaChoices WHERE groupId=? AND UPPER( choiceValue )=UPPER( ? )";
String getChoiceIdListSql  = "SELECT objMetaChoiceId FROM objMetaChoices WHERE groupId=? ORDER BY choiceValue";
String getChoiceImageSql   = "SELECT choiceImage FROM objMetaChoices WHERE objMetaChoiceId=?";
String addChoiceSql        = "INSERT INTO objMetaChoices( groupId, choiceValue, formOrder, minUserLevel ) VALUES( ?, ?, ?, ? )";
String addAliasSql         = "INSERT INTO objMetaChoiceAliases ( choiceId, aliasValue ) VALUES( ?, ? )";
String setChoiceImageSql   = "UPDATE objMetaChoices SET choiceImage=? WHERE objMetaChoiceId=?";
String editChoiceSql       = "UPDATE objMetaChoices SET choiceValue=?, minUserLevel=? WHERE objMetaChoiceId=?";
String setFormOrderByIdSql = "UPDATE objMetaChoices SET formOrder=? WHERE objMetaChoiceId=?";
String setFormOrderSql     = "UPDATE objMetaChoices SET formOrder=? WHERE groupId=? AND formOrder=?";
String decFormOrderSql     = "UPDATE objMetaChoices SET formOrder=formOrder-1 WHERE groupId=? AND formOrder>?";	// Move Up To Fill Gap
String incFormOrderSql     = "UPDATE objMetaChoices SET formOrder=formOrder+1 WHERE groupId=? AND formOrder<?";	// Move Down to Make Room
String deleteChoiceSql     = "DELETE FROM objMetaChoices WHERE objMetaChoiceId=?";
String deleteAliasSql      = "DELETE FROM objMetaChoiceAliases WHERE objMetaChoiceAliasId=?";

PropertyFile dataDictionary = PropertyFile.getDataDictionary();

int maxFormOrder         = 0;
int typeId               = NumberUtils.parseInt( request.getParameter( "typeId" ),               -1 );
int groupId              = NumberUtils.parseInt( request.getParameter( "groupId" ),              -1 );
int choiceId             = NumberUtils.parseInt( request.getParameter( "choiceId" ),             -1 );
int formOrder            = NumberUtils.parseInt( request.getParameter( "formOrder" ),            -1 );
int objMetaChoiceAliasId = NumberUtils.parseInt( request.getParameter( "objMetaChoiceAliasId" ), -1 );
int minUserLevel         = NumberUtils.parseInt( request.getParameter( "minUserLevel" ),          0 );

String errorDesc     = "";
String imageSavePath = getServletContext().getRealPath( "/" + dataDictionary.getString( "meta.choice.dir.img" ) );
String function      = StringUtils.nullString( request.getParameter( "function" ) );
String choiceValue   = StringUtils.nullString( request.getParameter( "choiceValue" ) );
String aliasValue    = StringUtils.nullString( request.getParameter( "aliasValue" ) );

Connection conn = DatabaseUtils.getDatabaseConnection();
PreparedStatement ps;
PreparedStatement ps2;
ResultSet rs;

ps = conn.prepareStatement( getMaxFormOrderSql );
ps.setInt( 1, groupId );
rs = ps.executeQuery();

if( rs.next() )
{
  maxFormOrder = NumberUtils.parseInt( rs.getString( "maxFormOrder" ), 0 );
}

rs.close();
ps.close();

if( function.equals( "sort" ) && choiceId == -1 )
{
  ps2 = conn.prepareStatement( setFormOrderByIdSql );
  ps  = conn.prepareStatement( getChoiceIdListSql );
  ps.setInt(    1, groupId );
  rs = ps.executeQuery();

  formOrder = 1;

  while( rs.next() )
  {
    ps2.setInt( 1, formOrder++ );
    ps2.setInt( 2, rs.getInt( "objMetaChoiceId" ) );
    ps2.executeUpdate();
  }

  rs.close();
  ps.close();
  ps2.close();
}
else if( function.equals( "aliasadd" ) && choiceId != -1 && !aliasValue.equals( "" ) )
{
  ps = conn.prepareStatement( addAliasSql );
  ps.setInt(    1, choiceId );
  ps.setString( 2, aliasValue );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "aliasdel" ) && objMetaChoiceAliasId != -1 )
{
  ps = conn.prepareStatement( deleteAliasSql );
  ps.setInt( 1, objMetaChoiceAliasId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "quickadd" ) && groupId != -1 )
{
  String[] choiceValues = StringUtils.split( StringUtils.nullString( request.getParameter( "choiceValues" ) ), "\r?\n" );
  ps = conn.prepareStatement( addChoiceSql );
  ps.setInt( 1, groupId );

  formOrder = maxFormOrder + 1;

  for( int i = 0 ; i < choiceValues.length ; i++ )
  {
    String choice = StringUtils.nullString( choiceValues[i] ).trim();

    if( !choice.equals( "" ) )
    {
      ps.setString( 2, choice );
      ps.setInt(    3, formOrder );
      ps.setInt(    4, minUserLevel );
      ps.executeUpdate();
      formOrder++;
    }
  }

  ps.close();
}
else if( function.equals( "add" ) && !choiceValue.equals( "" ) && choiceId == -1 )
{
  formOrder = maxFormOrder + 1;

  ps = conn.prepareStatement( getChoiceIdSql );
  ps.setInt(    1, groupId );
  ps.setString( 2, choiceValue );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    errorDesc = "alreadyexists";
  }

  rs.close();
  ps.close();

  if( errorDesc.equals( "" ) )
  {
    ps = conn.prepareStatement( addChoiceSql );
    ps.setInt(    1, groupId );
    ps.setString( 2, choiceValue );
    ps.setInt(    3, formOrder );
    ps.setInt(    4, minUserLevel );
    ps.executeUpdate();
    ps.close();

    ps = conn.prepareStatement( getChoiceIdSql );
    ps.setInt(    1, groupId );
    ps.setString( 2, choiceValue );
    rs = ps.executeQuery();

    if( rs.next() )
    {
      choiceId = rs.getInt( "objMetaChoiceId" );
    }

    rs.close();
    ps.close();

    if( imageNumber != -1 && !( (UploadUtils)request ).isFileMissing( imageNumber ) )
    {
      try
      {
        File   imageFile = new File( ( (UploadUtils)request ).saveFile( imageNumber, imageSavePath, String.valueOf( choiceId ) ) );
        String imageName = imageFile.getName();
        ps = conn.prepareStatement( setChoiceImageSql );
        ps.setString( 1, imageName );
        ps.setInt(    2, choiceId );
        ps.executeUpdate();
        ps.close();
      }
      catch( FileNotFoundException fe )
      {
        System.out.println( "extSell: admin: choiceDatabase: FileNotFoundException: " + fe );
      }
      catch( IOException ie )
      {
        System.out.println( "extSell: admin: choiceDatabase: IOException: " + ie );
      }
    }
  }
}
else if( function.equals( "edit" ) && !choiceValue.equals( "" ) && choiceId != -1 )
{
  ps = conn.prepareStatement( editChoiceSql );
  ps.setString( 1, choiceValue );
  ps.setInt(    2, minUserLevel );
  ps.setInt(    3, choiceId );
  ps.executeUpdate();
  ps.close();

  if( imageNumber != -1 && !( (UploadUtils)request ).isFileMissing( imageNumber ) )
  {
    try
    {
      File   imageFile = new File( ( (UploadUtils)request ).saveFile( imageNumber, imageSavePath, String.valueOf( choiceId ) ) );
      String imageName = imageFile.getName();
      ps = conn.prepareStatement( setChoiceImageSql );
      ps.setString( 1, imageName );
      ps.setInt(    2, choiceId );
      ps.executeUpdate();
      ps.close();
    }
    catch( FileNotFoundException fe )
    {
      System.out.println( "extSell: admin: choiceDatabase: FileNotFoundException: " + fe );
    }
    catch( IOException ie )
    {
      System.out.println( "extSell: admin: choiceDatabase: IOException: " + ie );
    }
  }
}
else if( function.equals( "bot" ) && choiceId != -1 && formOrder != -1 && formOrder < maxFormOrder )
{
  ps = conn.prepareStatement( decFormOrderSql );
  ps.setInt( 1, groupId );
  ps.setInt( 2, formOrder );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setFormOrderByIdSql );
  ps.setInt( 1, maxFormOrder );
  ps.setInt( 2, choiceId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "inc" ) && choiceId != -1 && formOrder != -1 && formOrder < maxFormOrder )
{
  ps = conn.prepareStatement( setFormOrderSql );
  ps.setInt( 1, formOrder );
  ps.setInt( 2, groupId );
  ps.setInt( 3, formOrder + 1 );
  ps.executeUpdate();
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setFormOrderByIdSql );
  ps.setInt( 1, formOrder + 1 );
  ps.setInt( 2, choiceId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "dec" ) && choiceId != -1 && formOrder > 1 )
{
  ps = conn.prepareStatement( setFormOrderSql );
  ps.setInt( 1, formOrder );
  ps.setInt( 2, groupId );
  ps.setInt( 3, formOrder - 1 );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setFormOrderByIdSql );
  ps.setInt( 1, formOrder - 1 );
  ps.setInt( 2, choiceId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "top" ) && choiceId != -1 && formOrder > 1 )
{
  ps = conn.prepareStatement( incFormOrderSql );
  ps.setInt( 1, groupId );
  ps.setInt( 2, formOrder );
  ps.executeUpdate();
  ps.close();

  ps = conn.prepareStatement( setFormOrderByIdSql );
  ps.setInt( 1, 1 );
  ps.setInt( 2, choiceId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "delete" ) && choiceId != -1 )
{
  String choiceImage = "";

  ps = conn.prepareStatement( getChoiceImageSql );
  ps.setInt( 1, choiceId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    choiceImage = StringUtils.nullString( rs.getString( "choiceImage" ) );
  }

  rs.close();
  ps.close();

  if( !choiceImage.equals( "" ) )
  {
    FileUtils.deleteFile( imageSavePath + "/" + choiceImage );
  }

  ps = conn.prepareStatement( deleteChoiceSql );
  ps.setInt( 1, choiceId );
  ps.executeUpdate();
  ps.close();
}
else if( function.equals( "delimg" ) && choiceId != -1 )
{
  String choiceImage = "";

  ps = conn.prepareStatement( getChoiceImageSql );
  ps.setInt( 1, choiceId );
  rs = ps.executeQuery();

  if( rs.next() )
  {
    choiceImage = StringUtils.nullString( rs.getString( "choiceImage" ) );
  }

  rs.close();
  ps.close();

  if( !choiceImage.equals( "" ) )
  {
    FileUtils.deleteFile( imageSavePath + "/" + choiceImage );
  }

  ps = conn.prepareStatement( setChoiceImageSql );
  ps.setNull( 1, Types.VARCHAR );
  ps.setInt(  2, choiceId );
  ps.executeUpdate();
  ps.close();
}

if( errorDesc.equals( "" ) )
{
  if( function.equals( "aliasadd" ) || function.equals( "aliasdel" ) )
  {
    response.sendRedirect( "choiceEditForm.jsp?groupId=" + groupId + "&choiceId=" + choiceId + "&typeId=" + typeId );
  }
  else
  {
    response.sendRedirect( "choiceList.jsp?groupId=" + groupId + "&typeId=" + typeId );
  }
}
else
{
  response.sendRedirect( "choiceEditForm.jsp?errorDesc=" + errorDesc + "&groupId="  + groupId + "&choiceValue=" + choiceValue + "&typeId=" + typeId );
}

%>