%mgsqlc5 ;(CM) sql compiler - get data ; 19 jan 2003  4:34 pm
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
a d vers^%mgsql("%mgsqlc5") q
 ;
keyidx ; file key for index
 n y,z,i
 s y=$g(key0(qnum,tnum)) i y="" q
 f i=1:1:$l(y,",") s z=$p($p(y,",",i),%z("dsv"),2) i z'="" s ^mgtmp($j,"get",z)=""
 q
 ;
data ; retrieve required data from file
 n fno,sqat
 d keyidx
 ; cmtaaa
 ;i $d(^mgtmp($j,"from","z",qnum,"def",tnum)) d
 ;. s line=" "_"s"_" "_^mgtmp($j,"from","z",qnum,"def",tnum)_"=1" d addline^%mgsqlc(grp,.line)
 ;. q
 ;
 i $g(^mgtmp($j,"dontgetdata",qnum,tnum))=1 q
 i $d(^mgtmp($j,"from","z",qnum,"pass",alias)) d ojda^%mgsqlc1
 s zglo=glb0(qnum,tnum),zgloz=$s(zglo[%z("dev"):""")",1:"")
 s zkey=key0(qnum,tnum)
 s subt="" i qnum=1,unique(1)=2 s subt=%z("vdef")
 i $d(data(qnum,tnum)) s glo=zglo,key=zkey,dat=%z("vdata"),fail=$s($d(tag(qnum)):" g "_tag(qnum),1:"") d g^%mgsqlci
 s x="" f  s x=$o(data(qnum,tnum,x)) q:x=""  d data1
 i $d(^mgtmp($j,"from","z",qnum,"pass",alias)) d ojdz^%mgsqlc1
 d corel
 q
 ;
data1 ; retrieve data item or just check if in parsed index
 n sm,ssubs,pce
 s ^mgtmp($j,"get",x)=""
 s sqat=x i $l(sqat,".")>2 s sqat=$p(sqat,".",1,2) i $d(data(qnum,tnum,sqat))#10 q
 i key0(qnum,tnum)[(%z("dsv")_sqat_%z("dsv")) q  ; primary key
 s pce=$p(data(qnum,tnum,x),"\",1),sm=$p(data(qnum,tnum,x),"\",3),ssubs=$g(data(qnum,tnum,x,"s"))
 i pce="" s line=" s "_%z("dsv")_sqat_%z("dsv")_"=""""" g data1x
 i sm="d",$l(odel(qnum,tnum)) s line="$p"_"("_%z("vdata")_","_odel(qnum,tnum)_","_pce_")"
 i sm="d",'$l(odel(qnum,tnum)) s line=%z("vdata")
 i sm="s",$l(subt) s line=" s %ds=""""" d addline^%mgsqlc(grp,.line)
 i sm="s" s glo=zglo,key=zkey_","_ssubs,dat="%ds",fail="" d g^%mgsqlci s line="%ds"
 i z[(%z("dsv")_x_%z("dsv")) s line=" "_"i"_" "_line_"'="_%z("dsv")_sqat_%z("dsv")_" "_"s"_" ^sqlerr("_$c(34)_tname_$c(34)_","_z_")="""" "_"g"_" "_tag(qnum)
 i z'[(%z("dsv")_x_%z("dsv")) s line=" "_"s"_" "_%z("dsv")_sqat_%z("dsv")_"="_line
data1x d addline^%mgsqlc(grp,.line)
 q
 ;
corel ; provide calls to correlated sub-queries
 n i,alias,ok,notgot,qnum1,com,sqvar,line,cmax,x
 s qnum1="",line="",com=""
corel1 s qnum1=$o(corel(qnum,qnum1)) i qnum1="" g corelx
 i corel(qnum,qnum1) g corel1
 s alias="" f  s alias=$o(corel(qnum,qnum1,alias)) q:alias=""  i '$d(got("f",alias)) s notgot(alias)=""
 s ok=1 s alias="" f  s alias=$o(notgot(alias)) q:alias=""!'ok  s sqvar="" f  s sqvar=$o(corel(qnum,qnum1,alias,sqvar)) q:sqvar=""  i '$d(got("a",sqvar)) s ok=0 q
 i 'ok g corel1
 s cmax=0,x="" f  s x=$o(corel("x",qnum1,x)) q:x=""  s cmax=x
 i cmax>0,qnum'=cmax g corel1
 s line=%z("dl")_%z("pt")_qnum1_"s"_%z("dl")_com_line,com=",",corel(qnum,qnum1)=1
 g corel1
corelx i $l(line) s line=" d "_line d addline^%mgsqlc(grp,.line)
 q
 ;
crind ; create required index
 s r=create("index"),tname=$p(r,"~",1),idx=$p(r,"~",2)
 s alias=$p(tname," ",2),tname=$p(tname," ",1)
 s ino=idx s %ref=$$ref^%mgsqld(dbid,tname,ino) s ref=%ref_"(",test="",comr="",comt=""
 s ino=idx s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(idx,i))  s (cname,xd)=%ind(idx,i) k %ind(idx,i) s:cname?1a.e xd=%z("dsv")_alias_"."_cname_%z("dsv") s ref=ref_comr_xd,comr="," i xd[%z("dsv") s ino=$$pkey^%mgsqld(dbid,tname) s %def=$$defkdi^%mgsqld(dbid,tname,cname,ino) i '%def s test=test_comt_"$l("_xd_")",comt=","
 i $l(test) s line=" i "_test
 s line=line_" s "_ref_")=""""" d addline^%mgsqlc(grp,.line)
 s line=" g "_tag(qnum) d addline^%mgsqlc(grp,.line)
 k %ind,r,tname,alias,ref,x,xd,test,comr,comt,idx
 q
 ;
klind ; kill off index to be created
 s r=create("index"),tname=$p(r,"~",1),idx=$p(r,"~",2)
 s alias=$p(tname," ",2),tname=$p(tname," ",1)
 s line="",com=""
 s ino=idx s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(idx,i))  s x=%idx(idx,i) k %idx(idx,i) q:x?1a.e  s line=line_com_x,com=","
 i $l(line) s line="("_line_")"
 s ino=idx s %ref=$$ref^%mgsqld(dbid,tname,ino) s line=" k "_%ref_line d addline^%mgsqlc(grp,.line)
 k %ind,r,tname,alias,idx,x
 q
 ;
 
 
