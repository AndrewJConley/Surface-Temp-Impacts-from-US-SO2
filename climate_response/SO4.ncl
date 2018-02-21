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
  gfdlfile = addfile(gfdl+"SO4_zg.nc","r")
  gissfile = addfile(giss+"climate_zg.nc","r")

;----------------------------------------------
; Which variable?
;----------------------------------------------

  fcesm = cesmfile->SO4_diff_mean
  fcesm = fcesm*1e6
  fcesm_g = cesmfile->SO4_diff_g_mean
  fcesm_g = fcesm_g*1e6
  fcesm_e = cesmfile->SO4_diff_stderr
  fcesm_e = fcesm_e*1e6

  fgfdl = gfdlfile->SO4_mean
  fgfdl = fgfdl*1e6
  fgfdl_g = gfdlfile->SO4_g_mean
  fgfdl_g = fgfdl_g*1e6
  fgfdl_e = gfdlfile->SO4_stderr
  fgfdl_e = fgfdl_e*1e6

  fgiss = gissfile->so4_mean
  fgiss = -1.*fgiss *1e6 * 1e-7
  fgiss_g = gissfile->so4_g_mean
  fgiss_g = -1.*fgiss_g *1e6 * 1e-7
  fgiss_e = gissfile->so4_stderr
  fgiss_e = fgiss_e  *1e6 * 1e-7

  fcesm = lonFlip(fcesm)
  fcesm_e = lonFlip(fcesm_e)
  fgfdl = lonFlip(fgfdl)
  fgfdl_e = lonFlip(fgfdl_e)

  ;printVarSummary(fcesm)
  ;printVarSummary(fgfdl)
  ;printVarSummary(fgiss)

;============================================================
; PLOTS
;============================================================

  wks = gsn_open_wks("png",proc+"SO4_climate")
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")       ; choose colormap
  plot = new(3,graphic)                ; create graphic array
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
  ;res@cnLevels    = (/ -10., -5., -2., -1., -.5, -.2, -.1, .1, .2, .5, 1./)
  res@cnLevels    = (/ -3., -1., -.3, -.1,-.03, .03, .1, .3, 1., 3./)

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
     res@gsnRightString  = " " + sprintf("%5.2f",fcesm_g) + " mg/m^2"
     plot(0)=gsn_csm_contour_map_ce(wks,fcesm,res)

     sigcesm = fcesm
     sigcesm = abs(fcesm)/fcesm_e
     plot0 = gsn_csm_contour(wks, sigcesm, res2)
     plot0 = gsn_contour_shade(plot0, 0.0, 2.0, opt)
     overlay(plot(0),plot0)

     res@gsnLeftString  = "GFDL"
     res@gsnRightString  = " " + sprintf("%5.2f",fgfdl_g) + " mg/m^2"
     plot(1)=gsn_csm_contour_map_ce(wks,fgfdl,res)
     siggfdl = fgfdl
     siggfdl = abs(fgfdl)/fgfdl_e
     plot1 = gsn_csm_contour(wks, siggfdl, res2)
     plot1 = gsn_contour_shade(plot1, 0.0, 2.0, opt)
     overlay(plot(1),plot1)


     res@gsnLeftString  = "GISS"
     res@gsnRightString  = " " + sprintf("%5.2f",fgiss_g) + " mg/m^2"
     plot(2)=gsn_csm_contour_map_ce(wks,fgiss,res)
     siggiss = fgiss
     siggiss = abs(fgiss)/fgiss_e
     plot2 = gsn_csm_contour(wks, siggiss, res2)
     plot2 = gsn_contour_shade(plot2, 0.0, 2.0, opt)
     overlay(plot(2),plot2)


     gsn_panel(wks,plot,(/3,1/),resP)     ; now draw as one plot

end

