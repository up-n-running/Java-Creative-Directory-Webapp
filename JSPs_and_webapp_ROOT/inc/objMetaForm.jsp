<%@ page language="java"
  import="com.extware.common.MetaData,
          com.extware.common.MetaObject,
          com.extware.utils.BooleanUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          java.sql.Connection,
          java.sql.PreparedStatement,
          java.sql.ResultSet,
          java.sql.SQLException"
%><%

String selectObjectAliasesSql = "SELECT objAlias FROM metaObjectAliases WHERE metaObjectId=?";
String selectClauseSql = "SELECT m.formOrder, m.objMetaTypeId, m.typeName, m.groupType, c.objMetaChoiceId, c.choiceValue, c.formOrder";
String dataSelectSql   = ", dt.data, dc.choiceId, b.bigTextValue";
String fromClauseSql   = " FROM objMetaTypes m LEFT OUTER JOIN objMetaChoices c ON (m.metaGroupId = c.groupId)";
String dataTableSql    = " LEFT OUTER JOIN objMetaData dt ON (m.objMetaTypeId = dt.metaTypeId AND dt.data IS NOT NULL AND dt.metaObjectId=?) " +
                         " LEFT OUTER JOIN objMetaData dc ON (c.objMetaChoiceId = dc.choiceId AND dc.metaObjectId=? ) " +
                         " LEFT OUTER JOIN objMetaData db ON (m.objMetaTypeId = db.metaTypeId AND db.bigTextId IS NOT NULL AND db.metaObjectId=?) " +
                         " LEFT OUTER JOIN objMetaBigTexts b ON (db.bigTextId = b.objMetaBigTextId )";
String whereClauseSql  = " WHERE m.objTypeId=?";
String defaultPageSql  = " AND m.objMetaPageId IS NULL";
String pageIdSql       = " AND m.objMetaPageId=?";
//String dataWhereSql    = " AND (dt.metaObjectId=? OR dt.metaObjectId IS NULL) AND (dc.metaObjectId=? OR dc.metaObjectId IS NULL) AND (db.metaObjectId=? OR db.metaObjectId IS NULL)";
String orderResultsSql = " ORDER BY m.formOrder, c.formOrder";

boolean allowAliases          = BooleanUtils.parseBoolean( request.getParameter( "allowAliases" ) );
boolean showCheckboxes        = BooleanUtils.parseBoolean( request.getParameter( "showCheckboxes" ) );
boolean limitMultiesToSingles = BooleanUtils.parseBoolean( request.getAttribute( "noMultiValues" ) );

int oldMetaTypeId = 0;
int objTypeId     = NumberUtils.parseInt( request.getParameter( "objTypeId" ), -1 );
int objectId      = NumberUtils.parseInt( request.getParameter( "objectId" ),  -1 );
int pageId        = NumberUtils.parseInt( request.getParameter( "pageId" ),    -1 );

int globalMetaTypeId = -1;

String oldGroupType = "";
String sql          = selectClauseSql + ( ( objectId != -1 ) ? dataSelectSql : "" ) +
                      fromClauseSql   + ( ( objectId != -1 ) ? dataTableSql : "" ) +
                      whereClauseSql  + ( ( pageId != -1 ) ? pageIdSql : defaultPageSql )  +
                                        /*( ( objectId != -1 ) ? dataWhereSql : "" ) + */
                      orderResultsSql;
String requestObj   = StringUtils.nullString( request.getParameter( "requestObj" ) );

MetaData   metaData = null;
MetaObject obj      = null;

if( !requestObj.equals( "" ) )
{
  obj = (MetaObject)request.getAttribute( requestObj );
}

Connection conn = (Connection)request.getAttribute( "conn" );

PreparedStatement ps = conn.prepareStatement( sql );
ResultSet rs = null;

int column = 1;

if( objectId != -1 )
{
  ps.setInt( column++, objectId );
  ps.setInt( column++, objectId );
  ps.setInt( column++, objectId );
}

ps.setInt( column++, objTypeId );

if( pageId != -1 )
{
  ps.setInt( column++, pageId );
}


try
{
  rs = ps.executeQuery();
}
catch( SQLException ex )
{

%><%= ex.toString() + " : " + sql %><%

  return;
}

while( rs.next() )
{
  int    choiceId     = -1;
  String data         = "";
  String bigTextValue = "";

  int    metaTypeId = rs.getInt( "objMetaTypeId" );
  String groupType  = StringUtils.nullString( rs.getString( "groupType" ) );
  String typeName   = rs.getString( "typeName" );

  if( objectId != -1 )
  {
    choiceId     = NumberUtils.parseInt( rs.getString( "choiceId" ), -1 );
    data         = StringUtils.nullString( rs.getString( "data" ) );
    bigTextValue = StringUtils.nullString( rs.getString( "bigTextValue" ) );

    if( !bigTextValue.equals( "" ) )
    {
      data = bigTextValue;
    }
  }
  else
  {
    if( obj != null )
    {
      metaData = obj.getMeta( typeName );

      if( metaData == null )
      {
        metaData = obj.getMeta( String.valueOf( metaTypeId ) );
      }

      if( metaData != null )
      {
        if( metaData.metaChoiceIds != null && metaData.metaChoiceIds.length > 0 )
        {
          choiceId = metaData.metaChoiceIds[0];
        }
        else
        {
          choiceId = -1;
        }

        if( metaData.metaValues != null && metaData.metaValues.length > 0 )
        {
          data         = metaData.metaValues[0];
          bigTextValue = metaData.metaValues[0];
        }
        else
        {
          data         = "";
          bigTextValue = "";
        }
      }
    }
    else
    {
      choiceId     = -1;
      data         = "";
      bigTextValue = "";
    }
  }

  if( metaTypeId != oldMetaTypeId )
  {
    if( oldMetaTypeId != 0 )
    {
      if( oldGroupType.equals( "S" ) || oldGroupType.equals( "M" ) )
      {
        out.print( "    </select>" );
      }

%></td>
<%= ( ( showCheckboxes ) ? "<td><input type=\"checkbox\" name=\"metaViewList\" value=\"" + globalMetaTypeId + "\" /></td>" : "" ) %>
</tr>
<%

    }

%>
<tr>
  <td class="formlabel"><%= typeName %></td>
  <td><%

    oldMetaTypeId = metaTypeId;
    oldGroupType  = groupType;

    if( groupType.equals( "S" ) || groupType.equals( "M" ) )
    {

%><select name="meta_<%= metaTypeId %>"<%= ( ( groupType.equals( "M" ) && ( !limitMultiesToSingles || showCheckboxes ) ) ? " size=\"5\" multiple=\"multiple\"" : "" ) %>>
      <option value=""></option>
<%

    }
  }

  if( groupType.equals( "T" ) || groupType.equals( "" ) )
  {

%><input type="text" name="meta_<%= metaTypeId %>" value="<%= data %>" /><%

  }
  else if( groupType.equals( "L" ) )
  {

%><textarea name="meta_<%= metaTypeId %>" cols="40" rows="5"><%= data %></textarea><%

  }
  else
  {
    int    objMetaChoiceId = rs.getInt(    "objMetaChoiceId" );
    String choiceValue     = rs.getString( "choiceValue" );

    if( true ) //choiceId == -1 || objMetaChoiceId == choiceId )
    {
      if( groupType.equals( "S" ) || groupType.equals( "M" ) )
      {

%>      <option value="<%= objMetaChoiceId %>"<%= ( ( objMetaChoiceId == choiceId ) ? " selected=\"selected\"" : "" ) %>><%= choiceValue %></option>
<%

      }
      else if( groupType.equals( "R" ) || groupType.equals( "C" ) )
      {

%>      <input type="<%= ( ( ( groupType.equals( "R" ) || limitMultiesToSingles ) && !showCheckboxes) ? "radio" : "checkbox" ) %>" name="meta_<%= metaTypeId %>" value="<%= objMetaChoiceId %>"<%= ( ( objMetaChoiceId == choiceId ) ? " checked=\"checked\"" : "" ) %> /><%= choiceValue %><br />
<%

      }
    }
  }

  globalMetaTypeId = metaTypeId;
}

rs.close();
ps.close();

%></td>
<%= (showCheckboxes)?"<td><input type=\"checkbox\" name=\"metaViewList\" value=\"" + globalMetaTypeId + "\" /><td/>":"" %>
</tr>
<%

if( allowAliases )
{

%>
<script type="text/javascript">
function add( theForm )
{
  if( theForm.alias.value != "" )
  {
    var o = new Option( theForm.alias.value );
    theForm.aliases.options[theForm.aliases.options.length] = o;
    theForm.aliases.selectedIndex = theForm.aliases.options.length - 1;
  }
}
function edit( theForm )
{
  if( theForm.aliases.selectedIndex != -1 && theForm.alias.value != "" )
  {
    theForm.aliases.options[theForm.aliases.selectedIndex].text = theForm.alias.value;
  }
}
function del( theForm )
{
  if( theForm.aliases.selectedIndex != -1 )
  {
    var i = theForm.aliases.selectedIndex;
    theForm.aliases.options[i] = null;

    if( theForm.aliases.options.length != 0 )
    {
      theForm.aliases.selectedIndex = Math.max( i - 1, 0 );
      sel( theForm );
    }
  }
}
function sel( theForm )
{
  if( theForm.aliases.selectedIndex != -1 )
  {
    theForm.alias.value=theForm.aliases.options[theForm.aliases.selectedIndex].text;
  }
}
</script>
<tr>
  <td class="formlabel">Aliases</td>
  <td><select name="aliases" size="5" multiple="multiple" style="width: 400px" onchange="sel(this.form)">
<%

  ps = conn.prepareStatement( selectObjectAliasesSql );
  ps.setInt( 1, objectId );
  rs = ps.executeQuery();

  while( rs.next() )
  {

%>      <option><%= rs.getString( "objAlias" ) %></option>
<%

  }

  rs.close();
  ps.close();

%>
    </select><br />
    <input type="text" name="alias" value="" style="width: 400px" /><br />
    <input type="button" value="Add" onclick="add(this.form)" /> <input type="button" value="Edit" onclick="edit(this.form)" /> <input type="button" value="Del" onclick="del(this.form)" /></td>
</tr>
<%

}

%>