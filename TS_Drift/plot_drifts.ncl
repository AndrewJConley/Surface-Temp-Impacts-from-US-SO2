load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_code.ncl"
load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/gsn_csm.ncl"


  cesm = addfile("cesm/coarse_ts_control.nc","r")
  sol_cesm = (/  2.88560802e+02,  -2.20898985e-01,   9.71218550e+01/)

  giss = addfile("giss/coarse_ts_control.nc","r")
  sol_giss = (/ 288.6,   -.45,   150./)

  gfdl = addfile("gfdl/coarse_ts_control.nc","r")
  sol_gfdl = (/ 289.67545376,   -1.09417718,  178.98200255/)

  plotfile = "drifts"

; plot

 wks   = gsn_open_wks ("pdf",plotfile)               ; send graphics to PNG file

 plot = new(3,graphic)

 resP = True
 res                  = True                     ; plot mods desired
 res@tiYAxisString = ""

 amres=True
 amres@amParallelPosF   =  0.48 ; +right,-left (0,0) is upper left?
 amres@amOrthogonalPosF =  0.46 ; -up +down
 amres@amJust           = "BottomRight"

 amres2=True
 amres2@amParallelPosF   =  -0.35 ; +right,-left (0,0) is upper left?
 amres2@amOrthogonalPosF =  -0.40 ; -up +down
 amres2@amJust           = "BottomRight"

 cesm_ts = cesm->ts_g
 cesm_year = cesm&year/365

 min_c_t = min(cesm_year)
 max_c_t = max(cesm_year)
 min_c_ts = min(cesm_ts)
 max_c_ts = max(cesm_ts)

 res@gsnDraw  = False                          ; don't draw
 res@gsnFrame = False                          ; don't draw

 ;res@tiXAxisString = "Year"
 ;res@tiYAxisString = "TS (cesm)"

 res@trYMinF = min(cesm_ts)
 res@trYMaxF = max(cesm_ts)

 res@tmYROn = False
 res@tmXTOn = False

 ; python fit
 sol = sol_cesm
 fit = sol(0)+sol(1)*exp(-cesm_year/sol(2))
 diff = cesm_ts-fit

 plot(0)  = gsn_csm_xy2 (wks, cesm_year, cesm_ts, fit, res, res)

 txres = True
 txres@txFontHeightF         = 0.02
 fitfun ="T = " + sprintf("%5.2f",sol(0)) +" + "+ sprintf("%4.2f",sol(1))+" exp(-t/"+sprintf("%3.1f",sol(2))+")"
 txfid = gsn_create_text(wks,fitfun,txres)
 annoid = gsn_add_annotation(plot(0),txfid, amres)

 txfid2 = gsn_create_text(wks,"CESM",txres)
 annoid = gsn_add_annotation(plot(0),txfid2, amres2)

 delete(res@trYMaxF)
 delete(res@trYMinF)

 is = dim_pqsort(diff, 1)
 ndata = dimsizes(diff)

 npercs = 20
 percentiles = ndata*fspan(0,1,npercs)
 percentiles(npercs-1) = ndata-1
 percentiles(0) = 0

 perc_diff = diff(is(toint(percentiles)))

 txres = True
 txres@txFontHeightF         = 0.02

 ; allocate...
 diffmean = 1.
 diffvar = 1.
 diffskew = 1.
 diffkurt = 1.
 npts = 1
 stat4(diff,diffmean,diffvar,diffskew,diffkurt,npts)

 conf = "    Mean = "+sprintf("%5.3f",diffmean)+" +/- "+sprintf("%7.5f",sqrt(diffvar/npts))
 print(conf)
 stats = ""+sprinti("%4i",npts) +", ("+sprintf("%5.3f",diffmean)+", "+sprintf("%5.3f",diffvar)+", "+sprintf("%5.3f",diffskew)+", "+sprintf("%5.3f",diffkurt)+")"
 print(stats)
 ;txid = gsn_create_text(wks,conf+"~C~"+stats,txres)
 txid = gsn_create_text(wks,stats,txres)

 ;res@tiXAxisString = "T diffs"
 ;res@tiYAxisString = "Percentile"
 ;res@gsnYRefLine = 50
 ;res@gsnXRefLine = 0.
 ;res@trYMinF = 0
 ;res@trYMaxF = 100
 ;plot(1)  = gsn_csm_xy (wks, perc_diff, 100.*percentiles/ndata, res )
 delete(res@trYMinF)
 delete(res@trYMaxF)


 ;annoid = gsn_add_annotation(plot(1),txid, amres2)

; gfdl
 gfdl_ts = gfdl->tref_g
 gfdl_year = gfdl&year/365 

 min_c_t = min(gfdl_year)
 max_c_t = max(gfdl_year)
 min_c_ts = min(gfdl_ts)
 max_c_ts = max(gfdl_ts)

 res@gsnDraw  = False                          ; don't draw
 res@gsnFrame = False                          ; don't draw

 ;res@tiXAxisString = "Year"
 ;res@tiYAxisString = "T Ref (gfdl)"

 res@trYMinF = min(gfdl_ts)
 res@trYMaxF = max(gfdl_ts)

 res@tmYROn = False
 res@tmXTOn = False

 ; python fit
 delete(diff)
 delete(fit)
 sol = sol_gfdl
 fit = sol(0)+sol(1)*exp(-gfdl_year/sol(2))
 diff = gfdl_ts-fit

 plot(1)  = gsn_csm_xy2 (wks, gfdl_year, gfdl_ts, fit, res, res)

 txres = True
 txres@txFontHeightF         = 0.02
 fitfun ="T = " + sprintf("%5.2f",sol(0)) +" + "+ sprintf("%4.2f",sol(1))+" exp(-t/"+sprintf("%3.1f",sol(2))+")"
 txfid = gsn_create_text(wks,fitfun,txres)

 annoid = gsn_add_annotation(plot(1),txfid, amres)

 txfid2 = gsn_create_text(wks,"GFDL",txres)
 annoid = gsn_add_annotation(plot(1),txfid2, amres2)


 delete(res@trYMaxF)
 delete(res@trYMinF)

 delete(is)
 is = dim_pqsort(diff, 1)
 ndata = dimsizes(diff)

 npercs = 20
 percentiles = ndata*fspan(0,1,npercs)
 percentiles(npercs-1) = ndata-1
 percentiles(0) = 0

 perc_diff = diff(is(toint(percentiles)))

 txres = True
 txres@txFontHeightF         = 0.02

 ; allocate...
 diffmean = 1.
 diffvar = 1.
 diffskew = 1.
 diffkurt = 1.
 npts = 1
 stat4(diff,diffmean,diffvar,diffskew,diffkurt,npts)

 conf = "    Mean = "+sprintf("%5.3f",diffmean)+" +/- "+sprintf("%7.5f",sqrt(diffvar/npts))
 print(conf)
 stats = ""+sprinti("%4i",npts) +", ("+sprintf("%5.3f",diffmean)+", "+sprintf("%5.3f",diffvar)+", "+sprintf("%5.3f",diffskew)+", "+sprintf("%5.3f",diffkurt)+")"
 print(stats)
 ;txid = gsn_create_text(wks,conf+"~C~"+stats,txres)
 txid = gsn_create_text(wks,stats,txres)

 ;res@tiXAxisString = "T diffs"
 ;res@tiYAxisString = "Percentile"
 ;res@trYMinF = 0
 ;res@trYMaxF = 100
 ;plot(3)  = gsn_csm_xy (wks, perc_diff, 100.*percentiles/ndata, res )
 ;annoid = gsn_add_annotation(plot(3),txid, amres2)
 delete(res@trYMinF)
 delete(res@trYMaxF)


; giss

 giss_ts = giss->tref_g
 giss_year = giss&year - 1624

 min_c_t = min(giss_year)
 max_c_t = max(giss_year)
 min_c_ts = min(giss_ts)
 max_c_ts = max(giss_ts)

 res@gsnDraw  = False                          ; don't draw
 res@gsnFrame = False                          ; don't draw

 res@trYMinF = min(giss_ts)
 res@trYMaxF = max(giss_ts)

 res@tmYROn = False
 res@tmXTOn = False

 ; python fit
 delete(fit)
 sol = sol_giss
 fit = sol(0)+sol(1)*exp(-giss_year/sol(2))

 delete(diff)
 diff = giss_ts-fit

 plot(2)  = gsn_csm_xy2 (wks, giss_year, giss_ts, fit, res, res)

 txres = True
 txres@txFontHeightF         = 0.02
 fitfun ="T = " + sprintf("%5.2f",sol(0)) +" + "+ sprintf("%4.2f",sol(1))+" exp(-t/"+sprintf("%3.1f",sol(2))+")"
 txfid = gsn_create_text(wks,fitfun,txres)

 annoid = gsn_add_annotation(plot(2),txfid, amres)

 txfid2 = gsn_create_text(wks,"GISS",txres)
 annoid = gsn_add_annotation(plot(2),txfid2, amres2)


 delete(res@trYMaxF)
 delete(res@trYMinF)

 delete(is)
 is = dim_pqsort(diff, 1)
 ndata = dimsizes(diff)

 npercs = 20
 percentiles = ndata*fspan(0,1,npercs)
 percentiles(npercs-1) = ndata-1
 percentiles(0) = 0

 perc_diff = diff(is(toint(percentiles)))

 txres = True
 txres@txFontHeightF         = 0.02

 ; allocate...
 diffmean = 1.
 diffvar = 1.
 diffskew = 1.
 diffkurt = 1.
 npts = 1
 stat4(diff,diffmean,diffvar,diffskew,diffkurt,npts)

 conf = "    Mean = "+sprintf("%5.3f",diffmean)+" +/- "+sprintf("%7.5f",sqrt(diffvar/npts))
 print(conf)
 stats = ""+sprinti("%4i",npts) +", ("+sprintf("%5.3f",diffmean)+", "+sprintf("%5.3f",diffvar)+", "+sprintf("%5.3f",diffskew)+", "+sprintf("%5.3f",diffkurt)+")"
 print(stats)
 ;txid = gsn_create_text(wks,conf+"~C~"+stats,txres)
 txid = gsn_create_text(wks,stats,txres)

 ;res@tiXAxisString = "T diffs"
 ;res@tiYAxisString = "Percentile"
 ;res@trYMinF = 0
 ;res@trYMaxF = 100
 ;plot(5)  = gsn_csm_xy (wks, perc_diff, 100.*percentiles/ndata, res )
 delete(res@trYMinF)
 delete(res@trYMaxF)
 ;annoid = gsn_add_annotation(plot(5),txid, amres2)


 gsn_panel(wks, plot, (/3,1/), resP)

