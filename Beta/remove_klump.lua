d=0x80000000;m=mainmemory;r=m.read_u32_be;w=m.writebyte
function f()
	for i=0,255 do
		o=r(0x7FBFF0+i*4)
		if o>d and o<d+d/10 then
			o=o-d
			if r(o+88)==187 then
				w(o+99,0);w(o+340,55)
			end
		end
	end
end
event.onframestart(f)