<%@ page language="java"
  import="com.extware.utils.PropertyFile,
          com.extware.utils.StringUtils,
          com.extware.utils.BooleanUtils"
%><%
PropertyFile richTextProps = new PropertyFile( "com.extware.properties.RichText" );
String[] tags = StringUtils.split( StringUtils.nullString( richTextProps.getString( "styleTagList" ) ), "\\|" );
String commaSepOptionList = "";
for( int i=0; i<tags.length; i++ )
{
  commaSepOptionList += (i==0?"":", ") + "'<option value=\"<" + tags[i] + ">\">" + richTextProps.getString( "styleName." + tags[i] ) + "</option>'";
}
%>
var formatDropDownSelectHtmlList = new Array( <%= commaSepOptionList %> );

var btn_insertHyperlink = <%= StringUtils.nullReplace( richTextProps.getString( "insertHyperlink" ), "false" ) %>;
var btn_cutCopyAndPaste = <%= StringUtils.nullReplace( richTextProps.getString( "cutCopyAndPaste" ), "false" ) %>;
var btn_textAlignAndJustify = <%= StringUtils.nullReplace( richTextProps.getString( "textAlignAndJustify" ), "false" ) %>;
var btn_undoAndRedo = <%= StringUtils.nullReplace( richTextProps.getString( "undoAndRedo" ), "false" ) %>;
var btn_spellCheck = <%= StringUtils.nullReplace( richTextProps.getString( "spellCheck" ), "false" ) %>;

var allowAccessToHTMLEvenWhenNotUltra = <%= StringUtils.nullReplace( richTextProps.getString( "allowAccessToHTMLEvenWhenNotUltra" ), "false" ) %>;
