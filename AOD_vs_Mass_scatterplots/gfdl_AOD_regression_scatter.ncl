begin

  f = addfile("gfdl_zUS_SO2_m_CTRL.nc","r")

  wks_type = "png"
  ;wks_type@wkWidth = 2500
  ;wks_type@wkHeight = 2500 

  lat = f->lat
  lon = f->lon
  lat_bounds = f->lat_bnds

  pi = 4.*atan(1.0)
  degtorad = (pi/180.)
  lat_bounds = (lat_bounds)*degtorad  ; bounds of lats in radians
  area_weighting = tofloat(sin(lat_bounds(:,1))-sin(lat_bounds(:,0)))
  area_weighting = area_weighting/sum(area_weighting)
  gw_match = conform_dims( (/1, 90, 144/), area_weighting, 1)
  gw_match = gw_match/sum(gw_match)

  dllAOD = f->aer_ex_c_vs
  dllAOD@long_name = ""
  dllAOD@units = ""

  dllSO4 = f->sulfate_col
  dllDUST = f->dust_col
  dllPOM = f->POA_col
  dllSSLT = f->salt_col
  dllSOA = f->SOA_col
  dllBC = f->blk_crb_col

  gAOD = wgt_areaave(dllAOD, area_weighting, 1, 1)

  BSO4 = sum(gw_match*dllSO4)
  BBC  = sum(gw_match*dllBC)
  BDUST= sum(gw_match*dllDUST)
  BPOM = sum(gw_match*dllPOM)
  BSSLT= sum(gw_match*dllSSLT)
  BSOA = sum(gw_match*dllSOA)

  print("sum(gw_match*dllAOD)")
  print(sum(gw_match*dllAOD))

  print(BSO4)
  print(BBC)
  print(BDUST)
  print(BPOM)
  print(BSSLT)
  print(BSOA)

  dAOD = ndtooned(gw_match*dllAOD)

  dSO4 = ndtooned(gw_match*dllSO4) 
  dBC = ndtooned(gw_match*dllBC) 
  dDUST = ndtooned(gw_match*dllDUST) 
  dPOM = ndtooned(gw_match*dllPOM) 
  dSEASALT = ndtooned(gw_match*dllSSLT) 
  dSOA = ndtooned(gw_match*dllSOA) 

  components=new ( (/7,dimsizes(dAOD)/), "float")
  components(0,:)=dSO4
  components(1,:)=dBC
  components(2,:)=dDUST
  components(3,:)=dPOM
  components(4,:)=dSEASALT
  components(5,:)=dSOA
  components(6,:)=ndtooned(gw_match)


  option = True
  option@print_anova = True
  option@print_data = False
  b = reg_multlin(dAOD,components,option)

  print(b)
  print("b")
  print(b)
  print("b.stderr")
  print(b@stderr)

  print("contributions: SO4, BC, DUST, POM, SSLT, SOA, offset")
  print(b(0)*BSO4)
  print(b(1)*BBC)
  print(b(2)*BDUST)
  print(b(3)*BPOM)
  print(b(4)*BSSLT)
  print(b(5)*BSOA)

  AOD_so4 = dllAOD
  AOD_so4 =  b(0)*dllSO4
  AOD_dust = dllAOD
  AOD_dust = b(2)*dllDUST
  AOD_sslt = dllAOD
  AOD_sslt = b(4)*dllSSLT
  AOD_carbon = dllAOD
  AOD_carbon = (b(3)*dllPOM+b(1)*dllBC+b(5)*dllSOA)

  AOD_residual = dllAOD
  AOD_residual = dllAOD - (b(0)*dllSO4 + b(2)*dllDUST + b(4)*dllSSLT + b(3)*dllPOM + b(1)*dllBC + b(5)*dllSOA )

  gSO4 = wgt_areaave(AOD_so4(0,:,:),area_weighting,1,1)
  gDUST = wgt_areaave(AOD_dust(0,:,:),area_weighting,1,1)
  gSSLT = wgt_areaave(AOD_sslt(0,:,:),area_weighting,1,1)
  gcarbon = wgt_areaave(AOD_carbon(0,:,:),area_weighting,1,1)
  gRES = wgt_areaave(AOD_residual(0,:,:),area_weighting,1,1)

  wks2   = gsn_open_wks (wks_type,"gfdl_AOD_vs_column_masses")           ; send graphics to PNG file

  plot = new(6,graphic)

  res                   = True                     ; plot mods desired
  res@gsnDraw  = False                          ; don't draw
  res@gsnFrame = False                          ; don't advance frame

  res@gsnMaximize       = True                     ; maximize plot
  res@xyMarkLineMode    = "Markers"                ; choose to use markers
  res@xyMarkers         =  16                      ; choose type of marker  
  res@xyMarkerColor     = "Black"               ; Marker color
  res@xyMarkerSizeF     = 0.002                    ; Marker size (default 0.01)

  res@tiMainString      = "AOD Sensitivity to SO4"           
  plot(0)  = gsn_csm_xy (wks2,ndtooned(1e6*dllSO4),ndtooned(dllAOD),res)                    

  res@tiMainString      = "AOD Sensitivity to BlackCarbon"           
  plot(1)  = gsn_csm_xy (wks2,ndtooned(1e6*dllBC),ndtooned(dllAOD),res)                    

  res@tiMainString      = "AOD Sensitivity to DUST"           
  plot(2)  = gsn_csm_xy (wks2,ndtooned(1e6*dllDUST),ndtooned(dllAOD),res)

  res@tiMainString      = "AOD Sensitivity to POM"           
  plot(3)  = gsn_csm_xy (wks2,ndtooned(1e6*dllPOM),ndtooned(dllAOD),res)                    

  res@tiMainString      = "AOD Sensitivity to SeaSalt"           
  plot(4)  = gsn_csm_xy (wks2,ndtooned(1e6*dllSSLT),ndtooned(dllAOD),res)                    

  res@tiMainString      = "AOD Sensitivity to SOA"           
  plot(5)  = gsn_csm_xy (wks2,ndtooned(1e6*dllSOA),ndtooned(dllAOD),res)                    


  gsn_panel(wks2,plot,(/3,2/),False)



end
