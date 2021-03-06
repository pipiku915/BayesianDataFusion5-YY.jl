using DataFrames
using SparseArrays

export IndexedDF, getData, getCount, removeSamples, getValues, valueMean
export FastIDF

mutable struct IndexedDF
  df::DataFrame
  index::Vector{Vector{Vector{Int64}}}

  function IndexedDF(df::DataFrame, dims::Vector{Int64})
    ## indexing all columns D - 1 columns (integers)
    index = [ [Int64[] for j in 1:i] for i in dims ]
    for i in 1:size(df, 1)
      for mode in 1:length(dims)
        j = df[i, mode]
        push!(index[mode][j], i)
      end
    end
    new(df, index)
  end
end

IndexedDF(df::DataFrame, dims::Tuple) = IndexedDF(df, Int64[i for i in dims])
IndexedDF(df::DataFrame) = IndexedDF(df, Int64[maximum(df[:,i]) for i in 1 : size(df,2)-1])

valueMean(idf::IndexedDF) = mean(idf.df[:,end])
import Base.size
size(idf::IndexedDF) = tuple( [length(i) for i in idf.index]... )
size(idf::IndexedDF, i::Integer) = length(idf.index[i])

nnz(idf::IndexedDF) = size(idf.df, 1)

function removeSamples(idf::IndexedDF, samples)
  df = idf.df[ setdiff(1:size(idf.df, 1), samples), :]
  return IndexedDF(df, size(idf))
end

getValues(idf::IndexedDF) = convert(Array, idf.df[:, end])
getMode(idf::IndexedDF, mode::Integer) = idf.df[:, mode]
getData(idf::IndexedDF, mode::Integer, i::Integer)  = idf.df[ idf.index[mode][i], :]
getCount(idf::IndexedDF, mode::Integer, i::Integer) = length( idf.index[mode][i] )
getI(idf::IndexedDF, mode::Integer, i::Integer)     = idf.index[mode][i]

## FastIDF used in sampling of latent variables
mutable struct FastIDF{Ti,Tv}
  ids::Matrix{Ti}
  values::Vector{Tv}
  index::Vector{Vector{Vector{Int64}}}
end

FastIDF(idf::IndexedDF) = FastIDF(Matrix(idf.df[:,1:end-1]), convert(Array, idf.df[:,end]), idf.index)
function FastIDF(df::DataFrame, dims::Vector{Int64})
  ## indexing all columns D - 1 columns (integers)
  index = [ [Int64[] for j in 1:i] for i in dims ]
  for i in 1:size(df, 1)
    for mode in 1:length(dims)
      j = df[i, mode]
      push!(index[mode][j], i)
    end
  end
  ix = convert(Matrix, df[:, 1:end-1])
  v  = convert(Array, df[:, end])
  return FastIDF(ix, v, index)
end

function getData(f::FastIDF, mode::Integer, i::Integer)
  id = f.index[mode][i]
  return f.ids[id,:], f.values[id]
end

import Base.size
size(f::FastIDF) = tuple( [length(i) for i in f.index]... )
size(f::FastIDF, i::Integer) = length(f.index[i])
nnz(f::FastIDF) = size(f.values, 1)
