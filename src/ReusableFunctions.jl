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

"Define a filename based on hash"
function gethashfilename(dirname::AbstractString, x::Any)
	hashstring = string(hash(x))
	filename = string(dirname, "/", hashstring, ".jld")
	return filename
end

"Make reusable function"
function maker3function(f::Function, dirname::AbstractString)
	if !isdir(dirname)
		try
			mkdir(dirname)
		catch
			error("Directory $dirname cannot be created")
		end
	end
	function r3f(x)
		filename = gethashfilename(dirname, x)
		try#try loading the result
			result = JLD.load(filename, "result")
			return result
		catch#if that fails, call the funciton
			result = f(x)
			if isfile(filename)
				rm(filename)
			end
			JLD.save(filename, "result", result, "x", x)
			return result
		end
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

function maker3function(f::Function, dirname::AbstractString, paramkeys::Vector, resultkeys::Vector)
	if !isdir(dirname)
		try
			mkdir(dirname)
		catch
			error("Directory $dirname cannot be created")
		end
	end
	function r3f(x::Associative)
		filename = gethashfilename(dirname, x)
		try
			vecresult = JLD.load(filename, "vecresult")
			if length(vecresult) != length(resultkeys)
				throw("The length of resultkeys does not match the length of the result stored in the file $(filename)")
			end
			result = Dict()
			i = 1
			for k in resultkeys
				result[k] = vecresult[i]
				i += 1
			end
			return result
		catch
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
			if isfile(filename)
				rm(filename)
			end
			JLD.save(filename, "vecresult", vecresult, "vecx", vecx)
			return result
		end
	end
	return r3f
end

end
