
[Mesh]
#Mesh generation generates each block with subdivisions, stitches together with stitched mesh
#generator then uses subdomain generator to rename blocks with 1=fuel 2=gap 3=clad
 [right]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0
  xmax = 0.5
  ymin = 0.0
  ymax = 100
  nx = 34
  ny = ${ny}
 []
 [middle]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0.5
  xmax = 0.505
  ymin = 0.0
  ymax = 100
  nx = 34
  ny = ${ny}
 []
 [left]
  type = GeneratedMeshGenerator
  dim = 2
  xmin = 0.505
  xmax = 0.605
  ymin = 0.0
  ymax = 100
  nx = 34
  ny = ${ny}
 []
 [cmbn]
  type = StitchedMeshGenerator
  inputs = 'right middle left'
  show_info = True
  stitch_boundaries_pairs = 'right left;
  right left; right left'
 []
 [fuel] 
   type = SubdomainBoundingBoxGenerator
   input = cmbn
   block_id = 1
   bottom_left = '0.0 0.0 0.0'
   top_right = '0.5 100 0.0'
 []
 [gap]
   type = SubdomainBoundingBoxGenerator
   input = fuel
   block_id = 2
   bottom_left = '0.5 0.0 0.0'
   top_right = '0.505 100 0.0'
 []
 [clad] 
   type = SubdomainBoundingBoxGenerator
   input = gap 
   block_id = 3
   bottom_left = '0.505 0.0 0.0'
   top_right = '0.605 100 0.0'
 []
 coord_type = 'RZ'
[]
#Define variables
[Variables]
        [./T]
                order = FIRST
                family = LAGRANGE        
        [../]
[]
#AuxVariables to track thermal conductivity
[AuxVariables]
  [./T_cool]
    order = FIRST
    family = LAGRANGE
  [../]
  [./fuel_k]
    order = CONSTANT  # Conductivity is a material property
    family = MONOMIAL
  [../]
  
  [./gap_k]
    order = CONSTANT
    family = MONOMIAL
  [../]

  [./clad_k]
    order = CONSTANT
    family = MONOMIAL
  [../]
[]
#Define temperature dependent k functions
[Functions]
    [./q_func]
        type = ParsedFunction
        expression = '(350*cos(1.2*(y/50-1)))/(0.25*pi)'
    [../]
    [./fuel_k_func]
        type = ParsedFunction
        expression = "1/(2*(1.48+0.04*max(x,300)))"  # OECD UO₂ model in W/cm·K
    [../]
    [./T_cool_func]
      type = ParsedFunction
      expression = "500+1/1.2*50*350/(.085*4180)*(sin(1.2)+sin(1.2*((y/50)-1)))"
      #specific heat of 5000 J/kgK, and mdot of 0.07 kg/cms
    [../]
    [./gap_k_func]
        type = ParsedFunction
        expression = "0.0025+0.00002*x"  # Approximate helium gas k(T)
    [../]

    [./clad_k_func]
        type = ParsedFunction
        expression = "0.18-0.00002*x"  # Zircaloy-4 k(T)
    [../]
[]
#Define materials
[Materials]
        [./fuel]
                type = HeatConductionMaterial
                block = 1
                temp = T
                thermal_conductivity_temperature_function = fuel_k_func
                specific_heat = 296.7
        [../]
        [./fuel_rho]
                type = GenericConstantMaterial
                block = 1
                prop_names = 'density'
                prop_values = 0.01097
        [../]
        [./gap]
                type = HeatConductionMaterial
                block = 2 
                temp = T
                thermal_conductivity_temperature_function = gap_k_func
                specific_heat = 5190
        [../]
        [./gap_rho]
                type = GenericConstantMaterial
                block = 2
                prop_names = 'density'
                prop_values = 0.000000164
        [../]
        [./clad]
                type = HeatConductionMaterial
                block = 3
                temp = T
                thermal_conductivity_temperature_function = clad_k_func
                specific_heat = 285
        [../]
        [./clad_rho]
                type = GenericConstantMaterial
                block = 3
                prop_names = 'density'
                prop_values = 0.00656
        [../]  
        [./coolant_temp]
                type = GenericFunctionMaterial
                prop_names = 'T_cool'
                prop_values = 'T_cool_func'
                boundary = right        # Apply to outer boundary
        [../]
[]

#Define Kernels
[Kernels]
        #add in kernels here
        [./heat_conduction]
                type = HeatConduction
                variable = T
        [../]
        #[./time_derivative]
        #        type = HeatConductionTimeDerivative
        #        variable = T
        #[../]
        [./heat_source]
                type = HeatSource
                variable = T
                block = 1
                function = q_func
        [../]
[]
#AuxKernels to track thermal conductivity
[AuxKernels]
  [./fuel_k_output]
    type = MaterialRealAux
    variable = fuel_k
    property = thermal_conductivity
    block = 1
  [../]
  [./gap_k_output]
    type = MaterialRealAux
    variable = gap_k
    property = thermal_conductivity
    block = 2
  [../]

  [./clad_k_output]
    type = MaterialRealAux
    variable = clad_k
    property = thermal_conductivity
    block = 3 
  [../]
[]
#Define IC to avoid divide by zero in temp function
[ICs]
  [./initial_temperature]
    type = ConstantIC
    variable = T  # ✅ Ensure this matches your temperature variable name
    value = 300   # ✅ Set a safe starting temperature
  [../]
[]

#Define BCs
[BCs]
        [./convective_cooling]
            type = ConvectiveHeatFluxBC
            variable = T
            boundary = right  # Outer surface of fuel rod
            T_infinity = T_cool  # Bulk coolant temperature (K)
            heat_transfer_coefficient = 3  # 30,000 W/m^2-K,
        [../]
        [./centerline_flux]
                type = NeumannBC
                variable = T
                boundary = left
                value = 0
        [../]
        #add in boundary conditions here
[]

#Choose executioner and parameters
[Executioner]
  type = Steady # Here we use the Transient Executioner (instead of steady)
  solve_type = 'PJFNK'
  # solve_type = 'NEWTON'
  [./TimeIntegrator]
    type = ImplicitEuler
    # type = BDF2
    # type = CrankNicolson
    # type = ImplicitMidpoint
    # type = LStableDirk2
    # type = LStableDirk3
    # type = LStableDirk4
    # type = AStableDirk4
    #
    # Explicit methods
    # type = ExplicitEuler
    # type = ExplicitMidpoint
    # type = Heun
    # type = Ralston
  [../]
  #num_steps = 150 # Run for 75 time steps, solving the system each step.
  #dt = .1 # each time step will have duration "1"
  #end_time = 15
  nl_max_its = 20
  nl_abs_tol = 1e-6
  nl_rel_tol = 1e-4
[]
#Outputs
[VectorPostprocessors]
  [./T_line_x0]
    type = LineValueSampler
    variable = T
    start_point = '0.0 0.0 0.0'
    end_point = '0.0 100.0 0.0'
    num_points = 1000
    sort_by = y
    execute_on = 'final'
  [../]

  [./T_line_x05]
    type = LineValueSampler
    variable = T
    start_point = '0.5 0.0 0.0'
    end_point = '0.5 100.0 0.0'
    num_points = 1000
    sort_by = y
    execute_on = 'final'
  [../]

  [./T_line_x0505]
    type = LineValueSampler
    variable = T
    start_point = '0.505 0.0 0.0'
    end_point = '0.505 100.0 0.0'
    num_points = 1000
    sort_by = y
    execute_on = 'final'
  [../]

  [./T_line_x0605]
    type = LineValueSampler
    variable = T
    start_point = '0.605 0.0 0.0'
    end_point = '0.605 100.0 0.0'
    num_points = 1000
    sort_by = y
    execute_on = 'final'
  [../]
[]

[Outputs]
    #[./exodus]
    #    type = Exodus
    #    time_step_interval = 1             # Output at every time step
    #    show = 'T'     # Ensure temperature is written to the file
    #[../]
#    [./exodus]
#      type = Exodus
#      file_base = ny${ny}.e
#      show = 'T'  # ✅ Ensure k(T) variables are listed
#      execute_on = 'final'
#    [../]
  [./csv]
    type = CSV
    file_base = ny${ny}_line
    precision = 6
    delimiter = ','
    execute_on = 'final'
    show = 'T_line_x0 T_line_x05 T_line_x0505 T_line_x0605'
  [../]
[]

