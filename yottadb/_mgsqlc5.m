%mgsqlc5 ;(CM) sql compiler - get data ; 28 Jan 2022  9:58 AM
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2022 M/Gateway Developments Ltd,                      |
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
keyidx(qnum,tnum) ; file key for index
 n y,z,i
 s y=$g(data(qnum,tnum,"pkey")) i y="" q
 f i=1:1:$l(y,",") s z=$p($p(y,",",i),%z("dsv"),2) i z'="" s ^mgtmp($j,"get",z)=""
 q
 ;
data(grp,qnum,tnum,data,got,error) ; retrieve required data from file
 n col,pkey,zglo,zgloz,zkey,subt,fail,col
 s pkey=data(qnum,tnum,"pkey")
 d keyidx(qnum,tnum)
 i $g(^mgtmp($j,"dontgetdata",qnum,tnum))=1 q
 i $d(^mgtmp($j,"from","z",qnum,"pass",alias)) d ojoinda^%mgsqlc1(grp,qnum,tnum,.data,.error)
 s zglo=data(qnum,tnum,"pglo"),zgloz=$s(zglo[%z("dev"):""")",1:"")
 s zkey=data(qnum,tnum,"pkey")
 s subt="" i qnum=1,$g(^mgtmp($j,"unique",1))=2 s subt=%z("vdef")
 i $d(data(qnum,tnum,"col")) s fail=$s($d(%zq("tag",qnum)):" g "_%zq("tag",qnum),1:"") d g^%mgsqlci(grp,subt,%z("vdata"),zglo,zkey,zgloz)
 s col="" f  s col=$o(data(qnum,tnum,"col",col)) q:col=""  d data1(grp,qnum,tnum,col,%z("vdata"),.data,.error)
 i $d(^mgtmp($j,"from","z",qnum,"pass",alias)) d ojoindz^%mgsqlc1(grp,qnum,tnum,.data,.error)
 d corelate(grp,qnum,.got)
 q
 ;
data1(grp,qnum,tnum,col,dstr,data,error) ; retrieve data item or just check if in parsed index
 n sm,ssubs,pce,fail,pkey,pglo,key,subt,ssubs,derv
 s ^mgtmp($j,"get",col)=""
 s pkey=data(qnum,tnum,"pkey"),pglo=data(qnum,tnum,"pglo")
 s subt="" i qnum=1,$g(^mgtmp($j,"unique",1))=2 s subt=%z("vdef")
 i $l(col,".")>2 s col=$p(col,".",1,2) i $d(data(qnum,tnum,"col",col))#10 q
 i data(qnum,tnum,"pkey")[(%z("dsv")_col_%z("dsv")) q  ; primary key
 s pce=$p(data(qnum,tnum,"col",col),"\",1),sm=$p(data(qnum,tnum,"col",col),"\",3)
 s ssubs=$g(data(qnum,tnum,"col",col,"s")),derv=$g(data(qnum,tnum,"col",col,"d"))
 i derv'="" d derv(grp,qnum,tnum,col,dstr,derv,.data,.error) q
 i pce="" s line=" s "_%z("dsv")_col_%z("dsv")_"=""""" g data1x
 i sm="d",$l(data(qnum,tnum,"dlm")) s line="$p"_"("_dstr_","_data(qnum,tnum,"dlm")_","_pce_")"
 i sm="d",'$l(data(qnum,tnum,"dlm")) s line=dstr
 i sm="s",$l(subt) s line=" s %ds=""""" d addline^%mgsqlc(grp,.line)
 i sm="s" s key=pkey_","_ssubs,dat="%ds",fail="" d g^%mgsqlci(grp,subt,dat,pglo,key,"") s line="%ds"
 i pkey[(%z("dsv")_col_%z("dsv")) s line=" "_"i"_" "_line_"'="_%z("dsv")_sqat_%z("dsv")_" "_"s"_" ^sqlerr("_$c(34)_tname_$c(34)_","_pkey_")="""" "_"g"_" "_%zq("tag",qnum)
 i pkey'[(%z("dsv")_col_%z("dsv")) s line=" "_"s"_" "_%z("dsv")_col_%z("dsv")_"="_line
data1x d addline^%mgsqlc(grp,.line)
 q
 ;
derv(grp,qnum,tnum,col,dstr,derv,data,error) ; derived column
 n %d,tname,alias,cn,pn,cname,ex,outv,word,zcode,fun,arg
 s %d=^mgtmp($j,"from",qnum,tnum)
 s tname=$p(%d,"~",1),alias=$p(%d,"~",2)
 s ex(1)="$$"_derv d ex^%mgsqle(col,.ex,.word,.zcode,.fun,.error) i $l(error) q
 f cn=1:1 q:'$d(zcode(cn))  f pn=4:2 s cname=$p(zcode(cn),%z("dsv"),pn) q:cname=""  d
 . s arg=alias_"."_cname
 . s $p(zcode(cn),%z("dsv"),pn)=arg
 . i '$d(^mgtmp($j,"get",arg)) d data1(grp,qnum,tnum,arg,dstr,.data,.error)
 . q
 f cn=1:1 q:'$d(zcode(cn))  s line=zcode(cn) d addline^%mgsqlc(grp,.line)
 q
 ;
corelate(grp,qnum,got) ; provide calls to correlated sub-queries
 n i,alias,ok,notgot,qnum1,com,sqvar,line,cmax,x
 s qnum1="",line="",com=""
 f  s qnum1=$o(^mgtmp($j,"corel",qnum,qnum1)) q:qnum1=""  d
 . i ^mgtmp($j,"corel",qnum,qnum1) q
 . s alias="" f  s alias=$o(^mgtmp($j,"corel",qnum,qnum1,alias)) q:alias=""  i '$d(got("f",alias)) s notgot(alias)=""
 . s ok=1 s alias="" f  s alias=$o(notgot(alias)) q:alias=""!'ok  s sqvar="" f  s sqvar=$o(^mgtmp($j,"corel",qnum,qnum1,alias,sqvar)) q:sqvar=""  i '$d(got("a",sqvar)) s ok=0 q
 . i 'ok q
 . s cmax=0,x="" f  s x=$o(^mgtmp($j,"corelx",qnum1,x)) q:x=""  s cmax=x
 . i cmax>0,qnum'=cmax q
 . s line=%z("dl")_%z("pt")_qnum1_"s"_%z("dl")_com_line,com=",",^mgtmp($j,"corel",qnum,qnum1)=1
 . q
 i $l(line) s line=" d "_line d addline^%mgsqlc(grp,.line)
 q
 ;
crind(grp,qnum) ; create required index
 n %def,%ind,%ref,r,tname,alias,ref,x,xd,test,comr,comt,idx,ino,sc
 s r=^mgtmp($j,"create","index"),tname=$p(r,"~",1),idx=$p(r,"~",2)
 s alias=$p(tname," ",2),tname=$p(tname," ",1)
 s ino=idx s %ref=$$ref^%mgsqld(dbid,tname,ino) s ref=%ref_"(",test="",comr="",comt=""
 s ino=idx s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(idx,i))  d
 . s (cname,xd)=%ind(idx,i)
 . k %ind(idx,i)
 . i cname?1a.e s xd=%z("dsv")_alias_"."_cname_%z("dsv")
 . s ref=ref_comr_xd,comr=","
 . i xd[%z("dsv") s ino=$$pkey^%mgsqld(dbid,tname) s %def=$$defkdi^%mgsqld(dbid,tname,cname,ino) i '%def s test=test_comt_"$l("_xd_")",comt=","
 . q
 i $l(test) s line=" i "_test
 s line=line_" s "_ref_")=""""" d addline^%mgsqlc(grp,.line)
 s line=" g "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line)
 q
 ;
klind(grp,qnum) ; kill off index to be created
 k %ind,%ref,r,tname,alias,idx,x,com,ino,i
 s r=^mgtmp($j,"create","index"),tname=$p(r,"~",1),idx=$p(r,"~",2)
 s alias=$p(tname," ",2),tname=$p(tname," ",1)
 s line="",com=""
 s ino=idx s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) f i=1:1 q:'$d(%ind(idx,i))  s x=%idx(idx,i) k %idx(idx,i) q:x?1a.e  s line=line_com_x,com=","
 i $l(line) s line="("_line_")"
 s ino=idx s %ref=$$ref^%mgsqld(dbid,tname,ino) s line=" k "_%ref_line d addline^%mgsqlc(grp,.line)
 q
 ;
