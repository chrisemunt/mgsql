%mgsqlv1 ;(CM) sql - validate query part 2 ; 14 aug 2002  6:24 pm
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
a d vers^%mgsql("%mgsqlv1") q
 ;
addwhr(qnum,item) ; add item to where statement
 n wnum
 s wnum=$i(^mgtmp($j,"wher",qnum))
 s ^mgtmp($j,"wher",qnum,wnum)=item
 q wnum
 ;
where(dbid,sql,qnum,arg,error) ; validate 'where' statement
 n ln,wn,wnum,pred,wrd,word,ex,sqlex
 s pred="" i $d(^mgtmp($j,"pred",qnum)) s pred=^(qnum)
 i $l(pred) s:$l(arg) arg=" and "_arg s arg="("_pred_")"_arg
 i $l(arg) s ex(1)=arg d where^%mgsqle(.ex,.word,.error) i $l(error) g wherex
 d link^%mgsqlv6
 s wn=0
where1 s wn=wn+1 i '$d(word(0,wn)) g wherex
 s wrd=word(0,wn)
 i wrd[%z("dsv") d where2 i $l(error) g wherex
 i wrd[%z("df") d where3 i $l(error) g wherex
 s wnum=$$addwhr(qnum,wrd)
 g where1
wherex i $l(error),qnum?1n.n s error(0)="where",error(1)=qnum
 q
 ;
where2 ; validate sql column
 n %d,%defk,%defd,%defm,x,y,z,typ,qnum1,fun,tname,alias
 i qnum'["g" s qnum1=qnum
 s x=$p(wrd,%z("dsv"),2)
 i qnum'["g" d corel i $l(error) s error=error_": "_x q
 i qnum["g",x="count(*)" s fun="count" g where21
 i x'["." s error="column '"_x_"' (in 'where'/'having' statement) is not qualified by table name/alias",error(5)="HY000" q
 s cname=x,fun="" i x["(" s fun=$p(x,"(",1),x=$p(x,"(",2,999) i fun="count"&(x[" ") s fun="cntd",x=$p(x," ",2,999)
 s x=$p(x,")",1)
 s f=$p(x,".",1),(x,cname)=$p(x,".",2)
 i qnum'["g",$l(fun) s error="the 'where' statement must not contain references to sql aggregates",error(5)="HY000" q
 i $d(sql("union",qnum)),'$d(^mgtmp($j,"from","x",qnum,f)) s error="invalid alias '"_f_"': 'union' queries cannot be correlated",error(5)="HY000" q
 i qnum'["g" f j=1:1:qnum q:'$d(^mgtmp($j,"from","x",j))  i $d(^mgtmp($j,"from","x",j,f)) s y=^mgtmp($j,"from","x",j,f),y=^mgtmp($j,"from",j,y),tname=$p(y,"~",1),alias=$p(y,"~",2) q
 i qnum["g" i $d(^mgtmp($j,"from","x",1,f)) s y=^mgtmp($j,"from","x",1,f),y=^mgtmp($j,"from",1,y),tname=$p(y,"~",1),alias=$p(y,"~",2)
 i qnum'["g",'$d(^mgtmp($j,"from","x",j,f)) s error="column '"_x_"' (in the 'where' statement) is qualified by an unknown table name/alias",error(5)="HY000" q
 i qnum["g",'$d(^mgtmp($j,"from","x",1,f)) s error="column '"_x_"' (in the 'having' statement) is qualified by an unknown table name/alias",error(5)="HY000" q
 i tname?@("1"""_%z("dq")_"""1n.n1"""_%z("dq")_"""") d  q:$l(error)  g where22
 . n qnum
 . s qnum=$p(tname,%z("dq"),2)
 . i '$d(^mgtmp($j,"vx",qnum,x)) s error="column '"_x_"' ('where'/'having' statement) is not part of derived table "_alias,error(5)="42S22" q
 . q
 s %defk=$$defk^%mgsqld(dbid,tname,cname),%defd=$$defd^%mgsqld(dbid,tname,cname) d remap^%mgsqlv2 i '%defk,'%defd,'%defm s error="column '"_x_"' ('where'/'having' statement) is not part of table "_tname,error(5)="42S22" q
 s %d=$$col^%mgsqld(dbid,tname,cname) s typ=$p(%d,"\",11)
where22 i qnum'["g" s item=%z("dsv")_f_"."_cname_%z("dsv"),snum=$$addselx^%mgsqlv2(qnum,item) s ^mgtmp($j,"wsel",item)=""
 i qnum["g" s item=%z("dsv")_f_"."_cname_%z("dsv"),snum=$$addselx^%mgsqlv2(qnum,item) s ^mgtmp($j,"wsel",item)=""
 i fun="" q
where21 i "count,cntd,sum,avg,max,min"'[fun q
 s qnum1=qnum+0
 i x="count(*)" s z="*"_qnum1,wrd=%z("dsv")_"count("_"*"_qnum1_")"_%z("dsv")
 i x'="count(*)" s z=f_"."_x
 s y=%z("dsv")_fun_"("_z_")"_%z("dsv")
 i fun["(" s y=y_")"
 s snum=$$addselx^%mgsqlv2(qnum1,y)
 s ^mgtmp($j,"wsel",y)=""
 i '$d(sqfun(qnum1,z,fun)) s sqfun(qnum1,z,fun)=selct
 q
 ;
where3 ; force declaration of functions in 'where' statement
 n ex,word,wn
 s ex(1)=$p(wrd,%z("df"),2) d exp i $l(error) q
 s wrd=%z("dsv")_outv_%z("dsv")
 q
 ;
corel ; determine if sql variable comes from different sub-query
 n i,alias
 s alias=$p(x,".",1) i alias="" q
 i $d(^mgtmp($j,"from","x",qnum,alias)) q
 f i=1:1 q:'$d(^mgtmp($j,"from","x",i))  i $d(^mgtmp($j,"from","x",i,alias)) q
 i '$d(^mgtmp($j,"from","x",i,alias)) q
 i $d(sql("union",qnum)),$d(sql("union",i)) s error="'union' (sub) queries may not be correlated",error(5)="HY000" q
 s corel(i,qnum,alias)="",corel("x",qnum,i,alias)="",corel(i,qnum)=0
 s corel(i,qnum,alias,x)=""
 q
 ;
exp ; embedded function
 s outv="cmcmcm"
 d ex^%mgsqle(outv,.ex,.word,.code,.fun,.error)
 q
 ;
 
