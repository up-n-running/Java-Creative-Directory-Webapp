<%@ page language="java"
         import="java.util.ArrayList,
                 java.util.Date,
                 com.extware.extsite.banners.BannerType,
                 com.extware.extsite.banners.Banner,
                 com.extware.extsite.AssetTypePostProcess,
                 com.extware.user.User,
                 com.extware.user.UserLevel,
                 com.extware.utils.*,
                 java.sql.Connection"
%><%@ include file="/admin/html/inc/template.jsp" %><%@
      include file="/html/inc/buildTextAreaAutoResize.jsp" %><%@
      include file="/html/inc/buildDateForm.jsp" %><%

  PropertyFile dataDictionary = PropertyFile.getDataDictionary();
  BannerType bt = (BannerType)request.getAttribute("bannerType");
  Banner banner = (Banner)request.getAttribute("banner");
  if ( banner==null )
  {
    banner = new Banner( -1, bt.id, "", "", 0, 0, -1, new Date(), null );
  }
  ArrayList pps = (ArrayList)request.getAttribute("postProcesses");

%>
  <script type="text/javascript" src="/html/js/autoSize.js"></script>
  <script type="text/javascript" src="/html/js/validate.js"></script>
  <script type="text/javascript" src="/html/js/dateForm.js"></script>
  <script type="text/javascript">
    addValidate( "name", "Name", true );
    addValidate( "url", "Url", true );
    addValidate( "live", "Live date", true, "date" );
    addValidate( "remove", "Remove date", false, "date" );
  </script>

  <div class="title"><%= bt.name %> admin</div>
  <br />
  <form name="f1" method="post" action="./" enctype="multipart/form-data" onsubmit="return validate(this)">
  <input type="hidden" name="mode" value="save">
  <input type="hidden" name="bannerTypeId" value="<%= bt.id %>">
  <input type="hidden" name="bannerId" value="<%= banner.id %>">
  <table>
  <tr>
    <td class="label">Name:</td>
    <td><input type="text" name="name" value="<%= banner.name %>" size="25" maxlength="250" class="formElement" /></td>
  </tr>
  <tr>
    <td class="label">Url:</td>
    <td><input type="text" name="url" value="<%= banner.url %>" size="50" maxlength="250" class="formElement" /></td>
  </tr>
  <tr>
    <td class="label">Live date:</td>
    <td><%= buildDateForm( "f1", "live", banner.live ) %></td>
  </tr>
  <tr>
    <td class="label">Remove date:</td>
    <td><%= buildDateForm( "f1", "remove", banner.remove ) %></td>
  </tr>
  <tr>
    <td class="label">Image:</td>
    <td><input type="file" name="asset" class="formElement" /></td>
  </tr>

<%
  String root = getServletContext().getRealPath("/");
  String dir = dataDictionary.getString("banner.directory."+bt.id);
%>
  <tr>
    <td colspan="2">
<%
  if ( banner.extension!=null && banner.extension.equals("swf") )
  {
%>
        <object classid="clsid:D27CDB6E-AE6D-11cf-96B8-444553540000" codebase="http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=5,0,0,0" width="468" height="60">
        <param name=movie value="/<%= dir %>/<%= banner.filename %>.<%= banner.extension %>">
        <param name=quality value=high>
        <embed src="/<%= dir %>/<%= banner.filename %>.<%= banner.extension %>" quality=high pluginspage="http://www.macromedia.com/shockwave/download/index.cgi?P1_Prod_Version=ShockwaveFlash" type="application/x-shockwave-flash" width="468" height="60"></embed>
        </object>
<%
  }
  else
  if ( banner.extension!=null )
  {
%>
      <img src="/<%= dir %>/<%= banner.filename %>.<%= banner.extension %>">
<%
  }
%>
    </td>
  </tr>
  <tr>
    <td colspan="2">
      <input type="submit" value="update" class="formButton" />
    </td>
  </tr>
  </table>
  </form>