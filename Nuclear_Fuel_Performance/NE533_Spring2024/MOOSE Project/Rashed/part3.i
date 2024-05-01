[GlobalParams]
    displacements = 'disp_r disp_z'
[]   

[Mesh] 
   [gen]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 200
      xmin = 0
      xmax = 0.605
      ny = 10
      ymin = 0
      ymax = 100
   []
   [subdomain1]
      input = gen
      type = SubdomainBoundingBoxGenerator
      bottom_left = '0 0 0'
      top_right = '0.5050 100.0 0'
      block_id = 1
   []
   [subdomain2] 
      input = subdomain1
      type = SubdomainBoundingBoxGenerator
      bottom_left = '0 0 0'
      top_right = '0.5000 100.0 0'
      block_id = 2
   []
   [fuel_sideset]
      type = SideSetsBetweenSubdomainsGenerator
      input = subdomain2
      primary_block = 2
      paired_block = 1
      new_boundary = 'fuel_with_gap'
   []
   [clad_sideset]
      type = SideSetsBetweenSubdomainsGenerator
      input = fuel_sideset
      primary_block = 0
      paired_block = 1
      new_boundary = 'clad_with_gap'
   []
   [part2_geom]
      type = BlockDeletionGenerator
      input = clad_sideset
      block = 1
   []
   coord_type = RZ
   rz_coord_axis = Y
[]

[Variables]
   [temp]
   []
[]

[Materials]
   [fuel]
      type = HeatConductionMaterial
      temp = temp
      block = '2'
      thermal_conductivity_temperature_function = '(1/(3.8+0.0217*t))'
      specific_heat = 0.28
   []

   [fuel_density]
      type = GenericConstantMaterial
      prop_names = 'density'
      prop_values = 10.98      
      block = '2'          
   []
   [fuel_elasticity]
      type = ComputeIsotropicElasticityTensor
      youngs_modulus = 250e9
      poissons_ratio = 0.32
      block = '2'
   []
   [fuel_expansion]
      type = ComputeThermalExpansionEigenstrain
      temperature = temp
      thermal_expansion_coeff = 10.471e-6
      stress_free_temperature = 300
      eigenstrain_name = thermal_expansion
      block = '2'
   []
   [fuel_stress]
      type = ComputeFiniteStrainElasticStress
      block = '2'
   []

   [clad]
      type = HeatConductionMaterial
      thermal_conductivity = .1700 #W/cm-K
      specific_heat = 0.35
      block = '0'
   []

   [clad_stress] 
      type = ComputeFiniteStrainElasticStress
      block = '0'
   [] 

   [clad_density] 
      type = GenericConstantMaterial
      prop_names = 'density'
      prop_values = 6.56      
      block = '0' 
   []

   [clad_elasticity]
       type = ComputeIsotropicElasticityTensor
       youngs_modulus = 99.3e9
       poissons_ratio = 0.37
       block = '0'
   []

   [clad_expansion]
       type = ComputeThermalExpansionEigenstrain
       temperature = temp
       thermal_expansion_coeff = 6e-6
       stress_free_temperature = 300
       eigenstrain_name = thermal_expansion
       block = '0'
   []
[]



[Problem]
  type = FEProblem
[]

[Preconditioning]
    [smp]
        type = SMP
        full = true
    []
[]


[Kernels]
   [heat_source]
     type = HeatSource
     function = LHR
     variable = temp
     block = '2'
   []
   [conduction]
     type = HeatConduction
     variable = temp
     block= '0 2'
   []
   [time_derivative]
       type = HeatConductionTimeDerivative
       variable = temp
       block = '0 2'
   []   
[]

[Functions]
   [LHR]
      type = ParsedFunction
      expression = (350*cos(1.2*((y/50)-1)))/(pi*(0.5)^2)
   []
   [coolant_temp]
      type = ParsedFunction ## Tco = Tcool + delta(Tco-Tcool)
      expression = (1/1.2)*(350*50)/(4200*0.1)*(sin(1.2)+sin(1.2*(y/50-1)))+500+350*cos(1.2*(y/50-1))/(2*3.14159*0.5*2.65) 
   []
[]

[Contact]
    [gap]
       primary = fuel_with_gap
       secondary = clad_with_gap
       model = frictionless
       formulation = mortar
    []
[]   
 
[ThermalContact]
   [gap_contact]
     type = GapHeatTransfer
     emissivity_primary = 0.4
     emissivity_secondary = 0.4
     variable = temp
     primary = 'fuel_with_gap'
     secondary = 'clad_with_gap'
     gap_conductivity = 0.0026
     gap_geometry_type = 'CYLINDER'
     quadrature = true
   []
[]
  


[BCs]
   [cl_temp]
     type = NeumannBC
     variable = temp
     boundary = left
     value = 0 
   []
   [fuel_surf_temp]
     type = FunctionDirichletBC
     variable = temp
     boundary = fuel_with_gap
     function = coolant_temp
   []
   [disp_r_BC]
      type = DirichletBC
      variable = disp_r
      boundary = bottom 
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
       eigenstrain_names = thermal
       generate_output = 'vonmises_stress'
       volumetric_locking_connection = true
       temperature = temp
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
        dt = 5
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
        end_point =   '0.605 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SxxLineSampler50]
        type = LineValueSampler
        variable = stress_xx
        start_point = '0.  50. 0.'
        end_point =   '0.605 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SxxLineSampler100]
        type = LineValueSampler
        variable = stress_xx
        start_point = '0.  100. 0.'
        end_point =   '0.605 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SxyLineSampler25]
        type = LineValueSampler
        variable = stress_xy
        start_point = '0.  25. 0.'
        end_point =   '0.605 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SxyLineSampler50]
        type = LineValueSampler
        variable = stress_xy
        start_point = '0.  50. 0.'
        end_point =   '0.605 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SxyLineSampler100]
        type = LineValueSampler
        variable = stress_xy
        start_point = '0.  100. 0.'
        end_point =   '0.5=605 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SxzLineSampler25]
        type = LineValueSampler
        variable = stress_xz
        start_point = '0.  25. 0.'
        end_point =   '0.605 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SxzLineSampler50]
        type = LineValueSampler
        variable = stress_xz
        start_point = '0.  50. 0.'
        end_point =   '0.605 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SxzLineSampler100]
        type = LineValueSampler
        variable = stress_xz
        start_point = '0.  100. 0.'
        end_point =   '0.605 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SyyLineSampler25]
        type = LineValueSampler
        variable = stress_yy
        start_point = '0.  25. 0.'
        end_point =   '0.605 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SyyLineSampler50]
        type = LineValueSampler
        variable = stress_yy
        start_point = '0.  50. 0.'
        end_point =   '0.605 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SyyLineSampler100]
        type = LineValueSampler
        variable = stress_yy
        start_point = '0.  100. 0.'
        end_point =   '0.605 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SyzLineSampler25]
        type = LineValueSampler
        variable = stress_yz
        start_point = '0.  25. 0.'
        end_point =   '0.605 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SyzLineSampler50]
        type = LineValueSampler
        variable = stress_yz
        start_point = '0.  50. 0.'
        end_point =   '0.605 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SyzLineSampler100]
        type = LineValueSampler
        variable = stress_yz
        start_point = '0.  100. 0.'
        end_point =   '0.605 100. 0.'
        num_points = 20
        sort_by = x
    []
    [SzzLineSampler25]
        type = LineValueSampler
        variable = stress_zz
        start_point = '0.  25. 0.'
        end_point =   '0.605 25. 0.'
        num_points = 20
        sort_by = x
    []
    [SzzLineSampler50]
        type = LineValueSampler
        variable = stress_zz
        start_point = '0.  50. 0.'
        end_point =   '0.605 50. 0.'
        num_points = 20
        sort_by = x
    []
    [SzzLineSampler100]
        type = LineValueSampler
        variable = stress_zz
        start_point = '0.  100. 0.'
        end_point =   '0.605 100. 0.'
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