%mgsqlv6 ;(CM) sql - set expansion ; 12 feb 2002  02:10pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2020 M/Gateway Developments Ltd,                      |
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
a d vers^%mgsql("%mgsqlv6") q
 ;
link ; expand where statement for set expansion link
 n at,man,alias
 i '$d(%link(qnum)) q
 s cname="" f i=0:0 s cname=$o(%link(qnum,cname)) q:cname=""  s alias="" f i=0:0 s alias=$o(%link(qnum,cname,alias)) q:alias=""  i $d(%link(qnum,cname,alias,"man")) s man(cname)=""
 s cname="" f i=0:0 s cname=$o(man(cname)) q:cname=""  s alias="" f i=0:0 s alias=$o(%link(qnum,cname,alias)) q:alias=""  s %link(qnum,cname,alias,"man")=""
 s cname="" f i=0:0 s cname=$o(%link(qnum,cname)) q:cname=""  s alias="" f i=0:0 s alias=$o(%link(qnum,cname,alias)) q:alias=""  d link1
 s cname="" f i=0:0 s cname=$o(%link(qnum,cname)) q:cname=""  i '$d(%link("done",qnum,cname)) d link4
 f i=1:1 q:'$d(^mgtmp($j,"sel",qnum,i))  s var=^(i) d links
linkx ;
 q
 ;
link1 ; expand where
 n tname,lnkat,strt,end
 s sqvar=alias_"."_cname,tname=%link(qnum,cname,alias),lnkat=$p(tname,".",2),tname=$p(tname,".",1)
 f i=1:1 q:'$d(word(0,i))  i i>1,word(0,i)="=",$d(word(0,i+1)) s x=word(0,i-1),y=word(0,i+1) d link2 i $d(cnst(0)) q
 i '$d(cnst(0)) q
 s %link("done",qnum,cname)=""
 s two=$d(%link(qnum,cname,alias,"man")) d link3
 f i=end+1:1 q:'$d(word(0,i))  s end(i-end)=word(0,i)
 s alias1=$o(%link(qnum,cname,alias,"a","")),alias2=$o(%link(qnum,cname,alias,"a",alias1)),%link("ord",qnum,alias1)="" i $l(alias2) s %link("ord",qnum,alias2)=""
 s l=strt
 s x="(" d link11 s x=%z("dsv")_alias1_"."_cname_%z("dsv") d link11 s x="=" d link11
 s i="" f  s i=$o(cnst(0,i)) q:i=""  s x=cnst(0,i) d link11
 s x=")" d link11 i '$l(alias2) d link12 g link13
 s x="&" d link11 s x="(" d link11 s x=%z("dsv")_alias2_"."_lnkat_%z("dsv") d link11 s x="=" d link11 s x=%z("dsv")_alias1_"."_lnkat_%z("dsv") d link11 s x=")" d link11
 s x="&" d link11 s x="(" d link11 s x=%z("dsv")_sqvar_%z("dsv") d link11 s x="=" d link11 s x=%z("dsv")_alias2_"."_cname_%z("dsv") d link11 s x=")" d link11
link13 f i=1:1 q:'$d(end(i))  s x=end(i) d link11
 q
 ;
link11 ; add processed word to where statement
 s word(0,l)=x,l=l+1
 q
 ;
link12 ; specific and unique
 s x="&" d link11 s x="(" d link11 s x=%z("dsv")_sqvar_%z("dsv") d link11 s x="=" d link11 s x=%z("dsv")_alias1_"."_lnkat_%z("dsv") d link11 s x=")" d link11
 q
 ;
link2 ; extract constant/expression
 n j,n,n1,n2,z,obr,cbr
 k cnst(0)
 s n1=0 i $e(x,1,3)=%z("dsv"),x'[" " s x=$p(x,%z("dsv"),2) i x?1a.e1"."1a.e,$d(%link(qnum,$p(x,".",2),$p(x,".",1))) s n1=i+1,n=1,cnst=y i y[%z("dsv") q
 i $e(y,1,3)=%z("dsv"),y'[" " s y=$p(y,%z("dsv"),2) i y?1a.e1"."1a.e,$d(%link(qnum,$p(y,".",2),$p(y,".",1))) s n1=i-1,n=-1,cnst=x i x[%z("dsv") q
 i 'n1 q
 i cnst[%z("dev") s cnst(0,1)=cnst,strt=i-1,end=i+1 q
 i cnst'="(",cnst'=")" q
 s (obr,cbr,n2)=0,ok=1 f j=n1:n q:'$d(word(0,j))  s z=word(0,j) s:z="(" obr=obr+1 s:z=")" cbr=cbr+1 s n2=n2+1,cnst(0,n2*n)=z s:z[%z("dsv") ok=0 i 'ok!obr=cbr q
 i n=1 s strt=i-1,end=j
 i n=-1 s strt=j,end=i+1
 i 'ok k cnst(0) q
 q
 ;
link3 ; expand from statement for link
 n n,alias1,fct
 i '$d(%link("a")) s %link("a")=0
 s n=%link("a")+1,%link("a")=n
 f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))
 s alias1="y$"_n
link31 s %link(qnum,cname,alias,"a",alias1)="",%link("ax",qnum,tname,alias1)="",^mgtmp($j,"from",qnum)=^mgtmp($j,"from",qnum)_","_tname_" "_alias1,^mgtmp($j,"from",qnum,tnum)=tname_"~"_alias1,^mgtmp($j,"from","x",qnum,alias1)=fct,^mgtmp($j,"from","x",qnum,tname)=fct
 i two s tnum=fct+1,alias1="z$"_n,two=0 g link31
 q
 ;
link4 ; non specific joins
 n end
 s %link("done",qnum,cname)=""
 f i=1:1 q:'$d(word(0,i))  s end(i)=word(0,i)
 s l=1
 s x="(" d link11
 s alias="" f i=0:1 s alias=$o(%link(qnum,cname,alias)) q:alias=""  d link41
 i $d(end(1)) s x="&" d link11 f i=1:1 q:'$d(end(i))  s x=end(i) d link11
 s x=")" d link11
 q
 ;
link41 ; add join
 s tname=%link(qnum,cname,alias),lnkat=$p(tname,".",2),tname=$p(tname,".",1)
link42 s alias1=$o(%link("ax",qnum,tname,""))
 i '$l(alias1) s two=0 d link3 g link42
 i i s x="&" d link11
 s x="(" d link11 s x=%z("dsv")_alias_"."_cname_%z("dsv") d link11 s x="=" d link11 s x=%z("dsv")_alias1_"."_cname_%z("dsv") d link11 s x=")" d link11
 q
 ;
links ; substitute select column
 n lvar,alias,alias1,tname1,cname,at1,var1,x
 i var'[%z("dsv") q
 s lvar=$p(var,%z("dsv"),2) i lvar'?1a.e1"."1a.e q
 s alias=$p(lvar,".",1),cname=$p(lvar,".",2) i '$d(%link(qnum,cname,alias)) q
 s tname1=%link(qnum,cname,alias),at1=$p(tname1,".",2),tname1=$p(tname1,".",1),alias1=$o(%link("ax",qnum,tname,""))
 i '$l(alias1) q
 s var1=%z("dsv")_"."_cname_%z("dsv")
 k ^mgtmp($j,"selx",qnum,var) s ^mgtmp($j,"sel",qnum,i)=var1,^mgtmp($j,"selx",qnum,var1)=i
 i $d(^mgtmp($j,"outsel",qnum,i)) k ^mgtmp($j,"outselx",qnum,var) s ^mgtmp($j,"outsel",qnum,i)=var1,^mgtmp($j,"outselx",qnum,var1)=i
 s item=%z("dsv")_alias1_"."_at1_%z("dsv") d addselx^%mgsqlv2
 s ln=$p(var1,%z("dsv"),2)_" <= "_alias1_"."_at1_" ;" d decex^%mgsqlv1
 q
 ;
