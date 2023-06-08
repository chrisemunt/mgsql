%mgsqlv5 ;(CM) sql - validate query - part 6 ; 28 Jan 2022  10:03 AM
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2023 MGateway Ltd                                     |
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
a d vers^%mgsql("%mgsqlv5") q
 ;
from(dbid,sql,qnum,arg,error) ; validate 'from' statement
 n tnum,nord,xord,i,x,tname,alias,args,index,on
 s ^mgtmp($j,"from","i","x",qnum)=0
 s arg=$$arg^%mgsqle(arg,.args)
 s tnum=0 f i=1:1:args s tname=args(i) i tname'="" d from1(dbid,qnum,.tnum,tname) i $l(error) q
 i '$l(error) s ^mgtmp($j,"from",qnum)=arg
fromx i $l(error) s error(0)="from",error(1)=qnum q
 s x="" f  s x=$o(^mgtmp($j,"from","z",qnum,"jn",x)) q:x=""  d natv(dbid,qnum,x,.error) i $l(error) q
 i $l(error) q
 s x="" f  s x=$o(^mgtmp($j,"from","z",qnum,"c",0,x)) q:x=""  s ^mgtmp($j,"from","z",qnum,"c","x",$p(^mgtmp($j,"from",qnum,x),"~",2))="",^mgtmp($j,"from","z",qnum,"c","x",$p(^mgtmp($j,"from",qnum,x+1),"~",2))=""
 s xord=1 s x=$o(^mgtmp($j,"from","z",qnum,"o",0,"")) i $l(x),^mgtmp($j,"from","z",qnum,"o",0,x)="right" s xord=-1
 s nord=0
 s x="" f  s x=$o(^mgtmp($j,"from","z",qnum,"o",0,x),xord) q:x=""  d from4(x,xord,.nord)
 f nord=1:1 q:'$d(^mgtmp($j,"from","z",qnum,"ord",nord))  s x=^mgtmp($j,"from","z",qnum,"ord",nord),^mgtmp($j,"from","z",qnum,"ord",nord)=$p(^mgtmp($j,"from",qnum,x),"~",2)
fromxx ; compile 'on' predicates
 f i=1:1 q:'$d(^mgtmp($j,"from","on",qnum,i))  s on=$g(^mgtmp($j,"from","on",qnum,i)) d  i $l(error) q
 . n qnumo
 . s qnumo=qnum_"gon"_i d where^%mgsqlv1(dbid,sql,qnumo,on,.error) i $l(error) q
 . q
 q
 ;
from1(dbid,qnum,tnum,tname) ; validate each table selected from
 n %ref,i,ii,j,x,y,z,z1,zz,ino,inof,inop,exp,pn,nat,jtyp,ok,com
 f x="inner","left","right","full" s jtyp(x)=""
 s (exp,pn,obr,cbr)=0,y="",com="" f i=1:1:$l(tname," ") s x=$$trim^%mgsqls($p(tname," ",i)," ") i $l(x) d
 . i x["(" s obr=obr+1
 . i x[")" s cbr=cbr+1
 . s y=y_com_x,com=" "
 . i obr=cbr s exp=exp+1,exp(exp)=y,y="",com="",(obr,cbr)=0
 . q
 f i=1:1 q:'$d(exp(i))  i exp(i)="on" d
 . i '$d(exp(i+1)) q
 . i exp(i+1)?1"(".e q
 . s x="(",com="" f ii=i+1:1 q:'$d(exp(ii))  s y=exp(ii) i y'="" q:$d(jtyp(y))!(y="join")!(y="natural")!(y="inner")!(y="cross")  s x=x_com_y,com=" " k exp(ii)
 . s x=x_")"
 . s j=i+1,exp(j)=x
 . f ii=ii:1 q:'$d(exp(ii))  s x=exp(ii) k exp(ii) s j=j+1,exp(j)=x
 . q
from11 s pn=pn+1 i '$d(exp(pn)) q
 s tname=exp(pn),nat=0
 s alias=tname i alias["." s alias=$p(tname,".",2)
 s pn=pn+1 i '$d(exp(pn)) g from16
 s x=exp(pn)
 i x="join" g from14
 i x="natural" s nat=1 g from12
 i x="cross" g from12
 i $d(jtyp(x)) s y=x g from12a
 s alias=x
 s pn=pn+1 i '$d(exp(pn)) g from16
 s x=exp(pn)
 i x="join" g from14
 i x="natural" s nat=1 g from12
 i x="cross" g from12
 i $d(jtyp(x)) s y=x g from12a
 s alias=x
 s pn=pn+1 i '$d(exp(pn)) g from16
 s x=exp(pn)
 i x="join" g from14
 i x="natural" s nat=1 g from12
 i x="cross" g from12
 i $d(jtyp(x)) s y=x g from12a
 s error="joins should be specified as [natural] <inner|left|right|full> or join or cross join",error(5)="HY000" q
from12 ; join expression
 s pn=pn+1 i '$d(exp(pn)) s error="'from' declaration may not be terminated with '"_x_"'",error(5)="HY000" q
 s y=exp(pn)
 i x="cross",y'="join" s error="keyword 'cross' must be followed by 'join'",error(5)="HY000" q
 i x="cross",y="join" g from13
 i x="natural",y="join" g from14
from12a i '$d(jtyp(y)) s error="invalid join type '"_y_"' use inner,left, right or full",error(5)="HY000" q
 s pn=pn+1 i '$d(exp(pn)) s error="'from' declaration must not be terminated with '"_y_"'",error(5)="HY000" q
 s z=exp(pn)
 i y="inner",z'="join" s error="keyword 'inner' should be followed by 'join'",error(5)="HY000" q
 i y="inner",z="join" g from14
 i z="join" g from15
 i z'="outer" s error="keyword left|right|full should be followed by outer or join",error(5)="HY000" q
 s pn=pn+1 i '$d(exp(pn)) s error="'from' declaration cannot be terminated with '"_z_"'",error(5)="HY000" q
 s z1=exp(pn) i z1'="join" s error="keyword 'outer' must be followed by 'join'",error(5)="HY000" q
 g from15
from13 ; cartesian product
 s ^mgtmp($j,"from","z",qnum,"c",0,tnum+1)=""
 g from16
from14 ; inner join
 s ^mgtmp($j,"from","z",qnum,"i",0,tnum+1)=""
 d nat(dbid,qnum,tnum,tname,nat,.exp,.error)
 g from16
from15 ; outer join
 s n="" f  s n=$o(^mgtmp($j,"from","z",qnum,"o",0,n)) q:n=""  i ^mgtmp($j,"from","z",qnum,"o",0,n)'=y s error="express all outer joins as either 'left', 'right' or 'full'",error(5)="HY000" q
 i $l(error) q
 s ^mgtmp($j,"from","z",qnum,"o",0,tnum+1)=y
 d nat(dbid,qnum,tnum,tname,nat,.exp,.error)
from16 ; process table/alias
 s inof=""
 i tname[" " s alias=$p(tname," ",2) s:'$l(alias) error="invalid component '"_tname_"' in 'from' statement",error(5)="HY000" q:$l(error)  s tname=$p(tname," ",1)
 i tname["." s dbid=$p(tname,".",1),tname=$p(tname,".",2)
 i tname[":" s inof=$p(tname,":",2),tname=$p(tname,":",1)
 i '$l(dbid) s error="invalid 'from' statement",error(5)="HY000" q
 i '$l(tname) s error="invalid 'from' statement",error(5)="HY000" q
 s (ino,inop)=$$pkey^%mgsqld(dbid,tname)
 i alias[":" s inof=$$from3(qnum,.alias)
 i inof'="" s:inof="0" inof=inop s ino=inof
 s ok=$$fromv(dbid,tname,.error) i $l(error) q
 f ii=1:1 q:'$d(^mgtmp($j,"from","x",ii))  i $d(^mgtmp($j,"from","x",ii,alias)) s error="query contains duplication of table/alias '"_alias_"'",error(5)="HY000" q
 i $l(error) q
 s %ref=$$ref^%mgsqld(dbid,tname,ino) i %ref="" s error="invalid index name '"_ino_"' for table '"_tname_"'",error(5)="HY000" q
 s tnum=tnum+1,^mgtmp($j,"from",qnum,tnum)=tname_"~"_alias,^mgtmp($j,"from","x",qnum,tname)=tnum,^mgtmp($j,"from","x",qnum,alias)=tnum
 s ^mgtmp($j,"from","i",0,alias)=ino i inof'="" s ^mgtmp($j,"from","i","f",$s(alias'="":alias,1:tname))=inof
 g from11
 ;
from3(qnum,alias) ; index specification
 n x,ino
 s x=$p(alias,":",2,999),alias=$p(alias,":",1)
 s ino=x,ino=$p(x,"(",1),^mgtmp($j,"from","i","x",qnum)=1
 q ino
 ;
from4(fnum,xord,nord) ; outer join mandatory running order
 n fnum1,fnum2
 i xord=1 s fnum1=fnum,fnum2=fnum+1
 i xord=-1 s fnum1=fnum+1,fnum2=fnum
 s ^mgtmp($j,"from","z",qnum,"pass",$p(^mgtmp($j,"from",qnum,fnum2),"~",2))=""
 i '$d(^mgtmp($j,"from","z",qnum,"ordx",fnum1)) s nord=nord+1,^mgtmp($j,"from","z",qnum,"ord",nord)=fnum1,^mgtmp($j,"from","z",qnum,"ordx",fnum1)=""
 i '$d(^mgtmp($j,"from","z",qnum,"ordx",fnum2)) s nord=nord+1,^mgtmp($j,"from","z",qnum,"ord",nord)=fnum2,^mgtmp($j,"from","z",qnum,"ordx",fnum2)=""
 q
 ;
fromv(dbid,tname,error) ; validate table
 n %d
 s %d=$$tab^%mgsqld(dbid,tname) i %d="" s error="no such table '"_tname_"'",error(5)="42S02" q 0
 q 1
 ;
nat(dbid,qnum,tnum,tname,nat,exp,error) ; extract join parameters
 n i,ii,x,cname,alias,on,onexp
 i nat q  ; data dictionary
 s on=""
 f i=pn+1:1 q:'$d(exp(i))  s x=exp(i) i x="using"!(x="on") s on=x q
 i on="" s error="if a join is not natural then qualify it with either an 'on' or 'using' statement",error(5)="HY000" q
 i '$d(exp(i+1)) s error="missing parameter(s) for 'on'/'using' statement",error(5)="HY000" q
 i on="on" g naton
 s x=exp(i+1)
 i x'?1"("1e.e1")" s error="syntax error in parameters to 'using' statement",error(5)="HY000" q
 s x=$p($p(x,"(",2),")",1)
 f ii=1:1:$l(x,",") s cname=$$trim^%mgsqls($p(x,",",ii)," ") i $l(cname) s ^mgtmp($j,"from","z",qnum,"jn",tnum+1,cname)=""
 i '$d(^mgtmp($j,"from","z",qnum,"jn",tnum+1)) s error="no valid parameters for 'using' statement found",error(5)="HY000" q
 k exp(i),exp(i+1) f i=i+2:1 q:'$d(exp(i))  s exp(i-2)=exp(i) k exp(i)
 q
naton ; 'on' statement
 s x=exp(i+1)
 i x?1"("1e.e1")" s x=$p($p(x,"(",2),")",1)
 ; cmtxxx
 d where^%mgsqle(x,.onexp,.error) i error'="" q
 s ^mgtmp($j,"from","on",qnum,$i(^mgtmp($j,"from","on",qnum)))=x
 ; cmtxxx
 ;f ii=1:1:$l(x," ") s cname=$$trim^%mgsqls($p(x," ",ii)," "),alias=$p(cname,".",1),cname=$p(cname,".",2) i cname'="",alias'="" s ^mgtmp($j,"from","z",qnum,"join",cname,alias)=""
 s ii="" f  s ii=$o(onexp("sqv",0,"x",ii)) q:ii=""  s alias=$p(ii,".",1),cname=$p(ii,".",2) i cname'="",alias'="" s ^mgtmp($j,"from","z",qnum,"join",cname,alias)=""
 k exp(i),exp(i+1) f i=i+2:1 q:'$d(exp(i))  s exp(i-2)=exp(i) k exp(i)
 q
 ;
natv(dbid,qnum,tnum,error) ; validate element in using statement
 n tname,tname1,tname2,alias,alias1,alias2,cname
 s tname1=$p(^mgtmp($j,"from",qnum,tnum),"~",1),alias1=$p(^mgtmp($j,"from",qnum,tnum),"~",2)
 s tname2=$p(^mgtmp($j,"from",qnum,tnum+1),"~",1),alias2=$p(^mgtmp($j,"from",qnum,tnum+1),"~",2)
 s cname="" f  s cname=$o(^mgtmp($j,"from","z",qnum,"jn",tnum,cname)) q:cname=""  d natv1(dbid,qnum,tname1,tname2,cname,.error) i $l(error) q
 i $l(error) q
 s ^mgtmp($j,"from","z",qnum,"c","x",alias1)="",^mgtmp($j,"from","z",qnum,"c","x",alias2)=""
 k ^mgtmp($j,"from","z",qnum,"jn",tnum)
 q
 ;
natv1(dbid,qnum,tname1,tname2,cname,error) ; column in tables test
 n %defk,%defd
 f tname=tname1,tname2 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) i '%defk,'%defd s error="'using' statement: column '"_cname_"' not found in table '"_tname_"'",error(5)="42S22" q
 i $l(error) q
 s ^mgtmp($j,"from","z",qnum,"join",cname,alias1)="",^mgtmp($j,"from","z",qnum,"join",cname,alias2)=""
 q
 ;
