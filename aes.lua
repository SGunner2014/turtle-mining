local function e(a)local o=setmetatable({},{__index=getfenv()})return
	setfenv(a,o)()or o end
	bit=e(function()
	local a=math.floor;local o,i=bit.band,bit.bxor
	local function n(d,l)if d>2147483647 then d=d-4294967296 end;if l>
	2147483647 then l=l-4294967296 end;return o(d,l)end
	local function s(d,l)if d>2147483647 then d=d-4294967296 end;if l>2147483647 then
	l=l-4294967296 end;return i(d,l)end;local h,r
	r=function(d,l)return a(d%4294967296/2^l)end
	h=function(d,l)return(d*2^l)%4294967296 end;return{bnot=bit.bnot,band=n,bor=bit.bor,bxor=s,rshift=r,lshift=h}end)
	gf=e(function()local a=bit.bxor;local o=bit.lshift;local i=0x100;local n=0xff;local s=0x11b;local h={}local r={}local function d(p,v)
	return a(p,v)end;local function l(p,v)return a(p,v)end;local function u(p)if(p==1)then return 1 end
	local v=n-r[p]return h[v]end
	local function c(p,v)
	if(p==0 or v==0)then return 0 end;local b=r[p]+r[v]if(b>=n)then b=b-n end;return h[b]end
	local function m(p,v)if(p==0)then return 0 end;local b=r[p]-r[v]if(b<0)then b=b+n end;return h[b]end
	local function f()for p=1,i do print("log(",p-1,")=",r[p-1])end end
	local function w()for p=1,i do print("exp(",p-1,")=",h[p-1])end end;local function y()local p=1
	for v=0,n-1 do h[v]=p;r[p]=v;p=a(o(p,1),p)if p>n then p=l(p,s)end end end;y()return
	{add=d,sub=l,invert=u,mul=c,div=dib,printLog=f,printExp=w}end)
	util=e(function()local a=bit.bxor;local o=bit.rshift;local i=bit.band;local n=bit.lshift;local s
	local function h(x)
	x=a(x,o(x,4))x=a(x,o(x,2))x=a(x,o(x,1))return i(x,1)end;local function r(x,z)
	if(z==0)then return i(x,0xff)else return i(o(x,z*8),0xff)end end
	local function d(x,z)if(z==0)then return i(x,0xff)else return
	n(i(x,0xff),z*8)end end
	local function l(x,z,_)local E={}
	for T=0,_-1 do
	E[T]=
	d(x[z+ (T*4)],3)+d(x[z+ (T*4)+1],2)+d(x[z+ (T*4)+2],1)+
	d(x[z+ (T*4)+3],0)if _%10000 ==0 then s()end end;return E end;local function u(x,z,_,E)E=E or#x;for T=0,E do
	for A=0,3 do z[_+T*4+ (3-A)]=r(x[T],A)end;if E%10000 ==0 then s()end end
	return z end;local function c(x)local z=""
	for _,E in
	ipairs(x)do z=z..string.format("%02x ",E)end;return z end
	local function m(x)local z=type(x)
	if
	(z=="number")then return string.format("%08x",x)elseif(z=="table")then return c(x)elseif
	(z=="string")then local _={string.byte(x,1,#x)}return c(_)else return x end end
	local function f(x)local z=#x;local _=math.random(0,255)local E=math.random(0,255)
	local T=string.char(_,E,_,E,r(z,3),r(z,2),r(z,1),r(z,0))x=T..x;local A=math.ceil(#x/16)*16-#x;local O=""for I=1,A do O=O..
	string.char(math.random(0,255))end;return x..O end
	local function w(x)local z={string.byte(x,1,4)}if
	(z[1]==z[3]and z[2]==z[4])then return true end;return false end
	local function y(x)if(not w(x))then return nil end
	local z=
	d(string.byte(x,5),3)+
	d(string.byte(x,6),2)+d(string.byte(x,7),1)+d(string.byte(x,8),0)return string.sub(x,9,8+z)end;local function p(x,z)for _=1,16 do x[_]=a(x[_],z[_])end end
	local v,b,g=os.queueEvent,coroutine.yield,os.time;local k=g()local function s()local x=g()
	if x-k>=0.03 then k=x;v("sleep")b("sleep")end end
	local function q(x)
	local z,_,E,T=string.char,math.random,s,table.insert;local A={}
	for O=1,x do T(A,_(0,255))if O%10240 ==0 then E()end end;return A end
	local function j(x)local z,_,E,T=string.char,math.random,s,table.insert;local A={}for O=1,x do
	T(A,z(_(0,255)))if O%10240 ==0 then E()end end
	return table.concat(A)end
	return
	{byteParity=h,getByte=r,putByte=d,bytesToInts=l,intsToBytes=u,bytesToHex=c,toHexString=m,padByteString=f,properlyDecrypted=w,unpadByteString=y,xorIV=p,sleepCheckIn=s,getRandomData=q,getRandomString=j}end)
	aes=e(function()local a=util.putByte;local o=util.getByte;local i='rounds'local n="type"local s=1;local h=2
	local r={}local d={}local l={}local u={}local c={}local m={}local f={}local w={}local y={}local p={}
	local v={0x01000000,0x02000000,0x04000000,0x08000000,0x10000000,0x20000000,0x40000000,0x80000000,0x1b000000,0x36000000,0x6c000000,0xd8000000,0xab000000,0x4d000000,0x9a000000,0x2f000000}
	local function b(D)mask=0xf8;result=0
	for L=1,8 do result=bit.lshift(result,1)
	parity=util.byteParity(bit.band(D,mask))result=result+parity;lastbit=bit.band(mask,1)
	mask=bit.band(bit.rshift(mask,1),0xff)if(lastbit~=0)then mask=bit.bor(mask,0x80)else
	mask=bit.band(mask,0x7f)end end;return bit.bxor(result,0x63)end;local function g()
	for D=0,255 do if(D~=0)then inverse=gf.invert(D)else inverse=D end
	mapped=b(inverse)r[D]=mapped;d[mapped]=D end end
	local function k()
	for D=0,255 do
	byte=r[D]
	l[D]=
	a(gf.mul(0x03,byte),0)+a(byte,1)+a(byte,2)+a(gf.mul(0x02,byte),3)
	u[D]=
	a(byte,0)+a(byte,1)+a(gf.mul(0x02,byte),2)+a(gf.mul(0x03,byte),3)
	c[D]=a(byte,0)+a(gf.mul(0x02,byte),1)+
	a(gf.mul(0x03,byte),2)+a(byte,3)
	m[D]=
	a(gf.mul(0x02,byte),0)+a(gf.mul(0x03,byte),1)+a(byte,2)+a(byte,3)end end
	local function q()
	for D=0,255 do byte=d[D]
	f[D]=
	a(gf.mul(0x0b,byte),0)+a(gf.mul(0x0d,byte),1)+a(gf.mul(0x09,byte),2)+
	a(gf.mul(0x0e,byte),3)
	w[D]=
	a(gf.mul(0x0d,byte),0)+a(gf.mul(0x09,byte),1)+a(gf.mul(0x0e,byte),2)+
	a(gf.mul(0x0b,byte),3)
	y[D]=
	a(gf.mul(0x09,byte),0)+a(gf.mul(0x0e,byte),1)+a(gf.mul(0x0b,byte),2)+
	a(gf.mul(0x0d,byte),3)
	p[D]=
	a(gf.mul(0x0e,byte),0)+a(gf.mul(0x0b,byte),1)+a(gf.mul(0x0d,byte),2)+
	a(gf.mul(0x09,byte),3)end end;local function j(D)local L=bit.band(D,0xff000000)return
	(bit.lshift(D,8)+bit.rshift(L,24))end
	local function x(D)return
	a(r[o(D,0)],0)+a(r[o(D,1)],1)+a(r[o(D,2)],2)+
	a(r[o(D,3)],3)end
	local function z(D)local L={}local U=math.floor(#D/4)if(
	(U~=4 and U~=6 and U~=8)or(U*4 ~=#D))then
	print("Invalid key size: ",U)return nil end;L[i]=U+6;L[n]=s;for C=0,U-1 do
	L[C]=
	a(D[
	C*4+1],3)+a(D[C*4+2],2)+a(D[C*4+3],1)+a(D[C*4+4],0)end
	for C=U,(L[i]+1)*4-1 do
	local M=L[C-1]
	if(C%U==0)then M=j(M)M=x(M)local F=math.floor(C/U)
	M=bit.bxor(M,v[F])elseif(U>6 and C%U==4)then M=x(M)end;L[C]=bit.bxor(L[(C-U)],M)end;return L end
	local function _(D)local L=o(D,3)local U=o(D,2)local C=o(D,1)local M=o(D,0)
	return
	
	
	
	a(gf.add(gf.add(gf.add(gf.mul(0x0b,U),gf.mul(0x0d,C)),gf.mul(0x09,M)),gf.mul(0x0e,L)),3)+
	a(gf.add(gf.add(gf.add(gf.mul(0x0b,C),gf.mul(0x0d,M)),gf.mul(0x09,L)),gf.mul(0x0e,U)),2)+
	a(gf.add(gf.add(gf.add(gf.mul(0x0b,M),gf.mul(0x0d,L)),gf.mul(0x09,U)),gf.mul(0x0e,C)),1)+
	a(gf.add(gf.add(gf.add(gf.mul(0x0b,L),gf.mul(0x0d,U)),gf.mul(0x09,C)),gf.mul(0x0e,M)),0)end
	local function E(D)local L=o(D,3)local U=o(D,2)local C=o(D,1)local M=o(D,0)local F=bit.bxor(M,C)
	local W=bit.bxor(U,L)local Y=bit.bxor(F,W)Y=bit.bxor(Y,gf.mul(0x08,Y))
	w=bit.bxor(Y,gf.mul(0x04,bit.bxor(C,L)))
	Y=bit.bxor(Y,gf.mul(0x04,bit.bxor(M,U)))
	return
	
	
	
	a(bit.bxor(bit.bxor(M,Y),gf.mul(0x02,bit.bxor(L,M))),0)+a(bit.bxor(bit.bxor(C,w),gf.mul(0x02,F)),1)+
	a(bit.bxor(bit.bxor(U,Y),gf.mul(0x02,bit.bxor(L,M))),2)+a(bit.bxor(bit.bxor(L,w),gf.mul(0x02,W)),3)end
	local function T(D)local L=z(D)if(L==nil)then return nil end;L[n]=h;for U=4,(L[i]+1)*4-5 do
	L[U]=_(L[U])end;return L end
	local function A(D,L,U)for C=0,3 do D[C]=bit.bxor(D[C],L[U*4+C])end end
	local function O(D,L)
	L[0]=bit.bxor(bit.bxor(bit.bxor(l[o(D[0],3)],u[o(D[1],2)]),c[o(D[2],1)]),m[o(D[3],0)])
	L[1]=bit.bxor(bit.bxor(bit.bxor(l[o(D[1],3)],u[o(D[2],2)]),c[o(D[3],1)]),m[o(D[0],0)])
	L[2]=bit.bxor(bit.bxor(bit.bxor(l[o(D[2],3)],u[o(D[3],2)]),c[o(D[0],1)]),m[o(D[1],0)])
	L[3]=bit.bxor(bit.bxor(bit.bxor(l[o(D[3],3)],u[o(D[0],2)]),c[o(D[1],1)]),m[o(D[2],0)])end
	local function I(D,L)
	L[0]=a(r[o(D[0],3)],3)+a(r[o(D[1],2)],2)+
	a(r[o(D[2],1)],1)+a(r[o(D[3],0)],0)
	L[1]=a(r[o(D[1],3)],3)+a(r[o(D[2],2)],2)+
	a(r[o(D[3],1)],1)+a(r[o(D[0],0)],0)
	L[2]=a(r[o(D[2],3)],3)+a(r[o(D[3],2)],2)+
	a(r[o(D[0],1)],1)+a(r[o(D[1],0)],0)
	L[3]=a(r[o(D[3],3)],3)+a(r[o(D[0],2)],2)+
	a(r[o(D[1],1)],1)+a(r[o(D[2],0)],0)end
	local function N(D,L)
	L[0]=bit.bxor(bit.bxor(bit.bxor(f[o(D[0],3)],w[o(D[3],2)]),y[o(D[2],1)]),p[o(D[1],0)])
	L[1]=bit.bxor(bit.bxor(bit.bxor(f[o(D[1],3)],w[o(D[0],2)]),y[o(D[3],1)]),p[o(D[2],0)])
	L[2]=bit.bxor(bit.bxor(bit.bxor(f[o(D[2],3)],w[o(D[1],2)]),y[o(D[0],1)]),p[o(D[3],0)])
	L[3]=bit.bxor(bit.bxor(bit.bxor(f[o(D[3],3)],w[o(D[2],2)]),y[o(D[1],1)]),p[o(D[0],0)])end
	local function S(D,L)
	L[0]=a(d[o(D[0],3)],3)+a(d[o(D[3],2)],2)+
	a(d[o(D[2],1)],1)+a(d[o(D[1],0)],0)
	L[1]=a(d[o(D[1],3)],3)+a(d[o(D[0],2)],2)+
	a(d[o(D[3],1)],1)+a(d[o(D[2],0)],0)
	L[2]=a(d[o(D[2],3)],3)+a(d[o(D[1],2)],2)+
	a(d[o(D[0],1)],1)+a(d[o(D[3],0)],0)
	L[3]=a(d[o(D[3],3)],3)+a(d[o(D[2],2)],2)+
	a(d[o(D[1],1)],1)+a(d[o(D[0],0)],0)end
	local function H(D,L,U,C,M)U=U or 1;C=C or{}M=M or 1;local F={}local W={}if(D[n]~=s)then
	print("No encryption key: ",D[n])return end;F=util.bytesToInts(L,U,4)
	A(F,D,0)local Y=util.sleepCheckIn;local P=1;while(P<D[i]-1)do O(F,W)A(W,D,P)P=P+1;O(W,F)
	A(F,D,P)P=P+1 end;Y()O(F,W)A(W,D,P)P=P+1;I(W,F)
	A(F,D,P)return util.intsToBytes(F,C,M)end
	local function R(D,L,U,C,M)U=U or 1;C=C or{}M=M or 1;local F={}local W={}if(D[n]~=h)then
	print("No decryption key: ",D[n])return end;F=util.bytesToInts(L,U,4)
	A(F,D,D[i])local Y=util.sleepCheckIn;local P=D[i]-1;while(P>2)do N(F,W)A(W,D,P)P=P-1;N(W,F)
	A(F,D,P)P=P-1;if P%32 ==0 then Y()end end;Y()
	N(F,W)A(W,D,P)P=P-1;S(W,F)A(F,D,P)return util.intsToBytes(F,C,M)end;g()k()q()
	return{ROUNDS=i,KEY_TYPE=n,ENCRYPTION_KEY=s,DECRYPTION_KEY=h,expandEncryptionKey=z,expandDecryptionKey=T,encrypt=H,decrypt=R}end)
	buffer=e(function()local function a()return{}end;local function o(n,h)table.insert(n,h)
	for s=#n-1,1,-1 do if
	#n[s]>#n[s+1]then break end;n[s]=n[s]..table.remove(n)end end
	local function i(n)for s=#n-1,1,-1 do n[s]=n[s]..
	table.remove(n)end;return n[1]end;return{new=a,addString=o,toString=i}end)
	ciphermode=e(function()local a={}
	function a.encryptString(o,i,n)
	local s=iv or{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}local h=aes.expandEncryptionKey(o)local r=buffer.new()for d=1,#i/16 do local l=
	(d-1)*16+1;local u={string.byte(i,l,l+15)}
	n(h,u,s)
	buffer.addString(r,string.char(unpack(u)))end;return
	buffer.toString(r)end;function a.encryptECB(o,i,n)aes.encrypt(o,i,1,i,1)end
	function a.encryptCBC(o,i,n)
	util.xorIV(i,n)aes.encrypt(o,i,1,i,1)for s=1,16 do n[s]=i[s]end end
	function a.encryptOFB(o,i,n)aes.encrypt(o,n,1,n,1)util.xorIV(i,n)end;function a.encryptCFB(o,i,n)aes.encrypt(o,n,1,n,1)util.xorIV(i,n)
	for s=1,16 do n[s]=i[s]end end
	function a.decryptString(o,i,n)local s=iv or
	{0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0}local h
	if(n==a.decryptOFB or
	n==a.decryptCFB)then
	h=aes.expandEncryptionKey(o)else h=aes.expandDecryptionKey(o)end;local r=buffer.new()for d=1,#i/16 do local l=(d-1)*16+1
	local u={string.byte(i,l,l+15)}s=n(h,u,s)
	buffer.addString(r,string.char(unpack(u)))end;return
	buffer.toString(r)end;function a.decryptECB(o,i,n)aes.decrypt(o,i,1,i,1)return n end;function a.decryptCBC(o,i,n)
	local s={}for h=1,16 do s[h]=i[h]end;aes.decrypt(o,i,1,i,1)
	util.xorIV(i,n)return s end;function a.decryptOFB(o,i,n)
	aes.encrypt(o,n,1,n,1)util.xorIV(i,n)return n end;function a.decryptCFB(o,i,n)
	local s={}for h=1,16 do s[h]=i[h]end;aes.encrypt(o,n,1,n,1)
	util.xorIV(i,n)return s end;return a end)AES128=16;AES192=24;AES256=32;ECBMODE=1;CBCMODE=2;OFBMODE=3;CFBMODE=4
	local function t(a,o)local i=o;if
	(o==AES192)then i=32 end
	if(i>#a)then local s=""
	for h=1,i-#a do s=s..string.char(0)end;a=a..s else a=string.sub(a,1,i)end;local n={string.byte(a,1,#a)}
	a=ciphermode.encryptString(n,a,ciphermode.encryptCBC)a=string.sub(a,1,o)return{string.byte(a,1,#a)}end
	function encrypt(a,o,i,n)assert(a~=nil,"Empty password.")
	assert(a~=nil,"Empty data.")local n=n or CBCMODE;local i=i or AES128;local s=t(a,i)
	local h=util.padByteString(o)
	if(n==ECBMODE)then
	return ciphermode.encryptString(s,h,ciphermode.encryptECB)elseif(n==CBCMODE)then
	return ciphermode.encryptString(s,h,ciphermode.encryptCBC)elseif(n==OFBMODE)then
	return ciphermode.encryptString(s,h,ciphermode.encryptOFB)elseif(n==CFBMODE)then
	return ciphermode.encryptString(s,h,ciphermode.encryptCFB)else return nil end end
	function decrypt(a,o,i,n)local n=n or CBCMODE;local i=i or AES128;local s=t(a,i)local h
	if(n==ECBMODE)then
	h=ciphermode.decryptString(s,o,ciphermode.decryptECB)elseif(n==CBCMODE)then
	h=ciphermode.decryptString(s,o,ciphermode.decryptCBC)elseif(n==OFBMODE)then
	h=ciphermode.decryptString(s,o,ciphermode.decryptOFB)elseif(n==CFBMODE)then
	h=ciphermode.decryptString(s,o,ciphermode.decryptCFB)end;result=util.unpadByteString(h)
	if(result==nil)then return nil end;return result end;return{}