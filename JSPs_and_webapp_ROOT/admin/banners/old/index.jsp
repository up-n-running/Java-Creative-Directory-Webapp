<%@ page language="java"
         import="java.util.*,
                 java.text.SimpleDateFormat,
                 com.extware.extsite.banners.BannerType,
                 com.extware.extsite.banners.Banner,
                 com.extware.extsite.Asset,
                 com.extware.extsite.AssetTypePostProcess,
                 com.extware.image.ImageProcessor,
                 com.extware.user.User,
                 com.extware.user.UserLevel,
                 com.extware.utils.*,
                 java.sql.Connection"
%><%

  PropertyFile dataDictionary = PropertyFile.getDataDictionary();

  if(request!=null && request.getContentType()!=null && request.getContentType().toLowerCase().indexOf("multipart/form-data") == 0)
  {
    request = new UploadUtils(getServletConfig(), request, response);
  }

  User user = User.getUser(request,response);
  if ( user==null || user.userLevel<dataDictionary.getInt("userlevel.admin") )
  {
%><jsp:forward page="/admin/html/user/login.jsp" /><%
  }

  String mode = StringUtils.nullReplace( request.getParameter("mode"), "view" );
  int bannerTypeId = NumberUtils.parseInt( request.getParameter("bannerTypeId"), -1 );

  SimpleDateFormat format = new SimpleDateFormat ( "yyMMddHHmmss" );

  String redirect = "type";

  try
  {
    Connection conn = DatabaseUtils.getDatabaseConnection();

    if ( bannerTypeId > 0 )
    {
      BannerType bt = BannerType.getBannerType( conn, bannerTypeId );
      request.setAttribute("bannerType", bt);
      ArrayList pps = new AssetTypePostProcess().getAssetTypePostProcesses( bt.assetTypeId );
      request.setAttribute("postProcesses",pps);

      if ( bt!=null )
      {

        redirect = "list";

        if ( request.getParameter("bannerId")!=null && mode.equals("save") )
        {
          int bannerId = NumberUtils.parseInt(request.getParameter("bannerId"),-1);
          String root = getServletContext().getRealPath("/");
          int imgNumber = ((UploadUtils)(request)).getFileNumber("asset");
          String fname = "banner";
          String fext = "";
          String uploadDir = root + dataDictionary.getString("banner.directory."+bannerTypeId);
          String tempDir = root + dataDictionary.getString("banner.directory.temp");
          Date live = DateUtils.parseParamDate( request, "live" );
          Date remove = DateUtils.parseParamDate( request, "remove" );
          Banner upload = Banner.getBanner( conn, bannerTypeId, NumberUtils.parseInt(request.getParameter("bannerId"),-1) );
          if ( upload==null || upload.id!=bannerId )
          {
            upload = new Banner( bannerId,
                                 bannerTypeId, "", "", 0, 0, -1, live, remove );
          }
          upload.bannerTypeId = bannerTypeId;
          upload.name = request.getParameter("name");
          upload.url = request.getParameter("url");
          upload.live = live;
          upload.remove = remove;
          upload.save( conn );

          if ( !( (UploadUtils)request ).isFileMissing(imgNumber) )
          {
            fext = ((UploadUtils)(request)).getFileExt(imgNumber);
            fname = bt.name.toLowerCase() + "_" + upload.id ;
            if( !FileUtils.fileExists( uploadDir ) )
            {
              java.io.File tempDirectory = new java.io.File( uploadDir );
              tempDirectory.mkdirs();
            }
            ((UploadUtils)(request)).saveFile(imgNumber, uploadDir, fname );

            Asset asset = new Asset( bt.assetTypeId, fname, -1, fext, upload.name );
            asset.setRow();
          /*
          ImageProcessor.process( uploadDir, tempDir, asset, asset.postProcesses, true, new TreeMap(), root+dataDictionary.getString("banner.logFile"), fname );
          */
            upload.assetId = asset.fileId;
            upload.save( conn );
          }
          redirect = "list";
        }
        else
        if ( request.getParameter("bannerId")!=null && mode.equals("delete") )
        {
          int bannerId = NumberUtils.parseInt(request.getParameter("bannerId"),-1);
          Banner.delete( conn, bannerId );
          redirect = "list" ;
        }
        else
        if ( request.getParameter("bannerId")!=null )
        {
           Banner banner = Banner.getBanner( conn, bannerTypeId, NumberUtils.parseInt(request.getParameter("bannerId"),-1) );
           request.setAttribute("banner", banner);
           redirect = "edit";
        }

        if ( redirect.equals("list") )
        {
          ArrayList banners = Banner.getBanners( conn, bt.id );
          request.setAttribute("banners", banners);
          redirect = "list";
        }
      }
    }

    if ( redirect.equals("type") )
    {
      ArrayList bannerTypes = BannerType.getBannerTypes( conn );
      request.setAttribute("bannerTypes", bannerTypes);
    }

    conn.close();
  }
  catch( Exception ex )
  {
    System.out.println( ex );
    ex.printStackTrace();
    %><jsp:forward page="/admin/html/errors/index.jsp" /><%
  }

  redirect += ".jsp";

%>
%><jsp:forward page="<%= redirect %>" />