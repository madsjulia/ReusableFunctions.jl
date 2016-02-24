__precompile__()

"""
MADS: Model Analysis & Decision Support in Julia (Mads.jl v1.0) 2016

http://mads.lanl.gov
http://madsjulia.lanl.gov
http://gitlab.com/mads/Mads.jl

Licensing: GPLv3: http://www.gnu.org/licenses/gpl-3.0.html

Copyright 2016.  Los Alamos National Security, LLC.  All rights reserved.

This material was produced under U.S. Government contract DE-AC52-06NA25396 for
Los Alamos National Laboratory, which is operated by Los Alamos National Security, LLC for
the U.S. Department of Energy. The Government is granted for itself and others acting on its
behalf a paid-up, nonexclusive, irrevocable worldwide license in this material to reproduce,
prepare derivative works, and perform publicly and display publicly. Beginning five (5) years after
--------------- November 17, 2015, ----------------------------------------------------------------
subject to additional five-year worldwide renewals, the Government is granted for itself and
others acting on its behalf a paid-up, nonexclusive, irrevocable worldwide license in this
material to reproduce, prepare derivative works, distribute copies to the public, perform
publicly and display publicly, and to permit others to do so.

NEITHER THE UNITED STATES NOR THE UNITED STATES DEPARTMENT OF ENERGY, NOR LOS ALAMOS NATIONAL SECURITY, LLC,
NOR ANY OF THEIR EMPLOYEES, MAKES ANY WARRANTY, EXPRESS OR IMPLIED, OR ASSUMES ANY LEGAL LIABILITY OR
RESPONSIBILITY FOR THE ACCURACY, COMPLETENESS, OR USEFULNESS OF ANY INFORMATION, APPARATUS, PRODUCT, OR
PROCESS DISCLOSED, OR REPRESENTS THAT ITS USE WOULD NOT INFRINGE PRIVATELY OWNED RIGHTS.

LA-CC-15-080; Copyright Number Assigned: C16008
"""
module ReusableFunctions

import JLD

function gethashfilename(dirname, x)
	hashstring = string(hash(x))
	filename = string(dirname, "/", hashstring, ".jld")
	return filename
end

"Make reusable function"
function maker3function(f::Function, dirname::ASCIIString)
	if !isdir(dirname)
		mkdir(dirname)
	end
	function r3f(x)
		filename = gethashfilename(dirname, x)
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

function maker3function(f::Function, dirname::ASCIIString, paramkeys, resultkeys)
	if !isdir(dirname)
		mkdir(dirname)
	end
	function r3f(x::Associative)
		filename = gethashfilename(dirname, x)
		if isfile(filename)
			vecresult = JLD.load(filename, "vecresult")
			if length(vecresult) != length(resultkeys)
				error("The length of resultkeys does not match the length of the result stored in the file $filename")
			end
			result = Dict()
			i = 1
			for k in resultkeys
				result[k] = vecresult[i]
				i += 1
			end
		else
			result = f(x)
			vecresult = Array(Float64, length(resultkeys))
			i = 1
			for k in resultkeys
				vecresult[i] = result[k]
				i += 1
			end
			vecx = Array(Float64, length(paramkeys))
			i = 1
			for k in paramkeys
				vecx[i] = x[k]
				i += 1
			end
			JLD.save(filename, "vecresult", vecresult, "vecx", vecx)
		end
		return result
	end
	return r3f
end

end
