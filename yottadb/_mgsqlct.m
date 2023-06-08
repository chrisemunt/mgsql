%mgsqlct ;(CM) sql compiler - get table details ; 28 Jan 2022  9:59 AM
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
a d vers^%mgsql("%mgsqlct") q
 ;
table(dbid,qnum,data,error) ; get file particulars for each alias
 n tnum
 f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))  d table1(dbid,qnum,tnum,.data,.error) i $l(error) q
 q
 ;
table1(dbid,qnum,tnum,data,error) ; get file particulars for alias alias (fid)
 n %d,%dv,%ref,%s,i,x,y,z,tname,alias,ino,dlm,pk,glo,com
 s %d=^mgtmp($j,"from",qnum,tnum)
 s tname=$p(%d,"~",1),alias=$p(%d,"~",2)
 s pk=$$pkey^%mgsqld(dbid,tname)
 s ino=pk i $d(^mgtmp($j,"from","i",0,alias)) s ino=^mgtmp($j,"from","i",0,alias)
 s %d=$$tab^%mgsqld(dbid,tname),%ref=$$ref^%mgsqld(dbid,tname,.ino),glo=%ref
 s dlm=$p(%d,"\",1)
 i dlm?1n.n,dlm>31,dlm<127 s dlm=""""_$c(dlm)_""""
 i dlm?1n.n,dlm<32!dlm>126 s dlm="$char("_dlm_")"
 s data(qnum,tnum,"dlm")=dlm
 s data(qnum,tnum,"glo")=glo
 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 s (z,com)="" f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) s:x?1a.e x=%z("dsv")_alias_"."_x_%z("dsv") s z=z_com_x,com=","
 s data(qnum,tnum,"key")=z
 i ino=pk s data(qnum,tnum,"pkey")=data(qnum,tnum,"key"),data(qnum,tnum,"pglo")=glo
 i ino'=pk d table2
 f i=1:1 q:'$d(^mgtmp($j,"sel",qnum,i))  s x=$p(^mgtmp($j,"sel",qnum,i),%z("dsv"),2)  d table3
 s y="" f  s y=$o(^mgtmp($j,"from","z",qnum,"join",y)) q:y=""  i $d(^mgtmp($j,"from","z",qnum,"join",y,alias)) s x=alias_"."_y d table3
 s cname="" f  s cname=$o(^mgtmp($j,"join",qnum,alias,cname)) q:cname=""  d
 . s %d=$$item^%mgsqld(dbid,tname,cname),%s=$$seps^%mgsqld(dbid,tname,cname),%dv=$$derv^%mgsqld(dbid,tname,cname)
 . s data(qnum,tnum,"col",alias_"."_at)=%d
 . s data(qnum,tnum,"col",alias_"."_at,"s")=%s
 . i %dv'="" s data(qnum,tnum,"col",alias_"."_at,"d")=%dv
 . q
 i $l(error) q
 q
 ;
table2 ; get details for primary key (for indexed search)
 n ino
 s ino=$$pkey^%mgsqld(dbid,tname)
 s sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 s data(qnum,tnum,"pkey")="",com=""
 f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) k %ind(ino,i) s:x?1a.e x=%z("dsv")_alias_"."_x_%z("dsv") s data(qnum,tnum,"pkey")=data(qnum,tnum,"pkey")_com_x,com=","
 s %ref=$$ref^%mgsqld(dbid,tname,ino) s data(qnum,tnum,"pglo")=%ref
 q
 ;
table3 ; process data item to be retrieved/derived
 i x="*" q
 i x["(",x[")" s x=$p($p(x,"(",2),")",1)
 s cname=x,ext="",f=""
 i x["." s cname=$p(x,".",2),f=$p(x,".",1)
 i f'=alias,f'=alias_"g" q
 s %d=$$item^%mgsqld(dbid,tname,cname),%s=$$seps^%mgsqld(dbid,tname,cname),%dv=$$derv^%mgsqld(dbid,tname,cname)
 s %defm=$$remap^%mgsqlv2(f,cname)
 i (%d'="")!%defm s data(qnum,tnum,"col",$p(x,".",1,2))=%d,data(qnum,tnum,"col",$p(x,".",1,2),"s")=%s,data(qnum,tnum,"col",$p(x,".",1,2),"d")=%dv
 q
 ;
xfid ; retrieve all indices for table
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
 k %ind(ino)
 q
 ;
dtyp ; get attribute details
 i cname'?1a.e q
 i $d(dtyp(cname)) q
 s %d=$$col^%mgsqld(dbid,tname,cname) s dtyp(cname)=$p(%d,"\",5)
 i $d(xfidx(cname)) q
 s %d=$$item^%mgsqld(dbid,tname,cname) i %d'="" s dtyp(cname,"e")=%d
 q
 ;
