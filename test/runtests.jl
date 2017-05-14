import Base.Test
import ReusableFunctions

ReusableFunctions.resetrestarts()

if !isdefined(Symbol("@stderrcapture"))
	macro stderrcapture(block)
		quote
			if ccall(:jl_generating_output, Cint, ()) == 0
				errororiginal = STDERR;
				(errR, errW) = redirect_stderr();
				errorreader = @async readstring(errR);
				evalvalue = $(esc(block))
				redirect_stderr(errororiginal);
				close(errW);
				close(errR);
				return evalvalue
			end
		end
	end
end

@stderrcapture function freuse(x)
	sleep(0.1)
	return x
end

@stderrcapture function greuse(x)
	sleep(0.1)
	return Dict("asdf"=>x["a"] - x["b"], "hjkl"=>x["a"] * x["b"])
end

restartdir = "ReusableFunctions_restart"

if isdir(restartdir)
	rm(restartdir, recursive=true)
end

@Base.Test.testset "Reusable" begin

	for fp in [ReusableFunctions.maker3function(freuse, restartdir), ReusableFunctions.maker3function(freuse)]
		for i = 1:2
			@Base.Test.test fp(1) == 1
		end
		#check to make sure it works if the jld file is corrupted
	    ReusableFunctions.checkhashfilename(restartdir, 1)
		hashfilename = ReusableFunctions.gethashfilename(restartdir, 1)
		run(`bash -c "echo blah >$hashfilename"`)
		for i = 1:2
			@Base.Test.test fp(1) == 1
		end

		t = @elapsed for i = 1:10
			@Base.Test.test fp(i) == i
		end
		@Base.Test.test t > 0.5
		@Base.Test.test t < 2.

		t = @elapsed for i = 1:10
			@Base.Test.test fp(i) == i
		end
		@Base.Test.test t < 0.1

		d = Dict(zip([1, 2], [3, 4]))
		for i = 1:2
			@Base.Test.test fp(d) == d
		end

		t = @elapsed for i = 1:10
			d = Dict(zip([1, 2], [i, i + 1]))
			@Base.Test.test fp(d) == d
		end
		@Base.Test.test t > 0.5
		@Base.Test.test t < 2.

		t = @elapsed for i = 1:10
			d = Dict(zip([1, 2], [i, i + 1]))
			@Base.Test.test fp(d) == d
		end
		@Base.Test.test t < 0.1

		v = zeros(10)
		for i = 1:2
			@Base.Test.test fp(v) == v
		end

		t = @elapsed for i = 1:10
			v = i * ones(10)
			@Base.Test.test fp(v) == v
		end
		@Base.Test.test t > 0.5
		@Base.Test.test t < 2.

		t = @elapsed for i = 1:10
			v = i * ones(10)
			@Base.Test.test fp(v) == v
		end
		@Base.Test.test t < 0.1
	end

	if isdir(restartdir)
		rm(restartdir, recursive=true)
	end

	r3g = ReusableFunctions.maker3function(greuse, restartdir, ["a", "b"], ["asdf", "hjkl"])
	d = Dict("a"=>1, "b"=>3)
	r = Dict("asdf"=>-2, "hjkl"=>3)
	for i = 1:2
		@Base.Test.test r3g(d) == r
	end

	#test to make sure it works if the JLD file is corrupted
	hashfilename = ReusableFunctions.gethashfilename(restartdir, d)
	run(`bash -c "echo blah >$hashfilename"`)
	for i = 1:2
		@Base.Test.test r3g(d) == r
	end

	t = @elapsed for i = 1:10
		d = Dict(zip(["a", "b"], [i, i + 2]))
		r = Dict("asdf"=>-2, "hjkl"=>i * (i + 2))
		@Base.Test.test r3g(d) == r
	end
	@Base.Test.test t > 0.5
	@Base.Test.test t < 2.

	t = @elapsed for i = 1:10
		d = Dict(zip(["a", "b"], [i, i + 2]))
		r = Dict("asdf"=>-2, "hjkl"=>i * (i + 2))
		@Base.Test.test r3g(d) == r
	end
	@Base.Test.test t < 0.1

	if isdir(restartdir)
		rm(restartdir, recursive=true)
	end
end

:passed
