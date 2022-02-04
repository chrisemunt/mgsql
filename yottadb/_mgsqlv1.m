%mgsqlv1 ;(CM) sql - validate query part 2 ; 28 Jan 2022  10:03 AM
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
a d vers^%mgsql("%mgsqlv1") q
 ;
addwhr(qnum,item) ; add item to where statement
 n wnum
 s wnum=$i(^mgtmp($j,"where",qnum))
 s ^mgtmp($j,"where",qnum,wnum)=item
 q wnum
 ;
where(dbid,sql,qnum,arg,error) ; validate 'where' statement
 n ln,wn,wnum,pred,wrd,word,ex
 s pred="" i $d(^mgtmp($j,"pred",qnum)) s pred=^(qnum)
 i $l(pred) s:$l(arg) arg=" and "_arg s arg="("_pred_")"_arg
 i $l(arg) s ex(1)=arg d where^%mgsqle(.ex,.word,.error) i $l(error) g wherex
 d link^%mgsqlv6(dbid,.sql,qnum,arg,.error)
 s wn=0
where1 s wn=wn+1 i '$d(word(0,wn)) g wherex
 s wrd=word(0,wn)
 i wrd[%z("dsv") s wrd=$$where2(dbid,qnum,wrd,.error) i $l(error) g wherex
 i wrd[%z("df") s wrd=$$where3(qnum,$p(wrd,%z("df"),2),error) i $l(error) g wherex
 s wnum=$$addwhr(qnum,wrd)
 g where1
wherex i $l(error),qnum?1n.n s error(0)="where",error(1)=qnum
 q
 ;
where2(dbid,qnum,item,error) ; validate sql column
 n %d,%defk,%defd,%defm,x,y,z,wrd,typ,qnum1,fun,mfun,alias,tname,cname,alias,snum
 s wrd=item
 i qnum["g" g where2h
 s qnum1=qnum
 s x=$p(wrd,%z("dsv"),2)
 d corelate(.sql,qnum,x,.error) i $l(error) s error=error_": "_x q wrd
 ;;i x'["." s error="column '"_x_"' (in 'where'/'having' statement) is not qualified by table name/alias",error(5)="HY000" q wrd
 s cname=x,fun="" i x["(" s fun=$p(x,"(",1),x=$p(x,"(",2,999) i fun="count"&(x[" ") s fun="cntd",x=$p(x," ",2,999)
 s item=$p(x,")",1)
 d table^%mgsqlv2(dbid,qnum,item,.alias,.tname,.cname,1,.error) i $l(error) q wrd
 ;;s f=$p(x,".",1),(x,cname)=$p(x,".",2)
 s mfun=$$sqlfun^%mgsqlv2(fun) i mfun'="" s wrd=%z("df")_mfun_"("_alias_"."_cname_")"_%z("df") q wrd
 i $l(fun) s error="the 'where' statement must not contain references to sql aggregates",error(5)="HY000" q wrd
 i $d(sql("union",qnum)),'$d(^mgtmp($j,"from","x",qnum,alias)) s error="invalid alias '"_alias_"': 'union' queries cannot be correlated",error(5)="HY000" q wrd
 ;;f j=1:1:qnum q:'$d(^mgtmp($j,"from","x",j))  i $d(^mgtmp($j,"from","x",j,f)) s y=^mgtmp($j,"from","x",j,f),y=^mgtmp($j,"from",j,y),tname=$p(y,"~",1),alias=$p(y,"~",2) q wrd
 ;;i '$d(^mgtmp($j,"from","x",j,f)) s error="column '"_x_"' (in the 'where' statement) is qualified by an unknown table name/alias",error(5)="HY000" q wrd
 g where21
where2h ; Having predicate
 s x=$p(wrd,%z("dsv"),2)
 i x="count(*)" s fun="count" g where23
 i x'["." s error="column '"_x_"' (in 'having' statement) is not qualified by table name/alias",error(5)="HY000" q
 s cname=x,fun="" i x["(" s fun=$p(x,"(",1),x=$p(x,"(",2,999) i fun="count"&(x[" ") s fun="cntd",x=$p(x," ",2,999)
 s item=$p(x,")",1)
 d table^%mgsqlv2(dbid,1,item,.alias,.tname,.cname,0,.error) i $l(error) q
 ;;s f=$p(x,".",1),(x,cname)=$p(x,".",2)
 i $d(sql("union",qnum)),'$d(^mgtmp($j,"from","x",qnum,alias)) s error="invalid alias '"_alias_"': 'union' queries cannot be correlated",error(5)="HY000" q
 ;;i $d(^mgtmp($j,"from","x",1,f)) s y=^mgtmp($j,"from","x",1,f),y=^mgtmp($j,"from",1,y),tname=$p(y,"~",1),alias=$p(y,"~",2)
 ;;i '$d(^mgtmp($j,"from","x",1,f)) s error="column '"_x_"' (in the 'having' statement) is qualified by an unknown table name/alias",error(5)="HY000" q
where21 ; Common
 ;;i tname?@("1"""_%z("dq")_"""1n.n1"""_%z("dq")_"""") d  q:$l(error)  g where22
 ;;. n qnum
 ;;. s qnum=$p(tname,%z("dq"),2)
 ;;. i '$d(^mgtmp($j,"vx",qnum,x)) s error="column '"_x_"' ('where'/'having' statement) is not part of derived table "_alias,error(5)="42S22" q
 ;;. q
 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname),%defm=$$remap^%mgsqlv2(alias,cname) i '%defk,'%defd,'%defm s error="column '"_item_"' ('where'/'having' statement) is not part of table "_tname,error(5)="42S22" q wrd
 s %d=$$col^%mgsqld(dbid,tname,cname) s typ=$p(%d,"\",11)
where22 s item=%z("dsv")_alias_"."_cname_%z("dsv"),snum=$$addselx^%mgsqlv2(qnum,item) s ^mgtmp($j,"wsel",item)=""
 i fun="" q item
where23 i "count,cntd,sum,avg,max,min"'[fun q wrd
 s qnum1=qnum+0
 i x="count(*)" s z="*"_qnum1,wrd=%z("dsv")_"count("_"*"_qnum1_")"_%z("dsv")
 i x'="count(*)" s z=alias_"."_x
 s y=%z("dsv")_fun_"("_z_")"_%z("dsv")
 i fun["(" s y=y_")"
 s snum=$$addselx^%mgsqlv2(qnum1,y)
 s ^mgtmp($j,"wsel",y)=""
 i '$d(^mgtmp($j,"sqag",qnum1,z,fun)) s ^mgtmp($j,"sqag",qnum1,z,fun)=snum
 q wrd
 ;
where3(qnum,mfun,error) ; embedded functions in 'where' statement
 n pn,i,fn,ax,outv,ex,word,zcode,fun,item,snum
 s ax=$g(^mgtmp($j,"e"))+1,^("e")=ax
 s outv="___v"_ax
 s ex(1)=mfun d ex^%mgsqle(outv,.ex,.word,.zcode,.fun,.error) i $l(error) q ""
 f fn=1:1 q:'$d(fun(fn))  f pn=1:1 q:'$d(fun(fn,"p",pn))  s item=$g(fun(fn,"p",pn,1)) i item[%z("dsv") s snum=$$addselx^%mgsqlv2(qnum,item)
 f i=1:1 q:'$d(zcode(i))  f  q:zcode(i)'[%z("df")  d
 . s fn=$p(zcode(i),%z("df"),2)
 . s zcode(i)=$p(zcode(i),%z("df"),1)_fun(fn,"s")_$p(zcode(i),%z("df"),3,999)
 . q
 m ^mgtmp($j,"e",outv)=zcode
 s item=%z("dsv")_outv_%z("dsv"),snum=$$addselx^%mgsqlv2(qnum,item)
 q (%z("dsv")_outv_%z("dsv"))
 ;
corelate(sql,qnum,item,error) ; determine if sql variable comes from different sub-query
 n i,alias
 s alias=$p(item,".",1) i alias="" q
 i $d(^mgtmp($j,"from","x",qnum,alias)) q
 f i=1:1 q:'$d(^mgtmp($j,"from","x",i))  i $d(^mgtmp($j,"from","x",i,alias)) q
 i '$d(^mgtmp($j,"from","x",i,alias)) q
 i $d(sql("union",qnum)),$d(sql("union",i)) s error="'union' (sub) queries may not be correlated",error(5)="HY000" q
 s ^mgtmp($j,"corel",i,qnum,alias)="",^mgtmp($j,"corelx",qnum,i,alias)="",^mgtmp($j,"corel",i,qnum)=0
 s ^mgtmp($j,"corel",i,qnum,alias,x)=""
 q
 ;
