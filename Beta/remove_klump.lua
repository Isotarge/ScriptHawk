d=0x80000000;r=mainmemory.read_u32_be;w=mainmemory.writebyte
function f()
	for i=0,255 do
		o=r(0x7FBFF0+i*4)
		if o>d and o<d+d/10 then
			o=o-d
			if r(o+0x58)==187 then
				w(o+0x63,0);w(o+0x154,0x37)
			end
		end
	end
end
event.onframestart(f)