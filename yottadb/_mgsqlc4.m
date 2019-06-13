%mgsqlc4 ;(CM) sql compiler - restrictions ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlc4") q
 ;
dep ; look for (bad) dependencies and bind sub-queries if necessary
 n i,sqvar,qnum1,subvar
 s ok=1
 f i=2:2 s sqvar=$p(other,%z("dsv"),i) q:sqvar=""  d got i 'ok q
 i 'ok q
 f  q:other'[%z("dq")  s qnum1=$p(other,%z("dq"),2) d gotsq q:'ok  s other=$p(other,%z("dq"),1)_subvar_$p(other,%z("dq"),3,999)
 i 'ok q
 q
 ;
got ; check that data restricted upon is available
 n i,ii,alias,cname,eno,sqvar1
 s sqvar1=sqvar,alias=$p(sqvar,".",1),cname=$p(sqvar,".",2)
 i $l(alias) d got1 q
 q
 ;
got1 ; look for evaluation of one alias
 i qnum>1,'$d(^mgtmp($j,"from","x",qnum,alias)) q  ; coorelated sq, must be ok
 i '$d(got("f",alias)),'$d(got("a",sqvar1)) s ok=0 q
 q
 ;
gotsq ; look for availability of data from subquery
 n alias1,sqvar1,notgot,cmax,x
 s subvar=""
 s cmax=0,x="" f  s cmax=$o(corel(qnum,x)) q:x=""  s cmax=x
 i cmax>0,qnum1=cmax,corel(qnum,qnum1)'=1 s ok=0 q
 s alias1="" f  s alias1=$o(corel(qnum,qnum1,alias1)) q:alias1=""  i '$d(got("f",alias1)) s notgot(alias1)=""
 s alias1="" f  s alias1=$o(notgot(alias1)) q:alias1=""!'ok  s sqvar1="" f  s sqvar1=$o(corel(qnum,qnum1,alias1,sqvar1)) q:sqvar1=""  i '$d(got("a",sqvar1)) s ok=0 q
 i 'ok q
 s subvar=^mgtmp($j,"sel",qnum1,1)
 q
 ;
pre ; preset subscript and determine stop condition(s)
 k pre(y),nopas(y)
 s lo=":]:>:'<:",hi=":']:<:'>:",cond=lo_"="_hi
 s preop=$s(dir="$zp":":=:']:<:'>:",1:":=:]:>:'<:")
 s postop=$s(dir="$zp":":=:]:>:'<:",1:":=:']:<:'>:")
 s sqlv=$p(y,%z("dsv"),2),cname=$p(sqlv,".",2)
 s other="" f ii=tnum-1:-1:1 s alias1=$p(^mgtmp($j,"from",qnum,ii),"~",2) i $d(joinx(qnum,cname,alias1)),'$d(^mgtmp($j,"from","z",qnum,"pass",alias1)) s other=%z("dsv")_alias1_"."_cname_%z("dsv") q
 i $l(other) s op="=",link=0 d pre1 g prex
 s link="" f  s link=$o(^mgtmp($j,"pre",qnum,y,link)) q:link=""  f iii=1:1 q:'$d(^mgtmp($j,"pre",qnum,y,link,iii))  s op=^(iii,"op"),other=^("cnst") d pre1,addpre
prex i 'con s link="" f  s link=$o(pre(y,"post",link)) q:link=""  i '$d(pre(y,"pre",link)) s pre(y,"pre",link)=" "_"s"_" "_y_"=""""",pre(y,"pre","nostrt")=""
 i 'con,'$d(pre(y,"pre",1)) s pre(y,"pre",1)=" "_"s"_" "_y_"=""""",pre(y,"pre","nostrt")="" i $d(pre(y,"pre",2)) s pre(y,"pre",1)=pre(y,"pre",2) k pre(y,"pre",2)
 k pre(y,"link")
 q
 ;
pre1 ; evaluate restriction
 s line="" ;g cm
 d dep i 'ok q
 g cm
 i other[%z("dsv"),$l($p($p(other,%z("dsv"),2),".",1)) i count=1,tnum=1,qnum=1 q
 i other[%z("dsv"),other["(" d gotsq i 'ok s nopas=0 q
 i other[%z("dsv"),other'["(" s okf=0 f ii=2:2 s zz=$p(other,%z("dsv"),ii) q:zz=""  d got
 i other[%z("dsv"),other'["(",'okf k zz,okf,otf,tnummx q
cm k zz,okf,otf,tnummx
 i op="=",'con s line=" "_"s"_" "_y_op_other,type="pre",nopas=1 d addpre q
 i op="=",con s line=" "_"i"_" "_y_"<"_other_"!("_other_"]"_y_")",strt=other,%k="%k",type="pre",nopas=1 d addpre s line=" "_"i"_" "_y_"'"_op_other,type="post",nopas=0 d addpre q
 s nopas=0
 i postop[(":"_op_":") g post
 ;
preset ; set up starting point for subscript
 s type="pre" i con g presetc ; concatenated keys
 i op=">"!(op="<") s line=" "_"s"_" "_y_"="_other q
 i op="]" s line=" "_"s"_" "_y_"="_other q
 d sort
 s typ(other)=typ
 ; cmtaaa
 i op="'<",typ="string" d  q
 . i other?.1"-".n.1"."1n.n s line=" "_"s"_" "_y_"="_other_"-0.00001" q
 . s line=" "_"s"_" "_y_"="_$e(other,1,$l(other)-2)_$c($a(other,$l(other)-1)-1)_$c(34) q
 . q
 i op="'<",typ="numeric"!(typ="float") s line=" "_"s"_" "_y_"="_other_"-0.00001" q
 i op="'<",typ="mixed" s line=" "_"s"_":"_other_"?.1""-"".n.1"".""1n.n "_y_"="_other_"-0.00001 "_"s"_":"_other_"'?.1""-"".n.1"".""1n.n "_y_"="_"$e"_"("_other_",1,"_"$l"_"("_other_")-1)_"_"$c"_"("_"$a"_"("_"$e"_"("_other_","_"$l"_"("_other_")))-1)_""~""" q
 i op="']"!(op="'>"),typ="string" s line=" "_"s"_" "_y_"="_$e(other,1,$l(other)-2)_$c($a(other,$l(other)-1)+1)_$c(34) q
 i op="']"!(op="'>"),typ="numeric"!(typ="float") s line=" "_"s"_" "_y_"="_other_"+0.00001" q
 i op="']"!(op="'>"),typ="mixed" s line=" "_"s"_":"_other_"?.1""-"".n.1"".""1n.n "_y_"="_other_"+0.00001 "_"s"_":"_other_"'?.1""-"".n.1"".""1n.n "_y_"="_"$e"_"("_other_",1,"_"$l"_"("_other_")-1)_"_"$c"_"("_"$a"_"("_"$e"_"("_other_","_"$l"_"("_other_")))+1)" q
 q
 ;
presetc ; starting point and pre-test for concatenated keys
 s strt=""
 i op=">"!(op="<")!(op="]") s line=" "_"i"_" "_y_"'"_op_other,strt=other,%k="%k_""~""" q
 d sort
 s typ(other)=typ
 i op="'<" s line=" "_"i"_" "_y_"<"_other,strt=other,%k="%k" q
 i op="']"!(op="'>") s line=" "_"i"_" "_y_"'"_$e(op,2)_other,strt=other,%k="%k" q
 q
 ;
post ; set up stop condition for subscript
 s type="post"
 d sort
 s typ(other)=typ
 i typ="string" s line=" "_"i"_" "_$s(op="<":y_"="_other_"!("_y_"]"_other_")",op="'>":y_"]"_other,op="']":y_"]"_other,op=">":y_"']"_other,op="]":y_"']"_other,op="'<":y_"'="_other_","_y_"']"_other,1:"") q
 i typ="numeric"!(typ="float") s line=" "_"i"_" "_$s(op="<":y_"'<"_other,op="'>":y_">"_other,op="']":y_"="_other_"!("_y_"]"_other_")",op=">":y_"'>"_other,op="]":y_"'>"_other,op="'<":y_"'="_other_","_y_"'>"_other,1:"") q
 i typ="mixed",op="]"!(op=">") s line=" "_"k"_" %s "_"s"_" %s("_y_")="""",%xx="_"$o"_"(%s("_other_")) "_"k"_" %s "_"i"_" %xx'="_y q
 i typ="mixed",op="'<" s line=" "_"i"_" "_"$l"_"("_other_") "_"k"_" %s "_"s"_" %s("_y_")="""",%xx="_"$o"_"(%s("_other_"),-1) "_"k"_" %s "_"i"_" %xx="_y q
 i typ="mixed",op="<" s line=" "_"k"_" %s "_"s"_" %s("_y_")="""",%xx="_"$o"_"(%s("_other_"),-1) "_"k"_" %s "_"i"_" %xx'="_y q
 i typ="mixed",op="']"!(op="'>") s line=" "_"i"_" "_"$l"_"("_other_") "_"k"_" %s "_"s"_" %s("_y_")="""",%xx="_"$o"_"(%s("_other_")) "_"k"_" %s "_"i"_" %xx="_y q
 q
 ;
addpre ; add line of code to subscript initialisation array
 n l
 i line="" q
 i '$d(seq(alias)) s ^mgtmp($j,"wexcl",qnum,y_op_other)="",^(other_op_y)=""
 i '$d(pre(y)) s pre(y)=0
 i '$d(pre(y,"link",link)) s l=pre(y)+1,pre(y)=l,pre(y,"link",link)=l
 s l=pre(y,"link",link)
 s pre(y,type,l)=line
 i con,type="pre",$l(strt) s pre(y,"strt",l)=strt,pre(y,"%k",l)=%k
 i nopas s nopas(y,l)=""
 q
 ;
sort ; determine sort of data
 s cname=$p($p(y,%z("dsv"),2),".",2) s %d=$$col^%mgsqld(dbid,tname,cname) k cname s typ=$p(%d,"\",11) i $l(typ) s:other[%z("dev")&(typ="string") typ="mixed" q
 i other?1"""".e s typ="string" q
 i other?.1"-".n.1"."1n.n s typ="numeric" q
 s typ="mixed"
 q
 ;
 
