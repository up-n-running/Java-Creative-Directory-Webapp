<%@ page language="Java"
  import="com.extware.asset.Asset,
          com.extware.asset.AssetIcon,
          com.extware.extsite.lists.ListItem,
          com.extware.extsite.lists.ListType,
          com.extware.extsite.lists.ListItemFile,
          com.extware.user.UserDetails,
          com.extware.utils.StringUtils,
          com.extware.utils.NumberUtils,
          java.text.SimpleDateFormat"
%><%

UserDetails user = UserDetails.getUser( session );

String listHandle = StringUtils.nullString( request.getParameter( "l" ) );
ListType listType = ListType.getListType( listHandle );

if( !listType.isVisibleTo( user ) )
{
  return;
}

int listItemId    = NumberUtils.parseInt( request.getParameter( "i" ), -1 );
ListItem listItem = ListItem.getListItem( listItemId );
SimpleDateFormat dateFormat = new SimpleDateFormat( "dd/MMM/yyyy" );
ListItemFile primaryImage = listItem.getFile( listType.defaultAssetTypeName );
int firstFile = ( ( primaryImage == null ) ? 0 : 1 );

%>
<h1>News: <%= listItem.title %></h1>
<table border="0" cellpadding="0" cellspacing="0" width="100%">
<tr>
  <td><h4>Location:</h4></td><td width="100%"><h4>&nbsp;<%= listItem.standfirst %></h4></td>
</tr>
<tr>
  <td><h4>Date:</h4></td><td><h4>&nbsp;<%= dateFormat.format( listItem.fromDate ) + ( ( listItem.toDate != null && !listItem.toDate.equals( listItem.fromDate ) ) ? " - " + dateFormat.format( listItem.toDate ) : "" ) %></h4></td>
</tr>
</table>
<%= ( ( primaryImage != null && primaryImage.asset != null ) ? "<img src=\"" + primaryImage.getImagePath( "Full Size" ) + "\" class=\"image\" onclick=\"return showImage('" + primaryImage.getFilePath() + "'," + primaryImage.asset.assetWidth + "," + primaryImage.asset.assetHeight + ",'" + primaryImage.title + "')\" title=\"" + primaryImage.title + " (click for larger view)\" />" : "" ) %>
<p><%= listItem.body %></p>
<table border="0" cellpadding="0" cellspacing="0"><tr><td nowrap="nowrap"><h6 class="burgundyh6" style="text-align: left;"><a target="_parent" onclick="window.history.go( -1 ); return false;" href="/index.jsp">Back</a></h6></td><td width="100%"></td></tr></table>