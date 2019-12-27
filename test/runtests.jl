using WeakValueDicts
using Test

mutable struct V
    v
end

struct ImmutableStruct
    v
end

@testset "WeakValueDict.jl" begin
    @testset "Basic Dict operations" begin
        foo = V("foo")
        bar = V("bar")
        wvd = WeakValueDict(
            "foo" => foo,
            "bar" => bar,
        )
        @test typeof(wvd) === WeakValueDict{String, V}
        @test length(wvd) == 2
        @test !isempty(wvd)

        @test copy(wvd) !== wvd
        @test copy(wvd) == wvd

        @test wvd["foo"] === foo
        @test get(wvd, "foo", nothing) === foo
        @test get!(wvd, "foo", V(nothing)) === foo

        @test pop!(wvd, "foo") === foo
        @test !haskey(wvd, "foo")
        @test_throws KeyError pop!(wvd, "foo")
        @test_throws KeyError wvd["foo"]
        @test delete!(wvd, "foo") === wvd

        @test get!(wvd, "foo", foo) === foo
        @test wvd["foo"] === foo
        @test delete!(wvd, "foo") === wvd
        @test !haskey(wvd, "foo")

        @test delete!(wvd, "bar") == empty(wvd)
        @test isempty(wvd)

        wvd["bar"] = V("bar")
        @test empty!(wvd) == empty(wvd)
        @test isempty(wvd)
    end

    @testset "Finalization" begin
        wvd = WeakValueDict{Int, V}()
        for i in 1:1000
            wvd[i] = V(i)
        end
        Base.GC.gc(true)
        @test length(wvd) < 1000
    end

    @testset "Constructors" begin
        wvd = WeakValueDict{String, String}()
        @test typeof(wvd) === WeakValueDict{String, String}

        wvd = WeakValueDict()
        @test typeof(wvd) === WeakValueDict{Any, Any}

        wvd = WeakValueDict(Tuple{}())
        @test typeof(wvd) === WeakValueDict{Any, Any}

        ps = Pair{String, V}["foo" => V(1), "bar" => V(2)]
        wvd = WeakValueDict(ps...)
        @test typeof(wvd) === WeakValueDict{String, V}

        ps = Pair{String}["foo" => "foo", "bar" => V(123)]
        wvd = WeakValueDict(ps...)
        @test typeof(wvd) === WeakValueDict{String, Any}

        wvd = WeakValueDict("foo" => "bar", 123 => "eggs")
        @test typeof(wvd) === WeakValueDict{Any, String}

        wvd = WeakValueDict("foo" => "bar", V(1) => V(2))
        @test typeof(wvd) === WeakValueDict{Any, Any}

        wvd = WeakValueDict(Dict("foo" => "bar", "spam" => "eggs"))
        @test typeof(wvd) === WeakValueDict{String, String}

        wvd = WeakValueDict{String, String}(Dict("foo" => "bar"))
        @test typeof(wvd) === WeakValueDict{String, String}

        wvd = WeakValueDict{String, String}("foo" => "bar")
        @test typeof(wvd) === WeakValueDict{String, String}

        wvd = WeakValueDict{String, String}("foo" => "bar", "spam" => "eggs")
        @test typeof(wvd) === WeakValueDict{String, String}

        wvd = WeakValueDict(Dict("foo" => "bar"))
        @test typeof(wvd) === WeakValueDict{String, String}
    end

    @testset "map! and filter!" begin
        foo = V("foo")
        bar = V("bar")
        wvd = WeakValueDict(
            "foo" => foo,
            "bar" => bar,
        )

        map!(values(wvd)) do value
            return V(uppercase(value.v))
        end
        @test wvd["foo"].v == "FOO"
        @test wvd["bar"].v == "BAR"

        filter!(wvd) do p
            return p.first == "foo"
        end
        @test wvd["foo"].v == "FOO"
        @test !haskey(wvd, "bar")
        @test length(wvd) == 1
    end

    @testset "iterate" begin
        foo = V("foo")
        bar = V("bar")
        wvd = WeakValueDict(
            "foo" => foo,
            "bar" => bar,
        )

        for (k, v) in wvd
            @test v.v == k
        end
    end
end
