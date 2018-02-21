;load "$NCARG_ROOT/lib/ncarg/nclscripts/csm/shea_util.ncl"
begin

  control = addfile("coarse_ts_control.nc","r")
  us015 = addfile("coarse_ts_015.nc","r")

  control_ts = control->ts_g
  control_time = control&year
  min_c_t = min(control_time)
  max_c_t = max(control_time)

  us015_ts = us015->ts_g
  us015_time = us015&year
  min_015_t = max((/min(us015_time), min_c_t/))
  max_015_t = min((/max(us015_time), max_c_t/))

  diff = us015_ts({min_015_t:max_015_t}) - control_ts({min_015_t:max_015_t})
  ds = dimsizes(diff)
  diff!0 = "year"
  diff&year = ispan(0,ds(0)-1,1)

; autocorrelation
  ; maximum distance of offset
  maxoffset = 40

  ; plot variables
  acr = new((/3,maxoffset/),"double")
  acr(0,:) = esacr(diff,maxoffset-1)

  len = dimsizes(diff)
  count = ispan(0,maxoffset-1,1)
  acr(1,:) = 1.96/sqrt(len-count)
  acr(2,:) = -1.96/sqrt(len-count)
 
  autocov = new ( (/maxoffset,maxoffset/), "double")

; plot

 wks   = gsn_open_wks ("pdf","autocor")               ; send graphics to PNG file

 res          = True
 res@gsnDraw  = True
 res@gsnFrame = True
 res@xyMarkLineModes = (/"MarkLines","Lines","Lines"/)
 res@xyMarkers = (/1,0,0/)
 res@xyDashPatterns     = (/0,2,2/) 

 res@gsnYRefLine = 0
 res@gsnYRefLineColor = "grey"

 res@trXMaxF = 40

 res@trYMinF = -1.0
 res@trYMaxF =  1.0

 res@tiYAxisString = "Strength of Autocorrelation"
 res@tiXAxisString = "Offset (year)"

 plot  = gsn_csm_xy (wks, count, acr, res)

end


