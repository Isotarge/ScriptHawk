d=0x800000;m=mainmemory;r=m.read_u24_be;w=m.writebyte
function f()
	for i=0,255 do
		o=r(0x7FBFF1+i*4)
		if o>0 and o<d and r(o+89)==187 then
			w(o+99,0);w(o+340,55)
		end
	end
end
event.onframestart(f)