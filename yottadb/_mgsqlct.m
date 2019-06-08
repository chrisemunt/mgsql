%mgsqlct ;(CM) sql compiler - get table details ; 19 jan 2003  7:12 pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2019 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqlct") q
 ;
getf ; get file particulars for each alias
 s con=0
 f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))  s tname=$p(^mgtmp($j,"from",qnum,tnum),"~",1),alias=$p(^mgtmp($j,"from",qnum,tnum),"~",2) d getf1 i $l(error) q
 i $l(error) q
 q
 ;
getf1 ; get file particulars for alias alias (fid)
 n x,y
 i tname?@("1"""_%z("dq")_"""1n.n1"""_%z("dq")_"""") d getfv q
 s ino=$$pkey^%mgsqld(dbid,tname) i $d(^mgtmp($j,"from","i",ino,alias)) s ino=^mgtmp($j,"from","i",ino,alias)
 s %d=$$tab^%mgsqld(dbid,tname) s r=%d,%ref=$$ref^%mgsqld(dbid,tname,.ino) s glb=%ref i glb="^sqlspool" s %qid=$p(tname,"(",1) d spl s glb=%spl
 s odel=$p(r,"\",1)
 i odel?1n.n,odel>31,odel<127 s odel=""""_$c(odel)_""""
 i odel?1n.n,odel<32!odel>126 s odel="$char("_odel_")"
 s odel(qnum,tnum)=odel
 s glb(qnum,tnum)=glb
 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 ;
 s (z,com)="" f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) s:x?1a.e x=%z("dsv")_alias_"."_x_%z("dsv") s z=z_com_x,com=","
 s ^mgtmp($j,"key",qnum,tnum)=z
 i ino=$$pkey^%mgsqld(dbid,tname) s key0(qnum,tnum)=^mgtmp($j,"key",qnum,tnum),glb0(qnum,tnum)=glb
 i ino'=0 d getf2
 f i=1:1 q:'$d(^mgtmp($j,"sel",qnum,i))  s x=$p(^mgtmp($j,"sel",qnum,i),%z("dsv"),2)  d getf11
 s y="" f  s y=$o(^mgtmp($j,"from","z",qnum,"join",y)) q:y=""  i $d(^mgtmp($j,"from","z",qnum,"join",y,alias)) s x=alias_"."_y d getf11
 s cname="" f  s cname=$o(^mgtmp($j,"join",qnum,alias,cname)) q:cname=""  s %d=$$item^%mgsqld(dbid,tname,cname) s data(qnum,tnum,alias_"."_at)=%d
 i $l(error) q
 k ino
 q
 ;
getf11 ; process data item to be retrieved/derived
 i x="*" q
 s cname=x,ext="",f=""
 i x["." s cname=$p(x,".",2),f=$p(x,".",1)
 i f'=alias,f'=alias_"g" q
 s %d=$$item^%mgsqld(dbid,tname,cname) d remap^%mgsqlv2 i (%d'="")!%defm s data(qnum,tnum,$p(x,".",1,2))=%d
 q
 ;
getf2 ; get details for primary key (for indexed search)
 n ino
 s ino=$$pkey^%mgsqld(dbid,tname)
 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) s (key0(qnum,tnum),com)="" f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) s:x?1a.e x=%z("dsv")_alias_"."_x_%z("dsv") s key0(qnum,tnum)=key0(qnum,tnum)_com_x,com=","
 s %ref=$$ref^%mgsqld(dbid,tname,ino) s glb0(qnum,tnum)=%ref
 q
 ;
getfv ; emulate a proper file for dynamic views
 n %k,i,vnum,cname,com
 ;b
 s vnum=$p(tname,%z("dq"),2)
 s ino=$$pkey^%mgsqld(dbid,tname)
 s %k(1)="$j"
 s %k(2)="0"
 s %k(3)=vnum
 s %k(4)=%z("dsv")_alias_"."_"line-no"_%z("dsv")
 s %k="",com="" f i=1:1 q:'$d(%k(i))  s %k=%k_com_%k(i),com=","
 s (key0(qnum,tnum),^mgtmp($j,"key",qnum,tnum))=%k
 s (glb(qnum,tnum),glb0(qnum,tnum))=%z("ctg")
 s odel(qnum,tnum)="$c(1)"
 ; get details for view
 f i=1:1 q:'$d(^mgtmp($j,"v",vnum,i))  s cname=$g(^(i)) s data(qnum,tnum,alias_"."_at)="d\"_i_"\"
 q
 ;
spl ; reference for sqlspool
 n arc
 s arc=$$get^%mgsql(%qid,"arc")
 i arc="" s %spl="^[$p(%iv(""uci""),"","",1),$p(%iv(""uci""),"","",2)]sqlspool"
 i arc'="" s %spl="^["""_$p(arc,",",1)_""","""_$p(arc,",",2)_"""]sqlspool"
 q
 ;
xfid ; retrieve all indices and superclass for file fid
 k xfid
 s rc=$$ind^%mgsqld(dbid,tname,.%ind) s ino=$$pkey^%mgsqld(dbid,tname) i (ino="")!'$d(%ind(ino)) g xfidx
 s ino="" f  s ino=$o(%ind(ino)) q:ino=""  s xfid(ino)=%ind(ino) k %ind(ino) d xfid1
 s %d=$$tab^%mgsqld(dbid,tname) s dlm=$c(34)_$c($p(%d,"\",1)+0)_$c(34)
xfidx k %ind
 q
 ;
xfid1 ; retrieve data for index
 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 s xfidx=0 f i=1:1 q:'$d(%ind(ino,i))  s cname=%ind(ino,i),xfid(ino,i,1)=cname s:ino=$$pkey^%mgsqld(dbid,tname)&(cname?1a.e) xfidx=xfidx+1,xfidx(cname)=""
 i $d(%ind(ino,"t")) s xfid(ino,"t")=""
 k %ind(ino)
 q
 ;
dtyp ; get attribute details
 i cname'?1a.e q
 i $d(dtyp(cname)) q
 s %d=$$col^%mgsqld(dbid,tname,cname) s dtyp(cname)=$p(%d,"\",5)
 i $d(xfidx(cname)) q
 s %d=$$item^%mgsqld(dbid,tname,cname) i %d'="" s dtyp(cname,"e")=$p(%d,"\",2)_"~"_$p(%d,"\",1)
 q
 ;
