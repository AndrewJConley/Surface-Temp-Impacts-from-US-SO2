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

  ctrlpath="ctrl/"
  c_so2emisfile = addfile(ctrlpath+"SO2_emis_cmip2.ann.nc","r")

  t_file = addfile("zUS_SO2/zUS_SO2.nc","r")

;----------------------------------------------
; Which variable?
;----------------------------------------------

  t_SO2_emis = t_file->SO2_emis_cmip2
  c_SO2_emis = c_so2emisfile->SO2_emis_cmip2
  SO2_emis = c_SO2_emis
  SO2_emis = t_SO2_emis(0,:,:) - c_SO2_emis

;============================================================
; PLOTS
;============================================================

  wks = gsn_open_wks("pdf",proc+"S_Source_change_climate")
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")       ; choose colormap
  plot = new(9,graphic)                ; create graphic array
                                          ; only needed if paneling
; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar = False

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
  ;res@lbLabelBarOn         = False        ; individual lb's
  ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
  ;res@cnLevels    = (/ -10., -5., -2., -1., -.5, -.2, -.1, .1, .2, .5, 1./)
  ;res@cnLevels    = (/ -3., -1., -.3, -.1,-.03, .03, .1, .3, 1., 3./)

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


     ;res@gsnLeftString  = "SO4_column change"
     ;res@gsnRightString  = " " + sprintf("%5.2f",fcesm_g) + " mg/m^2"
     ;plot(0)=gsn_csm_contour_map_ce(wks,SO4_col(0,:,:),res)

     ;sigcesm = fcesm
     ;sigcesm = abs(fcesm)/fcesm_e
     ;plot0 = gsn_csm_contour(wks, sigcesm, res2)
     ;plot0 = gsn_contour_shade(plot0, 0.0, 2.0, opt)
     ;overlay(plot(0),plot0)

     res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
     res@cnLevels    = (/ -10, -1, -.1, -.01, .01, .1, 1, 10/) * .1e-12
     res@gsnLeftString  = "SO2_emis change"
     plot(0)=gsn_csm_contour_map_ce(wks,SO2_emis,res)
     ;siggfdl = fgfdl
     ;siggfdl = abs(fgfdl)/fgfdl_e
     ;plot1 = gsn_csm_contour(wks, siggfdl, res2)
     ;plot1 = gsn_contour_shade(plot1, 0.0, 2.0, opt)
     ;overlay(plot(1),plot1)


     ;res@gsnLeftString  = "SO4 Change in Wet Removal"
     ;plot(1)=gsn_csm_contour_map_ce(wks,SO4_wetdep(0,:,:),res)
     ;siggiss = fgiss
     ;siggiss = abs(fgiss)/fgiss_e
     ;plot2 = gsn_csm_contour(wks, siggiss, res2)
     ;plot2 = gsn_contour_shade(plot2, 0.0, 2.0, opt)
     ;overlay(plot(2),plot2)

     ;res@gsnLeftString  = "SO4 Dry Dep change"
     ;plot(3)=gsn_csm_contour_map_ce(wks,SO4_drydep(0,:,:),res)

     ;res@gsnLeftString  = "SO4 Change in Total Removal"
     ;SO4_removal = SO4_drydep
     ;SO4_removal = SO4_removal + SO4_wetdep
     ;plot(0)=gsn_csm_contour_map_ce(wks,SO4_removal(0,:,:),res)

     ;res@gsnLeftString  = "SO4 removal rate"
     ;SO4_removalrate = SO4_col
     ;SO4_removalrate = where(abs(SO4_col).gt.1e-6, SO4_col/SO4_removal, 0.)/86400
     ;SO4_removalrate@units = "Days"
     ;SO4_removalrate@long_name = "Lifetime"
     ;plot(5)=gsn_csm_contour_map_ce(wks,SO4_removalrate(0,:,:),res)

     ;res@gsnLeftString  = "SO4 lifetime (zUS_SO2)"
     ;plot(4)=gsn_csm_contour_map_ce(wks,t_lifetime(0,:,:),res)

     ;res@gsnLeftString  = "Relative change in Burden (%)"
     ;res@cnLevelSelectionMode = "AutomaticLevels"   ; set explicit contour levels
     ;plot(0)=gsn_csm_contour_map_ce(wks,pdSO4(0,:,:),res)

     ;res@gsnLeftString  = "Relative change in Removal Rate (%)"
     ;plot(1)=gsn_csm_contour_map_ce(wks,pd_removal(0,:,:),res)

     ;res@gsnLeftString  = "SO4 lifetime (ctrl)"
     ;plot(2)=gsn_csm_contour_map_ce(wks,c_lifetime(0,:,:),res)

     ;res@gsnLeftString  = "SO4 lifetime change"
     ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
     ;res@cnLevels    = (/ -2.5, -2, -1.5, -1, -.5, 0, .5, 1, 1.5, 2, 2.5/) 
     ;change_lifetime = t_lifetime(0,:,:)  ; initialize
     ;change_lifetime = t_lifetime(0,:,:) - c_lifetime(0,:,:)
     ;plot(3)=gsn_csm_contour_map_ce(wks,change_lifetime,res)



     ;res@gsnLeftString  = "SO4 Column Burden (ctrl)"
     ;plot(7)=gsn_csm_contour_map_ce(wks,so4_column_ctrl(0,:,:),res)

     ;res@gsnLeftString  = "SO4 Column Burden covariance with Lifetime "
     ;res@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels
     ;res@cnLevels    = (/ -2.5e-5, -1.5e-5, -.5e-5, .5e-5, 1.5e-5, 2.5e-5/) / 2.5
     ;covar = SO4_col(0,:,:)
     ;covar = SO4_col(0,:,:) * change_lifetime
     ;covar@units = "kg/m2 * Days"
     ;plot(3)=gsn_csm_contour_map_ce(wks,covar,res)


     gsn_panel(wks,plot,(/1,1/),resP)     ; now draw as one plot

end

