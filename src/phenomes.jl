"""
    clone(x::Phenomes)::Phenomes

Clone a Phenomes object

## Example
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=2, t=2);

julia> copy_phenomes = clone(phenomes)
Phenomes(["", ""], ["", ""], ["", ""], Union{Missing, Float64}[missing missing; missing missing], Bool[0 0; 0 0])
```
"""
function clone(x::Phenomes)::Phenomes
    y::Phenomes = Phenomes(n = length(x.entries), t = length(x.traits))
    y.entries = deepcopy(x.entries)
    y.populations = deepcopy(x.populations)
    y.traits = deepcopy(x.traits)
    y.phenotypes = deepcopy(x.phenotypes)
    y.mask = deepcopy(x.mask)
    y
end

"""
    Base.hash(x::Phenomes, h::UInt)::UInt

Hash a Phenomes struct.

## Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=2, t=2);

julia> typeof(hash(phenomes))
UInt64
```
"""
function Base.hash(x::Phenomes, h::UInt)::UInt
    hash(Phenomes, hash(x.entries, hash(x.populations, hash(x.traits, hash(x.phenotypes, hash(x.mask, h))))))
end


"""
    Base.:(==)(x::Phenomes, y::Phenomes)::Bool

Equality of Phenomes structs using the hash function defined for Phenomes structs.

## Examples
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

Check dimension compatibility of the fields of the Phenomes struct

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

Count the number of entries, populations, and traits in the Phenomes struct

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);

julia> dimensions(phenomes)
Dict{String, Int64} with 3 entries:
  "n_entries"     => 10
  "n_traits"      => 3
  "n_populations" => 1
```
"""
function dimensions(phenomes::Phenomes)::Dict{String,Int64}
    if !checkdims(phenomes)
        throw(ArgumentError("Phenomes struct is corrupted."))
    end
    Dict(
        "n_entries" => length(unique(phenomes.entries)),
        "n_populations" => length(unique(phenomes.populations)),
        "n_traits" => length(phenomes.traits),
    )
end


"""
    plot(phenomes::Phenomes)::Nothing

Plot histogram/s of the trait value/s

# Examples
```
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);

julia> plot(phenomes);

```
"""
function plot(phenomes::Phenomes)
    # phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);
    if !checkdims(phenomes)
        throw(ArgumentError("Phenomes struct is corrupted."))
    end
    for j in eachindex(phenomes.traits)
        ϕ::Vector{Float64} = phenomes.phenotypes[.!ismissing.(phenomes.phenotypes[:, j]), j]
        if length(ϕ) > 2
            plt = UnicodePlots.histogram(ϕ, title = phenomes.traits[j], vertical = true, nbins = 5)
            display(plt)
        else
            println(string("Trait: ", phenomes.traits[j], " has ", length(ϕ), " non-missing data points."))
        end
    end
    return nothing
end

"""
    slice(phenomes::Phenomes; idx_entries::Vector{Int64}, idx_traits::Vector{Int64})::Phenomes

Slice a Phenomes struct by specifing indixes of entries and traits

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);

julia> sliced_phenomes = slice(phenomes, idx_entries=collect(1:5); idx_traits=collect(2:3));

julia> dimensions(sliced_phenomes)
Dict{String, Int64} with 3 entries:
  "n_entries"     => 5
  "n_traits"      => 2
  "n_populations" => 1
```
"""
function slice(phenomes::Phenomes; idx_entries::Vector{Int64}, idx_traits::Vector{Int64})::Phenomes
    # phenomes::Phenomes = simulatephenomes(); idx_entries::Vector{Int64}=sample(1:100, 10); idx_traits::Vector{Int64}=sample(1:10_000, 1000);
    if !checkdims(phenomes)
        throw(ArgumentError("Phenomes struct is corrupted."))
    end
    phenomes_dims::Dict{String,Int64} = dimensions(phenomes)
    n_entries::Int64 = phenomes_dims["n_entries"]
    n_traits::Int64 = phenomes_dims["n_traits"]
    if (minimum(idx_entries) < 1) || (maximum(idx_entries) > n_entries)
        throw(ArgumentError("We accept `idx_entries` from 1 to `n_entries` of `phenomes`."))
    end
    if (minimum(idx_traits) < 1) || (maximum(idx_traits) > n_traits)
        throw(ArgumentError("We accept `idx_traits` from 1 to `n_traits` of `phenomes`."))
    end
    sort!(idx_entries)
    sort!(idx_traits)
    unique!(idx_entries)
    unique!(idx_traits)
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

Filter a Phenomes struct using its mask matrix where all rows and columns with at least one false value are excluded

# Examples
```jldoctest; setup = :(using GBCore)
julia> phenomes = Phenomes(n=10, t=3); phenomes.entries = string.("entry_", 1:10); phenomes.traits = ["A", "B", "C"]; phenomes.phenotypes = rand(10,3);

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
        verbose::Bool = true,
    )::Phenomes

Merge two Phenomes structs using a tuple of conflict resolution weights

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