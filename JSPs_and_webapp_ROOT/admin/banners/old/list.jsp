<%@ page language="java"
         import="java.util.ArrayList,
                 java.util.Date,
                 java.text.SimpleDateFormat,
                 com.extware.extsite.banners.BannerType,
                 com.extware.extsite.banners.Banner,
                 com.extware.extsite.AssetTypePostProcess,
                 com.extware.user.User,
                 com.extware.user.UserLevel,
                 com.extware.utils.*,
                 java.sql.Connection"
%><%@ include file="/admin/html/inc/template.jsp" %><%

  PropertyFile dataDictionary = PropertyFile.getDataDictionary();

  BannerType bt = (BannerType)request.getAttribute("bannerType");
  ArrayList banners = (ArrayList)request.getAttribute("banners");
  ArrayList pps = (ArrayList)request.getAttribute("postProcesses");

%>
  <div class="title"><%= bt.name %> admin</div>
  <br />
  <a href="./?bannerTypeId=<%= bt.id %>&bannerId=0">Add new <%= bt.name %></a><br />
  <br />
  <table cellspacing="0">
<%
  SimpleDateFormat format = new SimpleDateFormat("dd MMM yyyy");

  String root = getServletContext().getRealPath("/");
  String dir = dataDictionary.getString("banner.directory."+bt.id);
  for ( int i=0; banners!=null && i<banners.size(); i++ )
  {
    if ( i==0 )
    {
%>
  <tr>
    <td class="th">&nbsp;</td>
    <td class="th">Banner</td>
    <td class="th">Clicks</td>
    <td class="th">Live</td>
    <td class="th">Remove</td>
    <td class="th">&nbsp;</td>
    <td class="th">&nbsp;</td>
    <td class="th">&nbsp;</td>
  </tr>
<%
    }
    Banner banner = (Banner)banners.get(i);
    boolean live = ( banner.live==null || banner.live.before(new Date()) ) && ( banner.remove==null || banner.remove.after(new Date()) );
%>
  <tr>
    <td class="datarow"><img src="/admin/html/art/visible<%= live ? "t" : "f" %>.gif" border="0" /></td>
    <td class="datarow"><%= banner.name %></td>
    <td class="datarow"><%= banner.clicked %></td>
    <td class="datarow"><%= banner.live!=null ? format.format(banner.live) : "none" %></td>
    <td class="datarow"><%= banner.remove!=null ? format.format(banner.remove) : "none" %></td>
    <td class="datarow"><a href="./?bannerTypeId=<%= bt.id %>&bannerId=<%= banner.id %>">edit</a></td>
    <td class="datarow"><a href="./?bannerTypeId=<%= bt.id %>&bannerId=<%= banner.id %>&mode=delete" onclick="return confirm('Delete this <%= bt.name %>?');">delete</a></td>
    <td class="datarow"><a href="/html/banners/?bannerId=<%= banner.id %>" target="_mcvclick">click</a></td>
  </tr>
<%
  }
%>
  </table>