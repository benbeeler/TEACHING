[GlobalParams]
    displacements = 'disp_r disp_z'
[]

[Mesh]
    [pellet]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 35
        ny = 3
        xmax = 0.5
        ymax = 1
        #block_name = 'pellet'
    []
    [pellet_id]
        type = SubdomainIDGenerator
        input = pellet
        subdomain_id = 1
    []
    [gap]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 5
        ny = 3
        xmin = 0.5
        xmax = 0.505
        ymax = 1
        #block_name = 'gap'
    []
    [gap_id]
        type = SubdomainIDGenerator
        input = gap
        subdomain_id = 2
    []
    [clad]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 10
        ny = 3
        xmin = 0.505
        xmax = 0.605
        ymax = 1
        #block_name = 'clad'
    []
    [clad_id]
        type = SubdomainIDGenerator
        input = clad
        subdomain_id = 3
    []
    [system]
        type = StitchedMeshGenerator
        inputs = 'pellet_id gap_id clad_id'
        stitch_boundaries_pairs = 'right left; right left'
        prevent_boundary_ids_overlap = false
    []
    coord_type = RZ                 # Axisymmetric RZ
    rz_coord_axis = Y              # Which axis the symmetry is around
[]

[Variables]
    [T]
        initial_condition = 500 #(K)
    []
[]

[Physics/SolidMechanics/QuasiStatic]
    [all]
        #This block adds all of the proper Kernels, strain calculators, and Variables
        #for SolidMechanics in the correct coordinate system (autodetected)
        add_variables = true
        strain = FINITE
        eigenstrain_names = 'thermal_expansion volumetric_eigenstrain'
        use_automatic_differentiation = false
        displacements = 'disp_r disp_z'
        temperature = T
        generate_output = 'vonmises_stress'
    []
[]

[Functions]
    [Burnup]
        type = ParsedFunction
        symbol_names = 'F Nu'
        symbol_values = '2.5e13 2.45e22'
        expression = '(F*t)/Nu' #FIMA
    []
[]

[Kernels]
    [heat_conduction]
        type = HeatConduction
        variable = T
    []
    [time_derivative]
        type = HeatConductionTimeDerivative
        variable = T
    []
    [heat_source]
        type = HeatSource
        variable = T
        function = '((350)/(pi*(0.5^2)))' #W/cm3
        block = 1 #pellet
    []
[]

[BCs]
    [grad_left]
        type = NeumannBC
        variable = T
        boundary = left
        value = 0 #(K/cm)
    []
    [temp_right]
        type = DirichletBC
        variable = T
        boundary = right
        value = 500 #(K)
    []
    [hold_bottom]
        type = DirichletBC
        variable = disp_z
        boundary = bottom
        value = 0
    []
    [hold_top]
        type = DirichletBC
        variable = disp_z
        boundary = top
        value = 0
    []
    [hold_center]
        type = DirichletBC
        variable = disp_r
        boundary = left
        value = 0
    []
[]

[Materials]
    [pellet_k]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        functor_names = Burnup
        functor_symbols = 'B'
        expression = '1/((3.8 + (200*B))+(0.0217*T))'
        block = 1 
    []
    [pellet_prop_thermal]
        type = GenericConstantMaterial
        prop_names = 'specific_heat density'
        prop_values = '0.33 10.97' #(J/g*K) (g/cm^3)
        block = 1
    []
    [gap_prop_thermal]
        type = GenericConstantMaterial
        prop_names = 'specific_heat density'
        prop_values = '5.193 0.1785' #(J/g*K) (g/cm^3)
        block = 2
    []
    [gap_k]
        type = ParsedMaterial
        property_name = thermal_conductivity
        coupled_variables = T
        expression = '(16*10^(-6))*(T^0.79)' #W/cm*K
        block = 2 
    []
    [clad_k_prop_thermal]
        type = GenericConstantMaterial
        prop_names = 'thermal_conductivity specific_heat density'
        prop_values = '0.23 0.35 6.511' #(W/cm*K) (J/g*K) (g/cm^3)
        block = 3 
        #all properties are from Lecture 3 for Zr
    []
    [pellet_elasticity]
        type = ComputeIsotropicElasticityTensor
        youngs_modulus = 192.9e9 # (Pa) from NIST
        poissons_ratio = .302 # from NIST
        block = 1
    []
    [pellet_elastic_stress]
        type = ComputeFiniteStrainElasticStress
        block = 1
    []
    [pellet_thermal_expansion]
        type = ComputeThermalExpansionEigenstrain
        stress_free_temperature = 300
        eigenstrain_name = thermal_expansion
        temperature = T
        thermal_expansion_coeff = 1.2e-5 #from NE533
        block = 1
    []
    [pellet_volumetric_eigenstrain]
        type = ComputeVolumetricEigenstrain
        eigenstrain_name = volumetric_eigenstrain
        volumetric_materials = volumetric_change
        block = 1
        args = ''
    []
    [pellet_volumetric_change]
        type = ParsedMaterial
        property_name = volumetric_change
        coupled_variables = T
        functor_names = Burnup
        functor_symbols = 'B'
        block = 1
        expression = '(0.01*exp(((B*log(0.01))/(1*0.005))-1))+((5.577e-2)*10.97*B)+(((1.96e-28)*10.97*B)*((2800-T)^11.73)*(exp(-0.0162*(2800-T)))*(exp(-17.8*10.97*B)))'
    []
    [gap_elasticity]
        type = ComputeIsotropicElasticityTensor
        youngs_modulus = 1e-9 # very low, gas
        poissons_ratio = 0 # n/a
        block = 2
    []
    [gap_elastic_stress]
        type = ComputeFiniteStrainElasticStress
        block = 2
    []
    [gap_thermal_strain]
        type = ComputeThermalExpansionEigenstrain
        stress_free_temperature = 300
        eigenstrain_name = thermal_expansion
        temperature = T
        thermal_expansion_coeff = 0 #n/a
        block = 2
    []
    [gap_volumetric_eigenstrain]
        type = ComputeVolumetricEigenstrain
        eigenstrain_name = volumetric_eigenstrain
        volumetric_materials = 0
        block = 2
        args = ''
    []
    [clad_elasticity]
        type = ComputeIsotropicElasticityTensor
        youngs_modulus = 99.3e9 # AZOM
        poissons_ratio = .37 # AZOM
        block = 3
    []
    [clad_elastic_stress]
        type = ComputeFiniteStrainElasticStress
        block = 3
    []
    [clad_thermal_strain]
        type = ComputeThermalExpansionEigenstrain
        stress_free_temperature = 300
        eigenstrain_name = thermal_expansion
        temperature = T
        thermal_expansion_coeff = 6e-6 # TM modules doesn't support material property, but it will
        block = 3
    []
    [clad_volumetric_eigenstrain]
        type = ComputeVolumetricEigenstrain
        eigenstrain_name = volumetric_eigenstrain
        volumetric_materials = 0
        block = 3
        args = ''
    []
[]

[Problem]
    type = FEProblem  # This is the "normal" type of Finite Element Problem in MOOSE
[]

[Executioner]
    type = Transient      
    solve_type = 'PJFNK'
    start_time = 0.0
    end_time = 3600
    automatic_scaling = true
    dt = 60
    nl_rel_tol = 1e-6 #default = 1e-8
    nl_abs_tol = 1e-6 #default = 1e-50
    l_tol = 1e-4 #default = 1e-5
    l_max_its = 50 #default is 10,000, want to fail faster
    #################################################################
    petsc_options_iname = '-pc_type -pc_hypre_type -pc_hypre_boomeramg_strong_threshold -mat_mffd_err' # PETSc option pairs with values below
    petsc_options_value = 'hypre boomeramg 0.5 1e-6'
    steady_state_detection = true
    steady_state_tolerance = 1e-8 #default is 1e-8
    normalize_solution_diff_norm_by_dt = false
    [TimeStepper]
        type = IterationAdaptiveDT
        optimal_iterations = 1
        linear_iteration_ratio = 100 #default = 25
        reset_dt = true
        dt = 1
    []
[]

[Outputs]
    exodus = true # Output Exodus format
[]



