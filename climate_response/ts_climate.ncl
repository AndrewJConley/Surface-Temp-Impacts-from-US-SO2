; ==============================================================
; ==============================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"

begin

;----------------------------------------------
; get gw
;----------------------------------------------
  proc = "./"

  cesm = "cesm/"
  gfdl = "gfdl/"
  giss = "giss/"

  cesmfile = addfile(cesm+"US_climate_diff.nc","r")
  gfdlfile = addfile(gfdl+"ts_zg.nc","r")
  gissfile = addfile(giss+"climate_zg.nc","r")

;----------------------------------------------
; Which variable?
;----------------------------------------------

  fcesm = cesmfile->ts_mean
  fcesm_g = cesmfile->ts_g_mean
  fcesm_e = cesmfile->ts_stderr
  printVarSummary(fcesm)

  fgfdl = gfdlfile->temp_mean
  fgfdl_g = gfdlfile->temp_g_mean
  fgfdl_e = gfdlfile->temp_stderr
  printVarSummary(fgfdl)

  fgfdl_cesmg = fcesm
  fgfdl_cesmg = linint2(gfdlfile->lon, gfdlfile->lat, gfdlfile->temp_mean, True, cesmfile->lon, cesmfile->lat, 0)
  fgfdl_cesmg(0,:) = avg(fgfdl(0,:))
  fgfdl_cesmg(95,:) = avg(fgfdl(89,:))

  printVarSummary(fgfdl_cesmg)
  if(any(ismissing(fgfdl_cesmg))) then
    print("GFDL contains some missing values. Beware.")
    print (ismissing(fgfdl_cesmg))
  end if

  fgiss = gissfile->tsurf_mean
  fgiss = -1*fgiss
  fgiss_g = gissfile->tsurf_g_mean
  fgiss_g= -1*fgiss_g
  fgiss_e = gissfile->tsurf_stderr
  fgiss = lonFlip(fgiss)
  fgiss_e = lonFlip(fgiss_e)
  ;printVarSummary(fgiss)

  if(any(ismissing(fgiss))) then
    print("GISS RAW contains some missing values. Beware.")
  ;  print (ismissing(fgiss_cesmg))
  end if

  fgiss_cesmg = fcesm
  fgiss_cesmg = linint2(fgiss&lon, gissfile->lat, gissfile->tsurf_mean, True, cesmfile->lon, cesmfile->lat, 0)
  fgiss_cesmg&lat = cesmfile->lat
  fgiss_cesmg&lon = cesmfile->lon
  printVarSummary(fgiss_cesmg)
  if(any(ismissing(fgiss_cesmg))) then
    print("GISS contains some missing values. Beware.")
  ;  print (ismissing(fgiss_cesmg))
  end if

  favg = fcesm
  favg = (fcesm + fgfdl_cesmg + fgiss_cesmg) / 3.
  ;favg(0,:) = (fcesm(0,:))
  ;favg(95,:) = (fcesm(95,:))
  favg_g = (fcesm_g + fcesm_g + fgiss_g ) / 3.
  favg&lat = cesmfile->lat 
  favg&lon = cesmfile->lon 
  printVarSummary(favg)
  if(any(ismissing(favg))) then
    print("AVG data contains some missing values. Beware.")
  end if
  
  fcesm=lonFlip(fcesm)
  fcesm_e=lonFlip(fcesm_e)
  fgfdl=lonFlip(fgfdl)
  fgfdl_e=lonFlip(fgfdl_e)
  fgiss=lonFlip(fgiss)
  fgiss_e=lonFlip(fgiss_e)
  favg = lonFlip(favg)


;============================================================
; PLOTS
;============================================================

  wks = gsn_open_wks("png",proc+"ts_climate_latlon_avg")
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")       ; choose colormap

  plot = new(4,graphic)                ; create graphic array
                                          ; only needed if paneling
; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar = True
  ;resP@txString             = "Forcing"

; ;EOF patterns
  res                      = True
  res@gsnDraw              = False        ; don't draw yet
  res@gsnFrame             = False        ; don't advance frame yet
  res@gsnScale  = True        ; force text scaling               

  res@lbLabelAutoStride   = True         ; auto stride on labels
  res@gsnSpreadColors      = True         ; spread out color table
  res@gsnAddCyclic         = True         ; plotted dataa are not cyclic
  res@mpFillOn             = False        ; turn off map fill

  res@cnFillOn             = True         ; turn on color fill
  res@cnLinesOn            = False        ; True is default
  res@cnLineLabelsOn       = False        ; True is default
  res@lbLabelBarOn         = False        ; individual lb's
  res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  res@cnLevels    = (/ -1, -.5, -.2, -.1, -.05, .05, .1, .2, .5, 1./)

; stippling
  res2 = True                            ; res2 probability plots
  res2@gsnDraw             = False       ; Do not draw plot
  res2@gsnFrame            = False       ; Do not advance frome
  res2@cnLevelSelectionMode = "ManualLevels" ; set manual contour levels
  res2@cnMinLevelValF      = 2.
  res2@cnMaxLevelValF      = 3.
  res2@cnLevelSpacingF     = 1.         ; set contour spacing
  res2@cnInfoLabelOn       = False       ; turn off info label
  res2@cnLinesOn           = False       ; do not draw contour lines
  res2@cnLineLabelsOn      = False       ; do not draw contour labels
  res2@cnFillScaleF        = 0.4         ; add extra density
  res2@gsnLeftString = ""
  res2@gsnRightString = ""
  opt = True
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeFillType = "pattern"
  opt@gsnShadeMid  = 17


     res@gsnLeftString  = "CESM"
     res@gsnRightString  = " " + sprintf("%5.2f",fcesm_g) + " K"
     plot(0)=gsn_csm_contour_map_ce(wks,fcesm,res)

     sigcesm = fcesm
     sigcesm = abs(fcesm)/fcesm_e
     plot0 = gsn_csm_contour(wks, sigcesm, res2)
     plot0 = gsn_contour_shade(plot0,-0.1, 2.0, opt)
     overlay(plot(0),plot0)

     res@gsnLeftString  = "GFDL"
     res@gsnRightString  = " " + sprintf("%5.2f",fgfdl_g) + " K"
     plot(1)=gsn_csm_contour_map_ce(wks,fgfdl,res)
     siggfdl = fgfdl
     siggfdl = abs(fgfdl)/fgfdl_e
     plot1 = gsn_csm_contour(wks, siggfdl, res2)
     plot1 = gsn_contour_shade(plot1,-0.1, 2.0, opt)
     overlay(plot(1),plot1)


     res@gsnLeftString  = "GISS"
     res@gsnRightString  = " " + sprintf("%5.2f",fgiss_g) + " K"
     plot(2)=gsn_csm_contour_map_ce(wks,fgiss,res)
     siggiss = fgiss
     siggiss = abs(fgiss)/fgiss_e
     plot2 = gsn_csm_contour(wks, siggiss, res2)
     plot2 = gsn_contour_shade(plot2,-0.1, 2.0, opt)
     overlay(plot(2),plot2)

     res@gsnLeftString  = "Multi-model Average"
     res@gsnAddCyclic  = True 
     res@gsnRightString  = " " + sprintf("%5.2f",favg_g) + " K"
     plot(3)=gsn_csm_contour_map_ce(wks,favg,res)

     gsn_panel(wks,plot,(/2,2/),resP)     ; now draw as one plot

end

