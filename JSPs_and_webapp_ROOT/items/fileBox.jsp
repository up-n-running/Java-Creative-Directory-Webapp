<%@ page language="Java"
  import="com.extware.asset.Asset,
          com.extware.asset.AssetIcon,
          com.extware.extsite.lists.ListItem,
          com.extware.extsite.lists.ListItemFile,
          com.extware.utils.NumberUtils,
          java.text.SimpleDateFormat"
%><%

ListItem listItem = (ListItem)request.getAttribute( "listItem" );

int firstFile = NumberUtils.parseInt( request.getParameter( "firstFile" ), 0 );

%><%

if( listItem.files.size() > firstFile )
{

%>  <td class="files">
<%

  int lastFileType = -1;

  String lastAssetTypeName = "";

  for( int i = firstFile ; i < listItem.files.size() ; i++ )
  {
    ListItemFile file = (ListItemFile)listItem.files.get( i );

    if( file.fileType != lastFileType )
    {

%>    <p class="fileHead"><%= ( ( file.fileType == 1 ) ? "More Images" : "Related Files" ) %></p>
<%

      lastFileType = file.fileType;
    }

    if( !file.assetTypeName.equals( lastAssetTypeName ) )
    {

%>    <p class="fileSubHead"><%= file.assetTypeName %></p>
<%

      lastAssetTypeName = file.assetTypeName;
    }

    if( file.fileType == 1 )
    {

%>    <img src="<%= file.getImagePath( "Thumbnail" ) %>" onclick="return showImage('<%= file.getFilePath() %>',<%= file.asset.assetWidth %>,<%= file.asset.assetHeight %>,'<%= file.title %>')" title="<%= file.title %> (click for larger view)" />
<%

    }
    else
    {

%>    <img src="<%= new AssetIcon( file.getFilePath() ).getSmallIconImageRef() %>" border="0" /> <a href="<%= file.getFilePath() %>"><%= file.title %></a>
<%

    }
  }

%></td>
<%

}

%>