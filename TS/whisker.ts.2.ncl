; ==============================================================
; ==============================================================

;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/contributed.ncl"
;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"

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

  wks = gsn_open_wks("png","Whisker_panel_US_2")

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
  mn(3,:)=(/avgts/)

  se(0,:)=cesmse
  se(1,:)=gfdlse
  se(2,:)=gissse
  se(3,:)=(/avgse/)

  plot = new(16,graphic)
  t_txt = new(16,graphic)

  labels = new ((/64/),string  )   
  models = new ((/64/),string  )   
  do i = 0, 15
    labels(i*4) = " "
    labels(i*4+1) =s_area_name(i)
    labels(i*4+2) =  " "
    labels(i*4+3) = " "
    models(i*4) = "blue"
    models(i*4+1) = "green"
    models(i*4+2) = "red"
    models(i*4+3) = "black"
  end do

  xval = (/1,2,3,4,  7,8,9,10,  13,14,15,16,  19,20,21,22, 25,26,27,28,   31,32,33,34,   37,38,39,40,  43,44,45,46,   49,50,51,52, 55,56,57,58, 61,62,63,64, 67,68,69,70, 73,74,75,76,  79,80,81,82, 85,86,87,88, 91,92,93,94/)

;----------------------------------------------
; plot
;----------------------------------------------

  res           = True
  res@tmXBLabelsOn = True
  res@tmXBMode        = "Explicit"	
  res@tmXBValues      = xval
  res@tmXBLabels      = labels
  res@tmXBLabelAngleF = -90
  res@tmYLLabelFontHeightF = .01 
  res@tmXBLabelFontHeightF = .01 
  res@tmYMajorGrid                = True
  res@tmYMajorGridThicknessF      = 1.0
  res@tmXBMajorLengthF = 0.00001
  res@tmYLMajorLengthF = 0.00001
  res@tmYLMinorLengthF = 0.005

  res@vpWidthF         = 0.9                      ; set width and height
  res@vpXF             = 0.05
  res@vpHeightF        = 0.8
  res@vpYF             = 0.95

  yval = new( (/16,4,5/), "double", -999)

  res@trYMinF  = -.20
  res@trYMaxF  = 0.50
  opti = True
  opti@boxColors = models
  opti@boxWidth = 0.6

  dum = new(num_areas,graphic)

  do iarea = 0,num_areas-1

      yval(iarea,:,0) = mn(:,iarea) - 2*se(:,iarea) 
      yval(iarea,:,1) = mn(:,iarea) - se(:,iarea) 
      yval(iarea,:,2) = mn(:,iarea)
      yval(iarea,:,3) = mn(:,iarea) + se(:,iarea)
      yval(iarea,:,4) = mn(:,iarea) + 2*se(:,iarea)

  end do

  yval_2 = reshape(yval, (/(16*4),5/) )

  xcor = (/5.5,5.5/)
  ycor = (/-.20,0.50/)

  plot = boxplot(wks ,xval ,yval_2, opti, res, False)
  ;dum = gsn_add_polyline(wks, plot, xcor, ycor, False)

  draw(wks)
  frame(wks)

end

