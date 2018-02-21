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

  forcingf = addfile("TS_forcing.nc","r")
  coupledf = addfile("TS_coupled.nc","r")

;----------------------------------------------
; Which variable?
;----------------------------------------------

  forcingTS = forcingf->TS
  coupledTS = coupledf->TS

;============================================================
; PLOTS
;============================================================

  wks = gsn_open_wks("png","feedback")
  gsn_define_colormap(wks,"BlueWhiteOrangeRed")

  plot = new(3,graphic)                ; create graphic array
                                          ; only needed if paneling
; panel plot only resources
  resP                     = True         ; modify the panel plot
  resP@gsnMaximize         = True         ; large format
  resP@gsnPanelLabelBar = True

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
  levels = (/ -.3, -.1, -.03, -.01, .01, .03, .1, .3/)
  res@cnLevels    = levels
  res@lbLabelStrings = sprintf("%6.2g",levels)

  res@gsnZonalMean    = True                    ; put zonal on side
  res@gsnZonalMeanYRefLine = 0.
  res@gsnZonalMeanXMinF = -0.1
  res@gsnZonalMeanXMaxF =  0.35


     res@gsnLeftString  = "Surface T Response (ERF) "
     ;res@gsnRightString  = "AOD " + sprintf("%5.2g",fcesm_g) 
     plot(0)=gsn_csm_contour_map_ce(wks,forcingTS(0,:,:),res)

     res@gsnLeftString  = "Surface T Response (Coupled) "
     ;res@gsnRightString  = "AOD " + sprintf("%5.2g",fcesm_g) 
     plot(1)=gsn_csm_contour_map_ce(wks,coupledTS(0,:,:),res)


     gsn_panel(wks,plot,(/2,1/),resP)     ; now draw as one plot

end

