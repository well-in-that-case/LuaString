local a={}local b={["!"]=0,['"']=0,["#"]=0,["$"]=0,["%"]=0,["&"]=0,["'"]=0,["("]=0,[")"]=0,["*"]=0,["+"]=0,[","]=0,["-"]=0,["."]=0,["/"]=0,[":"]=0,[";"]=0,["<"]=0,["="]=0,[">"]=0,["?"]=0,["@"]=0,["["]=0,["]"]=0,["^"]=0,["_"]=0,["`"]=0,["{"]=0,["|"]=0,["}"]=0,["~"]=0,["\\"]=0}local c={["\f"]=0,["\r"]=0,[" "]=0,["\t"]=0,["\v"]=0,["\n"]=0,["\r\n"]=0}local d={["a"]=0,["b"]=0,["c"]=0,["d"]=0,["e"]=0,["f"]=0,["A"]=0,["B"]=0,["C"]=0,["D"]=0,["E"]=0,["F"]=0}local e={}local f={}local g={}local h={}local i={}local j={}local k={["true"]=true,[" true"]=true,["true "]=true,["false"]=false,[" false"]=false,["false "]=false}local l={["k"]=10^3,["m"]=10^6,["b"]=10^9,["t"]=10^12,["q"]=10^15}local m=string.rep;local n=string.sub;local o=string.char;local p=string.gsub;local q=string.find;local r=math.ceil;local s=string.lower;local t=string.upper;local tostring=tostring;local u=string.gmatch;local v=math.random;local w=string.reverse;local x=table.concat;for y,z in pairs(string)do a[y]=z end;for A=0,7 do f[A]=0;f[tostring(A)]=0 end;for A=65,90 do j[o(A)]=0 end;for A=97,122 do i[o(A)]=0 end;for A=0,9 do local B=tostring(A)e[A]=0;e[B]=0;d[A]=0;d[B]=0 end;for A=26,132 do local C=o(A)h[A]=C;h[C]=A end;function a.isdigit(D)return q(D,'^%d+$')==1 end;function a.isascii(D)return q(D,"[\128-\255]")==nil end;function a.islower(D)return q(D,"^%l+$")==1 end;function a.isalpha(D)return q(D,'^%a+$')==1 end;function a.isupper(D)return q(D,"^%u+$")==1 end;function a.isalnum(D)return q(D,'^%w+$')==1 end;function a.isidentifier(D)if tonumber(n(D,1,1))~=nil then return false elseif q(D,"[^a-zA-Z0-9_]")then return false else return true end end;function a.lfind(D,E)local F,G=q(D,E,1,true)if F then return F-1 else return nil end end;function a.rfind(D,E)D=w(D)E=w(E)return#D-(#E-q(D,E,1,true))end;function a.iswhitespace(D)return q(D,"^%s+$")==1 end;function a.count(D,E)local H,I=q(D,E,1,true)if H==nil then return 0 else local J=0;while I~=nil do H,I=q(D,E,I+1,true)J=J+1 end;return J end end;function a.nil_or_empty(D)return D==nil or D==""end;function a.contains(D,E)return q(D,E,1,true)~=nil end;function a.endswith(D,E)return n(D,#D-#E+1)==E end;function a.startswith(D,E)return n(D,1,#E)==E end;function a.title(D)local K={}local L=1;local M=0;for N in u(D,"%S+")do M=M+1;N=s(N)if N=="the"and M==1 then K[L]="The "L=L+1 elseif N=="at"and M==1 then K[L]="At "L=L+1 else if N=="of"then K[L]="of "L=L+1 elseif N=="the"then K[L]="the "L=L+1 elseif N=="at"then K[L]="at "L=L+1 else K[L]=t(n(N,1,1))..n(N,2).." "L=L+1 end end end;return x(K)end;function a.sequence(D)local K={}for A=1,#D do K[A]=n(D,A,A)end;return K end;function a.commaify(D)local O;local P=tostring(D)while true do P,O=p(P,"^(-?%d+)(%d%d%d)",'%1,%2')if O==0 then break end end;return P end;function a.split_lines(D)local K={}local Q=0;for R in u(D,"[^\n\r\x80-\xFF]+")do Q=Q+1;K[Q]=R end;return K end;function a.tobool(D,S)local T=k[D]or k[s(D)]if T~=nil then return T elseif S==true then local U=tonumber(D)if U==0 then return false elseif U==1 then return true end end end;function a.strip(D,V)local G,I=q(D,"[^"..V.."+]")D=n(D,I or#D)local W=w(D)G,I=q(W,"[^"..V.."+]")if I==nil then return D else return n(D,1,#W-I+1)end end;function a.casefold(X,Y)return s(X)==s(Y)end;function a.lstrip(D,V)local G,I=q(D,"[^"..V.."+]")return n(D,I or#D)end;function a.rstrip(D,V)local W=w(D)local G,I=q(W,"[^"..V.."+]")if I==nil then return D else return n(D,1,#W-I+1)end end;function a.postfix(D,Z)local _=s(n(D,-1))local a0=n(D,1,#D-1)local a1=tonumber(a0)local K=l[_]if K==nil or a1==nil then return nil else if Z then return math.floor(K*a1)else return K*a1 end end end;function a.splitv(D,a2)local K={}local Q=0;for a3 in u(D,a2)do Q=Q+1;K[Q]=a3 end;return K end;function a.split(D,a4)local J={}local a5=0;for E in u(D,"([^"..a4 .."]+)")do a5=a5+1;J[a5]=E end;return J end;function a.partition(D,a4)local G,I=q(D,a4,1,true)if I==nil then return D else return n(D,1,I-1),n(D,I+1)end end;function a.rpartition(D,a4)local G,I=q(w(D),w(a4),1,true)if I==nil then return D else local a6=#D-I;return n(D,1,a6),n(D,a6+2)end end;function a.ljustify(D,a7,Q)return m(a7,Q-#D)..D end;function a.rjustify(D,a7,Q)return D..m(a7,Q-#D)end;function a.replace_first(D,a8,a9)local aa=1;local J,G=string.gsub(D,a8,function(B)if aa==1 then aa=0;return a9 else return B end end)if J then D=J end;return D end;function a.lrjustify(D,a7,Q)local ab=m(a7,r((Q-#D)/2))return ab..D..ab end;function a.subsequence(D,ac,ad)ac=ac or 1;ad=ad or#D;local K={}local Q=0;for A=ac,ad do local C=n(D,A,A)if C then Q=Q+1;K[Q]=C elseif C==""then break end end;return K end;function a.ltruncate(D,ae,af)if#D>ae then if af==true then return"..."..n(D,ae-#D)else return n(D,ae-#D)end else return D end end;function a.rtruncate(D,ae,af)if#D>ae then if af==true then return n(D,1,ae).."..."else return n(D,1,ae)end else return D end end;function a.translate(D,ag)local K,G=p(D,".",ag)return K end;function a.replace_many(D,a8,a9,ah)local aa=0;local J,G=p(D,a8,function(B)if aa<ah then aa=aa+1;return a9 else return B end end)if J then D=J end;return D end;function a.randomstring(ae,ai)local K={}if ai then for A=1,ae do local C=h[v(32,126)]while ai[C]~=nil do C=h[v(32,126)]end;K[A]=C end else for A=1,ae do K[A]=h[v(32,126)]end end;return x(K)end;function a.lines(D)return u(D,"[^\n\r\x80-\xFF]+")end;function a.iter_end(D)local H=#D+1;return function()H=H-1;local aj=n(D,H,H)if aj~=""then return aj end end end;function a.iter_begin(D)local H=0;return function()H=H+1;local aj=n(D,H,H)if aj~=""then return aj end end end;function a.map(D,ak,al)for A=1,#D,ak do al(n(D,A,A+ak-1))end end;function a.copy_table(am)local K={}for y,an in pairs(am)do K[y]=an end;return K end;a.ascii_punctuation=b;a.ascii_whitespace=c;a.ascii_lowercase=i;a.ascii_uppercase=j;a.ascii_printable=h;a.ascii_letters=g;a.hexdigits=d;a.octals=f;a.digits=e;return a