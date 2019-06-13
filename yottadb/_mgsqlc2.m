%mgsqlc2 ; was 3 (CM) sql compiler - sub driver ; 27 apr 2003  12:44 pm
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
a d vers^%mgsql("%mgsqlc2") q
 ;
output ; process output from subquery
 d where
 i $d(%delrec(0)) d delrec
 d outrec
 i qnum'=1,$d(sql("union",qnum)) g exit
 d updfun^%mgsqlc6
 d out
 d endsq^%mgsqlc3
exit ; exit
 q
 ;
where ; set up test data lines on basis of explicit criteria
 s var="" f  s var=$o(^mgtmp($j,"notnull",qnum,var)) q:var=""  s line=" "_"i"_" "_var_"="""" "_"s"_" "_var_"="" """ d addline^%mgsqlc(grp,.line)
 s test=1,line="" k gcont
 s hostes=1
 d sqinc
 f i=1:1 q:'$d(^mgtmp($j,"wher",qnum,i))  s x=^mgtmp($j,"wher",qnum,i) d where1
 k hostes
 s goto=1 i qnum=1,unique(1)=2 s goto=0
 s reset=""
 i '$d(con) s con=0
 i 'con s wexcl="" f  s wexcl=$o(^mgtmp($j,"wexcl",qnum,wexcl)) q:wexcl=""  i $l(line,wexcl)=2 d wexcl
 i $l(line) s line=" "_"i"_" '("_line_")"_reset_$s(goto:" "_"g"_" "_tag(qnum),1:"") d addline^%mgsqlc(grp,.line)
 q
 ;
wexcl ; remove clause from where predicate if possible
 n pre,pst,ok
 s pre=$p(line,wexcl,1),pst=$p(line,wexcl,2)
 i pre?."(",pst?.")" s line="" q
 i $e(pre,$l(pre))'="("!($e(pst)'=")") q
 s pre=$e(pre,1,$l(pre)-1),pst=$e(pst,2,32000)
 s ok=0 i "&"[$e(pre,$l(pre)) s ok=1,pre=$e(pre,1,$l(pre)-1)
 i 'ok,"&"[$e(pst) s ok=1,pst=$e(pst,2,32000)
 i 'ok q
 s line=pre_pst
 q
 ;
where1 ; for each word in predicate
 i ":<:>:'>:'<:]:']:"[(":"_x_":") d trans s x=newx
 s line=line_x ;d subvar^%mgsqlc
 q
 ;
where2 q  ; selected elements need reseting to null for unique query in hos
 n i,x,com
 s com="" f i=1:1:outsel q:'$d(^mgtmp($j,"sel",qnum,i))  s x=^(i) i x'["(" s reset=reset_com_x,com=","
 i $l(reset) s reset=" "_"s"_" ("_reset_")="""""
 q
 ;
trans s newx=x,other=^mgtmp($j,"wher",qnum,i+1) i other="(" q
 s typ="" i $d(typ(other)) s typ=typ(other)
 i typ="" s:other?.1"-".n.1"."1n.n typ="numeric" s:$e(other)=$c(34) typ="string" i typ="" q
 i typ="string" s test=$s(x="<":"']",x=">":"]",1:"") i test'="" s newx=test q
 i typ="numeric"!(typ="float") s test=$s(x="[":">",x="'[":"'>",1:"") i test'="" s newx=test q
 q
 ;
sqinc ; include subqueries into body of parents where predicate
 n i,subq,x,cmnd,relist,l
 s relist=0
 f i=1:1 q:'$d(^mgtmp($j,"wher",qnum,i))  s x=^(i) i x[%z("dq") s subq=$p(x,%z("dq"),2),cmnd=^(i-1) d sqinc1
 i relist s l=0,i="" f  s i=$o(^mgtmp($j,"wher",qnum,i)) q:i=""  s x=^(i) k ^(i) s l=l+1,^(l)=x
 q
 ;
sqinc1 ; include subquery
 n v
 i cmnd="exists" k ^mgtmp($j,"wher",qnum,i),^(i-1) s ^(i-2)="$d("_%z("ctg")_"("_%z("cts")_","_","_subq_"))",relist=1 q
 i cmnd="not exists" k ^mgtmp($j,"wher",qnum,i),^(i-1) s ^(i-2)="'$d("_%z("ctg")_"("_%z("cts")_","_subq_"))",relist=1 q
 i cmnd="in" s v=^mgtmp($j,"wher",qnum,i-2) k ^(i),^(i-1) s ^(i-2)="$d("_%z("ctg")_"("_%z("cts")_","_subq_","_v_"))",relist=1 q
 i cmnd="not in" s v=^mgtmp($j,"wher",qnum,i-2) k ^(i),^(i-1) s ^(i-2)="'$d("_%z("ctg")_"("_%z("cts")_","_subq_","_v_"))",relist=1 q
 i $d(unique(subq)),'unique(subq) s ^mgtmp($j,"wher",qnum,i)="$o("_%z("ctg")_"("_%z("cts")_","_subq_","_""""""_"))" q
 i $d(unique(subq)),unique(subq) s ^mgtmp($j,"wher",qnum,i)=^mgtmp($j,"sel",subq,1) q
 q
 ;
outrec ; set up record for output and test for 'distinct'
 f i=1:1 q:'$d(^mgtmp($j,"sel",qnum,i))  s lvar=$p(^mgtmp($j,"sel",qnum,i),%z("dsv"),2) i $l(lvar) d
 . n i
 . f i=1:1 q:'$d(^mgtmp($j,"e",lvar,i))  s line=^(i) d addline^%mgsqlc(grp,.line)
 . d subvar1^%mgsqlc
 . s lvar=$p($p(lvar,")",1),"(",2) i $l(lvar) d subvar1^%mgsqlc
 . q
 i $d(sql("union",qnum)) s x="" f  s x=$o(uvar(0,qnum,x)) q:x=""  s line=" "_"s"_" "_x_"="_uvar(0,qnum,x) d addline^%mgsqlc(grp,.line)
 i $d(sql("union",qnum)) s ret=%z("pv")_"(""u"")" s line=" "_"s"_" "_ret_"="_$s(tag(qnum)?1"@".e:$e(tag(qnum),2,999),1:""""_tag(qnum)_"""") s tag(qnum)="@"_ret d addline^%mgsqlc(grp,.line)
 i qnum'=1,$d(sql("union",qnum)) s line=" "_"g"_" "_%z("dl")_%z("pt")_"du"_%z("dl") d addline^%mgsqlc(grp,.line)
 i qnum=1,$d(sql("union",1)) s line=%z("dl")_%z("pt")_"du"_%z("dl")_" ;" d addline^%mgsqlc(grp,.line)
 ;
 s rec="",recc="",rdel="",rdelc=""
 f i=1:1 q:'$d(^mgtmp($j,"outsel",qnum,i))  s x=^(i) d outrec2
 i $l($g(ord)) s rec=recc
 i $g(^mgtmp($j,"sel",qnum))'="distinct"!$d(gvar(qnum)) q
 s line=" s "_rec d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("vck")_"="_recc_","_%z("vckcrc")_"="_"$zcrc("_%z("vck")_",7)" d addline^%mgsqlc(grp,.line)
 s line=" i $d("_%z("ctg")_"("_%z("cts")_","_"""d"","_qnum_","_"""x""_"_%z("vck")_")) g "_tag(qnum)
 ; condition for coping with log selects
 s line=" s "_%z("vckcrcdef")_"=0,"_%z("vnx")_"="""" f  s "_%z("vnx")_"=$o("_%z("ctg")_"("_%z("cts")_","_"""d"","_%z("vckcrc")_","_%z("vnx")_")) q:"_%z("vnx")_"=""""  i $g("_%z("ctg")_"("_%z("cts")_",""d"","_%z("vckcrc")_","_%z("vnx")_"))="_%z("vck")_" s "_%z("vckcrcdef")_"=1 q"
 d addline^%mgsqlc(grp,.line)
 s line=" i "_%z("vckcrcdef")_" g "_tag(qnum)
 d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("ctg")_"("_%z("cts")_","_"""d"","_qnum_","_"""x""_"_%z("vck")_")"_"=""""" d addline^%mgsqlc(grp,.line)
 s ktmp=1
 q
 ;
outrec1 ; substitute physical variables
 n line
 s line=rec d subvar^%mgsqlc s rec=line
 q
 ;
outrec2 ; output record
 i x[%z("dsv")&(x["(")&$d(gvar(qnum)) s x=0
 s recc=recc_rdelc_x,rdelc="_"_$c(34)_"~"_$c(34)_"_" d outrec1
 s rec=rec_rdel_"%d("_i_")="_x,rdel=","
 d outrec1
 q
 ;
out ; set up output to intermediate file
 i qnum=1,$d(update("update")) d main^%mgsqlcu q
 i qnum=1,$d(update("delete")) d main^%mgsqlcd q
 i qnum=1,$d(update("insert")) d main^%mgsqlci q
 i qnum=1,$d(create("index")) d crind^%mgsqlc5 q
 i $d(gvar(qnum)) s line=" g "_tag(qnum) d addline^%mgsqlc(grp,.line) q
 i $d(unique(qnum)),$d(term(qnum)) s line=term(qnum)_" g "_$s($d(endsq(qnum)):%z("dl")_%z("pt")_qnum_"x"_%z("dl"),1:tagout) d addline^%mgsqlc(grp,.line)
 i unique(qnum),qnum'=1 s line=" g "_tag(qnum) d addline^%mgsqlc(grp,.line) q
 ;;;i qnum=1,unique(1)=1,'$d(gvar(1)) s line=" g "_tag(qnum) d addline^%mgsqlc(grp,.line) q
 i $d(ord),$l(ord),qnum=1 g out2
 i qnum=1 g out1
 d outsq
 s x="" i $d(^mgtmp($j,"sqcom",qnum)) s x=^(qnum)
 i x="exists"!(x="not exists") s line=" g "_tagx d addline^%mgsqlc(grp,.line) q
 s line=" g "_tag(qnum) d addline^%mgsqlc(grp,.line)
 q
 ;
outsq ; output from inner query
 i $d(^mgtmp($j,"v",qnum)) d outsqv q
 s x=^mgtmp($j,"sel",qnum,1)
 s line=" s:"_x_"="""" "_x_"="" """ d addline^%mgsqlc(grp,.line)
 ; add data
 s line=" s "_%z("ctg")_"("_%z("cts")_","_qnum_","_x_")=""""" d addline^%mgsqlc(grp,.line)
 q
 ;
outsqv ; output view from inner query
 n %kv,i,cname,com,vnum,del,alias
 s vnum=qnum
 s del="$c(1)"
 s alias=$g(^mgtmp($j,"v",qnum))
 s %kv(1)=%z("dsv")_alias_"."_"line-no"_%z("dsv")
 s tk=%z("ctg")_"("_%z("cts")_","_qnum
 f i=1:1 q:'$d(%kv(i))  s tk=tk_","_%kv(i)
 s tk=tk_")"""
 s td="",com="" f i=1:1 q:'$d(^mgtmp($j,"outsel",vnum,i))  s cname=$g(^(i)) s td=td_com_cname,com="_"_del_"_"
 ; add data
 s line=" s "_line_")="_td d addline^%mgsqlc(grp,.line)
 q
 ;
out1 ; output from outer query - take data as it comes
 s %data=1,ptag=$g(tag(qnum)) d line^%mgsqlc3
 k rdel,rec
 q
 ;
out2 ; output is 'ordered'
 s com="",ordsub="" f i=1:1 q:'$d(order(i))  d out21
 s line=" s "_%z("pv")_"n="_%z("pv")_"n+1" d addline^%mgsqlc(grp,.line)
 d linel s line=" s "_%z("ctg")_"("_%z("cts")_","_"""x"",1,"_ordsub_","_%z("pv")_"n"_")="_"sqlcnt(0)" d addline^%mgsqlc(grp,.line)
 s line=" g "_tag(qnum) d addline^%mgsqlc(grp,.line)
 k rdel,rec
 q
 ;
out21 ; set up order
 s x=$p(order(i),"~",1),y=$p(order(i),"~",2)
 s ordsub=ordsub_com_y,com=","
 s line=" s "_y_"=$s("_x_"="""":"" "",1:"_x_")" d addline^%mgsqlc(grp,.line)
 q
 ;
linel ; split long lines
 n del,i,pre,psp,rx,nx
 s del="_""~""_",rx=rec,nx=0
 s line=line_" s sqlcnt(0)=""""" d addline^%mgsqlc(grp,.line)
linel1 i $l(rx)<200 g linel2
 f i=1:1 s pre=$p(rx,del,1,i),pst=$p(rx,del,i+1,9999) q:pst=""  i $l(pre)>200 q
 s nx=nx+1,line=line_" s sqlcnt(0)=sqlcnt(0)"_$s(nx=1:"_",1:del)_pre d addline^%mgsqlc(grp,.line)
 s rx=pst g linel1
linel2 ; output line
 i $l(rx) s nx=nx+1,line=line_" s sqlcnt(0)=sqlcnt(0)"_$s(nx=1:"_",1:del)_rx d addline^%mgsqlc(grp,.line)
 q
 ;
order ; determine order in which data will come out
 i $d(rev(alias)),rev(alias) d order3 q
 i qnum'=1!(tnum'=1)!$d(gvar(qnum))!$d(sql("union",1)) q
 k dir i '$d(ord) q
 i '$l(ord) q
 i $l(ord,",")>$l(z,",") q
 s ok=1,kno=1
 f i=1:1:$l(z,",") s y=$p(z,",",i) d order1 i 'ok q
 i 'ok k dir q
 k ord,order
 q
 ;
order1 ; check if order is in keeping with required order
 i y'[%z("dsv") q
 s x=$p(ord,",",kno),dir=$p(x,"~",2),x=$p(x,"~",1) i x="" q
 s x=^mgtmp($j,"sel",qnum,x) i z'[x s ok=0 q
 i x=y s kno=kno+1
 i x'=y d order2 i 'ok q
 ;
 i x=y d  i 'ok q
 . n link,or
 . s link=$o(^mgtmp($j,"pre",qnum,y,""))
 . i link'="" s or=$o(^mgtmp($j,"pre",qnum,y,link)) i $l(or) s ok=0 q
 . q
 ;
 s dir=$s(dir="desc":"$zp",1:"$o")
 s dir(x)=dir
 q
 ;
order2 ; check if 'leading' subscript is uniquely fixed
 n link,op,cnst,or
 s link=$o(^mgtmp($j,"pre",qnum,y,"")) i link="" s ok=0 q
 s or=$o(^mgtmp($j,"pre",qnum,y,link)) i $l(or) s ok=0 q
 s op=^mgtmp($j,"pre",qnum,y,link,1,"op"),cnst=^("cnst") i op'="="!(cnst[%z("dsv")) s ok=0 q
 s link=$o(^mgtmp($j,"pre",y,link)) i $l(link) s ok=0 q
 q
 ;
order3 ; reverse entire order of sequence
 f i=1:1:$l(z,",") s y=$p(z,",",i) i y[%z("dsv") s dir(y)="$zp"
 q
 ;
dist q  ; optimise distinct clause if possible
 n dn
 i $d(^mgtmp($j,"from",1,2)) q
 f i=1:1:outsel q:'$d(^mgtmp($j,"sel",qnum,i))  s x=^(i),dn("x",x)=""
 f i=1:1:$l(z,keyd) s y=$p(z,keyd,i) i y[%z("dsv") q:'$d(dn("x",y))  k dn("x",y) s dn=i
 i $d(dn("x")) q
 i dn=$l(z,keyd) s ^mgtmp($j,"sel",qnum)=""
 i dn<$l(z,keyd),'$d(^mgtmp($j,"sel",qnum,outsel+1)) s z=$p(z,",",1,dn),^mgtmp($j,"sel",qnum)=""
 q
 ;
delrec ; delete selected record
 q
 n %tagz,%tagi,%tdlm,%refile,tname,alias,dtyp,key,dat
 s alias=$o(%delrec(0,"")) i alias="" q
 i '$d(^mgtmp($j,"from","x",qnum,alias)) q
 s tname=$p(^mgtmp($j,"from",qnum,^mgtmp($j,"from","x",qnum,alias)),"~",1)
 s %tagz=%z("dl")_"delete"_qnum_alias_%z("dl"),%tagi=%z("pt")_"i",%tdlm=%z("dl")
 k dtyp d xfid^%mgsqlct
 s line=" k %do,%dn,%dx" d addline^%mgsqlc(grp,.line)
 f i=1:1 q:'$d(xfid(0,i))  s cname=xfid(0,i,1) i cname?1a.e d data^%mgsqlcd
 s %refile=0 d kill^%mgsqlci
 s line=%tagz_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
 
