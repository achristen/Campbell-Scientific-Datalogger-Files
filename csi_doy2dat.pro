;+
; name:
;   csi_doy2dat.pro
;
; purpose:
;   converts day of year (doy) and year stored in 
;   logger files to a date with day and month
;
; category:
;   date handling
;
; calling sequence:
;   result=csi_doy2dat(doy,jjjj,format=3)
;
; inputs:
;   doy    : day of year (1...366)
;   yyyy   : 4-digit year e.g. "1999" "2001"
;
; output:
;   array [month,day] or string
;
; subroutines:
;   #csi_months#
;
; example 
;   print, csi_doy2dat(201,1999) 
;   idl > [7,20] ; i.e. july-20
;   print, csi_doy2dat(201,2000) 
;   idl > [7,19] ; i.e. july-19
;   print, csi_doy2dat([201,300],[2000,1999])
;
; revision history:
;   13-dec-01 ac
;   18-may-07 ac, enhanced documentation
;-

function csi_doy2dat, doy, yyyy

    ni=min([n_elements(doy),n_elements(yyyy)])
    ret=intarr(2,ni)
    for i=0l, ni-1 do begin
      first_of_month=csi_months(yyyy[i])  ;-1
      lower_mon=where(first_of_month-1 lt doy[i])
      ret[0,i]=n_elements(lower_mon)
      ret[1,i]=doy[i]-(first_of_month[ret[0,i]-1]-1)
    endfor
    return, reform(ret)

end
