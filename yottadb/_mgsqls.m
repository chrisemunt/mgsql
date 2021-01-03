%mgsqls ;(CM) general utilities ; 12 feb 2002  02:10pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2021 M/Gateway Developments Ltd,                      |
 ;  | Surrey UK.                                                               |
 ;  | All rights reserved.                                                     |
 ;  |                                                                          |
 ;  | http://www.mgateway.com                                                  |
 ;  |                                                                          |
 ;  | Licensed under the Apache License, Version 2.0 (the "License"); you may  |
 ;  | not use this file except in compliance with the License.                 |
 ;  | You may obtain a copy of the License at                                  |
 ;  |                                                                          |
 ;  | http://www.apache.org/licenses/LICENSE-2.0                               |
 ;  |                                                                          |
 ;  | Unless required by applicable law or agreed to in writing, software      |
 ;  | distributed under the License is distributed on an "AS IS" BASIS,        |
 ;  | WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. |
 ;  | See the License for the specific language governing permissions and      |
 ;  | limitations under the License.                                           |
 ;  ----------------------------------------------------------------------------
 ;
a d vers^%mgsql("%mgsqls") q
 ;
isydb() ; see if this is yottadb
 i $zv["GT.M" q 1
 q 0
 ;
isidb() ; see if this is an InterSystems database
 i $zv["ISM" q 1
 i $zv["Cache" q 2
 i $zv["IRIS" q 3
 q 0
 ;
ismsm() ; see if this is MSM
 i $zv["MSM" q 1
 q 0
 ;
isdsm() ; see if this is DSM
 i $zv["DSM" q 1
 q 0
 ;
ism21() ; see if this is M21
 i $zv["M21" q 1
 q 0
 ;
crc(str,mode) ; cyclic redundancy check
 n x,i
 s x=0 f i=1:1:$l(str) s x=x+$a(str,i)
 q x
 ;
error() ; get last error
 i $$isydb() q $zs
 q $ze
 ;
seterror(v) ; Set error
 q
 ;
uci() ; get uci name
 i $$isydb() q $zg
 x "s uci=$namespace"
 q uci
 ;
cuci(uci) ; change uci
 i $$isydb() q $zg
 x "zn uci"
 q 1
 ;
gtmgr ; restore global
 s dev="/opt/gtm63/cm.go"
 o dev:(readonly)
 u dev f i=1:1 r x q:x=""  s ref=$p(x,$c(1),1),data=$p(x,$c(1),2),@ref=data
 c dev
 q
 ;
flush() ; flush output buffer
 i $$isydb() q
 w *-3
 q
 ;
trim(x,chrs) ; trim leading/trailing spaces from text
 q $$ltrim($$rtrim(x,chrs),chrs)
 ;
ltrim(x,chrs) ; trim leading spaces from text
 i chrs="" s chrs=" "
 f  q:chrs'[$e(x,1)  s x=$e(x,2,9999) i x="" q
 q x
 ;
rtrim(x,chrs) ; trim trailing spaces from text
 n len
 i chrs="" s chrs=" "
 s len=$l(x) f  q:chrs'[$e(x,len)  s x=$e(x,1,len-1),len=len-1 i x="" q
 q x
 ;
rreplace(x,this,with) ; recursive replace
 f  q:$e(x,1)'[this  s x=$p(x,this,1)_with_$p(x,this,2,9999)
 q x
 ;
ucase(x) ; convert string to upper-case
 q $tr(x,"abcdefghijklmnopqrstuvwxyz","ABCDEFGHIJKLMNOPQRSTUVWXYZ")
 ;
lcase(x) ; convert string to lower-case
 q $tr(x,"ABCDEFGHIJKLMNOPQRSTUVWXYZ","abcdefghijklmnopqrstuvwxyz")
 ;
hextodec(x) ; convert hexadecimal to decimal
 n len,d,n,c
 ;w !,">>>",x
 s len=$l(x),x=$$lcase(x)
 s d=0
 f n=len:-1:1 s c=$e(x,n),d=d+(($f("0123456789abcdef",c)-2)*(16**(len-n))) ;w !,c," = ",len," ",n," ",d," ### ",$f("0123456789abcdef",c)-2," ### ",16**(len-n)," === ",($f("0123456789abcdef",c)-2)*(16**(len-n))
 w !
 q d
 ;
urldecode(x) ; URL decode
 n y,cx,xy,i
 s y=""
 f i=1:1:$l(x) s cx=$e(x,i) q:cx=""  d
 . s cy=cx
 . i cx="+" s cy=" "
 . i cx="%" s cy=$c($$hextodec($e(x,i+1,i+2))) s i=i+2
 . s y=y_cy
 . q
 q y
 ;
cdate() ; current date
 q $p($h,",",1)
 ;
ctime() ; current time
 q $p($h,",",2)
 ;
ts() ; time stamp
 q $h
 ;
mv() ; missing value
 q ""
 ;
age(mdate) ; calculate age
 q (+$h-mdate)\365.25
 ;
dsep() ; get date separator
 n sep
 s sep="/"
 q sep
 ;
ddate(mdate,format) ; decode M date
 n d,m,y,ddate,sep
 i mdate="" q ""
 s sep=$$dsep()
 s ddate=$zd(mdate,1)
 s d=$p(ddate,sep,2)
 s m=$p(ddate,sep,1)
 s y=$p(ddate,sep,3)
 i $$isydb(),y<100 d
 . i mdate<58074 s y=y+1900
 . i mdate'<58074 s y=y+2000
 . q
 i '$$isydb(),y<100 d
 . i mdate<58074 s y=y+1900
 . q
 s ddate=y_"-"_m_"-"_d
 q ddate
 ;
edate(ddate,format) ; encode M date
 n dd,dj,djstr,dl,dlm,dm,dy,i,mdate,x,y,ok
 i ddate="" q ""
 s ddate=$$ltrim(ddate," ")
 i ddate?8n s dy=$e(ddate,1,4),dm=$e(ddate,5,6),dd=$e(ddate,7,8) g edate1
 i ddate?4n1"-"2n1"-"2n s dy=$p(ddate,"-",1),dm=$p(ddate,"-",2),dd=$p(ddate,"-",3) g edate1
 i ddate["." s dlm="."
 i ddate["," s dlm=","
 i ddate["/" s dlm="/"
 i ddate[" " s dlm=" "
 s dd=$p(ddate,dlm,1)
 s dm=$p(ddate,dlm,2)
 s dy=$p(ddate,dlm,3)
edate1 s mdate=""
 i dm'?1N.N d
 . s dm=$$lcase(dm)
 . f i=1:1:12 i $p("jan,feb,mar,apr,may,jun,jul,aug,sep,oct,nov,dec",",",i)=dm s dm=i q
 . i dm'?1n.n s dm=0
 . q
 i ((dd'<1)&(dd'>31)&(dm'<1)&(dm'>12)&(dy'<0)&(dy'>9999)) d
 . i dy<100,dy<30 s dy=dy+2000
 . i dy<100,dy'<30 s dy=dy+1900
 . s dl=0
 . i (((dy#4)=0)&(dy'=1900)) s dl=1
 . s ok=1
 . i ((dd>30)&((dm=4)!(dm=6)!(dm=9)!(dm=11))) s ok=0
 . i ((dm=2)&(((dl=0)&(dd>28))!((dl=1)&(dd>29)))) s ok=0 ;
 . i (ok=1) d
 .. i dl=0 s djstr=$p("000,031,059,090,120,151,181,212,243,273,304,334",",",dm),dj=djstr+dd
 .. i dl'=0 s djstr=$p("000,031,060,091,121,152,182,213,244,274,305,335",",",dm),dj=djstr+dd
 .. s x=(dy-1841)*365
 .. s y=(dy-1841)\4
 .. s mdate=dj+x+y
 .. i (dy>1900) s mdate=(mdate-1)
 .. i (dy'>1900) s mdate=mdate
 .. q
 . q
 q mdate
 ;
dtime(mtime,format) ; decode M time
 n h,m,s
 i mtime="" q ""
 i mtime["," s mtime=$p(mtime,",",2)
 s h=mtime\3600,s=mtime-(h*3600),m=s\60,s=s#60
 q $s(h<10:"0",1:"")_h_":"_$s(m<10:"0",1:"")_m_":"_$s(s<10:"0",1:"")_s
 ;
etime(dtime,format) ; encode M time
 n h,m,s
 i etime="" q ""
 s h=$p(dtime,":",1),m=$p(dtime,":",2),s=$p(dtime,":",3)
 q (h*3600)+(m*60)+s
 ;
logerror(text,title) ; log error condition
 d logevent(text,title,"ERROR") ; log
 q
 ;
logevent(record,title,context) ; log event
 s n=$i(^mglog)
 s ^mglog(n,0)=context_":"_title_":"_$$ddate($h)_"; "_$$dtime($h)
 s ^mglog(n,1)=record
 q
 ;
logarray(array,title,context) ; log event
 s n=$i(^mglog)
 s ^mglog(n,0)=context_":"_title_":"_$$ddate($h)_"; "_$$dtime($h)
 m ^mglog(n,1)=array
 q
 ;
