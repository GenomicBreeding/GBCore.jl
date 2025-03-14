"""
    clone(x::Phenomes)::Phenomes

Create a deep copy of a `Phenomes` object, including all its fields.

This function performs a deep copy of the following fields:
- entries: Vector of entry names
- populations: Vector of population identifiers
- traits: Vector of trait names
- phenotypes: Matrix of phenotypic values
- mask: Matrix of boolean masks

Returns a new `Phenomes` object with identical structure but independent memory allocation.

# Arguments
- `x::Phenomes`: The source Phenomes object to be cloned

# Returns
- `Phenomes`: A new Phenomes object containing deep copies of all fields

# Example
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=2, t=2);

julia> copy_phenomes = clone(phenomes)
Phenomes(["", ""], ["", ""], ["", ""], Union{Missing, Float64}[missing missing; missing missing], Bool[1 1; 1 1])
```
"""
function clone(x::Phenomes)::Phenomes
    out = Phenomes(n = length(x.entries), t = length(x.traits))
    for field in fieldnames(typeof(x))
        # field = fieldnames(typeof(x))[1]
        setfield!(out, field, deepcopy(getfield(x, field)))
    end
    out
end

"""
    Base.hash(x::Phenomes, h::UInt)::UInt

Compute a hash value for a `Phenomes` struct by recursively hashing its internal fields.

# Arguments
- `x::Phenomes`: The Phenomes struct to be hashed
- `h::UInt`: The hash value to be mixed with

# Returns
- `UInt`: A hash value for the entire Phenomes struct

# Note
This function is used for dictionary operations and computing hash-based data structures.
The hash is computed by combining hashes of all internal fields: entries, populations,
traits, phenotypes, and mask.

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=2, t=2);

julia> typeof(hash(phenomes))
UInt64
```
"""
function Base.hash(x::Phenomes, h::UInt)::UInt
    for field in fieldnames(typeof(x))
        # field = fieldnames(typeof(x))[1]
        h = hash(getfield(x, field), h)
    end
    h
end


"""
    ==(x::Phenomes, y::Phenomes)::Bool

Compare two `Phenomes` structs for equality using their hash values.

This method implements equality comparison for `Phenomes` objects by comparing their hash values,
ensuring that two phenomes with identical structure and content are considered equal.

# Arguments
- `x::Phenomes`: First phenomes object to compare
- `y::Phenomes`: Second phenomes object to compare

# Returns
- `Bool`: `true` if the phenomes are equal, `false` otherwise

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes_1 = phenomes = Phenomes(n=2, t=4);

julia> phenomes_2 = phenomes = Phenomes(n=2, t=4);

julia> phenomes_3 = phenomes = Phenomes(n=1, t=2);

julia> phenomes_1 == phenomes_2
true

julia> phenomes_1 == phenomes_3
false
```
"""
function Base.:(==)(x::Phenomes, y::Phenomes)::Bool
    hash(x) == hash(y)
end


"""
    checkdims(y::Phenomes)::Bool

Verify dimensional compatibility between all fields of a Phenomes struct.

Checks if:
- Number of entries matches the number of rows in phenotypes matrix
- All entry names are unique
- Number of populations matches number of entries
- Number of traits matches number of columns in phenotypes matrix
- All trait names are unique
- Dimensions of mask matrix match phenotypes matrix

# Arguments
- `y::Phenomes`: A Phenomes struct containing phenotypic data

# Returns
- `Bool`: `true` if all dimensions are compatible, `false` otherwise

# Examples
```jldoctest; setup = :(using GBCore)
julia> y = Phenomes(n=2, t=2);

julia> checkdims(y)
false

julia> y.entries = ["entry_1", "entry_2"];

julia> y.traits = ["trait_1", "trait_2"];

julia> checkdims(y)
true
```
"""
function checkdims(y::Phenomes)::Bool
    n, p = size(y.phenotypes)
    if (n != length(y.entries)) ||
       (n != length(unique(y.entries))) ||
       (n != length(y.populations)) ||
       (p != length(y.traits)) ||
       (p != length(unique(y.traits))) ||
       ((n, p) != size(y.mask))
        return false
    end
    true
end

"""
    dimensions(phenomes::Phenomes)::Dict{String, Int64}

Calculate various dimensional statistics of a `Phenomes` struct.

Returns a dictionary containing counts of:
- `"n_entries"`: unique entries in the dataset
- `"n_populations"`: unique populations
- `"n_traits"`: number of traits
- `"n_total"`: total number of phenotypic observations (entries × traits)
- `"n_zeroes"`: number of zero values in phenotypes
- `"n_missing"`: number of missing values
- `"n_nan"`: number of NaN values
- `"n_inf"`: number of infinite values

# Arguments
- `phenomes::Phenomes`: A Phenomes struct containing phenotypic data

# Returns
- `Dict{String,Int64}`: Dictionary with dimensional statistics

# Throws
- `ArgumentError`: If the Phenomes struct dimensions are inconsistent

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = fill(0.0, 10,3);

julia> dimensions(phenomes)
Dict{String, Int64} with 8 entries:
  "n_total"       => 30
  "n_zeroes"      => 30
  "n_nan"         => 0
  "n_entries"     => 10
  "n_traits"      => 3
  "n_inf"         => 0
  "n_populations" => 1
  "n_missing"     => 0
```
"""
function dimensions(phenomes::Phenomes)::Dict{String,Int64}
    if !checkdims(phenomes)
        throw(ArgumentError("Phenomes struct is corrupted."))
    end
    idx_non_missing = .!ismissing.(phenomes.phenotypes)
    Dict(
        "n_entries" => length(unique(phenomes.entries)),
        "n_populations" => length(unique(phenomes.populations)),
        "n_traits" => length(phenomes.traits),
        "n_total" => prod(size(phenomes.phenotypes)),
        "n_zeroes" => sum(phenomes.phenotypes[idx_non_missing] .== 0.0),
        "n_missing" => sum(.!idx_non_missing),
        "n_nan" => sum(isnan.(phenomes.phenotypes[idx_non_missing])),
        "n_inf" => sum(isinf.(phenomes.phenotypes[idx_non_missing])),
    )
end

"""
    distances(
        phenomes::Phenomes; 
        distance_metrics::Vector{String}=["euclidean", "correlation", "mad", "rmsd", "χ²"],
        standardise_traits::Bool = false
    )::Tuple{Vector{String}, Vector{String}, Dict{String, Matrix{Float64}}}

Calculate pairwise distances/correlations between traits and entries in a phenotypic dataset.

# Arguments
- `phenomes::Phenomes`: A Phenomes struct containing phenotypic data
- `distance_metrics::Vector{String}`: Vector of distance metrics to compute. Valid options are:
  * "euclidean": Euclidean distance
  * "correlation": Pearson correlation coefficient
  * "mad": Mean absolute deviation
  * "rmsd": Root mean square deviation
  * "χ²": Chi-square distance
- `standardise_traits::Bool`: If true, standardizes traits to mean=0 and sd=1 before computing distances

# Returns
A tuple containing:
1. Vector of trait names
2. Vector of entry names
3. Dictionary mapping "{dimension}|{metric}" to distance matrices, where:
   * dimension ∈ ["traits", "entries"]
   * metric ∈ distance_metrics ∪ ["counts"]
   * "counts" matrices contain the number of non-missing pairs used in calculations

# Notes
- Pairs with fewer than 2 non-missing values result in -Inf distance values
- For correlation calculations, traits with near-zero variance (< 1e-7) are skipped
- χ² distance adds machine epsilon to denominator to avoid division by zero

# Examples
```jldoctest; setup = :(using GBCore, LinearAlgebra)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3); phenomes.phenotypes[2,2] = missing;

julia> (traits, entries, dist) = distances(phenomes, distance_metrics=["correlation", "χ²"]);

julia> sort(string.(keys(dist))) == ["entries|correlation", "entries|counts", "entries|χ²", "traits|correlation", "traits|counts", "traits|χ²"]
true

julia> C = dist["entries|correlation"]; C[diagind(C)] == repeat([1], length(phenomes.entries))
true

julia> dist["traits|counts"][:, 2] == dist["traits|counts"][2, :] == repeat([9], length(phenomes.traits))
true

julia> dist["entries|counts"][:, 2] == dist["entries|counts"][2, :] == repeat([2], length(phenomes.entries))
true
```
"""
function distances(
    phenomes::Phenomes;
    distance_metrics::Vector{String} = ["euclidean", "correlation", "mad", "rmsd", "χ²"],
    standardise_traits::Bool = false,
)::Tuple{Vector{String},Vector{String},Dict{String,Matrix{Float64}}}
    # phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);
    # distance_metrics = ["euclidean", "correlation", "mad", "rmsd", "χ²"]; standardise_traits = true
    if !checkdims(phenomes)
        throw(ArgumentError("The phenomes struct is corrupted."))
    end
    recognised_distance_metrics = ["euclidean", "correlation", "mad", "rmsd", "χ²"]
    unique!(distance_metrics)
    m = length(distance_metrics)
    if m < 1
        throw(
            ArgumentError(
                "Please supply at least 1 distance metric. Choose from:\n\t‣ " *
                join(recognised_distance_metrics, "\n\t‣ "),
            ),
        )
    end
    idx_unrecognised_distance_metrics = findall([sum(recognised_distance_metrics .== m) == 0 for m in distance_metrics])
    if length(idx_unrecognised_distance_metrics) > 0
        throw(
            ArgumentError(
                "Unrecognised metric/s:\n\t‣ " *
                join(distance_metrics[idx_unrecognised_distance_metrics], "\n\t‣ ") *
                "\nPlease choose from:\n\t‣ " *
                join(recognised_distance_metrics, "\n\t‣ "),
            ),
        )
    end
    # Standardise traits if requested
    Φ = if standardise_traits
        Φ = deepcopy(phenomes)
        for j = 1:size(Φ.phenotypes, 2)
            y = Φ.phenotypes[:, j]
            idx = findall(.!ismissing.(y) .&& .!isnan.(y) .&& .!isinf.(y))
            y = y[idx]
            Φ.phenotypes[idx, j] = (y .- mean(y)) ./ std(y)
        end
        Φ
    else
        deepcopy(phenomes)
    end
    # Instantiate vectors of matrices and metric names
    dimension::Vector{String} = [] # across traits and/or entries
    metric_names::Vector{String} = []
    matrices::Vector{Matrix{Float64}} = []
    # Number of traits and entries
    n = length(Φ.entries)
    t = length(Φ.traits)
    # Per trait first
    if t > 1
        y1::Vector{Union{Missing,Float64}} = fill(missing, n)
        y2::Vector{Union{Missing,Float64}} = fill(missing, n)
        counts = fill(0.0, t, t)
        for metric in distance_metrics
            # metric = distance_metrics[1]
            D::Matrix{Float64} = fill(-Inf, t, t)
            for i = 1:t
                # i = 1
                y1 .= Φ.phenotypes[:, i]
                bool1 = .!ismissing.(y1) .&& .!isnan.(y1) .&& .!isinf.(y1)
                for j = 1:t
                    # j = 3
                    # Make sure we have no missing, NaN or infinite values
                    y2 .= Φ.phenotypes[:, j]
                    bool2 = .!ismissing.(y2) .&& .!isnan.(y2) .&& .!isinf.(y2)
                    idx = findall(bool1 .&& bool2)
                    if length(idx) < 2
                        continue
                    end
                    # Count the number of elements used to estimate the distance
                    if metric == distance_metrics[1]
                        counts[i, j] = length(idx)
                    end
                    # Estimate the distance/correlation
                    if metric == "euclidean"
                        D[i, j] = sqrt(sum((y1[idx] - y2[idx]) .^ 2))
                    elseif metric == "correlation"
                        (var(y1[idx]) < 1e-7) || (var(y2[idx]) < 1e-7) ? continue : nothing
                        D[i, j] = cor(y1[idx], y2[idx])
                    elseif metric == "mad"
                        D[i, j] = mean(abs.(y1[idx] - y2[idx]))
                    elseif metric == "rmsd"
                        D[i, j] = sqrt(mean((y1[idx] - y2[idx]) .^ 2))
                    elseif metric == "χ²"
                        D[i, j] = sum((y1[idx] - y2[idx]) .^ 2 ./ (y2[idx] .+ eps(Float64)))
                    else
                        throw(
                            ErrorException(
                                "This should not happen as we checked for the validity of the distance_metrics above.",
                            ),
                        )
                    end
                end
            end
            push!(dimension, "traits")
            push!(metric_names, metric)
            push!(matrices, D)
        end
        push!(dimension, "traits")
        push!(metric_names, "counts")
        push!(matrices, counts)
    end
    # Finally per entry
    if n > 1
        ϕ1::Vector{Union{Missing,Float64}} = fill(missing, t)
        ϕ2::Vector{Union{Missing,Float64}} = fill(missing, t)
        counts = fill(0.0, n, n)
        for metric in distance_metrics
            # metric = distance_metrics[1]
            D::Matrix{Float64} = fill(-Inf, n, n)
            for i = 1:n
                # i = 1
                ϕ1 .= Φ.phenotypes[i, :]
                bool1 = .!ismissing.(ϕ1) .&& .!isnan.(ϕ1) .&& .!isinf.(ϕ1)
                for j = 1:n
                    # j = 4
                    # Make sure we have no missing, NaN or infinite values
                    ϕ2 .= Φ.phenotypes[j, :]
                    bool2 = .!ismissing.(ϕ2) .&& .!isnan.(ϕ2) .&& .!isinf.(ϕ2)
                    idx = findall(bool1 .&& bool2)
                    if length(idx) < 2
                        continue
                    end
                    # Count the number of elements used to estimate the distance
                    if metric == distance_metrics[1]
                        counts[i, j] = length(idx)
                    end
                    # Estimate the distance/correlation
                    if metric == "euclidean"
                        D[i, j] = sqrt(sum((ϕ1[idx] - ϕ2[idx]) .^ 2))
                    elseif metric == "correlation"
                        (var(ϕ1[idx]) < 1e-7) || (var(ϕ2[idx]) < 1e-7) ? continue : nothing
                        D[i, j] = cor(ϕ1[idx], ϕ2[idx])
                    elseif metric == "mad"
                        D[i, j] = mean(abs.(ϕ1[idx] - ϕ2[idx]))
                    elseif metric == "rmsd"
                        D[i, j] = sqrt(mean((ϕ1[idx] - ϕ2[idx]) .^ 2))
                    elseif metric == "χ²"
                        D[i, j] = sum((ϕ1[idx] - ϕ2[idx]) .^ 2 ./ (ϕ2[idx] .+ eps(Float64)))
                    else
                        throw(
                            ErrorException(
                                "This should not happen as we checked for the validity of the distance_metrics above.",
                            ),
                        )
                    end
                end
            end
            push!(dimension, "entries")
            push!(metric_names, metric)
            push!(matrices, D)
        end
        push!(dimension, "entries")
        push!(metric_names, "counts")
        push!(matrices, counts)
    end
    # Output
    if length(dimension) == 0
        throw(ErrorException("Phenomes struct is too sparse. No distance matrix was calculated."))
    end
    dist::Dict{String,Matrix{Float64}} = Dict()
    for i in eachindex(dimension)
        # i = 4
        key = string(dimension[i], "|", metric_names[i])
        dist[key] = matrices[i]
    end
    (Φ.traits, Φ.entries, dist)
end

"""
    plot(phenomes::Phenomes; nbins::Int64 = 10)::Nothing

Generate diagnostic plots for phenotypic data stored in a `Phenomes` struct.

# Arguments
- `phenomes::Phenomes`: A Phenomes struct containing phenotypic data
- `nbins::Int64=10`: Number of bins for the histograms (optional)

# Description
For each population in the dataset:
1. Creates histograms showing the distribution of each trait
2. Generates a heatmap of trait correlations for traits with non-zero variance

# Notes
- Skips traits with all missing, NaN, or infinite values
- Only includes traits with variance > 1e-10 in correlation analysis
- Requires at least 3 data points to generate a histogram
- Uses UnicodePlots for visualization in terminal

# Examples
```
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);

julia> GBCore.plot(phenomes);

```
"""
function plot(phenomes::Phenomes; nbins::Int64 = 10)
    # phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3); nbins = 10;
    if !checkdims(phenomes)
        throw(ArgumentError("Phenomes struct is corrupted."))
    end
    # View distributions per population per trait using histograms
    for pop in unique(phenomes.populations)
        # pop = phenomes.populations[1]
        idx_trait_with_variance::Vector{Int64} = []
        for j in eachindex(phenomes.traits)
            # j = 1
            println("##############################################")
            println("Population: " * pop * " | Trait: " * phenomes.traits[j])
            idx = findall(
                (phenomes.populations .== pop) .&&
                .!ismissing.(phenomes.phenotypes[:, j]) .&&
                .!isnan.(phenomes.phenotypes[:, j]) .&&
                .!isinf.(phenomes.phenotypes[:, j]),
            )
            if length(idx) == 0
                println("All values are missing, NaN and/or infinities.")
                continue
            end
            ϕ::Vector{Float64} = phenomes.phenotypes[idx, j]
            if StatsBase.var(ϕ) > 1e-10
                append!(idx_trait_with_variance, j)
            end
            if length(ϕ) > 2
                plt = UnicodePlots.histogram(ϕ, title = phenomes.traits[j], vertical = false, nbins = nbins)
                display(plt)
            else
                println(string("Trait: ", phenomes.traits[j], " has ", length(ϕ), " non-missing data points."))
            end
        end
        # Build the correlation matrix
        idx_pop = findall(phenomes.populations .== pop)
        _, _, dist = try
            distances(
                slice(phenomes, idx_entries = idx_pop, idx_traits = idx_trait_with_variance),
                distance_metrics = ["correlation"],
            )
        catch
            println("Error in computing distances for the Phenomes struct.")
            continue
        end
        C = try
            dist["traits|correlation"]
        catch
            continue
        end
        plt = UnicodePlots.heatmap(
            C;
            height = length(phenomes.traits),
            width = length(phenomes.traits),
            title = string(
                "Trait correlations: {",
                join(
                    string.(collect(1:length(idx_trait_with_variance))) .* " => " .*
                    phenomes.traits[idx_trait_with_variance],
                    ", ",
                ),
                "}",
            ),
        )
        display(plt)
    end
    # Return John Snow's knowledge.
    return nothing
end

"""
    slice(phenomes::Phenomes; idx_entries::Union{Nothing, Vector{Int64}}=nothing, idx_traits::Union{Nothing, Vector{Int64}}=nothing)::Phenomes

Create a new `Phenomes` object containing a subset of the original data by selecting specific entries and traits.

# Arguments
- `phenomes::Phenomes`: The original Phenomes object to slice
- `idx_entries::Union{Nothing, Vector{Int64}}=nothing`: Indices of entries to keep. If `nothing`, all entries are kept
- `idx_traits::Union{Nothing, Vector{Int64}}=nothing`: Indices of traits to keep. If `nothing`, all traits are kept

# Returns
- `Phenomes`: A new Phenomes object containing only the selected entries and traits

# Notes
- The function preserves the original structure while reducing dimensions
- Indices must be within valid ranges (1 to n_entries/n_traits)
- Duplicate indices are automatically removed
- The resulting object maintains all relationships between entries, populations, traits, and phenotypes

# Throws
- `ArgumentError`: If the input Phenomes struct is corrupted or if indices are out of bounds
- `DimensionMismatch`: If the slicing operation results in invalid dimensions

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = fill(0.0, 10,3);

julia> sliced_phenomes = slice(phenomes, idx_entries=collect(1:5); idx_traits=collect(2:3));

julia> dimensions(sliced_phenomes)
Dict{String, Int64} with 8 entries:
  "n_total"       => 10
  "n_zeroes"      => 10
  "n_nan"         => 0
  "n_entries"     => 5
  "n_traits"      => 2
  "n_inf"         => 0
  "n_populations" => 1
  "n_missing"     => 0
```
"""
function slice(
    phenomes::Phenomes;
    idx_entries::Union{Nothing,Vector{Int64}} = nothing,
    idx_traits::Union{Nothing,Vector{Int64}} = nothing,
)::Phenomes
    # phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3); nbins = 10;
    # idx_entries::Vector{Int64}=collect(2:7); idx_traits::Vector{Int64}=collect(1:2);
    if !checkdims(phenomes)
        throw(ArgumentError("Phenomes struct is corrupted."))
    end
    phenomes_dims::Dict{String,Int64} = dimensions(phenomes)
    n_entries::Int64 = phenomes_dims["n_entries"]
    n_traits::Int64 = phenomes_dims["n_traits"]
    idx_entries = if isnothing(idx_entries)
        collect(1:n_entries)
    else
        if (minimum(idx_entries) < 1) || (maximum(idx_entries) > n_entries)
            throw(ArgumentError("We accept `idx_entries` from 1 to `n_entries` of `phenomes`."))
        end
        unique(sort(idx_entries))
    end
    idx_traits = if isnothing(idx_traits)
        collect(1:n_traits)
    else
        if (minimum(idx_traits) < 1) || (maximum(idx_traits) > n_traits)
            throw(ArgumentError("We accept `idx_traits` from 1 to `n_traits` of `phenomes`."))
        end
        unique(sort(idx_traits))
    end
    n, t = length(idx_entries), length(idx_traits)
    sliced_phenomes::Phenomes = Phenomes(n = n, t = t)
    for (i1, i2) in enumerate(idx_entries)
        sliced_phenomes.entries[i1] = phenomes.entries[i2]
        sliced_phenomes.populations[i1] = phenomes.populations[i2]
        for (j1, j2) in enumerate(idx_traits)
            if i1 == 1
                sliced_phenomes.traits[j1] = phenomes.traits[j2]
            end
            sliced_phenomes.phenotypes[i1, j1] = phenomes.phenotypes[i2, j2]
            sliced_phenomes.mask[i1, j1] = phenomes.mask[i2, j2]
        end
    end
    ### Check dimensions
    if !checkdims(sliced_phenomes)
        throw(DimensionMismatch("Error slicing the genome."))
    end
    # Output
    return sliced_phenomes
end


"""
    filter(phenomes::Phenomes)::Phenomes

Filter a Phenomes struct by removing rows (entries) and columns (traits) as indicated by the mask matrix. 
An entry or trait is removed if it contains at least one false value in the mask.

# Arguments
- `phenomes::Phenomes`: The Phenomes struct to be filtered, containing entries, populations, traits,
  phenotypes, and a boolean mask matrix.

# Returns
- `Phenomes`: A new Phenomes struct with filtered entries and traits, where the mask matrix is all true.

# Details
The function uses the mean of rows and columns in the mask matrix to identify which entries and traits
should be kept. Only entries and traits with a mean of 1.0 (all true values) are retained in the
filtered result.

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = fill(0.0, 10,3);

julia> phenomes.mask .= true; phenomes.mask[6:10, 1] .= false;
    
julia> filtered_phenomes = filter(phenomes);

julia> size(filtered_phenomes.phenotypes)
(5, 2)
```
"""
function Base.filter(phenomes::Phenomes)::Phenomes
    # phenomes = simulatephenomes(); phenomes.mask[1:10, 42:100] .= false;
    idx_entries = findall(mean(phenomes.mask, dims = 2)[:, 1] .== 1.0)
    idx_traits = findall(mean(phenomes.mask, dims = 1)[1, :] .== 1.0)
    filtered_phenomes::Phenomes = slice(phenomes, idx_entries = idx_entries; idx_traits = idx_traits)
    filtered_phenomes
end

"""
    merge(
        phenomes::Phenomes,
        other::Phenomes;
        conflict_resolution::Tuple{Float64,Float64} = (0.5, 0.5),
        verbose::Bool = true
    )::Phenomes

Merge two `Phenomes` structs into a single combined struct, handling overlapping entries and traits.

# Arguments
- `phenomes::Phenomes`: The first Phenomes struct to merge
- `other::Phenomes`: The second Phenomes struct to merge
- `conflict_resolution::Tuple{Float64,Float64}`: Weights for resolving conflicts between overlapping values (must sum to 1.0)
- `verbose::Bool`: Whether to display a progress bar during merging

# Returns
- `Phenomes`: A new merged Phenomes struct containing all entries and traits from both input structs

# Details
The merge operation combines:
- All unique entries from both structs
- All unique traits from both structs
- Phenotype values and masks, using weighted averaging for conflicts
- Population information, marking conflicts with a "CONFLICT" prefix

For overlapping entries and traits:
- Identical values are preserved as-is
- Different values are combined using the weights specified in `conflict_resolution`
- Missing values are handled by using the available non-missing value
- Population conflicts are marked in the format "CONFLICT (pop1, pop2)"

# Throws
- `ArgumentError`: If either Phenomes struct is corrupted (invalid dimensions)
- `ArgumentError`: If conflict_resolution weights don't sum to 1.0 or aren't a 2-tuple
- `ErrorException`: If the merging operation produces an invalid result

# Examples
```jldoctest; setup = :(using GBCore)
julia> all = Phenomes(n=10, t=3); all.entries = string.("entry_", 1:10); all.traits = ["A", "B", "C"]; all.phenotypes = rand(10,3);

julia> phenomes = slice(all, idx_entries=collect(1:7), idx_traits=[1,2]);

julia> other = slice(all, idx_entries=collect(5:10), idx_traits=[2,3]);

julia> merged_phenomes = merge(phenomes, other, conflict_resolution=(0.75, 0.25), verbose=false);

julia> size(merged_phenomes.phenotypes)
(10, 3)

julia> sum(ismissing.(merged_phenomes.phenotypes))
7
```
"""
function Base.merge(
    phenomes::Phenomes,
    other::Phenomes;
    conflict_resolution::Tuple{Float64,Float64} = (0.5, 0.5),
    verbose::Bool = true,
)::Phenomes
    # Check arguments
    if !checkdims(phenomes) && !checkdims(other)
        throw(ArgumentError("Both Phenomes structs are corrupted."))
    end
    if !checkdims(phenomes)
        throw(ArgumentError("The first Phenomes struct is corrupted."))
    end
    if !checkdims(other)
        throw(ArgumentError("The second Phenomes struct is corrupted."))
    end
    if (length(conflict_resolution) != 2) && (sum(conflict_resolution) != 1.00)
        throw(ArgumentError("We expect `conflict_resolution` 2 be a 2-item tuple which sums up to exactly 1.00."))
    end
    # Instantiate the merged Phenomes struct
    entries::Vector{String} = phenomes.entries ∪ other.entries
    populations::Vector{String} = fill("", length(entries))
    traits::Vector{String} = phenomes.traits ∪ other.traits
    phenotypes::Matrix{Union{Missing,Float64}} = fill(missing, (length(entries), length(traits)))
    mask::Matrix{Bool} = fill(false, (length(entries), length(traits)))
    out::Phenomes = Phenomes(n = length(entries), t = length(traits))
    # Merge and resolve conflicts in allele frequencies and mask
    if verbose
        pb = ProgressMeter.Progress(length(entries) * length(traits); desc = "Merging 2 Phenomes structs: ")
    end
    idx_entry_1::Vector{Int} = []
    idx_entry_2::Vector{Int} = []
    bool_entry_1::Bool = false
    bool_entry_2::Bool = false
    idx_trait_1::Vector{Int} = []
    idx_trait_2::Vector{Int} = []
    bool_trait_1::Bool = false
    bool_trait_2::Bool = false
    for (i, entry) in enumerate(entries)
        # entry = entries[i]
        idx_entry_1 = findall(phenomes.entries .== entry)
        idx_entry_2 = findall(other.entries .== entry)
        # We expect a maximum of 1 match per entry as we checked the Phenomes structs
        bool_entry_1 = length(idx_entry_1) > 0
        bool_entry_2 = length(idx_entry_2) > 0
        if bool_entry_1 && bool_entry_2
            if phenomes.populations[idx_entry_1[1]] == other.populations[idx_entry_2[1]]
                populations[i] = phenomes.populations[idx_entry_1[1]]
            else
                populations[i] = string(
                    "CONFLICT (",
                    phenomes.populations[idx_entry_1[1]]...,
                    ", ",
                    other.populations[idx_entry_2[1]]...,
                    ")",
                )
            end
        elseif bool_entry_1
            populations[i] = phenomes.populations[idx_entry_1[1]]
        elseif bool_entry_2
            populations[i] = other.populations[idx_entry_2[1]]
        else
            continue # should never happen
        end
        for (j, trait) in enumerate(traits)
            # trait = traits[j]
            # We expect 1 locus-allele match as we checked the Phenomes structs
            idx_trait_1 = findall(phenomes.traits .== trait)
            idx_trait_2 = findall(other.traits .== trait)
            bool_trait_1 = length(idx_trait_1) > 0
            bool_trait_2 = length(idx_trait_2) > 0
            if bool_entry_1 && bool_trait_1 && bool_entry_2 && bool_trait_2
                q_1 = phenomes.phenotypes[idx_entry_1[1], idx_trait_1[1]]
                q_2 = other.phenotypes[idx_entry_2[1], idx_trait_2[1]]
                m_1 = phenomes.mask[idx_entry_1[1], idx_trait_1[1]]
                m_2 = other.mask[idx_entry_2[1], idx_trait_2[1]]
                if skipmissing(q_1) == skipmissing(q_2)
                    phenotypes[i, j] = q_1
                    mask[i, j] = m_1
                else
                    if !ismissing(q_1) && !ismissing(q_2)
                        phenotypes[i, j] = sum((q_1, q_2) .* conflict_resolution)
                    elseif !ismissing(q_1)
                        phenotypes[i, j] = q_1
                    else
                        phenotypes[i, j] = q_2
                    end
                    mask[i, j] = Bool(round(sum((m_1, m_2) .* conflict_resolution)))
                end
            elseif bool_entry_1 && bool_trait_1
                phenotypes[i, j] = phenomes.phenotypes[idx_entry_1[1], idx_trait_1[1]]
                mask[i, j] = phenomes.mask[idx_entry_1[1], idx_trait_1[1]]
            elseif bool_entry_2 && bool_trait_2
                phenotypes[i, j] = other.phenotypes[idx_entry_2[1], idx_trait_2[1]]
                mask[i, j] = other.mask[idx_entry_2[1], idx_trait_2[1]]
            else
                continue
            end
            if verbose
                next!(pb)
            end
        end
    end
    if verbose
        finish!(pb)
    end
    # Output
    out.entries = entries
    out.populations = populations
    out.traits = traits
    out.phenotypes = phenotypes
    out.mask = mask
    if !checkdims(out)
        throw(ErrorException("Error merging the 2 Phenomes structs."))
    end
    out
end

"""
    tabularise(phenomes::Phenomes)::DataFrame

Convert a `Phenomes` struct into a tabular format as a `DataFrame`.

The resulting DataFrame contains the following columns:
- `id`: Integer index for each entry
- `entries`: Entry identifiers
- `populations`: Population assignments
- Additional columns for each trait in `phenomes.traits`

# Arguments
- `phenomes::Phenomes`: A valid Phenomes struct containing phenotypic data

# Returns
- `DataFrame`: A DataFrame with entries as rows and traits as columns

# Throws
- `ArgumentError`: If the Phenomes struct dimensions are inconsistent

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = fill(0.0, 10,3);

julia> tabularise(phenomes)
10×6 DataFrame
 Row │ id     entries   populations  A         B         C        
     │ Int64  String    String       Float64?  Float64?  Float64? 
─────┼────────────────────────────────────────────────────────────
   1 │     1  entry_1   pop_1             0.0       0.0       0.0
   2 │     2  entry_2   pop_1             0.0       0.0       0.0
   3 │     3  entry_3   pop_1             0.0       0.0       0.0
   4 │     4  entry_4   pop_1             0.0       0.0       0.0
   5 │     5  entry_5   pop_1             0.0       0.0       0.0
   6 │     6  entry_6   pop_1             0.0       0.0       0.0
   7 │     7  entry_7   pop_1             0.0       0.0       0.0
   8 │     8  entry_8   pop_1             0.0       0.0       0.0
   9 │     9  entry_9   pop_1             0.0       0.0       0.0
  10 │    10  entry_10  pop_1             0.0       0.0       0.0
```
"""
function tabularise(phenomes::Phenomes)::DataFrame
    # phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);
    if !checkdims(phenomes)
        throw(ArgumentError("Phenomes struct is corrupted."))
    end
    df_ids::DataFrame =
        DataFrame(; id = 1:length(phenomes.entries), entries = phenomes.entries, populations = phenomes.populations)
    df_phe::DataFrame = DataFrame(phenomes.phenotypes, :auto)
    rename!(df_phe, phenomes.traits)
    df_phe.id = 1:length(phenomes.entries)
    df = innerjoin(df_ids, df_phe; on = :id)
    return df
end

"""
    @stringevaluation(x)

Parse and evaluate a string expression at compile time.

# Arguments
- `x`: A string containing a Julia expression to be parsed.

# Returns
- The parsed expression as an `Expr` object ready for evaluation.
"""
macro stringevaluation(x)
    Meta.parse(string("$(x)"))
end

"""
    addcompositetrait(phenomes::Phenomes; composite_trait_name::String, formula_string::String)::Phenomes

Create a new composite trait by combining existing traits using mathematical operations.

# Arguments
- `phenomes::Phenomes`: A Phenomes struct containing the original trait data
- `composite_trait_name::String`: Name for the new composite trait
- `formula_string::String`: Mathematical formula describing how to combine existing traits. 
  Supports traits as variables and the following operations:
  * Basic arithmetic: +, -, *, /, ^, %
  * Functions: abs(), sqrt(), log(), log2(), log10()
  * Parentheses for operation precedence

# Returns
- `Phenomes`: A new Phenomes struct with the composite trait added as the last column

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);

julia> phenomes_new = addcompositetrait(phenomes, composite_trait_name = "some_wild_composite_trait", formula_string = "A");

julia> phenomes_new.phenotypes[:, end] == phenomes.phenotypes[:, 1]
true

julia> phenomes_new = addcompositetrait(phenomes, composite_trait_name = "some_wild_composite_trait", formula_string = "(A^B) + (C/A) - sqrt(abs(B-A)) + log(1.00 + C)");

julia> phenomes_new.phenotypes[:, end] == (phenomes.phenotypes[:,1].^phenomes.phenotypes[:,2]) .+ (phenomes.phenotypes[:,3]./phenomes.phenotypes[:,1]) .- sqrt.(abs.(phenomes.phenotypes[:,2].-phenomes.phenotypes[:,1])) .+ log.(1.00 .+ phenomes.phenotypes[:,3])
true
```
"""
function addcompositetrait(phenomes::Phenomes; composite_trait_name::String, formula_string::String)::Phenomes
    # phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.populations .= "pop_1"; phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);
    # composite_trait_name = "some_wild_composite_trait";
    # formula_string = "((A^B) + C) + sqrt(abs(log(1.00 / A) - (A * (B + C)) / (B - C)^2))";
    # formula_string = "A";
    df = tabularise(phenomes)
    formula_parsed_orig = deepcopy(formula_string)
    formula_parsed = deepcopy(formula_string)
    symbol_strings = ["=", "+", "-", "*", "/", "^", "%", "abs(", "sqrt(", "log(", "log2(", "log10(", "(", ")"]
    for s in symbol_strings
        formula_string = replace(formula_string, s => " ")
    end
    component_trait_names = unique(split(formula_string, " "))
    ϕ = Vector{Union{Missing,Float64}}(undef, size(df, 1))
    for i in eachindex(ϕ)
        # i = 1
        for var_name in component_trait_names
            # var_name = component_trait_names[2]
            if sum(names(df) .== var_name) == 0
                continue
            else
                formula_parsed = replace(formula_parsed, var_name => string(df[i, var_name]))
            end
        end
        ϕ[i] = @eval(@stringevaluation $(formula_parsed))
        # Reset the formula
        formula_parsed = deepcopy(formula_parsed_orig)
    end
    out = clone(phenomes)
    idx = findall(out.traits .== composite_trait_name)
    if length(idx) == 0
        push!(out.traits, composite_trait_name)
        out.phenotypes = hcat(out.phenotypes, ϕ)
    elseif length(idx) == 1
        out.phenotypes[:, idx] = ϕ
    else
        throw(ErrorException("Duplicate traits in phenomes, i.e. trait: " * composite_trait_name))
    end
    out.mask = hcat(out.mask, ones(size(out.mask, 1)))
    if !checkdims(out)
        throw(ErrorException("Error generating composite trait: `" * composite_trait_name * "`"))
    end
    out
end
