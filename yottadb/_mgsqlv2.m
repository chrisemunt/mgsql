%mgsqlv2 ;(CM) sql - validate query part 3 ; 14 aug 2002  6:24 pm
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
a d vers^%mgsql("%mgsqlv2") q
 ;
addsel(qnum,item) ; add item to output select list
 n snum,snum1
 s snum=$$addselx(qnum,item)
 s snum1=$i(^mgtmp($j,"outsel",qnum))
 s ^mgtmp($j,"outsel",qnum,snum1)=item,^mgtmp($j,"outselx",qnum,item)=snum1
 q snum1
 ;
addselx(qnum,item) ; add item to general select list
 n snum
 s snum=$i(^mgtmp($j,"sel",qnum))
 s ^mgtmp($j,"sel",qnum,snum)=item,^mgtmp($j,"selx",qnum,item)=snum
 q snum
 ;
group(dbid,sql,qnum,arg,error) ; validate 'group by' statement
 s gvar(qnum)="",com=""
 f i=1:1:$l(arg,",") s x=$p(arg,",",i) d group1 i $l(error) s error(0)="group",error(1)=qnum q
 i '$l(gvar(qnum)) k gvar(qnum)
 q
 ;
group1 ; for each element grouped by
 d getf i $l(error) q
 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) i '%defk,'%defd s error="column '"_cname_"' (in 'group by' statement) is not part of table '"_tname_"'",error(5)="42S22" q
 s gvar(qnum,i)=%z("dsv")_f_"."_cname_%z("dsv"),gvar(qnum)=gvar(qnum)_com_gvar(qnum,i),com=","
 q
 ;
having(dbid,sql,qnum,arg,error) ; validate 'having'
 n qnumh
 s x="count(distinct " f i=1:1:$l(arg,x) q:arg'[x  s arg=$p(arg,x,1)_"cntd("_$p(arg,x,2,999)
 s qnumh=qnum_"g" d where^%mgsqlv1(dbid,sql,qnumh,arg,error) i $l(error) g havingx
 f i=1:1 q:'$d(^mgtmp($j,"wher",qnumh,i))  s hav(i)=^mgtmp($j,"wher",qnumh,i) i hav(i)[%z("dsv"),$p(hav(i),%z("dsv"),2)'?1a.a1"("1e.e1")" s error="'having' statements can only contain references to sql aggregates",error(5)="HY000" q
havingx i $l(error) s error(0)="having",error(1)=qnum
 k ^mgtmp($j,"wher",qnumh)
 q
 ;
getf ; check table/alias
 s f="",cname=x i x["." s f=$p(x,".",1),cname=$p(x,".",2) i '$l(cname) s error="invalid sql column '"_x_"'",error(5)="HY000" q
 i f="",$d(^mgtmp($j,"from",qnum,2)) s error="ambiguous column '"_x_"'",error(5)="HY000" q
 i f'="" s tname="" i $d(^mgtmp($j,"from","x",qnum,f)) s y=^mgtmp($j,"from","x",qnum,f) s tname=$p(^mgtmp($j,"from",qnum,y),"~",1)
 i f="" s tname=^mgtmp($j,"from",qnum,1),f=$p(tname,"~",2),tname=$p(tname,"~",1)
 i tname="" s error="invalid alias '"_f_"' for column '"_cname_"'",error(5)="HY000" q
 s tnamer=tname
 q
 ;
remap ; look for extra column defined for soft view only
 s %defmd="",%defm=0
 i '$l(f) q
 i '$l(cname) q
 i $d(^mgtmp($j,"remap",f,cname)) s %defm=1,%defmd=^(cname)
 q
 ;
order(dbid,sql,qnum,arg,error) ; validate 'order by'
 n argn,com,x,y,dir,args
 s ord="",com=""
 s argn=$$arg^%mgsqle(arg,.args)
 f j=1:1:args s x=args(j) d order1 i $l(error) s error(0)="order",error(1)=0 q
 q
 ;
order1 ; validate order by item
 n num,sel
 s dir="asc" i x[" " s dir=$p(x," ",2),x=$p(x," ",1)
 i dir'="asc",dir'="desc" s error="the 'order' for item '"_x_"' must be defined as 'asc' (ascending) or 'desc' (descending)",error(5)="HY000" q
 i x?1n.n,'$d(^mgtmp($j,"sel",1,x)) s error="invalid 'order by' item no. '"_x_"'",error(5)="HY000" q
 i x?1n.n s num=x,sel=^mgtmp($j,"sel",1,num) g order2
 s sel="",len=$l(x,".") f num=1:1 q:'$d(^mgtmp($j,"sel",1,num))  s y=$p(^(num),%z("dsv"),2) i $p(y,".",1,len)=x s sel=%z("dsv")_x_%z("dsv") q
 i '$l(sel) s error="'order by' item '"_x_"' is not in the 'select' statement",error(5)="HY000" q
order2 s ord=ord_com_num_"~"_dir,com=","
 s ord(j)=sel
 q
 ;
select(dbid,sql,qnum,arg,error) ; validate 'select' statement
 n opu,op,opu,argn,args,snum,snum1,fr,x
 s op="" i arg?1an.an1" "1e.e s op=$p(arg," ",1),arg=$p(arg," ",2,999)
 s opu=$$lcase^%mgsqls(op)
 i opu'="",opu'="distinct" s error="invalid row operator '"_op_"' in 'select' statement",error(5)="HY000" g selectx
 i opu="distinct" s op=opu
 s ^mgtmp($j,"sel",qnum)=op
 s argn=$$arg^%mgsqle(arg,.args)
 i qnum>1,'$d(sql("union",qnum)),$d(args(2)),'$d(^mgtmp($j,"v",qnum)) s error="sub-query 'select' statements may have only 1 output",error(5)="HY000" g selectx
 s (snum,snum1)=0
 f fr=1:1 q:'$d(args(fr))  s x=$$trim^%mgsqls(args(fr)) d select1 i $l(error) q
 i $l(error) g selectx
 i qnum'=1,$d(sql("union",qnum)) d union i $l(error) g selectx
selectx i $l(error) s error(0)="select",error(1)=qnum
 q
 ;
select1 ; validate specific item in 'select' line
 n len,as,asl,asv
 s len=$l(x," ")
 i len>1 d
 . s asl=$p(x," ",len)
 . s as="" i len>2 s as=$p(x," ",len-1) s as=$$ucase^%mgsqls(as)
 . i as="as" s asv=$p(x," ",1,len-2)
 . i as'="as" s asv=$p(x," ",1,len-1)
 . i $l(asv,"(")'=$l(asv,")") q
 . i '($l(asv,"""")#2) q
 . s x=asv,^mgtmp($j,"map",qnum,fr)=asl
 . q
 i x'["(",x?1a.e1"."1"{".e1"}"1"."1a.e s item=%z("dsv")_x_%z("dsv"),snum=$$addsel(qnum,item) q
 i x?1a.e,x'["(",x'[" ",x'["*" k fun d select2 q:$l(error)  s item=%z("dsv")_f_"."_cname_%z("dsv"),snum=$$addsel(qnum,item) q  ; columns
 i x="*"!(x?1a.e1"."1"*") d select3 q  ; all table columns (key & data)
 i x?1a.a1"("1e.e1")" d select4 q  ; aggregates
 d select5
 q
 ;
select2 ; columns
 n ok
 d getf i $l(error) q
 i x?1a.e1"."1"{".e1"}"1"."1a.e g select21
 i tname?@("1"""_%z("dq")_"""1n.n1"""_%z("dq")_"""") d  q:$l(error)  g select21
 . n qnum
 . ;b
 . s qnum=$p(tname,%z("dq"),2)
 . i '$d(^mgtmp($j,"vx",qnum,cname)) s error="'select' item '"_cname_"' is not a column of derived table "_alias,error(5)="42S22" q
 . q
 s com="",ok=0 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) d remap s ok=%defk!%defd!%defm
 i 'ok s error="'select' item '"_cname_"' is not a column of table '"_tname_"'",error(5)="42S22" q
select21 i $d(fun),$l(fun) i $d(sqfun(qnum,f_"."_cname,fun)) s error="duplication of aggregate in 'select' line",error(5)="HY000" q
 q
 ;
select3 ; x="*" - get all key & data columns
 n pkey,pkeyx,datax,n
 d getf i $l(error) q
 s ino=$$pkey^%mgsqld(dbid,tname) s sc=$$key^%mgsqld(dbid,tname,ino,.%ind) s pkey=0 f j=1:1 q:'$d(%ind(ino,j))  s x=%ind(ino,j) i x?1a.e s pkey=pkey+1,pkey(pkey)=x,pkeyx(x)=pkey
 i qnum'=1,$d(pkey(1)) s x=pkey(1),item=%z("dsv")_f_"."_x_%z("dsv"),snum=$$addsel(qnum,item) q
 f j=1:1 q:'$d(pkey(j))  s (y,x)=pkey(j) s item=%z("dsv")_f_"."_x_%z("dsv"),snum=$$addsel(qnum,item)
 s sc=$$data^%mgsqld(dbid,tname,.%data)
 s x="" f  s x=$o(%data(x)) q:x=""  s r=$g(%data(x)),n=$p(r,"\",1)+0 s datax(n,x)="" k %data(x)
 s n="" f  s n=$o(datax(n)) q:n=""  s x="" f  s x=$o(datax(n,x)) q:x=""  k datax(n,x) i '$d(pkeyx(x)) s item=%z("dsv")_f_"."_x_%z("dsv"),snum=$$addsel(qnum,item)
 q
 ;
select4 ; aggregates
 n key
 s fun=$p(x,"(",1),x=$p(x,"(",2,999),x=$e(x,1,$l(x)-1)
 i fun="count",$p(x," ",1)="distinct" s fun="cntd",x=$p(x," ",2,999)
 i $p(x," ",1)="notnull" s fun=fun_"_"_"notnull",x=$p(x," ",2,999)
 i "count,cntd,sum,avg,max,min"'[$p(fun,"_",1) s error="invalid aggregate '"_fun_"'",error(5)="HY000" q
 i x?.1"-".n.1"."1n.n!($e(x)=$c(34)) s error="you may not select the '"_fun_"' of '"_x_"'",error(5)="HY000" q
 i x="*",fun'="count" s error="you may not 'select' the '"_fun_"' of '*'",error(5)="HY000" q
 i x="*",fun="count" i $d(sqfun(qnum,x_qnum,fun)) s error="duplication of aggregate in 'select' line",error(5)="HY000" q
 i x="*",fun="count" s key=x_qnum,newx=fun_"("_x_qnum_")" g select41
 d select2 i $l(error) q
 s key=f_"."_cname,newx=fun_"("_f_"."_cname s newx=newx_")"
select41 s item=%z("dsv")_newx_%z("dsv"),snum=$$addsel(qnum,item),sqfun(qnum,key,fun)=snum
 k newx
 q
 ;
select5 ; undeclared expression
 n pn,fn,ax,outv,ex,word,zcode,fun
 s ax=$g(^mgtmp($j,"e"))+1,^("e")=ax
 s outv="___v"_ax
 s ex(1)=x d ex^%mgsqle(outv,.ex,.word,.zcode,.fun,.error) i $l(error) q
 f fn=1:1 q:'$d(fun(fn))  f pn=1:1 q:'$d(fun(fn,"p",pn))  s item=$g(fun(fn,"p",pn,1)) i item[%z("dsv"),snum=$$addselx(qnum,item)
 f i=1:1 q:'$d(zcode(i))  f  q:zcode(i)'[%z("df")  d
 . s fn=$p(zcode(i),%z("df"),2)
 . s zcode(i)=$p(zcode(i),%z("df"),1)_fun(fn,"s")_$p(zcode(i),%z("df"),3,999)
 . q
 m ^mgtmp($j,"e",outv)=zcode
 s item=%z("dsv")_outv_%z("dsv"),snum=$$addsel(qnum,item)
 q
 ;
union ; check line for union compatibility
 n i,x,y,x1,y1,outsel
 s outsel=$g(^mgtmp($j,"outsel",qnum))
 i snum'=outsel s error="each participating 'select' in a 'union' must have the same number of selected items",error(5)="HY000" q
 f i=1:1:outsel s x=$p(^mgtmp($j,"sel",1,i),%z("dsv"),2),y=$p(^mgtmp($j,"sel",qnum,i),%z("dsv"),2) d union1
 q
 ;
union1 ; for each item
 s (x1,y1)="" s:x["(" x1=$p(x,"(",1) s:y["(" y1=$p(y,"(",1)
 i $l(x1),y1'=x1 s error="'union': 'select' item '"_y_"' should be a '"_x1_"' aggregate",error(5)="HY000" q
 i $l(y1),y1'=x1 s error="'union': 'select' aggregate '"_y_"' is not compatible with the first query",error(5)="HY000" q
 q
 ;
 
