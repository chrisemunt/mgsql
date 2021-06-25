%mgsqle ;(CM) SQL : Embedded expressions ; 12 feb 2002  02:10pm
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
a d vers^%mgsql("%mgsqle") q
 ;
ex(outv,ex,word,code,sqlfn,error) ; 'ex' expression
 n i,en,fn,fun,ops
 s en=0,fn=0,error=""
 s ops=$$ops(.ops)
 d word^%mgsqle1(en,.ex,.word,.sqlex,.ops,.error) i $l(error) g exe
 d vrfy^%mgsqle1(en,.word,.ops,.error) i $l(error) g exe
 d brac^%mgsqle1(en,.word,.ops,.error) i $l(error) g exe
 f i=1:1 q:'$d(word(en,i))  s fun=word(en,i) i fun[%z("df") s fun=$p(fun,%z("df"),2),fn=$$fun(fun,.sqlfn,.ops,.error) s word(en,i)=%z("df")_fn_%z("df") i $l(error) q
 i $l(error) g exe
 d comp^%mgsqle2(en,outv,.word,.sqlfn,.sqlex,.code,.error)
exe ; exit
 q
 ;
where(ex,word,error) ; validate sql 'where' predicate
 n en,ops
 s en=0,error=""
 s ops=$$ops(.ops)
 d word^%mgsqle1(en,.ex,.word,.sqlex,.ops,.error) i $l(error) g wheree
 d vrfy^%mgsqle1(en,.word,.ops,.error) i $l(error) g wheree
 d brac^%mgsqle1(en,.word,.ops,.error) i $l(error) g wheree
wheree ; exit
 q
 ;
arg(arg,args) ; produce argument list from arguments string
 n pn,an,i,str,obr,cbr,chr,arg1
 k args s pn=0,an=0
arg1 s pn=pn+1 i pn>$l(arg,",") g argx
 s arg1=$p(arg,",",pn)
 f i=pn+1:1 q:i>$l(arg,",")!($l(arg1,"""")#2)  s arg1=arg1_","_$p(arg,",",i),pn=pn+1
 i arg1["(" s str=arg1_","_$p(arg,",",pn+1,999),(obr,cbr)=0 f i=1:1 s chr=$e(str,i) q:chr=""  i $l($e(str,1,i),"""")#2 s:chr="(" obr=obr+1 s:chr=")" cbr=cbr+1 i chr=",",obr=cbr q
 i arg1["(" s arg1=$e(str,1,i-1),pn=pn+$l(arg1,",")-1
 s an=an+1,args(an)=arg1
 g arg1
argx s args=an
 q args
 ;
ops(ops) ; operator list
 n i,op
 s ops=":*:/:\:#:-:+:=:i=:<>:!=:'=:?:>:<:>:<:>=:'<:<=:'>:[:[:]:]:in:not in:like:not like:exists:not exists:between:not between:and:&:or:!:"
 f i=2:1:$l(ops,":") s op=$p(ops,":",i) i op'="" s ops(op)=i
 q ops
 ;
oper(ops,props,neops) ; get list of valid operators
 n x
 s ops=$$ops(.x)
 ; list of operators which may be translated into physical restrictions
 s props=":=:>:<:'>:'<:>=:<=:'>=:'<=:]:']:"
 ; list of operators which may be used to exclude null only
 s neops=":'=:[:"
 s ops("=")="=",ops("'=")="'="
 s ops(">")="<",ops("<")=">"
 s ops("'>")="'<",ops("'<")="'>"
 s ops(">=")="<=",ops("<=")=">="
 s ops("]")="<",ops("']")="'<"
 s ops("+")="-",ops("-")="+"
 s ops("*")="/",ops("/")="*"
 q ops
 ;
fun(fun,sqlfn,ops,error) ; decompose function fun (number fn)
 n funlin,pars,fn
 s fn=0
 s fun=$$fun1(fun)
 i fun'?1"{a}".e s error="invalid function "_fun,error(5)="HY000" q fn
fun2 i fun'["{a}" g funx
 s funlin=$p(fun,"{a}",$l(fun,"{a}")),fn=$i(sqlfn)
 s wrd=$$funlin(funlin,.error) i $l(error) g funx
 s fun=$p(fun,"{a}",1,$l(fun,"{a}")-1)_%z("df")_fn_%z("df")_$e(funlin,$l(wrd)+1,999),sqlfn(fn)=wrd
 s pars=$p(wrd,"(",2,999),pars=$e(pars,1,$l(pars)-1)
 d pars(funlin,pars,.sqlfn,fn,.ops,.error) i $l(error) g funx
 g fun2
funx ; exit
 q fn
 ;
fun1(fun) ; insert leading delimiter '{a}' for each nested function
 n i,pn,pre,post
 s pn=0
fun11 s pn=pn+1 i pn>$l(fun,"(") q fun
 s pre=$p(fun,"(",1,pn),post=$p(fun,"(",pn+1,999)
 i pre=""!(post="")!(pre=fun)!'($l(pre,"""")#2) g fun11
 f i=$l(pre):-1:0 i " ,("[$e(pre,i) q
 s fun=$e(pre,1,i)_"{a}"_$e(pre,i+1,999)_"("_post
 g fun11
 ;
pars(funlin,pars,sqlfn,fn,ops,error) ; get parameter list for function
 n select,pn,parn,par,i
 s select=0 i funlin?1"$s(".e s select=1
 s pn=0,parn=0
pars1 s pn=pn+1 i pn>$l(pars,",") g parsx
 s par=$p(pars,",",pn)
 f i=pn+1:1 q:i>$l(pars,",")!($l(par,"""")#2)  s par=par_","_$p(pars,",",i),pn=pn+1
 i select s select("a",2)=$p(par," : ",2,999),par=$p(par," : ",1)
pars11 s parn=parn+1
 d pars2(par,parn,.sqlfn,fn,.ops,.error) i $l(error) g parsx
 i select,$d(select("a",2)) s par=select("a",2) k select("a") g pars11
 g pars1
parsx ; exit
 q
 ;
pars2(par,parn,sqlfn,fn,ops,error) ; validate/bracket expression for parameter
 n en,ex,pn,word
 i par="" q  ; niladic
 s en="f"
 i par?1u1":"1a.e s word(en,1)=par,entpar(par)="" g pars3
 s ex(1)=par d word^%mgsqle1(en,.ex,.word,.sqlex,.ops,.error) i $l(error) q
 d vrfy^%mgsqle1(en,.word,.ops,.error) i $l(error) q
 d brac^%mgsqle1(en,.word,.ops,.error) i $l(error) q
pars3 f i=1:1 q:'$d(word(en,i))  s sqlfn(fn,"p",parn,i)=word(en,i)
 k word(en)
 q
 ;
funlin(funlin,error) ; extract function & parameters wrd from funlin
 n obr,cbr,chr,i,wrd
 s (obr,cbr)=0 f i=1:1:$l(funlin) s chr=$e(funlin,i) i "()"[chr,$l($e(funlin,1,i),"""")#2 s:chr="(" obr=obr+1 s:chr=")" cbr=cbr+1 i obr=cbr q
 s wrd=$e(funlin,1,i)
 i 'obr!(obr'=cbr) s error="error in function "_wrd,error(5)="HY000" q wrd
 q wrd
 ;
