module BayesianDataFusion

using Distributed: Future, @spawnat, remotecall_wait, remotecall_fetch, myid
using Printf: @printf, @sprintf
using SharedArrays: SharedVector, SharedArray
using Statistics: mean

include("ROC.jl")
include("normal_wishart.jl")
include("RelationData.jl")
include("parallel_matrix.jl")
include("parallel_cg.jl")
include("sampling.jl")
include("macau.jl")

end # module
