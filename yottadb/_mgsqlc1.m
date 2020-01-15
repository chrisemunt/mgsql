%mgsqlc1 ; was 2 (CM) sql compiler - parse files ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqlc1") q
 ;
subq ; compile sub-query data extraction
 n %d,data,got,tnum
 d table^%mgsqlct(dbid,qnum,.data,.error) i $l(error) q
 d temps
 s nxtun="" i $d(sql("union",qnum)) s nxtun=$o(sql("union",qnum))
 f tnum=1:1 q:'$d(^mgtmp($j,"from",qnum,tnum))  d
 . s %d=^mgtmp($j,"from",qnum,tnum)
 . s tname=$p(%d,"~",1),alias=$p(%d,"~",2)
 . d parse(dbid,.sql,grp,qnum,tnum,.data,.got,.error)
 . d data^%mgsqlc5(grp,qnum,tnum,.data,.got,.error)
 . s got("f",alias)=""
 . d corelate^%mgsqlc5(grp,qnum,.got)
 . q
 d output^%mgsqlc2
exit ; exit
 q
 ;
dist(grp,qnum,tnum) ; optimize select distinct
 n done,x,got,ii
 s done=0
 i $g(^mgtmp($j,"sel",qnum))'="distinct" q done
 i $d(^mgtmp($j,"from",qnum,2)) q done
 f ii=1:1:i s x=$p(z,",",i) i x'="" s got(x)=""
 s done=1 f ii=1:1 q:'$d(^mgtmp($j,"sel",qnum,ii))  s x=$g(^(ii)) i x'="",'$d(got(x)) s done=0 q
 i done s ^mgtmp($j,"dontgetdata",qnum,tnum)=1
 q done
 ;
parse(dbid,sql,grp,qnum,tnum,data,got,error) ; parse global
 n cond,zkey,zglo,zgloz,tagn,x,key,kno
 i tnum=1 s %zq("tagc")="" d
 . s line=%z("dl")_%z("pt")_qnum_"s"_%z("dl")_" ;"
 . s ^mgtmp($j,"s",qnum)=grp_"~"_"1"
 . d addline^%mgsqlc(grp,.line)
 . d aginit^%mgsqlc6(grp,qnum,tnum)
 . q
 s zkey=data(qnum,tnum,"key"),zglo=data(qnum,tnum,"glo"),zgloz=$s(zglo[%z("dev"):""")",1:"")
 d order^%mgsqlc2(.sql,qnum,tnum,.data,.dir)
 i tnum=1 s %zq("tagx")=%z("dl")_%z("pt")_qnum_"x"_%z("dl")
 k got("a")
 f kno=1:1:$l(zkey,",") s x=$p(zkey,",",kno) i x[%z("dsv") d
 . s dir=$g(dir(x)) i dir="" s dir=1
 . d pre^%mgsqlc4(dbid,qnum,tnum,x,.data,.dir,.got,.cond)
 . s x=$p($p(zkey,",",kno),%z("dsv"),2)
 . i x'="" s got("a",x)=""
 . q
 i qnum=1,tnum=1,$g(^mgtmp($j,"sel",qnum))="distinct" s zkey=$$dist^%mgsqlc2(qnum,tnum)
 s (key,key(0))="",tagn=1 i tnum=1,'$d(%zq("tag",qnum)) s %zq("tag",qnum)=%zq("tagx")
 i $d(^mgtmp($j,"from","z",qnum,"pass",alias)) d ojoin(grp,qnum,tnum,.data,.error)
 k got("a")
 s %zq("tagc")=""
 f kno=1:1:$l(zkey,",") d  i $$dist(grp,qnum,tnum) q
 . d parse1(grp,qnum,tnum,zkey,.kno,.got,.data,.cond,.key,.tagn)
 . d gota(grp,qnum,tnum,zkey,kno,.got,.data)
 . i %zq("tagc")'="" s %zq("tag",qnum)=%zq("tagc")
 . q
 i %zq("tagc")="" s %zq("tagc")=%zq("tagx")
 i %zq("tagc")'=%zq("tagx") s %zq("tag",qnum)=%zq("tagc")
 q
 ;
parse1(grp,qnum,tnum,zkey,kno,got,data,cond,key,tagn) ; set up line(s) of code for this level of subscript
 n var,reset
 s var=$p(zkey,",",kno)
 s key=key_key(0)_var,key(0)=","
 i var'[%z("dsv") q
 s dir=$g(dir(var)) i dir="" s dir=1
 s %zq("tagp")=%zq("tag",qnum)
 i $d(^mgtmp($j,"sqin",var)),$d(cond(var,"pre","nostrt")),'$d(^mgtmp($j,"corel",qnum)) g parse11
 i $d(cond(var,"fixed")),'$d(cond(var,"pre",2)) d fixed(grp,qnum,tnum,zkey,.kno,.got,.data,.cond,.key) q
 ;
 i $d(cond(var,"pre",2)) d or(grp,qnum,tnum,zkey,.kno,.got,.data,.cond,.key,.tagn) g parse1x q
 ;
 s line=cond(var,"pre",1) d addline^%mgsqlc(grp,.line)
 s %zq("tagc")=%z("dl")_%z("pt")_qnum_tnum_tagn_%z("dl")
 s (reset,reset(0))="" i qnum=1,$g(^mgtmp($j,"unique",qnum)),%zq("tagp")=%zq("tagout") d reset(qnum,.reset,.data) i $l(reset) s reset=" s "_reset
 s line=%zq("tagc")_" "_"s"_" "_var_"="_"$o"_"("_zglo_"("_key_")"_zgloz_","_dir_") "_"i"_" "_var_"="_$c(34)_$c(34)_reset_" "_"g"_" "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 i $d(cond(var,"post",1)) s line=cond(var,"post",1)_" "_"g"_" "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 g parse1x
parse11 ; generate optimal code for 'in' clause
 s %zq("tagc")=%z("dl")_%z("pt")_qnum_tnum_tagn_%z("dl")
 s line=cond(var,"pre",1) d addline^%mgsqlc(grp,.line)
 s line=%zq("tagc")_" "_"s"_" "_var_"="_"$o"_"("_%z("ctg")_"("_%z("cts")_","_^mgtmp($j,"sqin",var)_","_var_")"_","_dir_") "_"i"_" "_var_"="""""_" "_"g"_" "_%zq("tagp") d addline^%mgsqlc(grp,.line)
 s line=" "_"i"_" '"_"$d"_"("_zglo_"("_key_")"_zgloz_") "_"g"_" "_%zq("tagc") d addline^%mgsqlc(grp,.line)
parse1x s tagn=tagn+1
 q
 ;
or(grp,qnum,tnum,zkey,kno,got,data,cond,key,tagn) ; generate code to handle 'or' predicate for subscript
 n var,nxtag,pretag,pastag,datag,lcase,orn,tagv,tagvp
 s var=$p(zkey,",",kno)
 s lcase="abcdefghijklmnopqrstuvwxyz"
 s orn=0,tagv=%z("pv")_"("_tnum_","_i_")",tagvp=%z("pv")_"("_tnum_","_kno_",""p"")",datag=%z("dl")_%z("pt")_qnum_tnum_tagn_"x"_%z("dl")
or1 s orn=orn+1 i '$d(cond(y,"pre",orn)) g orx
 s pretag=%z("dl")_%z("pt")_qnum_tnum_tagn_"or"_orn_%z("dl"),pastag=%z("dl")_%z("pt")_qnum_tnum_tagn_"or"_$e(lcase,orn)_%z("dl")
 s nxtag=$s($d(cond(y,"pre",orn+1)):tag_tagn_"or"_(orn+1)_%z("dl"),1:%zq("tagp"))
 i $d(cond(var,"fixed",orn)) g or2
 ; generate code to pass on subscript
 s line="" i orn>1 s line=pretag_" ;" d addline^%mgsqlc(grp,.line)
 s line=line_cond(var,"pre",orn)_" s "_tagv_"="""_pastag_"""" d addline^%mgsqlc(grp,.line)
 s line=pastag_" s "_var_"="_dirf_"("_zglo_"("_key_")"_zgloz_dirp_") i "_var_"="_$c(34)_$c(34)_" g "_nxtag d addline^%mgsqlc(grp,.line)
 i $d(cond(var,"post",orn)) s line=cond(y,"post",orn)_" g "_nxtag d addline^%mgsqlc(grp,.line)
 i $d(cond(var,"pre",orn+1)) s line=" g "_datag d addline^%mgsqlc(grp,.line)
 g or1
or2 ; generate code for definition test on subscript only
 s line="" i orn>1 s line=pretag_" ;" d addline^%mgsqlc(grp,.line)
 s line=line_cond(var,"pre",orn)_","_tagv_"="""_nxtag_"""" d addline^%mgsqlc(grp,.line)
 s line=" i '$l("_var_") g "_nxtag d addline^%mgsqlc(grp,.line)
 s line=" i '$d("_zglo_"("_key_")"_zgloz_") g "_nxtag d addline^%mgsqlc(grp,.line)
 i $d(cond(var,"pre",orn+1)) s line=" g "_datag d addline^%mgsqlc(grp,.line)
 g or1
orx s line=datag_" ;" d addline^%mgsqlc(grp,.line)
 s %zq("tagc")="@"_tagv
 q
 ;
fixed(grp,qnum,tnum,zkey,kno,got,data,cond,key) ; generate definition test for fixed subscript(s)
 n reset,mxi,var,npn,lines,coms,linet,or,sub,trans,com,to,alias,qual,goto
 s (reset,reset(0))="" i qnum=1,$g(^mgtmp($j,"unique",qnum)) d reset(qnum,.reset,.data)
 s mxi=kno,(lines,coms,linet,or)=""
 ; build key and null subscript tests
 f npn=kno:1:$l(zkey,",") s var=$p(zkey,",",npn) q:'$d(cond(var,"fixed"))!$d(cond(var,"pre",2))  s mxi=npn d
 . s sub=var,set=$p(cond(var,"pre",1)," ",3,999),to=$p(set,"=",2,999),alias=$p($p(var,%z("dsv"),2),".",1)
 . s trans=0 i '$d(^mgtmp($j,"from",2)),to'["(",to'[")",$l(to,%z("dsv"))'>3,$l(to,%z("dev"))'>3,'$d(^mgtmp($j,"outselx",1,var)),'$d(^mgtmp($j,"from","z",qnum,"pass",alias)) s trans=1,(sub,^mgtmp($j,"trans",$p(var,%z("dsv"),2)))=to
 . i npn>kno s key=key_com_sub
 . i 'trans s lines=lines_coms_set,coms=","
 . i to'[%z("dsv"),to'[%z("dev"),to?1""""1e.e1""""!(to?1n.n)!(to[%z("ds")) q
 . s linet=linet_or_"'$l("_sub_")",or="!"
 . q
 s qual="",goto=1 i qnum=1,$g(^mgtmp($j,"unique",1))=2 s lines=lines_coms_%z("vdef")_"=1,%d=""""",reset=reset_reset(0)_%z("vdef")_"=0",qual=%z("vdef")_",",goto=0
 i $l(lines) s lines=" "_"s"_" "_lines
 i $l(linet) s linet=" "_"i"_" "_linet
 i $l(reset) s reset=" "_"s"_" "_reset
 s line=lines
 i linet'="" s line=line_linet_reset_$s(goto:" "_"g"_" "_%zq("tagp"),1:"")
 i line'="" d addline^%mgsqlc(grp,.line)
 s line=" "_"i"_" "_qual_"'"_"$d"_"("_zglo_"("_$p(zkey,",",1,mxi)_")"_zgloz_")"_reset_$s(goto:" "_"g"_" "_%zq("tagp"),1:"") d addline^%mgsqlc(grp,.line)
fixedx s kno=mxi
 q
 ;
reset(qnum,reset,data) ; check for need to reset unique key outputs on failure
 n line,outsel,i,item
 s outsel=$g(^mgtmp($j,"sel",qnum))
 f i=1:1:outsel s item=^mgtmp($j,"sel",qnum,i) d reset1(qnum,.reset,item,.data)
 i $l(reset) s line=reset d subvar^%mgsqlc(.line) s reset="("_line_")="""""
 q
 ;
reset1(qnum,reset,item,data) ; determine whether data item needs to be reset
 n tnum,x,alias
 i item["("!(item'[%z("dsv")) q
 s x=$p(item,%z("dsv"),2),alias=$p(x,".",1) i alias="" q
 s tnum=^mgtmp($j,"from","x",qnum,alias)
 i $d(data(qnum,tnum,"col",x)),data(qnum,tnum,"key")'[item q
 s reset=reset_reset(0)_item,reset(0)=","
 q
 ;
ojoin(grp,qnum,tnum,data,error) ; outer join
 n i,taga,tagz,cname,kno
 s %zq("ojc")=%z("dsv")_"\#oj\"_qnum_"\"_tnum_%z("dsv")
 s %zq("ojc0")=1
 s %zq("ojc1")=%z("dsv")_"\#ojc\"_qnum_"\"_tnum_%z("dsv")
 s %zq("ojtbp")=%z("dl")_%z("pt")_qnum_tnum_"\ojtbp"_%z("dl")
 s %zq("ojtx")=%z("dl")_%z("pt")_qnum_tnum_"\ojtx"_%z("dl")
 s %zq("ojtbx")=%z("dl")_%z("pt")_qnum_tnum_"\ojtbx"_%z("dl")
 s %zq("ojtpx")=%zq("tag",qnum)
 s taga=%z("dl")_%z("pt")_qnum_tnum_"\oja"_%z("dl"),tagz=%z("dl")_%z("pt")_qnum_tnum_"\ojz"_%z("dl")
 s line=" "_"s"_" "_%zq("ojc")_"=0"_","_%zq("ojc1")_"=1"_" "_"g"_" "_tagz d addline^%mgsqlc(grp,.line)
 s line=taga_" "_"i"_" "_%zq("ojc")_">0 "_"g"_" "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line)
 s %zq("tag",qnum)=taga
 s line=" "_"s"_" "_%zq("ojc1")_"=0" d addline^%mgsqlc(grp,.line)
 s kno=0 f i=1:1:$l(data(qnum,tnum,"pkey")) d
 . s cname=$p(data(qnum,tnum,"pkey"),",",i)
 . i cname'[%z("dsv") q
 . s kno=kno+1,line=" "_"s"_" "_cname_"=""""" d addline^%mgsqlc(grp,.line)
 . i kno=1 s %zq("ojkey")=cname
 . q
 s cname="" f  s cname=$o(data(qnum,tnum,"col",cname)) q:cname=""  s line=" "_"s"_" "_%z("dsv")_cname_%z("dsv")_"=""""" d addline^%mgsqlc(grp,.line)
 s line=" "_"g"_" "_%zq("ojtbp") d addline^%mgsqlc(grp,.line)
 s line=tagz_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
ojoinda(grp,qnum,tnum,data,error) ; process at end of parse, before get data
 s line=" g "_%zq("ojtbx") d addline^%mgsqlc(grp,.line)
 s line=%zq("ojtx")_" "_"g"_":'$l("_%zq("ojkey")_") "_%zq("ojtpx")_" "_"g"_" "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line)
 s line=%zq("ojtbx")_" ;" d addline^%mgsqlc(grp,.line)
 s %zq("tag",qnum)=%zq("ojtx")
 q
 ;
ojoindz(grp,qnum,tnum,data,error) ; process after data retrieval
 n i,cname,alias,x
 s x="" f  s x=$o(^mgtmp($j,"where",x)) q:x=""  i (x+0)=qnum,x["gon" d
 . s line="" f i=1:1 q:'$d(^mgtmp($j,"where",x,i))  s line=line_^mgtmp($j,"where",x,i)
 . i $l(line) s line=" "_"i"_" '("_line_")"_" g "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line)
 . q
 s cname="" f  s cname=$o(^mgtmp($j,"from","z",qnum,"join",cname)) q:cname=""  d
 . k x
 . s alias="" f i=1:1 s alias=$o(^mgtmp($j,"from","z",qnum,"join",cname,alias)) q:alias=""  s x(i)=alias_"."_cname
 . i $d(x(2)) s line=" i "_%z("dsv")_x(1)_%z("dsv")_"'="_%z("dsv")_x(2)_%z("dsv")_" g "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line)
 . q
 s line=" "_"s"_" "_%zq("ojc")_"="_%zq("ojc")_"+1" d addline^%mgsqlc(grp,.line)
 s line=%zq("ojtbp")_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
ojoindz1(grp,qnum,tnum,cname,alias) ; perform natural inner join on data
 q
 ;
gota(grp,qnum,tnum,zkey,no,got,data) ; new attribute available from single-level parse
 n i,x,sqvar
 f i=1:1:no s x=$p(zkey,",",i) i x[%z("dsv") s sqvar=$p(x,%z("dsv"),2) i sqvar'="" s got("a",sqvar)=""
 d corelate^%mgsqlc5(grp,qnum,.got)
 q
 ;
temps ; determine subscripts for order/group sort file
 k order,order2
 s sort2=0 i qnum=1,$d(^mgtmp($j,"group",qnum)),$d(^mgtmp($j,"order")) d temps2
 s order=0
 i qnum=1,'sort2 f i=1:1 q:'$d(^mgtmp($j,"order",i))  s lvar=^mgtmp($j,"order",i),orderx(lvar)="" d temps1
 f i=1:1 q:'$d(^mgtmp($j,"group",qnum,i))  s lvar=^mgtmp($j,"group",qnum,i) i '$d(orderx(lvar)) d temps1
 k orderx
 q
 ;
temps1 ; determine pseudo-logical variable
 s order=order+1
 s var="\cm"_order
 s var=%z("dsv")_var_%z("dsv")
 s order(order)=lvar_"~"_var
 q
 ;
temps2 ; determine whether two sorts required
 n gvarx
 f i=1:1 q:'$d(^mgtmp($j,"group",qnum,i))  s ^mgtmp($j,"groupx",^mgtmp($j,"group",qnum,i))=""
 f i=1:1 q:'$d(^mgtmp($j,"order",i))  i '$d(^mgtmp($j,"groupx",^mgtmp($j,"order",i))) s sort2=1 q
 i 'sort2 q
 s order2=0
 f i=1:1 q:'$d(^mgtmp($j,"order",i))  s lvar=^mgtmp($j,"order",i) d temps3
 q
 ;
temps3 ; determine pseudo-logical variable for second parse
 s order2=order2+1
 s var="\\cm"_order2
 s var=%z("dsv")_var_%z("dsv")
 s order2(order2)=lvar_"~"_var
 q
 ;
 
 
 
 
