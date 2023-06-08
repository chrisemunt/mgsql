%mgsqlc4 ;(CM) sql compiler - restrictions ; 28 Jan 2022  9:58 AM
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
a d vers^%mgsql("%mgsqlc4") q
 ;
pre(dbid,qnum,tnum,item,data,dir,got,cond) ; preset subscript and determine stop condition(s)
 n i,preop,postop,sqlv,cname,op,other,link
 s dir=$g(dir(item)) i dir="" s dir=1
 s preop=$s(dir=-1:":=:']:<:'>:",1:":=:]:>:'<:")
 s postop=$s(dir=-1:":=:]:>:'<:",1:":=:']:<:'>:")
 s sqlv=$p(item,%z("dsv"),2),cname=$p(sqlv,".",2)
 s link="" f  s link=$o(^mgtmp($j,"pre",qnum,item,link)) q:link=""  d
 . f i=1:1 q:'$d(^mgtmp($j,"pre",qnum,item,link,i))  d
 . . s op=^mgtmp($j,"pre",qnum,item,link,i,"op"),other=^mgtmp($j,"pre",qnum,item,link,i,"cnst")
 . . s line=""
 . . d pre1(dbid,qnum,tnum,item,op,other,link,.got,.cond,preop,postop)
 . . ;d addpre(qnum,line,item,op,other,link,type,0,.cond)
 . . q
 . q
prex s link="" f  s link=$o(cond(item,"post",link)) q:link=""  i '$d(cond(item,"pre",link)) s cond(item,"pre",link)=" "_"s"_" "_item_"=""""",cond(item,"pre","nostrt")=""
 i '$d(cond(item,"pre",1)) s cond(item,"pre",1)=" "_"s"_" "_item_"=""""",cond(item,"pre","nostrt")="" i $d(cond(item,"pre",2)) s cond(item,"pre",1)=cond(item,"pre",2) k cond(item,"pre",2)
 k cond(item,"link")
 q
 ;
pre1(dbid,qnum,tnum,item,op,other,link,got,cond,preop,postop) ; evaluate restriction
 n type,mtype
 s line=""
 i '$$dep(qnum,line,item,op,other,.got) q
 i op="=" s line=" "_"s"_" "_item_op_other d addpre(qnum,line,item,op,other,link,"pre",1,.cond) q
 i postop[(":"_op_":") g pre2
 ; pre condition
 s line=$$preset(dbid,qnum,tnum,item,op,other)
 d addpre(qnum,line,item,op,other,link,"pre",0,.cond)
 q
pre2 ; post condition
 s line=$$post(dbid,qnum,tnum,item,op,other)
 d addpre(qnum,line,item,op,other,link,"post",0,.cond)
 q
 ;
preset(dbid,qnum,tnum,item,op,other) ; set up starting point for subscript
 s line=""
 i op=">"!(op="<") s line=" "_"s"_" "_item_"="_other q line
 i op="]" s line=" "_"s"_" "_item_"="_other q line
 s mtype=$$mtype(dbid,qnum,tnum,item,other)
 s ^mgtmp($j,"mtype",other)=mtype
 i op="'<",mtype="str" d  q line
 . i other?.1"-".n.1"."1n.n s line=" "_"s"_" "_item_"="_other_"-0.00001" q
 . s line=" "_"s"_" "_item_"="_$e(other,1,$l(other)-2)_$c($a(other,$l(other)-1)-1)_$c(34) q
 . q
 i op="'<",mtype="num" s line=" "_"s"_" "_item_"="_other_"-0.00001" q line
 i op="'<",mtype="var" s line=" "_"s"_":"_other_"?.1""-"".n.1"".""1n.n "_item_"="_other_"-0.00001 "_"s"_":"_other_"'?.1""-"".n.1"".""1n.n "_item_"="_"$e"_"("_other_",1,"_"$l"_"("_other_")-1)_"_"$c"_"("_"$a"_"("_"$e"_"("_other_","_"$l"_"("_other_")))-1)_""~""" q line
 i op="']"!(op="'>"),mtype="str" s line=" "_"s"_" "_item_"="_$e(other,1,$l(other)-2)_$c($a(other,$l(other)-1)+1)_$c(34) q line
 i op="']"!(op="'>"),mtype="num" s line=" "_"s"_" "_item_"="_other_"+0.00001" q line
 i op="']"!(op="'>"),mtype="var" s line=" "_"s"_":"_other_"?.1""-"".n.1"".""1n.n "_item_"="_other_"+0.00001 "_"s"_":"_other_"'?.1""-"".n.1"".""1n.n "_item_"="_"$e"_"("_other_",1,"_"$l"_"("_other_")-1)_"_"$c"_"("_"$a"_"("_"$e"_"("_other_","_"$l"_"("_other_")))+1)" q line
 q line
 ;
post(dbid,qnum,tnum,item,op,other) ; set up stop condition for subscript
 s line=""
 s mtype=$$mtype(dbid,qnum,tnum,item,other)
 s ^mgtmp($j,"mtype",other)=mtype
 i mtype="str" s line=" "_"i"_" "_$s(op="<":item_"="_other_"!("_item_"]"_other_")",op="'>":item_"]"_other,op="']":item_"]"_other,op=">":item_"']"_other,op="]":item_"']"_other,op="'<":item_"'="_other_","_item_"']"_other,1:"") q line
 i mtype="num" s line=" "_"i"_" "_$s(op="<":item_"'<"_other,op="'>":item_">"_other,op="']":item_"="_other_"!("_item_"]"_other_")",op=">":item_"'>"_other,op="]":item_"'>"_other,op="'<":item_"'="_other_","_item_"'>"_other,1:"") q line
 i mtype="var",op="]"!(op=">") s line=" "_"k"_" %s "_"s"_" %s("_item_")="""",%xx="_"$o"_"(%s("_other_")) "_"k"_" %s "_"i"_" %xx'="_item q line
 i mtype="var",op="'<" s line=" "_"i"_" "_"$l"_"("_other_") "_"k"_" %s "_"s"_" %s("_item_")="""",%xx="_"$o"_"(%s("_other_"),-1) "_"k"_" %s "_"i"_" %xx="_item q line
 i mtype="var",op="<" s line=" "_"k"_" %s "_"s"_" %s("_item_")="""",%xx="_"$o"_"(%s("_other_"),-1) "_"k"_" %s "_"i"_" %xx'="_item q line
 i mtype="var",op="']"!(op="'>") s line=" "_"i"_" "_"$l"_"("_other_") "_"k"_" %s "_"s"_" %s("_item_")="""",%xx="_"$o"_"(%s("_other_")) "_"k"_" %s "_"i"_" %xx="_item q line
 q line
 ;
dep(qnum,line,item,op,other,got) ; look for (bad) dependencies and bind sub-queries if necessary
 n i,sqvar,qnum1,subvar,ok
 s ok=1
 f i=2:2 s sqvar=$p(other,%z("dsv"),i) q:sqvar=""  s ok=$$got(qnum,sqvar,.got) i 'ok q
 i 'ok q 0
 f  q:other'[%z("dq")  s qnum1=$p(other,%z("dq"),2) s ok=$$gotsq(qnum,qnum1,.got,.subvar) q:'ok  s other=$p(other,%z("dq"),1)_subvar_$p(other,%z("dq"),3,999)
 i 'ok q 0
 q 1
 ;
got(qnum,sqvar,got) ; check that data restricted upon is available
 n alias,cname
 s alias=$p(sqvar,".",1),cname=$p(sqvar,".",2)
 i alias="" q 1
 i qnum>1,'$d(^mgtmp($j,"from","x",qnum,alias)) q 1 ; coorelated sq, must be ok
 i '$d(got("f",alias)),'$d(got("a",sqvar)) q 0
 q 1
 ;
gotsq(qnum,qnum1,got,subvar) ; look for availability of data from subquery
 n alias1,sqvar1,notgot,cmax,x,ok
 s subvar=""
 s cmax=0,x="" f  s cmax=$o(^mgtmp($j,"corel",qnum,x)) q:x=""  s cmax=x
 i cmax>0,qnum1=cmax,^mgtmp($j,"corel",qnum,qnum1)'=1 q 0
 s alias1="" f  s alias1=$o(^mgtmp($j,"corel",qnum,qnum1,alias1)) q:alias1=""  i '$d(got("f",alias1)) s notgot(alias1)=""
 s alias1="" f  s alias1=$o(notgot(alias1)) q:alias1=""!'ok  d
 . s sqvar1=""
 . f  s sqvar1=$o(^mgtmp($j,"corel",qnum,qnum1,alias1,sqvar1)) q:sqvar1=""  i '$d(got("a",sqvar1)) s ok=0 q
 . q
 i 'ok q 0
 s subvar=^mgtmp($j,"sel",qnum1,1)
 q 1
 ;
addpre(qnum,line,item,op,other,link,type,fixed,cond) ; add line of code to subscript initialisation array
 n ln
 i line="" q
 s ^mgtmp($j,"wexcl",qnum,item_op_other)="",^(other_op_item)=""
 i '$d(cond(item)) s cond(item)=0
 i '$d(cond(item,"link",link)) s ln=$i(cond(item)),cond(item,"link",link)=ln
 s ln=cond(item,"link",link)
 s cond(item,type,ln)=line
 i fixed s cond(item,"fixed",ln)=""
 q
 ;
mtype(dbid,qnum,tnum,item,other) ; determine sort of data
 n %d,tname,cname,mtype
 s %d=^mgtmp($j,"from",qnum,tnum)
 s tname=$p(%d,"~",1)
 s cname=$p($p(item,%z("dsv"),2),".",2)
 s %d=$$col^%mgsqld(dbid,tname,cname) s mtype=$p(%d,"\",11)
 i mtype'="",other[%z("dev"),mtype="str" s mtype="var" q mtype
 i other?1"""".e s mtype="str" q mtype
 i other?.1"-".n.1"."1n.n s mtype="num" q mtype
 s mtype="var"
 q mtype
 ;
