<%@ page language="java"
         import="java.util.ArrayList,
                 java.util.Date,
                 com.extware.extsite.banners.BannerType,
                 com.extware.user.User,
                 com.extware.user.UserLevel,
                 com.extware.utils.*,
                 java.sql.Connection"
%><%@ include file="/admin/html/inc/template.jsp" %><%

  ArrayList bannerTypes = (ArrayList)request.getAttribute("bannerTypes");

%>
<div class="title">Banner/button admin</div>

<%
  for ( int i=0; bannerTypes!=null && i<bannerTypes.size(); i++ )
  {
    BannerType bt = (BannerType)bannerTypes.get(i);
%>
    <a href="./?bannerTypeId=<%= bt.id %>"><%= bt.name %></a><br />
<%
  }

%>