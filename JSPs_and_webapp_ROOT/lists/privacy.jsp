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
int listItemIdx = NumberUtils.parseInt( request.getParameter( "iIdx" ), 0 );
ListItem itemToShow = null;

ListType listType = ListType.getListType( listHandle );

if( !listType.isVisibleTo( user ) )
{
  return;
}

ArrayList listItems = listType.getListItems();

boolean showView = BooleanUtils.parseBoolean( request.getParameter( "showView" ) );

int maxItems = NumberUtils.parseInt( request.getParameter( "maxItems" ), listItems.size() );

//SimpleDateFormat dateFormat = new SimpleDateFormat( "dd/MMM/yyyy" );

%>
<h1>Nextface Privacy Policy</h1>
<table width="100%" border="0" cellpadding="0" cellspacing="0">
<%

for( int i = 0 ; i < listItems.size() && i < maxItems ; i++ )
{
  ListItem item = (ListItem)listItems.get( i );
  if( i == listItemIdx )
  {
    itemToShow = item;
  }
%><tr>
  <td><table cellpadding="0" cellspacing="0" width="100%"><tr><td nowrap="nowrap"><h6 class="orangeh6" style="margin-bottom: 2px"><a href="/pages/list.jsp?l=<%= listHandle %>&iIdx=<%= i %>"><%= item.title %></a></h6></td><td width="100%"></td></tr></table></td>
</tr>
<%

}
%></table><%
if( listItems.size() == 0 )
{

%><tr>
  <td>No <%= listType.listName %> today</td>
</tr>
<%

}
else
{
%>
<br />
<h4><%= itemToShow.title %></h4>
<p style="color: #000000"><%= itemToShow.body %></p>
<%
}
%>