; ==============================================================
; ==============================================================

load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

begin

  variable = "TS"

;----------------------------------------------
; input
;----------------------------------------------
  ; US_SO2
  cesm = addfile("cesm/US_regional_diff.nc","r")
  gfdl = addfile("gfdl/regional.nc","r")
  giss = addfile("giss/regional_ts.nc","r")

;----------------------------------------------
; output
;----------------------------------------------

  wks = gsn_open_wks("png","Whisker_panel_US")

;----------------------------------------------
; Sampling parameters
;----------------------------------------------
  cesmts= cesm->ts_mean
  cesmse= cesm->ts_stderr
  gfdlts= gfdl->ts_mean
  gfdlse= gfdl->ts_stderr
  gissts= giss->ts_mean
  gissse= giss->ts_stderr
  avgts= (cesmts + gfdlts + gissts ) / 3.
  avgse= sqrt( (cesmts^2 + gfdlts^2 + gissts^2)/3. - avgts^2 )

  num_areas = 16

   area_name = (/ "Global","South Australia", "North Australia", "Central America", "West N America", "Central N America", "East N America", "Alaska", "Mediterranean Basin", "N Europe", "South Asia", "Central Asia", "North Asia" ,"Sahel", "N60", "Nino 3.4"/)
  s_area_name = (/ "Global","SAustralia", "NAustralia", "CAmerica", "WNAmerica", "CNAmerica", "ENAmerica", "Alaska", "MBasin", "NEurope", "SAsia", "CAsia", "NAsia", "Sahel", "N60", "Nino 3.4" /)

  mn = new ((/4,num_areas/), "double",-999) 
  se = new ((/4,num_areas/), "double",-999) 


;----------------------------------------------
; Extract control simulation
;----------------------------------------------

  mn(0,:)=cesmts
  mn(1,:)=gfdlts
  mn(2,:)=gissts
  mn(3,:)=avgts

  se(0,:)=cesmse
  se(1,:)=gfdlse
  se(2,:)=gissse
  se(3,:)=avgse

  plot = new(16,graphic)
  t_txt = new(16,graphic)

;----------------------------------------------
; plot
;----------------------------------------------

  res           = True
  res@tmXBLabelsOn = True
  res@tmXBLabels              = (/"CESM","GFDL","GISS","Avg"/)
  res@tmYLLabelFontHeightF = .02 
  res@tmXBLabelFontHeightF = .02 
  res@tiMainOffsetYF  = -.024

  xval = (/0.,1.,2.,3./)
  yval = new( (/4,5/), "double", -999)

  printVarSummary(yval)
  printVarSummary(mn)

  res@trYMinF  = -.20
  res@trYMaxF  = 0.50
  opti = True
  opti@boxColors = (/"blue","red","green","black"/)

  dum = new(num_areas,graphic)

  do iarea = 0,num_areas-1

      res@tiMainString = s_area_name(iarea)

      yval(:,0) = mn(:,iarea) - 2*se(:,iarea) 
      yval(:,1) = mn(:,iarea) - se(:,iarea) 
      yval(:,2) = mn(:,iarea)
      yval(:,3) = mn(:,iarea) + se(:,iarea)
      yval(:,4) = mn(:,iarea) + 2*se(:,iarea)

      plot(iarea) = boxplot(wks ,xval ,yval, opti, res, False)
      dum(iarea) = gsn_add_polyline(wks, plot(iarea), (/-1.,4./),(/0., 0./), False)
      
  end do

  gsn_panel(wks,plot,(/4,4/),False)             ; now draw as one plot

end

