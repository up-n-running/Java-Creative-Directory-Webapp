<%@ page language="java"
  import="com.extware.extsite.lists.ListType,
          com.extware.extsite.lists.ListItem,
          com.extware.user.UserDetails,
          com.extware.utils.BooleanUtils,
          com.extware.utils.NumberUtils,
          com.extware.utils.StringUtils,
          java.util.ArrayList,
          java.text.SimpleDateFormat"
%><%

UserDetails user = UserDetails.getUser( session );

String listHandle = StringUtils.nullString( request.getParameter( "l" ) );
ListType listType = ListType.getListType( listHandle );

if( !listType.isVisibleTo( user ) )
{
  return;
}

ArrayList listItems = listType.getListItems();

boolean showView = BooleanUtils.parseBoolean( request.getParameter( "showView" ) );

int maxItems = NumberUtils.parseInt( request.getParameter( "maxItems" ), listItems.size() );

String siteSpec = StringUtils.padRight( StringUtils.nullString( request.getParameter( "s" ) ), 4, '1' );

SimpleDateFormat dateFormat = new SimpleDateFormat( "dd/MMM/yyyy" );

%><table width="146" border="0" cellpadding="0" cellspacing="0">
<%

for( int i = 0 ; i < listItems.size() && i < maxItems ; i++ )
{
  ListItem item = (ListItem)listItems.get( i );

%><tr>
  <td><table border="0" cellpadding="0" cellspacing="0" width="100%">
    <tr>
      <td colspan="2" class="newsTitle" width="100%"><%= item.title %>: <%= item.standfirst %></td>
    </tr>
    <tr>
      <td class="newsDate"><%= ( ( item.toDate != null && !item.toDate.equals( item.fromDate ) ) ? "starts" : "date" ) %>:</td>
      <td class="newsDate"><%= dateFormat.format( item.fromDate ) %></td>
<%

  if( item.toDate != null && !item.toDate.equals( item.fromDate ) )
  {

%>    </tr>
    <tr>
      <td class="newsDate">ends:</td>
      <td class="newsDate"><%= dateFormat.format( item.toDate ) %></td>
    </tr>
<%

  }

%>    <tr>
      <td colspan="2" class="newsMore"><a href="/pages/list.jsp?l=news&i=<%= item.listItemId %>" onmouseover="newsStop();" onmouseout="newsNormal()">more</td>
    </tr>
  </table></td>
</tr>
<%

}

if( listItems.size() == 0 )
{

%><tr>
  <td>No <%= listType.listName %> today</td>
</tr>
<%

}

if( showView )
{

%><tr>
  <td class="view"><a href="/?l=<%= listType.listHandle %>&s=<%= siteSpec %>">View the <%= listType.listName %> page</a></td>
</tr>
<%

}

%></table>