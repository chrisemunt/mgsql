%mgsqlv2 ;(CM) sql - validate query part 3 ; 14 aug 2002  6:24 pm
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
table(qnum,item,alias,tname,cname,error) ; check table/alias
 n x
 s alias="",cname=item i item["." s alias=$p(item,".",1),cname=$p(item,".",2) i '$l(cname) s error="invalid sql column '"_item_"'",error(5)="HY000" q
 i alias="",$d(^mgtmp($j,"from",qnum,2)) s error="ambiguous column '"_item_"'",error(5)="HY000" q
 i alias'="" s tname="" i $d(^mgtmp($j,"from","x",qnum,alias)) s x=^mgtmp($j,"from","x",qnum,alias) s tname=$p(^mgtmp($j,"from",qnum,x),"~",1)
 i alias="" s tname=^mgtmp($j,"from",qnum,1),alias=$p(tname,"~",2),tname=$p(tname,"~",1)
 i tname="" s error="invalid alias '"_alias_"' for column '"_cname_"'",error(5)="HY000" q
 q
 ;
group(dbid,sql,qnum,arg,error) ; validate 'group by' statement
 n i,item,com,line
 s ^mgtmp($j,"group",qnum)=""
 f i=1:1:$l(arg,",") s item=$p(arg,",",i) d group1(dbid,qnum,i,item,.error) i $l(error) s error(0)="group",error(1)=qnum q
 s line="",com="" f i=1:1 q:'$d(^mgtmp($j,"group",qnum,i))  s line=line_com_^mgtmp($j,"group",qnum,i),com=","
 i line'="" s ^mgtmp($j,"group",qnum)=line
 q
 ;
group1(dbid,qnum,itemno,item,error) ; for each element grouped by
 n %defk,%defd,alias,tname,cname
 d table(qnum,item,.alias,.tname,.cname,.error) i $l(error) q
 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) i '%defk,'%defd s error="column '"_cname_"' (in 'group by' statement) is not part of table '"_tname_"'",error(5)="42S22" q
 s ^mgtmp($j,"group",qnum,itemno)=%z("dsv")_alias_"."_cname_%z("dsv")
 q
 ;
having(dbid,sql,qnum,arg,error) ; validate 'having'
 n qnumh,i,item,x
 s x="count(distinct " f i=1:1:$l(arg,x) q:arg'[x  s arg=$p(arg,x,1)_"cntd("_$p(arg,x,2,999)
 s qnumh=qnum_"g" d where^%mgsqlv1(dbid,sql,qnumh,arg,.error) i $l(error) g havingx
 f i=1:1 q:'$d(^mgtmp($j,"where",qnumh,i))  d
 . s item=^mgtmp($j,"where",qnumh,i)
 . i item[%z("dsv"),$p(item,%z("dsv"),2)'?1a.a1"("1e.e1")" s error="'having' statements can only contain references to sql aggregates",error(5)="HY000" q
 . s ^mgtmp($j,"having",i)=item
 . q
havingx i $l(error) s error(0)="having",error(1)=qnum
 k ^mgtmp($j,"where",qnumh)
 q
 ;
remap(alias,cname) ; look for extra column defined for soft view only
 i alias=""!(cname="") q 0
 i $d(^mgtmp($j,"remap",alias,cname)) q 1
 q 0
 ;
order(dbid,sql,qnum,arg,error) ; validate 'order by'
 n i,argn,item,args
 s argn=$$arg^%mgsqle(arg,.args)
 f i=1:1:args s item=args(i) d order1(qnum,i,item,.error) i $l(error) s error(0)="order",error(1)=0 q
 q
 ;
order1(qnum,itemno,item,error) ; validate order by item
 n num,len,sel,dir,x
 s dir="asc" i item[" " s dir=$p(item," ",2),item=$p(item," ",1)
 i dir'="asc",dir'="desc" s error="the 'order' for item '"_item_"' must be defined as 'asc' (ascending) or 'desc' (descending)",error(5)="HY000" q
 i item?1n.n,'$d(^mgtmp($j,"sel",1,item)) s error="invalid 'order by' item no. '"_item_"'",error(5)="HY000" q
 i item?1n.n s num=item,sel=^mgtmp($j,"sel",1,num) g order2
 s sel="",len=$l(item,".") f num=1:1 q:'$d(^mgtmp($j,"sel",1,num))  s x=$p(^(num),%z("dsv"),2) i $p(x,".",1,len)=item s sel=%z("dsv")_item_%z("dsv") q
 i '$l(sel) s error="'order by' item '"_item_"' is not in the 'select' statement",error(5)="HY000" q
order2 s ^mgtmp($j,"order",itemno)=sel,^mgtmp($j,"order",itemno,0)=num_"~"_dir
 q
 ;
select(dbid,sql,qnum,arg,error) ; validate 'select' statement
 n opu,op,opu,argn,args,snum,snum1,itemno,item
 s op="" i arg?1an.an1" "1e.e s op=$p(arg," ",1),arg=$p(arg," ",2,999)
 s opu=$$lcase^%mgsqls(op)
 i opu'="",opu'="distinct" s error="invalid row operator '"_op_"' in 'select' statement",error(5)="HY000" g selectx
 i opu="distinct" s op=opu
 s ^mgtmp($j,"sel",qnum)=op
 s argn=$$arg^%mgsqle(arg,.args)
 i qnum>1,'$d(sql("union",qnum)),$d(args(2)) s error="sub-query 'select' statements may have only 1 output",error(5)="HY000" g selectx
 s (snum,snum1)=0
 f itemno=1:1 q:'$d(args(itemno))  s item=$$trim^%mgsqls(args(itemno)) d select1(dbid,qnum,itemno,item,.error) i $l(error) q
 i $l(error) g selectx
 i qnum'=1,$d(sql("union",qnum)) d union(qnum,.error) i $l(error) g selectx
selectx i $l(error) s error(0)="select",error(1)=qnum
 q
 ;
select1(dbid,qnum,itemno,item,error) ; validate specific item in 'select' line
 n len,as,asl,asv
 s len=$l(item," ")
 i len>1 d
 . s asl=$p(item," ",len)
 . s as="" i len>2 s as=$p(item," ",len-1) s as=$$ucase^%mgsqls(as)
 . i as="as" s asv=$p(item," ",1,len-2)
 . i as'="as" s asv=$p(item," ",1,len-1)
 . i $l(asv,"(")'=$l(asv,")") q
 . i '($l(asv,"""")#2) q
 . s item=asv,^mgtmp($j,"map",qnum,itemno)=asl
 . q
 i item'["(",item?1a.e1"."1"{".e1"}"1"."1a.e s item=%z("dsv")_item_%z("dsv"),snum=$$addsel(qnum,item) q
 i item?1a.e,item'["(",item'[" ",item'["*" d select2(dbid,qnum,itemno,item,.error) q
 i item="*"!(item?1a.e1"."1"*") d select3(dbid,qnum,itemno,item,.error) q
 i item?1a.a1"("1e.e1")" d select4(dbid,qnum,itemno,item,.error) q
 d select5(qnum,item,.error)
 q
 ;
select2(dbid,qnum,itemno,item,error) ; columns
 n %defk,%defd,%defm,ok,alias,tname,cname
 d table(qnum,item,.alias,.tname,.cname,.error) i $l(error) q
 i item?1a.e1"."1"{".e1"}"1"."1a.e g select21
 i tname?@("1"""_%z("dq")_"""1n.n1"""_%z("dq")_"""") d  q:$l(error)  g select21
 . n qnum
 . s qnum=$p(tname,%z("dq"),2)
 . i '$d(^mgtmp($j,"vx",qnum,cname)) s error="'select' item '"_cname_"' is not a column of derived table "_alias,error(5)="42S22" q
 . q
 s ok=0,%defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname),%defm=$$remap(alias,cname) s ok=%defk!%defd!%defm
 i 'ok s error="'select' item '"_cname_"' is not a column of table '"_tname_"'",error(5)="42S22" q
select21 s item=%z("dsv")_alias_"."_cname_%z("dsv"),snum=$$addsel(qnum,item)
 q
 ;
select3(dbid,qnum,itemno,item,error) ; x="*" - get all key & data columns
 n %ind,%data,pkey,ino,pkeyx,datax,i,n,x,r,sc,alias,tname,cname
 d table(qnum,item,.alias,.tname,.cname,.error) i $l(error) q
 s ino=$$pkey^%mgsqld(dbid,tname),sc=$$key^%mgsqld(dbid,tname,ino,.%ind)
 s pkey=0 f i=1:1 q:'$d(%ind(ino,i))  s x=%ind(ino,i) i x?1a.e s pkey=pkey+1,pkey(pkey)=x,pkeyx(x)=pkey
 i qnum'=1,$d(pkey(1)) s item=pkey(1),item=%z("dsv")_alias_"."_item_%z("dsv"),snum=$$addsel(qnum,item) q
 f i=1:1 q:'$d(pkey(i))  s item=pkey(i) s item=%z("dsv")_alias_"."_item_%z("dsv"),snum=$$addsel(qnum,item)
 s sc=$$data^%mgsqld(dbid,tname,.%data)
 s x="" f  s x=$o(%data(x)) q:x=""  s r=$g(%data(x)),n=$p(r,"\",1)+0 s datax(n,x)=""
 s n="" f  s n=$o(datax(n)) q:n=""  s x="" f  s x=$o(datax(n,x)) q:x=""  k datax(n,x) i '$d(pkeyx(x)) s item=%z("dsv")_alias_"."_x_%z("dsv"),snum=$$addsel(qnum,item)
 q
 ;
select4(dbid,qnum,itemno,item,error) ; aggregates
 n %defk,%defd,%defm,ok,key,fun,mfun,newx,alias,tname,cname
 s fun=$p(item,"(",1),item=$p(item,"(",2,999),item=$e(item,1,$l(item)-1)
 s mfun=$$sqlfun(fun) i mfun'="" d select5(qnum,mfun_"("_item_")",.error) q
 i fun="count",$p(item," ",1)="distinct" s fun="cntd",item=$p(item," ",2,999)
 i $p(item," ",1)="notnull" s fun=fun_"_"_"notnull",item=$p(item," ",2,999)
 i "count,cntd,sum,avg,max,min"'[$p(fun,"_",1) s error="invalid aggregate '"_fun_"'",error(5)="HY000" q
 i item?.1"-".n.1"."1n.n!($e(item)=$c(34)) s error="you may not select the '"_fun_"' of '"_item_"'",error(5)="HY000" q
 i item="*" d  g select41
 . i fun'="count" s error="you may not 'select' the '"_fun_"' of '*'",error(5)="HY000" q
 . i $d(^mgtmp($j,"sqag",qnum,item_qnum,fun)) s error="duplication of aggregate in 'select' line",error(5)="HY000" q
 . s key=item_qnum,newx=fun_"("_item_qnum_")"
 . q
 d table(qnum,item,.alias,.tname,.cname,.error) i $l(error) q
 s ok=0,%defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname),%defm=$$remap(alias,cname) s ok=%defk!%defd!%defm
 i 'ok s error="'select' item '"_cname_"' is not a column of table '"_tname_"'",error(5)="42S22" q
 s key=alias_"."_cname,newx=fun_"("_alias_"."_cname s newx=newx_")"
select41 i error'="" q
 s item=%z("dsv")_newx_%z("dsv"),snum=$$addsel(qnum,item),^mgtmp($j,"sqag",qnum,key,fun)=snum
 q
 ;
select5(qnum,mfun,error) ; undeclared expression
 n pn,i,fn,ax,outv,ex,word,zcode,fun,item,snum
 s ax=$g(^mgtmp($j,"e"))+1,^("e")=ax
 s outv="___v"_ax
 s ex(1)=mfun d ex^%mgsqle(outv,.ex,.word,.zcode,.fun,.error) i $l(error) q
 f fn=1:1 q:'$d(fun(fn))  f pn=1:1 q:'$d(fun(fn,"p",pn))  s item=$g(fun(fn,"p",pn,1)) i item[%z("dsv") s snum=$$addselx(qnum,item)
 f i=1:1 q:'$d(zcode(i))  f  q:zcode(i)'[%z("df")  d
 . s fn=$p(zcode(i),%z("df"),2)
 . s zcode(i)=$p(zcode(i),%z("df"),1)_fun(fn,"s")_$p(zcode(i),%z("df"),3,999)
 . q
 m ^mgtmp($j,"e",outv)=zcode
 s item=%z("dsv")_outv_%z("dsv"),snum=$$addsel(qnum,item)
 q
 ;
union(qnum,error) ; check line for union compatibility
 n i,item1,item2,outsel,snum
 s outsel=$g(^mgtmp($j,"outsel",1))
 s snum=$g(^mgtmp($j,"sel",qnum))
 i snum'=outsel s error="each participating 'select' in a 'union' must have the same number of selected items",error(5)="HY000" q
 f i=1:1:outsel s item1=$p(^mgtmp($j,"sel",1,i),%z("dsv"),2),item2=$p(^mgtmp($j,"sel",qnum,i),%z("dsv"),2) d union1(item1,item2,.error)
 q
 ;
union1(item1,item2,error) ; for each item
 n a1,a2
 s (a1,a2)=""
 i item1["(" s a1=$p(item1,"(",1)
 i item2["(" s a2=$p(item2,"(",1)
 i item1'="",a1'=a2 s error="'union': 'select' item '"_item2_"' should be a '"_a1_"' aggregate",error(5)="HY000" q
 i item2'="",a1'=a2 s error="'union': 'select' aggregate '"_item2_"' is not compatible with the first query",error(5)="HY000" q
 q
 ;
sqlfun(sqlfun) ; translate SQL function name to M equivalent
 s mfun=""
 i sqlfun="lower" s mfun="$$lcase^%mgsqls"
 i sqlfun="upper" s mfun="$$ucase^%mgsqls"
 q mfun
 ;
 
