
[Mesh]
#Mesh generation generates each block with subdivisions, stitches together with stitched mesh
#generator then uses subdomain generator to rename blocks with 1=fuel 2=gap 3=clad
[right]
 type = GeneratedMeshGenerator
 dim = 2
 xmin = 0
 xmax = 0.5
 ymin = 0.0
 ymax = 0.1
 nx = 34
 ny = 3
[]
[middle]
 type = GeneratedMeshGenerator
 dim = 2
 xmin = 0.5
 xmax = 0.505
 ymin = 0.0
 ymax = 0.1
 nx = 34
 ny = 3
[]
[left]
 type = GeneratedMeshGenerator
 dim = 2
 xmin = 0.505
 xmax = 0.605
 ymin = 0.0
 ymax = 0.1
 nx = 34
 ny = 3
[]
#Combine blocks
[cmbn]
 type = StitchedMeshGenerator
 inputs = 'right middle left'
 show_info = True
 stitch_boundaries_pairs = 'right left;
 right left; right left'
[]
#Define blocks
[fuel] 
  type = SubdomainBoundingBoxGenerator
  input = cmbn
  block_id = 1
  bottom_left = '0.0 0.0 0.0'
  top_right = '0.5 0.1 0.0'
[]
[gap]
  type = SubdomainBoundingBoxGenerator
  input = fuel
  block_id = 2
  bottom_left = '0.5 0.0 0.0'
  top_right = '0.505 0.1 0.0'
[]
[clad] 
  type = SubdomainBoundingBoxGenerator
  input = gap 
  block_id = 3
  bottom_left = '0.505 0.0 0.0'
  top_right = '0.605 0.1 0.0'
[]
coord_type = 'RZ'
[]
#Define materials
[Materials]
        [./fuel]
                type = HeatConductionMaterial
                block = 1
                thermal_conductivity = .03
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
                thermal_conductivity = 0.004
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
                thermal_conductivity = .18
                specific_heat = 2850
        [../]
        [./clad_rho]
                type = GenericConstantMaterial
                block = 3
                prop_names = 'density'
                prop_values = 0.00656
        [../]

[]
#Define volumetric heat generation rate
[Functions]
    [./q_func]
        type = ParsedFunction
        expression = '(350*exp(-((t-20)^2)/2)+350)/(0.25*pi)'
    [../]
[]
#Define variables
[Variables]
        [./temp]
                order = FIRST
                family = LAGRANGE        
        [../]
[]
#Define Kernels
[Kernels]
        #add in kernels here
        [./heat_conduction]
                type = HeatConduction
                variable = temp
        [../]
        [./time_derivative]
                type = HeatConductionTimeDerivative
                variable = temp
        [../]
        [./heat_source]
                type = HeatSource
                variable = temp
                block = 1
                function = q_func
        [../]
[]
#Define BCs
[BCs]
        [./fixed_temp]
                type = DirichletBC
                variable = temp
                boundary = right
                value = 550
        [../]
        [./centerline_flux]
                type = NeumannBC
                variable = temp
                boundary = left
                value = 0
        [../]
[]
#Choose executioner and parameters
[Executioner]
  type = Transient
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
  num_steps = 1000 # Run for 75 time steps, solving the system each step.
  dt = .1 # each time step will have duration "1"
  end_time = 100
  nl_max_its = 20
  nl_abs_tol = 1e-6
  nl_rel_tol = 1e-4
[]
[Outputs]
    [./exodus]
        type = Exodus
        interval = 1             # Output at every time step
        show = 'temp'     # Ensure temperature is written to the file
    [../]
[]

