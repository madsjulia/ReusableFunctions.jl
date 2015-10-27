module R3Function

import JLD

function maker3function(f::Function, dirname::ASCIIString)
	if !isdir(dirname)
		mkdir(dirname)
	end
	function r3f(x)
		hashstring = string(hash(x))
		filename = string(dirname, "/", hashstring, ".jld")
		if isfile(filename)
			#we've already computed the result for this x, so load it
			result = JLD.load(filename, "result")
		else
			#we need to compute it for the first time, and save the results
			result = f(x)
			JLD.save(filename, "result", result, "x", x)
		end
		return result
	end
end

function maker3function(f::Function)
	d = Dict()
	function r3f(x)
		if !haskey(d, x)
			d[x] = f(x)
		end
		return d[x]
	end
end

end
