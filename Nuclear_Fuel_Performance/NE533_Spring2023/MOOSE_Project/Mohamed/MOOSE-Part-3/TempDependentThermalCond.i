[GlobalParams]
    displacements = 'disp_r disp_z'
[]   

[Mesh]
    [fuel]
        type = GeneratedMeshGenerator
        dim = 2
        nx = 20
        ny = 20
        ymin = 0
        xmin = 0
        xmax = 0.5 
        ymax = 100.
    []  
    [fuel_block]
        type = SubdomainBoundingBoxGenerator
        input = fuel
        bottom_left = '0 0 0'
        top_right = '0.5 100. 0'
        block_id = 1
    []
    [pin]
        type = ExtraNodesetGenerator
        input = fuel_block
        new_boundary = pin
        coord = '0 0 0'
    []
    coord_type = RZ
    rz_coord_axis = Y
    final_generator = pin
[]

[Variables]
    [T]
        initial_condition = 650
    []
[]

[Kernels]
    [heat_conduction]
        type = AnisoHeatConduction
        variable = T  
    []
    [heat_source]
        type = HeatSource
        variable = T
        function = Q 
    []
    [time_derivative]
        type = HeatConductionTimeDerivative
        variable = T
    []   
[]

[Functions]
    [Q]
        type = ParsedFunction
        expression = 'L0*cos(A*(y/Z0-1))/(pi*0.5^2)'
        symbol_names  = 'L0   Z0  A'
        symbol_values = '350. 50. 1.208305' 
    []
[]

[BCs]
    [fuel_surface]
        type = DirichletBC
        variable = T
        boundary = right 
        value = 650
    []
    [centerline]
        type = NeumannBC
        variable = T
        boundary = left
        value = 0
    []
    [disp_r_BC]
        type = DirichletBC
        variable = disp_r
        boundary = pin 
        value = 0
    []
    [disp_z_BC]
        type = DirichletBC
        variable = disp_z
        boundary = bottom
        value = 0
    []
[]

[Modules/TensorMechanics/Master]
    [all]
        add_variables = true
        strain = FINITE
        eigenstrain_names = thermal_expansion
        incremental = true
        automatic_eigenstrain_names = true
        generate_output = 'vonmises_stress'
    []
[]

[AuxVariables]
    [stress_xx]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_xy]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_xz]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_yy]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_yz]
        order = CONSTANT
        family = MONOMIAL
    []
    [stress_zz]
        order = CONSTANT
        family = MONOMIAL
    []
[]

[AuxKernels]
    [stress_xx]
        type = RankTwoAux
        rank_two_tensor = stress
        variable = stress_xx
        index_i = 0
        index_j = 0
    []
    [stress_xy]
        type = RankTwoAux
        rank_two_tensor = stress
        variable = stress_xy
        index_i = 0
        index_j = 1
    []
    [stress_xz]
        type = RankTwoAux
        rank_two_tensor = stress
        variable = stress_xz
        index_i = 0
        index_j = 2
    []
    [stress_yy]
        type = RankTwoAux
        rank_two_tensor = stress
        variable = stress_yy
        index_i = 1
        index_j = 1
    []
    [stress_yz]
        type = RankTwoAux
        rank_two_tensor = stress
        variable = stress_yz
        index_i = 1
        index_j = 2
    []
    [stress_zz]
        type = RankTwoAux
        rank_two_tensor = stress
        variable = stress_zz
        index_i = 2
        index_j = 2
    []
[] 

[Materials]
    [fuel]
        type = AnisoHeatConductionMaterial
        specific_heat = 0.33
        thermal_conductivity = '0.07298 0 0 0 0.07298 0 0 0 0.07298'
        thermal_conductivity_temperature_coefficient_function = -0.000438
        reference_temperature = 0.
        temperature = T
    []
    [fuel_density]
        type = GenericConstantMaterial
        prop_names = 'density'
        prop_values = 10.98                
    []
    [elasticity]
        type = ComputeIsotropicElasticityTensor
        youngs_modulus = 250e9
        poissons_ratio = 0.32
    []
    [expansion]
        type = ComputeThermalExpansionEigenstrain
        temperature = T
        thermal_expansion_coeff = 10.471e-6
        stress_free_temperature = 300
        eigenstrain_name = thermal_expansion
    []
    [stress]
        type = ComputeFiniteStrainElasticStress
    []
[]

[Preconditioning]
    [smp]
        type = SMP
        full = true
    []
[]

[Executioner]
    type = Transient
    solve_type = PJFNK
    end_time = 50
    automatic_scaling = true
    compute_scaling_once = false
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
    [TimeStepper]
        type = SolutionTimeAdaptiveDT
        dt = 1
    []
[]

[VectorPostprocessors]
    [TLineSampler25]
        type = LineValueSampler
        variable = T
        start_point = '0.  25. 0.'
        end_point =   '0.5 25. 0.'
        num_points = 20
        sort_by = x
    []
    [TLineSampler50]
        type = LineValueSampler
        variable = T
        start_point = '0.  50. 0.'
        end_point =   '0.5 50. 0.'
        num_points = 20
        sort_by = x
    []
    [TLineSampler100]
        type = LineValueSampler
        variable = T
        start_point = '0.  100. 0.'
        end_point =   '0.5 100. 0.'
        num_points = 20
        sort_by = x
    []
    [TNodalSamplerCL]
        type = NodalValueSampler
        variable = T
        sort_by = y
        boundary = 'left' 
    []
    [SxxLineSampler25]
        type = LineValueSampler
        variable = stress_xx
        start_point = '0.  25. 0.'
        end_point =   '0.5 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SxxLineSampler50]
        type = LineValueSampler
        variable = stress_xx
        start_point = '0.  50. 0.'
        end_point =   '0.5 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SxxLineSampler100]
        type = LineValueSampler
        variable = stress_xx
        start_point = '0.  100. 0.'
        end_point =   '0.5 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SxyLineSampler25]
        type = LineValueSampler
        variable = stress_xy
        start_point = '0.  25. 0.'
        end_point =   '0.5 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SxyLineSampler50]
        type = LineValueSampler
        variable = stress_xy
        start_point = '0.  50. 0.'
        end_point =   '0.5 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SxyLineSampler100]
        type = LineValueSampler
        variable = stress_xy
        start_point = '0.  100. 0.'
        end_point =   '0.5 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SxzLineSampler25]
        type = LineValueSampler
        variable = stress_xz
        start_point = '0.  25. 0.'
        end_point =   '0.5 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SxzLineSampler50]
        type = LineValueSampler
        variable = stress_xz
        start_point = '0.  50. 0.'
        end_point =   '0.5 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SxzLineSampler100]
        type = LineValueSampler
        variable = stress_xz
        start_point = '0.  100. 0.'
        end_point =   '0.5 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SyyLineSampler25]
        type = LineValueSampler
        variable = stress_yy
        start_point = '0.  25. 0.'
        end_point =   '0.5 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SyyLineSampler50]
        type = LineValueSampler
        variable = stress_yy
        start_point = '0.  50. 0.'
        end_point =   '0.5 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SyyLineSampler100]
        type = LineValueSampler
        variable = stress_yy
        start_point = '0.  100. 0.'
        end_point =   '0.5 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SyzLineSampler25]
        type = LineValueSampler
        variable = stress_yz
        start_point = '0.  25. 0.'
        end_point =   '0.5 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SyzLineSampler50]
        type = LineValueSampler
        variable = stress_yz
        start_point = '0.  50. 0.'
        end_point =   '0.5 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SyzLineSampler100]
        type = LineValueSampler
        variable = stress_yz
        start_point = '0.  100. 0.'
        end_point =   '0.5 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SzzLineSampler25]
        type = LineValueSampler
        variable = stress_zz
        start_point = '0.  25. 0.'
        end_point =   '0.5 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SzzLineSampler50]
        type = LineValueSampler
        variable = stress_zz
        start_point = '0.  50. 0.'
        end_point =   '0.5 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SzzLineSampler100]
        type = LineValueSampler
        variable = stress_zz
        start_point = '0.  100. 0.'
        end_point =   '0.5 100. 0.'
        num_points = 20
        sort_by = x
    []    
[]    

[Outputs]
    exodus = true
    [csv]
        type = CSV
        execute_on = 'final'
    []
[]


