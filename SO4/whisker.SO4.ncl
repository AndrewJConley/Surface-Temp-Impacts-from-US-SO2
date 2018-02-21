; ==============================================================
; ==============================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  variable = "SO4"

;----------------------------------------------
; input
;----------------------------------------------
  ; US_SO2
  cesm = addfile("cesm/regional_SO4.nc","r")
  gfdl = addfile("gfdl/regional_SO4.nc","r")
  giss = addfile("giss/regional_SO4.nc","r")


;----------------------------------------------
; output
;----------------------------------------------

  wks = gsn_open_wks("pdf","Whisker_SO4_panel")

;----------------------------------------------
; Sampling parameters
;----------------------------------------------
  cesmts= cesm->SO4_mean * 1e3
  cesmse= cesm->SO4_stderr * 1e3
  gfdlts= gfdl->SO4_mean * 1e3
  gfdlse= gfdl->SO4_stderr * 1e3
  gissts= giss->so4_mean * 1e-7 * 1e3
  gissse= giss->so4_stderr * 1e-7 * 1e3

  num_areas = 16

   area_name = (/ "Global","South Australia", "North Australia", "Central America", "West N America", "Central N America", "East N America", "Alaska", "Mediterranean Basin", "N Europe", "South Asia", "Central Asia", "North Asia" ,"Sahel", "N60", "Nino 3.4"/)
  s_area_name = (/ "Global","SAustralia", "NAustralia", "CAmerica", "WNAmerica", "CNAmerica", "ENAmerica", "Alaska", "MBasin", "NEurope", "SAsia", "CAsia", "NAsia", "Sahel", "N60", "Nino 3.4" /)

  mn = new ((/3,num_areas/), "double",-999) 
  se = new ((/3,num_areas/), "double",-999) 


;----------------------------------------------
; Extract control simulation
;----------------------------------------------

  mn(0,:)=1e3*cesmts
  mn(1,:)=1e3*gfdlts
  mn(2,:)=1e3*gissts

  se(0,:)=1e3*cesmse
  se(1,:)=1e3*gfdlse
  se(2,:)=1e3*gissse

  plot = new(16,graphic)
  t_txt = new(16,graphic)

;----------------------------------------------
; plot
;----------------------------------------------

  res           = True
  res@tmXBLabelsOn = True
  res@tmXBLabels              = (/"CESM","GFDL","GISS"/)
  res@tmYLLabelFontHeightF = .02 
  res@tmXBLabelFontHeightF = .02 
  res@tiMainOffsetYF  = -.024

  xval = (/0.,1.,2./)
  yval = new( (/3,5/), "double", -999)

  printVarSummary(yval)
  printVarSummary(mn)

  minplot = (/-.5,-.5,-.5,-5.,-5,-5,-5,-.5,-.5,-.5,-.5,-.5,-.5,-.5,-.5,-.5/)
  maxplot = (/ .3, .3, .3, 1., 1, 1, 1, .3, .3, .3, .3, .3, .3, .3, .3, .3/)
  
  opti = True
  opti@boxColors = (/"blue","green","red"/)
  opti@boxWidth = 0.6

  dum = new(num_areas,graphic)

  do iarea = 0,num_areas-1

      res@tiMainString = s_area_name(iarea)

      yval(:,0) = mn(:,iarea) - se(:,iarea) 
      yval(:,1) = mn(:,iarea) - se(:,iarea) 
      yval(:,2) = mn(:,iarea)
      yval(:,3) = mn(:,iarea) + se(:,iarea)
      yval(:,4) = mn(:,iarea) + se(:,iarea)

      res@trYMinF  = minplot(iarea)
      res@trYMaxF  = maxplot(iarea)

      plot(iarea) = boxplot(wks ,xval ,yval, opti, res, False)
      dum(iarea) = gsn_add_polyline(wks, plot(iarea), (/-1.,3./),(/0., 0./), False)
      
  end do

  gsn_panel(wks,plot,(/4,4/),False)             ; now draw as one plot

end

