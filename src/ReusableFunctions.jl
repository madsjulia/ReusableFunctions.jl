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

restarts = 0
quiet = true

import JLD
import DataStructures
import Compat
import Compat.String

"Reset restart counter"
function resetrestarts()
	global restarts = 0
end

"Make ReusableFunctions quiet"
function quieton()
	global quiet = true;
end

"Make ReusableFunctions not quiet"
function quietoff()
	global quiet = false;
end

"Define a filename based on hash"
function gethashfilename(dirname::String, x::Any)
	hashstring = string(hash(x))
	filename = joinpath(dirname, string(hashstring, ".jld"))
	return filename
end

"Check if a file with a filename based on hash exists"
function checkhashfilename(dirname::String, x::Any)
	filename = gethashfilename(dirname, x)
	isfile(filename)
end

"Load JLD result file"
function loadresultfile(filename::String; key::String="result")
	try
		result = JLD.load(filename, key)
		return result
	catch
		return nothing
	end
end

"Save JLD result file"
function saveresultfile(name::String, result::Any, x::Any; keyresult::String="result", keyx::String="x")
	if isdir(name)
		filename = gethashfilename(name, x)
	else
		filename = name
		if isfile(filename)
			rm(filename)
		end
	end
	JLD.save(filename, keyresult, result, keyx, x)
end

"Make a reusable function expecting both regular and keyword arguments"
function maker3function(f::Function, dirname::String; ignore_keywords::Array{Symbol, 1}=Array(Symbol, 0))
	ignore_keywords = checkfunctionignore_keywords(f, ignore_keywords)
	if !isdir(dirname)
		try
			mkdir(dirname)
		catch
			error("Directory $dirname cannot be created")
		end
	end
	function r3f(x...; kw...) # dropout expected unimportant keywords such as verbose, verbosity and quiet
		kwx = Dict()
		for k in ignore_keywords
			for i = 1:length(kw)
				if kw[i][1] == k
					kwx[k] = kw[i][2]
					delete!(kw, i)
				end
			end
		end
		filename = length(kw) > 0 ? gethashfilename(dirname, (x, kw)) : gethashfilename(dirname, x)
		result = loadresultfile(filename)
		!quiet && @show filename
		!quiet && @show x
		!quiet && @show result
		if result == nothing
			result = f(x...; kw..., kwx...)
			saveresultfile(filename, result, x)
		else
			global restarts += 1
		end
		return result
	end
end
function maker3function(f::Function)
	d = Dict()
	function r3f(x...; kw...)
		tp = length(kw) > 0 ? (x, kw) : x
		if !haskey(d, tp)
			d[tp] = f(x...; kw...)
		end
		return d[tp]
	end
end
function maker3function(f::Function, dirname::String, paramkeys::Vector, resultkeys::Vector)
	!quiet && @show paramkeys
	!quiet && @show resultkeys
	if !isdir(dirname)
		try
			mkdir(dirname)
		catch
			error("Directory $dirname cannot be created")
		end
	end
	function r3f(x::Associative)
		filename = gethashfilename(dirname, x)
		vecresult = loadresultfile(filename; key="vecresult")
		!quiet && @show filename
		!quiet && @show x
		!quiet && @show vecresult
		if vecresult != nothing
			if length(vecresult) != length(resultkeys)
				throw("The length of resultkeys does not match the length of the result stored in the file $(filename)")
			end
			result = DataStructures.OrderedDict()
			i = 1
			for k in resultkeys
				result[k] = vecresult[i]
				i += 1
			end
			global restarts += 1
			return result
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
			saveresultfile(filename, vecresult, vecx; keyresult="vecresult", keyx="vecx")
			return result
		end
	end
	return r3f
end

function checkfunctionkeywords(f::Function, keyword::Symbol)
	m = methods(f)
	mp = getfunctionkeywords(f)
	any(mp .== keyword)
end

function getfunctionkeywords(f::Function)
	m = methods(f)
	mp = Array(Symbol, 0)
	l = 0
	try
		l = length(m.ms)
	catch
		l = 0
	end
	for i in 1:length(m.ms)
		kwargs = []
		try
			kwargs = Base.kwarg_decl(m.ms[i].sig, typeof(m.mt.kwsorter))
		catch
			kwargs = []
		end
		for j in 1:length(kwargs)
			push!(mp, kwargs[j])
		end
	end
	return sort(unique(mp))
end

function checkfunctionignore_keywords(f::Function, ignore_keywords::Array{Symbol, 1}=Array(Symbol, 0))
	i = 1
	while i <= length(ignore_keywords)
		if !checkfunctionkeywords(f, ignore_keywords[i])
			warn("Keyword $(ignore_keywords[i]) not used")
			deleteat!(ignore_keywords, i)
		end
		i += 1
	end
	ignore_keywords_default = [:verbose, :verbosity, :quiet]
	i = 1
	while i <= length(ignore_keywords_default)
		if !checkfunctionkeywords(f, ignore_keywords_default[i])
			deleteat!(ignore_keywords_default, i)
		end
		i += 1
	end
	return vcat(ignore_keywords, ignore_keywords_default)
end

end