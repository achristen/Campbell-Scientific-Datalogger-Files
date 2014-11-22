;+ 
; name: 
;   csi_fs2.pro 
; 
; purpose: 
;   interprets an array of exactly two byte elements as a campbell scientific
;   binary format "fs2" number used in the tob binary file format of dataloggers.
;
; category:
;   campbell scientific file formats
;
; calling sequence: 
;   value=csi_fs2(twobytearray[2]) 
; 
; inputs: 
;   twobytearray[2]:  two byte elements which form together a fs2 number.
;
; output: 
;   float. value of the fs2 number.
;
; reference:
;   jon trauntvein, 'campbell scientific data file formats', version 1.1.1.10, p. 50/51
; 
; example 
;   print, csi_fs2(byte([37,107])) 
;   idl> 13.87
;
; revision history: 
;   may-23-2007 ac 
;-

function csi_fs2, twobytearray

   bits=bytarr(16)
   if keyword_set(debug) then print, twobytearray
   for i=0, 7 do bits[7-i]  = byte((twobytearray[0] mod 2l^(i+1))/2l^i) 
   for i=0, 7 do bits[15-i] = byte((twobytearray[1] mod 2l^(i+1))/2l^i) 

   s=bits[0] ; sign
   e=(-1.0)*float(bits[2]+2*bits[1]) ;exponent reverse order
   m=0 ;mantissa reverse order
   for i=3, 15 do m=m+long(bits[i])*2l^(15-i)

   case 1 of
    (s eq 0 and e eq 0 and m eq 8191) : value=!values.f_infinity
    (s eq 1 and e eq 0 and m eq 8191) : value=!values.f_infinity*(-1)
    (s eq 0 and e eq 0 and m eq 8190) : value=!values.f_nan
    (s eq 1 and e eq 0 and m eq 8190) : value=!values.f_nan*(-1)
    else : value=float((-1.0)^s * 10.0^(e) * m)
 endcase

   return, value

end
