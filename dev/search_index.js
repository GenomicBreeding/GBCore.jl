var documenterSearchIndex = {"docs":
[{"location":"","page":"Home","title":"Home","text":"CurrentModule = GBCore","category":"page"},{"location":"#GBCore","page":"Home","title":"GBCore","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"Documentation for GBCore.","category":"page"},{"location":"","page":"Home","title":"Home","text":"","category":"page"},{"location":"","page":"Home","title":"Home","text":"Modules = [GBCore]","category":"page"},{"location":"#GBCore.AbstractGB","page":"Home","title":"GBCore.AbstractGB","text":"Abstract super type for all GenomicBreeding.jl custom types\n\n\n\n\n\n","category":"type"},{"location":"#GBCore.CV","page":"Home","title":"GBCore.CV","text":"Cross-validation struct\n\n\n\n\n\n","category":"type"},{"location":"#GBCore.Genomes","page":"Home","title":"GBCore.Genomes","text":"Genomes struct\n\nContaines unique entries and loci_alleles where allele frequencies can have missing values\n\nConstructor\n\nGenomes(; n::Int64 = 1, p::Int64 = 2)\n\nFields\n\nentries: names of the n entries or samples\npopulations: name/s of the population/s each entries or samples belong to\nloci_alleles: names of the p loci-alleles combinations (p = l loci x a-1 alleles) including the \n\nchromsome or scaffold name, position, all alleles, and current allele separated by tabs (\"\\t\")\n\nallele_frequencies: n x p matrix of allele frequencies between 0 and 1 which can have missing values\nmask: n x p matrix of boolean mask for selective analyses and slicing\n\nExamples\n\njulia> genomes = Genomes(n=2, p=2)\nGenomes([\"\", \"\"], [\"\", \"\"], [\"\", \"\"], Union{Missing, Float64}[missing missing; missing missing], Bool[0 0; 0 0])\n\njulia> fieldnames(Genomes)\n(:entries, :populations, :loci_alleles, :allele_frequencies, :mask)\n\njulia> genomes.entries = [\"entry_1\", \"entry_2\"];\n\njulia> genomes.populations = [\"pop_1\", \"pop_1\"];\n\njulia> genomes.loci_alleles = [\"chr1\\t12345\\tA|T\\tA\", \"chr2\\t678910\\tC|D\\tD\"];\n\njulia> genomes.allele_frequencies = [0.5 0.25; 0.9 missing];\n\njulia> genomes.mask = [true true; true false];\n\njulia> genomes\nGenomes([\"entry_1\", \"entry_2\"], [\"pop_1\", \"pop_1\"], [\"chr1\\t12345\\tA|T\\tA\", \"chr2\\t678910\\tC|D\\tD\"], Union{Missing, Float64}[0.5 0.25; 0.9 missing], Bool[1 1; 1 0])\n\n\n\n\n\n","category":"type"},{"location":"#GBCore.Phenomes","page":"Home","title":"GBCore.Phenomes","text":"Phenomes struct\n\nConstains unique entries and traits where phenotype data can have missing values\n\nConstructor\n\nPhenomes(; n::Int64 = 1, t::Int64 = 2)\n\nFields\n\nentries: names of the n entries or samples\npopulations: name/s of the population/s each entries or samples belong to\ntraits: names of the t traits\nphenotypes: n x t matrix of numeric (R) phenotype data which can have missing values\nmask: n x t matrix of boolean mask for selective analyses and slicing\n\nExamples\n\njulia> phenomes = Phenomes(n=2, t=2)\nPhenomes([\"\", \"\"], [\"\", \"\"], [\"\", \"\"], Union{Missing, Float64}[missing missing; missing missing], Bool[0 0; 0 0])\n\njulia> fieldnames(Phenomes)\n(:entries, :populations, :traits, :phenotypes, :mask)\n\njulia> phenomes.entries = [\"entry_1\", \"entry_2\"];\n\njulia> phenomes.populations = [\"pop_A\", \"pop_B\"];\n\njulia> phenomes.traits = [\"height\", \"yield\"];\n\njulia> phenomes.phenotypes = [200.0 2.5; 150.0 missing];\n\njulia> phenomes.mask = [true true; true false];\n\njulia> phenomes\nPhenomes([\"entry_1\", \"entry_2\"], [\"pop_A\", \"pop_B\"], [\"height\", \"yield\"], Union{Missing, Float64}[200.0 2.5; 150.0 missing], Bool[1 1; 1 0])\n\n\n\n\n\n","category":"type"},{"location":"#GBCore.SimulatedEffects","page":"Home","title":"GBCore.SimulatedEffects","text":"SimulatedEffects struct\n\nContains:\n\nIdentification, i.e. trait, year, season, harvest, site, and replication\nAdditive environmental effects:\nyear\nseason\nsite\nEnvironmental interaction effects:\nseasonsxyear\nharvestsxseasonxyear\nsitesxharvestxseasonxyear\nSpatial effects including the field layout per year-season-harvest-site combination\nfield_layout\nreplicationsxsitexharvestxseasonxyear\nblocksxsitexharvestxseasonxyear\nrowsxsitexharvestxseasonxyear\ncolsxsitexharvestxseasonxyear\nGenetic effects\nadditive_genetic\ndominance_genetic\nepistasis_genetic\nGxE effects\nadditiveallelexsitexharvestxseasonx_year\ndominanceallelexsitexharvestxseasonx_year\nepistasisallelexsitexharvestxseasonx_year\n\nConstructor\n\nSimulatedEffects()\n\n\n\n\n\n","category":"type"},{"location":"#GBCore.TEBV","page":"Home","title":"GBCore.TEBV","text":"Trial-estimate breeding values (TEBV) struct\n\nContains trial-estimated breeding values as generated by analyse(trials::Trials, ...).\n\nFields\n\ntraits: names of the traits t traits\nformulae: best-fitting formula for each trait\nmodels: best-fitting linear mixed model for each trait\ndf_BLUEs: vector of data frames of best linear unbiased estimators or fixed effects table of each best fitting model\ndf_BLUPs: vector of data frames of best linear unbiased predictors or random effects table of each best fitting model\nphenomes: vector of Phenomes structs each containing the breeding values\n\nExamples\n\njulia> tebv = TEBV(traits=[\"\"], formulae=[\"\"], models=[MixedModel(@formula(y~1+(1|x)), DataFrame(y=1, x=1))], df_BLUEs=[DataFrame(x=1)], df_BLUPs=[DataFrame(x=1)], phenomes=[Phenomes(n=1, t=1)]);\n\njulia> tebv.traits\n1-element Vector{String}:\n \"\"\n\n\n\n\n\n","category":"type"},{"location":"#GBCore.Trials","page":"Home","title":"GBCore.Trials","text":"Trials struct\n\nContains phenotype data across years, seasons, harvest, sites, populations, replications, blocks, rows, and columns\n\nConstructor\n\nTrials(; n::Int64 = 2, p::Int64 = 2)\n\nFields\n\nphenotypes: n x t matrix of numeric phenotype data which can have missing values\ntraits: names of the traits t traits\nyears: names of the years corresponding to each row in the phenotype matrix\nseasons: names of the seasons corresponding to each row in the phenotype matrix\nharvests: names of the harvests corresponding to each row in the phenotype matrix\nsites: names of the sites corresponding to each row in the phenotype matrix\nreplications: names of the replications corresponding to each row in the phenotype matrix\nblocks: names of the blocks corresponding to each row in the phenotype matrix\nrows: names of the rows corresponding to each row in the phenotype matrix\ncols: names of the cols corresponding to each row in the phenotype matrix\nentries: names of the entries corresponding to each row in the phenotype matrix\npopulations: names of the populations corresponding to each row in the phenotype matrix\n\nExamples\n\njulia> trials = Trials(n=1, t=2)\nTrials(Union{Missing, Float64}[missing missing], [\"\", \"\"], [\"\"], [\"\"], [\"\"], [\"\"], [\"\"], [\"\"], [\"\"], [\"\"], [\"\"], [\"\"])\n\njulia> fieldnames(Trials)\n(:phenotypes, :traits, :years, :seasons, :harvests, :sites, :replications, :blocks, :rows, :cols, :entries, :populations)\n\n\n\n\n\n","category":"type"},{"location":"#Base.:==-Tuple{Genomes, Genomes}","page":"Home","title":"Base.:==","text":"Base.:(==)(x::Genomes, y::Genomes)::Bool\n\nEquality of Genomes structs using the hash function defined for Genomes structs.\n\nExamples\n\njulia> genomes_1 = genomes = Genomes(n=2,p=4);\n\njulia> genomes_2 = genomes = Genomes(n=2,p=4);\n\njulia> genomes_3 = genomes = Genomes(n=1,p=2);\n\njulia> genomes_1 == genomes_2\ntrue\n\njulia> genomes_1 == genomes_3\nfalse\n\n\n\n\n\n","category":"method"},{"location":"#Base.:==-Tuple{Phenomes, Phenomes}","page":"Home","title":"Base.:==","text":"Base.:(==)(x::Phenomes, y::Phenomes)::Bool\n\nEquality of Phenomes structs using the hash function defined for Phenomes structs.\n\nExamples\n\njulia> phenomes_1 = phenomes = Phenomes(n=2, t=4);\n\njulia> phenomes_2 = phenomes = Phenomes(n=2, t=4);\n\njulia> phenomes_3 = phenomes = Phenomes(n=1, t=2);\n\njulia> phenomes_1 == phenomes_2\ntrue\n\njulia> phenomes_1 == phenomes_3\nfalse\n\n\n\n\n\n","category":"method"},{"location":"#Base.:==-Tuple{SimulatedEffects, SimulatedEffects}","page":"Home","title":"Base.:==","text":"Base.:(==)(x::SimulatedEffects, y::SimulatedEffects)::Bool\n\nEquality of SimulatedEffects structs using the hash function defined for SimulatedEffects structs.\n\nExamples\n\njulia> effects_1 = SimulatedEffects();\n\njulia> effects_2 = SimulatedEffects();\n\njulia> effects_3 = SimulatedEffects(); effects_3.id[1] = \"SOMETHING_ELSE\";\n\njulia> effects_1 == effects_2\ntrue\n\njulia> effects_1 == effects_3\nfalse\n\n\n\n\n\n","category":"method"},{"location":"#Base.:==-Tuple{Trials, Trials}","page":"Home","title":"Base.:==","text":"Base.:(==)(x::Trials, y::Trials)::Bool\n\nEquality of Trials structs using the hash function defined for Trials structs.\n\nExamples\n\njulia> trials_1 = trials = Trials(n=2, t=4);\n\njulia> trials_2 = trials = Trials(n=2, t=4);\n\njulia> trials_3 = trials = Trials(n=1, t=2);\n\njulia> trials_1 == trials_2\ntrue\n\njulia> trials_1 == trials_3\nfalse\n\n\n\n\n\n","category":"method"},{"location":"#Base.filter-Tuple{Genomes}","page":"Home","title":"Base.filter","text":"filter(\n    genomes::Genomes;\n    maf::Float64,\n    max_entry_sparsity::Float64 = 0.0,\n    max_locus_sparsity::Float64 = 0.0,\n    chr_pos_allele_ids::Union{Missing,Vector{String}} = missing,\n)::Genomes\n\nFilter a Genomes struct by minimum allele frequency\n\nExamples\n\njulia> genomes = simulategenomes(n=100, l=1_000, n_alleles=4, verbose=false);\n\njulia> filtered_genomes_1 = filter(genomes, maf=0.1);\n\njulia> filtered_genomes_2 = filter(genomes, maf=0.1, chr_pos_allele_ids=genomes.loci_alleles[1:1000]);\n\njulia> size(genomes.allele_frequencies)\n(100, 3000)\n\njulia> size(filtered_genomes_1.allele_frequencies)\n(100, 1236)\n\njulia> size(filtered_genomes_2.allele_frequencies)\n(100, 388)\n\n\n\n\n\n","category":"method"},{"location":"#Base.hash-Tuple{Genomes, UInt64}","page":"Home","title":"Base.hash","text":"Base.hash(x::Genomes, h::UInt)::UInt\n\nHash a Genomes struct using the entries, populations and locialleles. We deliberately excluded the allelefrequencies, and mask for efficiency.\n\nExamples\n\njulia> genomes = Genomes(n=2, p=2);\n\njulia> typeof(hash(genomes))\nUInt64\n\n\n\n\n\n","category":"method"},{"location":"#Base.hash-Tuple{Phenomes, UInt64}","page":"Home","title":"Base.hash","text":"Base.hash(x::Phenomes, h::UInt)::UInt\n\nHash a Phenomes struct.\n\nExamples\n\njulia> phenomes = Phenomes(n=2, t=2);\n\njulia> typeof(hash(phenomes))\nUInt64\n\n\n\n\n\n","category":"method"},{"location":"#Base.hash-Tuple{SimulatedEffects, UInt64}","page":"Home","title":"Base.hash","text":"Base.hash(x::SimulatedEffects, h::UInt)::UInt\n\nHash a SimulatedEffects struct.\n\nExamples\n\njulia> effects = SimulatedEffects();\n\njulia> typeof(hash(effects))\nUInt64\n\n\n\n\n\n","category":"method"},{"location":"#Base.hash-Tuple{Trials, UInt64}","page":"Home","title":"Base.hash","text":"Base.hash(x::Trials, h::UInt)::UInt\n\nHash a Trials struct.\n\nExamples\n\njulia> trials = Trials(n=2, t=2);\n\njulia> typeof(hash(trials))\nUInt64\n\n\n\n\n\n","category":"method"},{"location":"#Base.merge-Tuple{Genomes, Genomes}","page":"Home","title":"Base.merge","text":"merge(\n    genomes::Genomes,\n    other::Genomes;\n    conflict_resolution::Tuple{Float64,Float64} = (0.5, 0.5),\n    verbose::Bool = true,\n)::Genomes\n\nMerge two Genomes structs using a tuple of conflict resolution weights\n\nExamples\n\njulia> n = 100; l = 5_000; n_alleles = 2;\n\njulia> all = simulategenomes(n=n, l=l, n_alleles=n_alleles, verbose=false);\n\njulia> genomes = slice(all, idx_entries=collect(1:Int(floor(n*0.75))), idx_loci_alleles=collect(1:Int(floor(l*(n_alleles-1)*0.75))));\n\njulia> other = slice(all, idx_entries=collect(Int(floor(n*0.50)):n), idx_loci_alleles=collect(Int(floor(l*(n_alleles-1)*0.50)):l*(n_alleles-1)));\n\njulia> merged_genomes = merge(genomes, other, conflict_resolution=(0.75, 0.25), verbose=false);\n\njulia> size(merged_genomes.allele_frequencies)\n(100, 5000)\n\njulia> sum(ismissing.(merged_genomes.allele_frequencies))\n123725\n\n\n\n\n\n","category":"method"},{"location":"#Base.merge-Tuple{Genomes, Phenomes}","page":"Home","title":"Base.merge","text":"merge(genomes::Genomes, phenomes::Phenomes; keep_all::Bool=true)::Tuple{Genomes,Phenomes}\n\nMerge a Genomes struct with a Phenomes struct using union or intersection\n\nExamples\n\njulia> genomes = simulategenomes(n=10, verbose=false);\n\njulia> trials, effects = simulatetrials(genomes=slice(genomes, idx_entries=collect(1:5), idx_loci_alleles=collect(1:length(genomes.loci_alleles))), f_add_dom_epi=[0.90 0.05 0.05;], n_years=1, n_seasons=1, n_harvests=1, n_sites=1, n_replications=2, verbose=false);\n\njulia> phenomes = Phenomes(n=5, t=1);\n\njulia> phenomes.entries = trials.entries[1:5];\n\njulia> phenomes.populations = trials.populations[1:5];\n\njulia> phenomes.traits = trials.traits;\n\njulia> phenomes.phenotypes = trials.phenotypes[1:5, :];\n\njulia> phenomes.mask .= true;\n\njulia> genomes_merged_1, phenomes_merged_1 = merge(genomes, phenomes, keep_all=true);\n\njulia> size(genomes_merged_1.allele_frequencies), size(phenomes_merged_1.phenotypes)\n((10, 10000), (10, 1))\n\njulia> genomes_merged_2, phenomes_merged_2 = merge(genomes, phenomes, keep_all=false);\n\njulia> size(genomes_merged_2.allele_frequencies), size(phenomes_merged_2.phenotypes)\n((5, 10000), (5, 1))\n\n\n\n\n\n","category":"method"},{"location":"#Base.sum-Tuple{SimulatedEffects}","page":"Home","title":"Base.sum","text":"sum(effects::SimulatedEffects)::Tuple{Int64, Int64, Int64}\n\nSum up the simulated effects to generate the simulated phenotype values\n\nExamples\n\njulia> effects = SimulatedEffects();\n\njulia> sum(effects)\n1-element Vector{Float64}:\n 0.0\n\njulia> effects.additive_genetic[1] = pi;\n\njulia> sum(effects)\n1-element Vector{Float64}:\n 3.141592653589793\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.checkdims-Tuple{Genomes}","page":"Home","title":"GBCore.checkdims","text":"checkdims(genomes::Genomes)::Bool\n\nCheck dimension compatibility of the fields of the Genomes struct\n\nExamples\n\njulia> genomes = Genomes(n=2,p=4);\n\njulia> checkdims(genomes)\nfalse\n\njulia> genomes.entries = [\"entry_1\", \"entry_2\"];\n\njulia> genomes.loci_alleles = [\"chr1\\t1\\tA|T\\tA\", \"chr1\\t2\\tC|G\\tG\", \"chr2\\t3\\tA|T\\tA\", \"chr2\\t4\\tG|T\\tG\"];\n\njulia> checkdims(genomes)\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.checkdims-Tuple{Phenomes}","page":"Home","title":"GBCore.checkdims","text":"checkdims(y::Phenomes)::Bool\n\nCheck dimension compatibility of the fields of the Phenomes struct\n\nExamples\n\njulia> y = Phenomes(n=2, t=2);\n\njulia> checkdims(y)\nfalse\n\njulia> y.entries = [\"entry_1\", \"entry_2\"];\n\njulia> y.traits = [\"trait_1\", \"trait_2\"];\n\njulia> checkdims(y)\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.checkdims-Tuple{SimulatedEffects}","page":"Home","title":"GBCore.checkdims","text":"checkdims(effects::SimulatedEffects)::Bool\n\nCheck dimension compatibility of the fields of the SimulatedEffects struct\n\nExamples\n\njulia> effects = SimulatedEffects();\n\njulia> checkdims(effects)\ntrue\n\njulia> effects.id = [\"beaking_change\"];\n\njulia> checkdims(effects)\nfalse\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.checkdims-Tuple{Trials}","page":"Home","title":"GBCore.checkdims","text":"checkdims(trials::Trials)::Bool\n\nCheck dimension compatibility of the fields of the Trials struct\n\nExamples\n\njulia> trials = Trials(n=1, t=2);\n\njulia> trials.entries = [\"entry_1\"];\n\njulia> checkdims(trials)\ntrue\n\njulia> trials.entries = [\"entering_2_entries\", \"instead_of_just_1\"];\n\njulia> checkdims(trials)\nfalse\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.clone-Tuple{Genomes}","page":"Home","title":"GBCore.clone","text":"clone(x::Genomes)::Genomes\n\nClone a Genomes object\n\nExample\n\njulia> genomes = Genomes(n=2, p=2);\n\njulia> copy_genomes = clone(genomes)\nGenomes([\"\", \"\"], [\"\", \"\"], [\"\", \"\"], Union{Missing, Float64}[missing missing; missing missing], Bool[0 0; 0 0])\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.clone-Tuple{Phenomes}","page":"Home","title":"GBCore.clone","text":"clone(x::Phenomes)::Phenomes\n\nClone a Phenomes object\n\nExample\n\njulia> phenomes = Phenomes(n=2, t=2);\n\njulia> copy_phenomes = clone(phenomes)\nPhenomes([\"\", \"\"], [\"\", \"\"], [\"\", \"\"], Union{Missing, Float64}[missing missing; missing missing], Bool[0 0; 0 0])\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.clone-Tuple{Trials}","page":"Home","title":"GBCore.clone","text":"clone(x::Trials)::Trials\n\nClone a Trials object\n\nExample\n\njulia> trials = Trials(n=2, t=2);\n\njulia> copy_trials = clone(trials)\nTrials(Union{Missing, Float64}[missing missing; missing missing], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"], [\"\", \"\"])\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.dimensions-Tuple{Genomes}","page":"Home","title":"GBCore.dimensions","text":"dimensions(genomes::Genomes)::Dict{String, Int64}\n\nCount the number of entries, populations, loci-alleles combination, loci, and maximum number of alleles per locus in the Genomes struct\n\nExamples\n\njulia> genomes = simulategenomes(n=100, l=1_000, n_alleles=4, verbose=false);\n\njulia> dimensions(genomes)\nDict{String, Int64} with 6 entries:\n  \"n_entries\"      => 100\n  \"n_chr\"          => 7\n  \"n_loci\"         => 1000\n  \"n_loci_alleles\" => 3000\n  \"n_populations\"  => 1\n  \"max_n_alleles\"  => 4\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.loci-Tuple{Genomes}","page":"Home","title":"GBCore.loci","text":"loci(genomes::Genomes)::Tuple{Vector{String},Vector{Int64},Vector{Int64},Vector{Int64}}\n\nExtract chromosome names, positions, start and end indexes of each locus across loci\n\nExamples\n\njulia> genomes = simulategenomes(n=100, l=1_000, n_alleles=4, verbose=false);\n\njulia> chromsomes, positions, loci_ini_idx, loci_fin_idx = loci(genomes);\n\njulia> length(chromsomes), length(positions), length(loci_ini_idx), length(loci_fin_idx)\n(1000, 1000, 1000, 1000)\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.loci_alleles-Tuple{Genomes}","page":"Home","title":"GBCore.loci_alleles","text":"loci_alleles(genomes::Genomes)::Tuple{Vector{String},Vector{Int64},Vector{String}}\n\nExtract chromosomes, positions, and alleles across loci-allele combinations\n\nExamples\n\njulia> genomes = simulategenomes(n=100, l=1_000, n_alleles=4, verbose=false);\n\njulia> chromsomes, positions, alleles = loci_alleles(genomes);\n\njulia> length(chromsomes), length(positions), length(alleles)\n(3000, 3000, 3000)\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.plot","page":"Home","title":"GBCore.plot","text":"plot(genomes::Genomes)::Nothing\n\nPlot allele frequencies\n\nExamples\n\njulia> genomes = simulategenomes(n=100, l=1_000, n_alleles=4, verbose=false);\n\njulia> GBCore.plot(genomes);\n\n\n\n\n\n\n","category":"function"},{"location":"#GBCore.simulateeffects-Tuple{}","page":"Home","title":"GBCore.simulateeffects","text":"Simulate effects\n\nSample p x q effects from a multivariate normal distribution with μ~Exp(λ) and Σ=μμ'\n\nArguments\n\np: number of correlated effects to simulate (default = 2)\nq: number times to simulate the correlated effects from the same distribution (default = 1)\nλ: parameter of the exponential distritbution from which the means will be sampled from (default = 1.00)\nseed: randomisation seed (default = 42)\n\nOutput\n\np x q matrix of correlated effects\n\nExamples\n\njulia> θ::Matrix{Float64} = simulateeffects();\n\njulia> sum(abs.(θ - [-0.0886501800782904; -0.596478483888422])) < 0.00001\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.simulategenomes-Tuple{}","page":"Home","title":"GBCore.simulategenomes","text":"Simulate genomes\n\nArguments\n\nn: number of entries (default = 100)\nl: number of loci (default = 10_000)\nn_chroms: number of chromosomes (default = 7)\nn_alleles: number of alleles per locus (default = 2)\nmax_pos: total length of the genome in base-pairs (bp) (default = 135000000)\nld_corr_50perc_kb: distance in bp at which linkage expressed as correlation between a pair of loci is at 50% (default = 1_000)\nμ_β_params: the shape parameters of the Beta distribution from which the mean allele frequencies will be sampled  (default = (0.5, 0.5); U-shaped distribution; you may use (2.0, 2.0) for a bell-shaped distribution)\nsparsity: Proportion of missing data (default = 0.0)\nseed: psuedo-random number generator seed for replicability (default = 42)\nverbose: Show progress bar and plot the linkage heatmap into an svg file? (default = true)\n\nOutput\n\nGenomes\n\nExamples\n\njulia> genomes = simulategenomes(n=100, l=10_000, n_alleles=3, verbose=false);\n\njulia> length(genomes.entries)\n100\n\njulia> length(genomes.populations)\n100\n\njulia> length(genomes.loci_alleles)\n20000\n\njulia> size(genomes.allele_frequencies)\n(100, 20000)\n\njulia> mean(ismissing.(genomes.allele_frequencies))\n0.0\n\njulia> rng::TaskLocalRNG = Random.seed!(123);\n\njulia> idx = StatsBase.sample(rng, range(1, 20_000, step=2), 250, replace = false, ordered = true);\n\njulia> correlations = StatsBase.cor(genomes.allele_frequencies[:, idx]);\n\njulia> correlations[10,10] == 1.00\ntrue\n\njulia> correlations[10,10] > correlations[10,250]\ntrue\n\njulia> genomes = simulategenomes(n=100, l=10_000, n_alleles=3, sparsity=0.25, verbose=false);\n\njulia> mean(ismissing.(genomes.allele_frequencies))\n0.25\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.simulategenomiceffects-Tuple{}","page":"Home","title":"GBCore.simulategenomiceffects","text":"Simulate genomic effects\n\nSimulate additive, dominance, and epistatic effects\n\nArguments\n\ngenomes: Genome struct includes the n entries x p loci-alleles combinations (p = l loci x a-1 alleles)\nf_additive: proportion of the l loci with non-zero additive effects on the phenotype\nf_dominance: proportion of the l*f_additive additive effects loci with additional dominance effects\nf_epistasis: proportion of the l*f_additive additive effects loci with additional epistasis effects\n\nOutputs\n\nn x 3 matrix of additive, dominance and epistasis effects per entry\np x 3 matrix of additive, dominance and epistasis effects per locus-allele combination\n\nExamples\n\njulia> genomes::Genomes = simulategenomes(n=100, l=2_000, n_alleles=3, verbose=false);\n\njulia> G, B = simulategenomiceffects(genomes=genomes, f_additive=0.05, f_dominance=0.75, f_epistasis=0.25);\n\njulia> size.([G, B])\n2-element Vector{Tuple{Int64, Int64}}:\n (100, 3)\n (4000, 3)\n\njulia> sum(B .!= 0.0, dims=1)\n1×3 Matrix{Int64}:\n 200  75  50\n\nDetails\n\nThe additive, dominance, and epistasis allele effects share a common exponential distribution (λ=1) from which  the mean of the effects (μ) are sampled, and the covariance matrix is derived (Σ = μ * μ';  where if det(Σ)≈0 then we iteratively add 1.00 to the diagonals until it becomes invertible or 10 iterations  finishes and throws an error). The non-additive or epistasis allele effects were simulated by multiplying the allele  frequencies of all possible unique pairs of epistasis alleles and their effects.\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.simulatetrials-Tuple{}","page":"Home","title":"GBCore.simulatetrials","text":"Simulate trials\n\nArguments\n\ngenomes: Genome struct includes the n entries x p loci-alleles combinations (p = l loci x a-1 alleles)\nf_add_dom_epi: n_traits x 3 numeric matrix of loci proportion with additive, dominance and epistasis effects, i.e. each column refers to:\nf_additive: proportion of the l loci with non-zero additive effects on the phenotype\nf_dominance: proportion of the l*f_additive additive effects loci with additional dominance effects\nf_epistasis: proportion of the l*f_additive additive effects loci with additional epistasis effects\nn_years: Number of years (default = 2)\nn_seasons: Number of seasons (default = 4)\nn_harvests: Number of harvests (default = 2)\nn_sites: Number of sites (default = 4)\nn_replications: Number of replications (default = 2)\nn_blocks: Number of blocks across the entire field layout (default = missing)\nn_rows: Number of rows across the entire field layout (default = missing)\nn_cols: Number of columns across the entire field layout (default = missing)\nproportion_of_variance: 9 x n_traits numeric matrix of scaled/non-scaled proportion of variances allocated to   genetic and environmental effects (default = missing; values will be sampled from a uniform distribution  followed by a biased sample on the first row, i.e. additive effects row).  The rows correspond to the variance allocated to:\nadditive genetic effects\ndominance genetic effects\nepistasis genetic effects\nyears effects\nseasons effects\nsites effects\nenvironmental interactions\nspatial interactions\nGxE interactiions\nseed: Randomisation seed (default = 42)\nsparsity: Proportion of missing data (default = 0.0)\nverbose: Show trials simulation progress bar? (default = true)\n\nOutputs\n\nTrials struct of simulated phenotype data\nVector of SimulatedEffects each corresponding to each trait-year-season-harvest-site-replication combination\n\nExamples\n\njulia> genomes::Genomes = simulategenomes(n=100, l=2_000, n_alleles=3, verbose=false);\n\njulia> trials::Trials, vector_of_effects::Array{SimulatedEffects,1} = simulatetrials(genomes=genomes, sparsity=0.25, verbose=false);\n\njulia> size(trials.phenotypes)\n(12800, 3)\n\njulia> size(trials.traits)\n(3,)\n\njulia> unique(trials.entries) == genomes.entries\ntrue\n\njulia> unique(trials.populations) == unique(genomes.populations)\ntrue\n\njulia> abs(mean(ismissing.(trials.phenotypes)) - 0.25) < 0.00001\ntrue\n\n\n\n\n\n","category":"method"},{"location":"#GBCore.slice-Tuple{Genomes}","page":"Home","title":"GBCore.slice","text":"slice(genomes::Genomes;idx_entries::Vector{Int64},idx_loci_alleles::Vector{Int64})::Genomes\n\nSlice a Genomes struct by specifing indixes of entries and loci-allele combinations\n\nExamples\n\njulia> genomes = simulategenomes(n=100, l=1_000, n_alleles=4, verbose=false);\n\njulia> sliced_genomes = slice(genomes, idx_entries=collect(1:10); idx_loci_alleles=collect(1:300));\n\njulia> dimensions(sliced_genomes)\nDict{String, Int64} with 6 entries:\n  \"n_entries\"      => 10\n  \"n_chr\"          => 1\n  \"n_loci\"         => 100\n  \"n_loci_alleles\" => 300\n  \"n_populations\"  => 1\n  \"max_n_alleles\"  => 4\n\n\n\n\n\n","category":"method"}]
}
