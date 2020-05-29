<%@ page language="java"
  import="com.extware.extsite.text.TextPage,
          com.extware.utils.StringUtils"
%><%
String pageHandle = StringUtils.nullString( request.getParameter( "t" ) );
TextPage textPage = TextPage.getTextPage( pageHandle );
%><table class="<%= pageHandle %>" border="0" cellpadding="0" cellspacing="0">
<tr>
  <!-- PLEASE NOTE: the following text is generated through an administrable rich text editor within the administration suite for this site. As such, eleventeenth, the creators of this site accept no liability for it's functionality and content -->
  <td class="richtext"><%= textPage.pageContent %></td>
  <!-- END OF GENERATED CONTENT -->
</tr>
</table>