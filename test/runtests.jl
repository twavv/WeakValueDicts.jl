using WeakValueDicts
using Test

mutable struct V
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
    end

    @testset "Finalization" begin
        wvd = WeakValueDict{Int, V}()
        for i in 1:1000
            wvd[i] = V(i)
        end
        Base.GC.gc(true)
        @test length(wvd) < 1000
    end
end
