begin
  gissf = addfile ("giss/climate_zg.nc","r")
  gfdlf = addfile ("gfdl/ts_zg.nc","r")
  cesmf = addfile ("cesm/US_climate_diff.nc","r")

  cesmz = cesmf->ts_z_mean
  gissz = gissf->tsurf_z_mean
  gissz = -1*gissz
  gfdlz = gfdlf->temp_z_mean

  cesmzse = cesmf->ts_z_stderr
  gisszse = gissf->tsurf_z_stderr
  gfdlzse = gfdlf->temp_z_stderr

  dsgiss=dimsizes(gissz)
  gissrange = conform_dims( (/2,dsgiss(0)/), gissz, (/1/) )
  gissrange(0,:)=gissz-gisszse
  gissrange(1,:)=gissz+gisszse

  dsgfdl=dimsizes(gfdlz)
  gfdlrange = conform_dims( (/2,dsgfdl(0)/), gfdlz, (/1/) )
  gfdlrange(0,:)=gfdlz-gfdlzse
  gfdlrange(1,:)=gfdlz+gfdlzse

  dscesm=dimsizes(cesmz)
  cesmrange = conform_dims( (/2,dscesm(0)/), cesmz, (/1/) )
  cesmrange(0,:)=cesmz-cesmzse
  cesmrange(1,:)=cesmz+cesmzse

  gisslat = gissf->lat
  gfdllat = gfdlf->lat
  cesmlat = cesmf->lat

  giss_force= -gissf->tsurf_g_mean
  gfdl_force= gfdlf->temp_g_mean
  cesm_force= cesmf->tref_g_mean

  giss_force_se= gissf->tsurf_g_stderr
  gfdl_force_se= gfdlf->temp_g_stderr
  cesm_force_se= cesmf->tref_g_stderr

  avgz = cesmz
  avgz@longname = ""
  avgz = cesmz + linint1 (gisslat,gissz, False, cesmlat, 0) + linint1 (gfdllat,gfdlz, False, cesmlat, 0)
  avgz = avgz/3.0

  gissrange@longname = ""
  cesmrange@longname = ""
  gfdlrange@longname = ""
  avgz@longname = ""

  gissrangeL="GISS "+sprintf("%1.3f",giss_force) +" +/- "+ sprintf("%1.3f",giss_force_se) + " K"
  gfdlrangeL="GFDL "+sprintf("%1.3f",gfdl_force) +" +/- "+ sprintf("%1.3f",gfdl_force_se) + " K"
  cesmrangeL="CESM "+sprintf("%1.3f",cesm_force) +" +/- "+ sprintf("%1.3f",cesm_force_se) + " K"
  avgzrangeL="Multi-model Mean 0.07 K"

  wks  = gsn_open_wks("png","zonal_TS_diff")

  plot = new(3,graphic)
  res                            = True                ; plot mods desired

  res@gsnYRefLine           = 0.0
  res@trXMinF  = -1.                 ; min value on y-axis
  res@trXMaxF  =  1.                   ; max value on y-axis
  res@trYMinF  = -0.10                   ; min value on y-axis
  res@trYMaxF  =  0.60                  ; max value on y-axis
  res@gsnDraw = False
  res@gsnFrame= False

  res@tiYAxisString	 = "Temperature Change (K)"      ; add an axis title  
  res@tiXAxisString	 = "Latitude"      ; add an axis title  

  xlabst = (/-90, -50, -30, -15, 0, 15, 30, 50, 90/)
  xlabs = sin(3.14159/180.* (/-90, -50, -30, -15, 0, 15, 30, 50, 90/))

  res@tmXBMode                = "Explicit"
  res@tmXBLabels              = xlabst
  res@tmXBValues              = xlabs

  res@xyLineThicknessF	 = 5


;---Create the plots, but don't draw them yet

  ; zonal stderr boundaries
  res@xyLineColor     = -1         
  res@gsnXYFillColors = (/0.,0.,1.0,0.1/)
  plot0  = gsn_csm_xy(wks, sin(3.14159/180.*cesmlat), cesmrange,res)
  res@gsnXYFillColors = (/0.5,0.,0.5,0.1/)
  plot1  = gsn_csm_xy(wks, sin(3.14159/180.*gfdllat), gfdlrange,res)
  res@gsnXYFillColors = (/0.9,0.,0.,0.1/)
  plot2  = gsn_csm_xy(wks, sin(3.14159/180.*gisslat), gissrange,res)

  ; zonal average
  delete(res@gsnXYFillColors)
  delete(res@xyLineColor)
  res@xyLineColor     = "blue"
  res@xyDashPattern = 1
  plot3  = gsn_csm_xy(wks, sin(3.14159/180.*cesmlat), cesmz,res)
  res@xyLineColor     = "darkviolet"
  res@xyDashPattern = 2
  plot4  = gsn_csm_xy(wks, sin(3.14159/180.*gfdllat), gfdlz,res)
  res@xyLineColor     = "firebrick1"
  res@xyDashPattern = 3
  plot5  = gsn_csm_xy(wks, sin(3.14159/180.*gisslat), gissz,res)

  ; multi-model average
  ;res@xyLineColor     = "darkslategray"
  ;res@xyDashPattern = 0
  ;plot6  = gsn_csm_xy(wks, sin(3.14159/180.*cesmlat), avgz,res)

  overlay(plot0,plot1)
  overlay(plot0,plot2)
  overlay(plot0,plot3)
  overlay(plot0,plot4)
  overlay(plot0,plot5)
  ;overlay(plot0,plot6)

;*****************************************************   
; Manually create and attach legend
;***************************************************** 

  res_text                    = True                  ; text mods desired
  res_text@txFontHeightF      = 0.015                 ; change text size
  res_text@txJust             = "CenterLeft"          ; text justification

  res_lines                   = True                  ; polyline mods desired
  res_lines@gsLineThicknessF  = 5.                    ; line thicker

  xx = (/-0.1,0.1/)

  yy = (/0.55, 0.55 /)
  res_lines@gsLineColor     = "blue"
  res_lines@gsLineDashPattern = 1.                    ; solid line
  dum1 = gsn_add_polyline(wks,plot0,xx,yy,res_lines)              ; add polyline
  dum2 = gsn_add_text(wks,plot0,cesmrangeL,-0.9,0.55,res_text); add text
  
  yy = (/0.5,0.5/)
  res_lines@gsLineDashPattern = 2.           
  res_lines@gsLineColor       = "darkviolet"                 ; line color
  dum3 = gsn_add_polyline(wks,plot0,xx,yy,res_lines)                ; add polyline
  dum4 = gsn_add_text(wks,plot0,gfdlrangeL,-0.9,0.5,res_text)       ; add text
  
  yy = (/0.45,0.45/)
  res_lines@gsLineDashPattern = 3.                    ; solid line
  res_lines@gsLineColor       = "firebrick1"                 ; line color
  dum5 = gsn_add_polyline(wks,plot0,xx,yy,res_lines)                ; add polyline
  dum6 = gsn_add_text(wks,plot0,gissrangeL,-0.9,0.45,res_text) ; add text

  ;yy = (/0.4,0.4/)
  ;res_lines@gsLineDashPattern = 0.                    ; solid line
  ;res_lines@gsLineColor       = "darkslategray"                 ; line color
  ;dum7 = gsn_add_polyline(wks,plot0,xx,yy,res_lines)                ; add polyline
  ;dum8 = gsn_add_text(wks,plot0,avgzrangeL,-0.9,0.4,res_text) ; add text

  res_text               = True
  res_text@txFontHeightF = 0.025                       ; change font size
  txid_top = gsn_create_text(wks, "Zonal Surface Temperature Change", res_text)

  amres                  = True
  amres@amJust           = "BottomCenter"
  amres@amParallelPosF   =  0.0    ; This is the center of the plot.
  amres@amOrthogonalPosF = -0.55   ; This is above the top edge of the plot.
  annoid_top = gsn_add_annotation(plot0, txid_top, amres)


  pres = True
  maximize_output(wks,pres)

end


