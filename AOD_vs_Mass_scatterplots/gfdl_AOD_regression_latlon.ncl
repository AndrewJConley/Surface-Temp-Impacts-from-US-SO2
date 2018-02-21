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

  ; initialize variables
  AOD_so4 = dllAOD
  AOD_dust = dllAOD
  AOD_sslt = dllAOD
  AOD_carbon = dllAOD
  AOD_residual = dllAOD

  AOD_so4 =  b(0)*dllSO4
  AOD_dust = b(2)*dllDUST
  AOD_sslt = b(4)*dllSSLT
  AOD_carbon = (b(3)*dllPOM+b(1)*dllBC+b(5)*dllSOA)

  AOD_residual = dllAOD - (b(0)*dllSO4 + b(2)*dllDUST + b(4)*dllSSLT + b(3)*dllPOM + b(1)*dllBC + b(5)*dllSOA )

  gSO4 = wgt_areaave(AOD_so4(0,:,:),area_weighting,1,1)
  gDUST = wgt_areaave(AOD_dust(0,:,:),area_weighting,1,1)
  gSSLT = wgt_areaave(AOD_sslt(0,:,:),area_weighting,1,1)
  gcarbon = wgt_areaave(AOD_carbon(0,:,:),area_weighting,1,1)
  gRES = wgt_areaave(AOD_residual(0,:,:),area_weighting,1,1)

  wks = gsn_open_wks(wks_type,"gfdl_regressed_latlon_contributions")

  gsn_define_colormap(wks,"BlueWhiteOrangeRed")

  plt2 = new(6,graphic)

  res2 = True
  res2@cnFillOn          = True  
  res2@cnLineLabelsOn    = False 
  res2@cnLineLabelsOn    = False             ; turn off contour lines
  res2@cnLinesOn   = False             ; turn off contour lines
  res2@cnLineLabelsOn   = False             ; turn off contour lines
  res2@cnLinesOn   = False             ; turn off contour lines
  res2@txFontHeightF     = 0.015 
  res2@gsnDraw = False
  res2@gsnFrame = False
  res2@txFontHeightF     = 0.015 
  res2@cnLevelSelectionMode = "ExplicitLevels"   ; set explicit contour levels

  levels = (/ -100., -30., -10., -3., -1., 1., 3., 10., 30., 100./)/1000
  res2@cnLevels    = levels
  res2@lbLabelStrings = (/"-.1", "-.03", "-.01", "-.003", "-.001", ".001", ".003", ".01", ".03", ".1" /)

  form="%4.2g"

  res2@tiMainString = "Total AOD Response"
  res2@gsnRightString = sprintf(form,1e3*gAOD) + "e-3"
  plt2(0) = gsn_csm_contour_map(wks,dllAOD(0,:,:),res2)

  res2@tiMainString = "SO4 (regressed contribution)"
  res2@gsnRightString = sprintf(form,1e3*gSO4) + "e-3"
  plt2(1) = gsn_csm_contour_map(wks,AOD_so4(0,:,:),res2)

  res2@tiMainString = "Dust (regressed contribution)"
  res2@gsnRightString = sprintf(form,1e3*gDUST) + "e-3"
  plt2(2) = gsn_csm_contour_map(wks,AOD_dust(0,:,:),res2)

  res2@tiMainString = "SSLT (regressed contribution)"
  res2@gsnRightString = sprintf(form,1e3*gSSLT) + "e-3"
  plt2(3) = gsn_csm_contour_map(wks,AOD_sslt(0,:,:),res2)

  res2@tiMainString = "Carbons (regressed contribution)"
  res2@gsnRightString = sprintf(form,1e3*gcarbon) + "e-3"
  plt2(4) = gsn_csm_contour_map(wks,AOD_carbon(0,:,:),res2)

  res2@tiMainString = "Residual Contribution to AOD"
  res2@gsnRightString = sprintf(form,1e3*gRES) + "e-3"
  plt2(5) = gsn_csm_contour_map(wks,AOD_residual(0,:,:),res2)

  gsn_panel(wks,plt2,(/3,2/),False)

end
