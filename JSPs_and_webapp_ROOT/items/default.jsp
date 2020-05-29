<%@ page language="Java"
  import="com.extware.asset.Asset,
          com.extware.asset.AssetIcon,
          com.extware.extsite.lists.ListItem,
          com.extware.extsite.lists.ListType,
          com.extware.extsite.lists.ListItemFile,
          com.extware.user.UserDetails,
          java.text.SimpleDateFormat"
%><%

UserDetails user = UserDetails.getUser( session );

ListItem listItem = (ListItem)request.getAttribute( "listItem" );
ListType listType = (ListType)request.getAttribute( "listType" );

if( !listType.isVisibleTo( user ) )
{
  return;
}

SimpleDateFormat dateFormat = new SimpleDateFormat( "dd/MMM/yyyy" );

ListItemFile primaryImage = listItem.getFile( listType.defaultAssetTypeName );

int firstFile = ( ( primaryImage == null ) ? 0 : 1 );

%><table class="<%= listType.listHandle %>" border="0" cellpadding="0" cellspacing="0">
<tr>
  <td class="item"><%= ( ( primaryImage != null && primaryImage.asset != null ) ? "<img src=\"" + primaryImage.getImagePath( "Full Size" ) + "\" class=\"image\" onclick=\"return showImage('" + primaryImage.getFilePath() + "'," + primaryImage.asset.assetWidth + "," + primaryImage.asset.assetHeight + ",'" + primaryImage.title + "')\" title=\"" + primaryImage.title + " (click for larger view)\" />" : "" ) %>
    <p class="title"><%= listItem.title %></p>
    <p class="date"><%= dateFormat.format( listItem.fromDate ) + ( ( listItem.toDate != null && !listItem.toDate.equals( listItem.fromDate ) ) ? " - " + dateFormat.format( listItem.toDate ) : "" ) %></p>
    <p class="standfirst"><%= listItem.standfirst %></p>
    <p class="body"><%= listItem.body %></p>
    <div class="clear"></div></td>
<jsp:include page="fileBox.jsp" flush="true" >
  <jsp:param name="firstFile" value="<%= firstFile %>"/>
</jsp:include>
</tr>
</table>