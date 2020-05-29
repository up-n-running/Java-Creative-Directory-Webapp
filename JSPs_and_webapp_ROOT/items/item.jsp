<%@ page language="java"
  import="com.extware.extsite.lists.ListItem,
          com.extware.extsite.lists.ListType,
          com.extware.utils.FileUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.SiteUtils,
          java.util.ArrayList"
%><%

int listItemId = NumberUtils.parseInt( request.getParameter( "i" ), -1 );

ListItem listItem = ListItem.getListItem( listItemId );

if( listItem != null )
{
  ListType listType = ListType.getListType( listItem.listTypeId );
  listItem.files = listItem.getListItemFiles();

  request.setAttribute( "listItem", listItem );
  request.setAttribute( "listType", listType );

  String itemPage = listType.listHandle + ".jsp";

  if( !FileUtils.fileExists( SiteUtils.getWebappRoot() + "/items/" + itemPage ) )
  {
    itemPage = "default.jsp";
  }

%><jsp:include page="<%= itemPage %>" flush="true" /><%

}
else
{
  out.print( "Null List Item" );
}

%>