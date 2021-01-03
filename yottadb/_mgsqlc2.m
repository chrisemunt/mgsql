%mgsqlc2 ; was 3 (CM) sql compiler - sub driver ; 27 apr 2003  12:44 pm
 ;
 ;  ----------------------------------------------------------------------------
 ;  | MGSQL                                                                    |
 ;  | Author: Chris Munt cmunt@mgateway.com, chris.e.munt@gmail.com            |
 ;  | Copyright (c) 2016-2021 M/Gateway Developments Ltd,                      |
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
 i $d(%zq("drec",0)) d delrec
 d outrec
 i qnum'=1,$d(sql("union",qnum)) g exit
 d updfun^%mgsqlc6
 d outrow
 d endsq^%mgsqlc3
exit ; exit
 q
 ;
where ; set up test data lines on basis of explicit criteria
 s var="" f  s var=$o(^mgtmp($j,"notnull",qnum,var)) q:var=""  s line=" "_"i"_" "_var_"="""" "_"s"_" "_var_"="" """ d addline^%mgsqlc(grp,.line)
 s test=1,line="" k gcont
 s hostes=1
 d sqinc
 f i=1:1 q:'$d(^mgtmp($j,"where",qnum,i))  s x=^mgtmp($j,"where",qnum,i) d where1(qnum,x,i,.line)
 k hostes
 s goto=1 i qnum=1,$g(^mgtmp($j,"unique",1))=2 s goto=0
 s reset=""
 s wexcl="" f  s wexcl=$o(^mgtmp($j,"wexcl",qnum,wexcl)) q:wexcl=""  i $l(line,wexcl)=2 d wexcl
 i $l(line) s line=" "_"i"_" '("_line_")"_reset_$s(goto:" "_"g"_" "_%zq("tag",qnum),1:"") d addline^%mgsqlc(grp,.line)
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
where1(qnum,item,no,line) ; for each word in predicate
 i ":<:>:'>:'<:]:']:"[(":"_item_":") s item=$$trans(qnum,item,no)
 s line=line_item
 q
 ;
trans(qnum,item,no) ; translate operator
 n item1,mtype,test,other
 s item1=item,other=^mgtmp($j,"where",qnum,no+1) i other="(" q item1
 s mtype="" i $d(^mgtmp($j,"mtype",other)) s mtype=^mgtmp($j,"mtype",other)
 i mtype="" s:other?.1"-".n.1"."1n.n mtype="num" s:$e(other)=$c(34) mtype="str" i mtype="" q item1
 i mtype="str" s test=$s(x="<":"']",x=">":"]",1:"") i test'="" s item1=test q item1
 i mtype="num" s test=$s(x="[":">",x="'[":"'>",1:"") i test'="" s item1=test q item1
 q item1
 ;
sqinc ; include subqueries into body of parents where predicate
 n i,subq,x,cmnd,relist,l
 s relist=0
 f i=1:1 q:'$d(^mgtmp($j,"where",qnum,i))  s x=^(i) i x[%z("dq") s subq=$p(x,%z("dq"),2),cmnd=^(i-1) d sqinc1
 i relist s l=0,i="" f  s i=$o(^mgtmp($j,"where",qnum,i)) q:i=""  s x=^(i) k ^(i) s l=l+1,^(l)=x
 q
 ;
sqinc1 ; include subquery
 n v
 i cmnd="exists" k ^mgtmp($j,"where",qnum,i),^(i-1) s ^(i-2)="$d("_%z("ctg")_"("_%z("cts")_","_","_subq_"))",relist=1 q
 i cmnd="not exists" k ^mgtmp($j,"where",qnum,i),^(i-1) s ^(i-2)="'$d("_%z("ctg")_"("_%z("cts")_","_subq_"))",relist=1 q
 i cmnd="in" s v=^mgtmp($j,"where",qnum,i-2) k ^(i),^(i-1) s ^(i-2)="$d("_%z("ctg")_"("_%z("cts")_","_subq_","_v_"))",relist=1 q
 i cmnd="not in" s v=^mgtmp($j,"where",qnum,i-2) k ^(i),^(i-1) s ^(i-2)="'$d("_%z("ctg")_"("_%z("cts")_","_subq_","_v_"))",relist=1 q
 i '$g(^mgtmp($j,"unique",subq)) s ^mgtmp($j,"where",qnum,i)="$o("_%z("ctg")_"("_%z("cts")_","_subq_","_""""""_"))" q
 i $g(^mgtmp($j,"unique",subq)) s ^mgtmp($j,"where",qnum,i)=^mgtmp($j,"sel",subq,1) q
 q
 ;
outrec ; set up record for output and test for 'distinct'
 f i=1:1 q:'$d(^mgtmp($j,"sel",qnum,i))  s lvar=$p(^mgtmp($j,"sel",qnum,i),%z("dsv"),2) i $l(lvar) d
 . n i
 . s pvar=$$subvar1^%mgsqlc(lvar)
 . s lvar=$p($p(lvar,")",1),"(",2) i $l(lvar) s pvar=$$subvar1^%mgsqlc(lvar)
 . q
 i $d(sql("union",qnum)) s x="" f  s x=$o(uvar(0,qnum,x)) q:x=""  s line=" "_"s"_" "_x_"="_uvar(0,qnum,x) d addline^%mgsqlc(grp,.line)
 i $d(sql("union",qnum)) s ret=%z("pv")_"(""u"")" s line=" "_"s"_" "_ret_"="_$s(%zq("tag",qnum)?1"@".e:$e(%zq("tag",qnum),2,999),1:""""_%zq("tag",qnum)_"""") s %zq("tag",qnum)="@"_ret d addline^%mgsqlc(grp,.line)
 i qnum'=1,$d(sql("union",qnum)) s line=" "_"g"_" "_%z("dl")_%z("pt")_"du"_%z("dl") d addline^%mgsqlc(grp,.line)
 i qnum=1,$d(sql("union",1)) s line=%z("dl")_%z("pt")_"du"_%z("dl")_" ;" d addline^%mgsqlc(grp,.line)
 ;
 s rec="",recc="",rdel="",rdelc=""
 f i=1:1 q:'$d(^mgtmp($j,"outsel",qnum,i))  s x=^(i) d outrec2
 i $d(^mgtmp($j,"order")) s rec=recc
 i $g(^mgtmp($j,"sel",qnum,0))'="distinct"!$d(^mgtmp($j,"group",qnum)) q
 s line=" s "_rec d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("vck")_"="_recc_","_%z("vckcrc")_"="_"$$crc^%mgsqls("_%z("vck")_",7)" d addline^%mgsqlc(grp,.line)
 s line=" i $d("_%z("ctg")_"("_%z("cts")_","_"""d"","_qnum_","_"""x""_"_%z("vck")_")) g "_%zq("tag",qnum)
 ; cope with long select lines
 s line=" s "_%z("vckcrcdef")_"=0,"_%z("vnx")_"="""" f  s "_%z("vnx")_"=$o("_%z("ctg")_"("_%z("cts")_","_"""d"","_%z("vckcrc")_","_%z("vnx")_")) q:"_%z("vnx")_"=""""  i $g("_%z("ctg")_"("_%z("cts")_",""d"","_%z("vckcrc")_","_%z("vnx")_"))="_%z("vck")_" s "_%z("vckcrcdef")_"=1 q"
 d addline^%mgsqlc(grp,.line)
 s line=" i "_%z("vckcrcdef")_" g "_%zq("tag",qnum)
 d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("ctg")_"("_%z("cts")_","_"""d"","_qnum_","_"""x""_"_%z("vck")_")"_"=""""" d addline^%mgsqlc(grp,.line)
 s ^mgtmp($j,"ktmp")=1
 q
 ;
outrec1 ; substitute physical variables
 n line
 s line=rec d subvar^%mgsqlc(.line) s rec=line
 q
 ;
outrec2 ; output record
 i x[%z("dsv")&(x["(")&$d(^mgtmp($j,"group",qnum)) s x=0
 s recc=recc_rdelc_x,rdelc="_"_$c(34)_"~"_$c(34)_"_" d outrec1
 s rec=rec_rdel_"%d("_i_")="_x,rdel=","
 d outrec1
 q
 ;
outrow ; set up output to intermediate file
 i qnum=1,$d(^mgtmp($j,"upd","update")) d main^%mgsqlcu q
 i qnum=1,$d(^mgtmp($j,"upd","delete")) d main^%mgsqlcd q
 i qnum=1,$d(^mgtmp($j,"upd","insert")) d main^%mgsqlci q
 i qnum=1,$d(^mgtmp($j,"create","index")) d crind^%mgsqlc5(grp,qnum) q
 i $d(^mgtmp($j,"group",qnum)) s line=" g "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line) q
 i $g(^mgtmp($j,"unique",qnum)),qnum'=1 s line=" g "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line) q
 i $d(^mgtmp($j,"order")),qnum=1 g outrow2
 i qnum=1 g outrow1
 d outrowsq
 s x="" i $d(^mgtmp($j,"sqcom",qnum)) s x=^(qnum)
 i x="exists"!(x="not exists") s line=" g "_%zq("tagx") d addline^%mgsqlc(grp,.line) q
 s line=" g "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line)
 q
outrow1 ; output from outer query - take data as it comes
 s %zq("tagp")=$g(%zq("tag",qnum))
 i '$g(^mgtmp($j,"unique",qnum)) d row^%mgsqlc3(grp,qnum,0,""),top^%mgsqlc3(grp,qnum,0)
 s line=line_" g "_%zq("tagp") d addline^%mgsqlc(grp,.line) q
 q
outrow2 ; output is 'ordered'
 s com="",ordsub="" f i=1:1 q:'$d(^mgtmp($j,"order",i))  d
 . s x=$g(^mgtmp($j,"order",i)) ;,y=%z("dsv")_"__order"_$p(^mgtmp($j,"order",i,0),"~",1)_%z("dsv")
 . s ordsub=ordsub_com_"$s("_x_"="""":"" "",1:"_x_")",com=","
 . q
 s line=" k %zo("_%z("vrc")_")" d addline^%mgsqlc(grp,.line)
 s outsel=^mgtmp($j,"outsel",qnum)
 f i=1:1:outsel s line=line_" s %zo("_%z("vrc")_","_i_")="_^mgtmp($j,"outsel",qnum,i) d addline^%mgsqlc(grp,.line)
 s line=" s "_%z("pv")_"n="_%z("pv")_"n+1" d addline^%mgsqlc(grp,.line)
 ;d linel
 s line=" m "_%z("ctg")_"("_%z("cts")_","_"""x"",1,"_ordsub_","_%z("pv")_"n"_")="_"%zo("_%z("vrc")_")" d addline^%mgsqlc(grp,.line)
 s line=" g "_%zq("tag",qnum) d addline^%mgsqlc(grp,.line)
 q
 ;
outrowsq ; output from inner query
 s x=^mgtmp($j,"sel",qnum,1)
 s line=" s:"_x_"="""" "_x_"="" """ d addline^%mgsqlc(grp,.line)
 ; add data
 s line=" s "_%z("ctg")_"("_%z("cts")_","_qnum_","_x_")=""""" d addline^%mgsqlc(grp,.line)
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
order(sql,qnum,tnum,data,dir) ; determine order in which data will come out
 n i,ord,key,item,ok
 i qnum'=1!(tnum'=1)!$d(^mgtmp($j,"group",qnum))!$d(sql("union",1)) q
 s key=data(qnum,tnum,"key")
 i '$d(^mgtmp($j,"order")) q
 i '$d(^mgtmp($j,"order",$l(key,","))) q
 s ok=1,kno=1
 f i=1:1:$l(key,",") s item=$p(key,",",i) s ok=$$order1(qnum,key,item,.kno,.dir) i 'ok q
 i 'ok k dir q
 k ^mgtmp($j,"order")
 q
 ;
order1(qnum,key,item,kno,dir) ; check if order is in keeping with required order
 n x,ord,ok
 s ok=0
 i item'[%z("dsv") q 0
 s ord=$g(^mgtmp($j,"order",kno,0))
 s x=$p(ord,",",kno),dir=$p(x,"~",2),x=$p(x,"~",1) i x="" q 1
 s x=^mgtmp($j,"sel",qnum,x) i key'[x q 0
 i x=item s kno=kno+1
 i x'=item s ok=$$order2(qnum,item) q 0
 ;
 i ok=1,x=item d  i 'ok q ok
 . n link,or
 . s link=$o(^mgtmp($j,"pre",qnum,item,""))
 . i link'="" s or=$o(^mgtmp($j,"pre",qnum,item,link)) i $l(or) s ok=0 q
 . q
 ;
 s dir=$s(dir="desc":"-1",1:"1")
 s dir(x)=dir
 q ok
 ;
order2(qnum,item) ; check if 'leading' subscript is uniquely fixed
 n link,op,cnst,or
 s link=$o(^mgtmp($j,"pre",qnum,item,"")) i link="" q 0
 s or=$o(^mgtmp($j,"pre",qnum,item,link)) i $l(or) q 0
 s op=^mgtmp($j,"pre",qnum,item,link,1,"op"),cnst=^("cnst") i op'="="!(cnst[%z("dsv")) q 0
 s link=$o(^mgtmp($j,"pre",item,link)) i $l(link) q 0
 q 1
 ;
dist(qnum,tnum) ; optimise distinct clause if possible
 n dn,zkey,outsel,i,x
 s zkey=data(qnum,tnum,"key")
 i $d(^mgtmp($j,"from",1,2)) q zkey
 s outsel=$g(^mgtmp($j,"outsel")) i outsel="" q zkey
 f i=1:1:outsel q:'$d(^mgtmp($j,"sel",qnum,i))  s x=^(i),dn("x",x)=""
 f i=1:1:$l(z,",") s y=$p(zkey,",",i) i y[%z("dsv") q:'$d(dn("x",y))  k dn("x",y) s dn=i
 i $d(dn("x")) q zkey
 i dn=$l(zkey,",") s ^mgtmp($j,"sel",qnum,0)=""
 i dn<$l(zkey,","),'$d(^mgtmp($j,"sel",qnum,outsel+1)) s zkey=$p(zkey,",",1,dn),^mgtmp($j,"sel",qnum,0)=""
 q zkey
 ;
delrec ; delete selected record
 q
 n %tagz,%refile,tname,alias,dtyp,key,dat
 s alias=$o(%zq("drec",0,"")) i alias="" q
 i '$d(^mgtmp($j,"from","x",qnum,alias)) q
 s tname=$p(^mgtmp($j,"from",qnum,^mgtmp($j,"from","x",qnum,alias)),"~",1)
 s %tagz=%z("dl")_"delete"_qnum_alias_%z("dl")
 k dtyp d xfid^%mgsqlct
 s line=" k %do,%dn,%dx" d addline^%mgsqlc(grp,.line)
 f i=1:1 q:'$d(xfid(0,i))  s cname=xfid(0,i,1) i cname?1a.e d data^%mgsqlcd
 s %refile=0 d kill^%mgsqlci
 s line=%tagz_" ;" d addline^%mgsqlc(grp,.line)
 q
 ;
 
 
