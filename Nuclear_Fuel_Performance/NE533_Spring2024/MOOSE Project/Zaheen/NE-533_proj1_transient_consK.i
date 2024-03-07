[Mesh]
    [rod]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 1000
      ny = 1000
      xmin = 0
      xmax = 0.605
      ymin = 0
      ymax = 1
    []
    [fuelandgap]
        input = rod
        type = SubdomainBoundingBoxGenerator
        block_id = 1
        bottom_left = '0 0 0'
        top_right = '0.5050 1.0000 0'
    []
    [fuel]
        input = fuelandgap
        type = SubdomainBoundingBoxGenerator
        block_id = 2
        bottom_left = '0 0 0'
        top_right = '0.5000 1.0000 0'
    []
    coord_type = RZ
    
[]
  
[Variables]
    [temp]
        initial_condition = 550
      
    []
[]
  
[Functions]
    [lhr]
        type = ParsedFunction
        expression = (250*exp(-((t-20)^2)/10)+150)/(pi*(0.5)^2)
    []
    
[]
  
[Kernels]
    [diff]
      type = HeatConduction
      variable = temp
      block = '0 1 2'
    
    []
    [source]
      type = HeatSource
      variable = temp
      function = lhr
      block = 2
    []
    [timeder]
        type = SpecificHeatConductionTimeDerivative
        variable = temp
        specific_heat = specific_heat
        density = density
        block = '0 1 2'

    []
[]
  
[BCs]
    [left]
      type = NeumannBC
      variable = temp
      boundary = left
      value = 0

    []
    [right]
      type = DirichletBC
      variable = temp
      boundary = right
      value = 550
    []
[]
  
[Materials]
    [uotwo]
        type = HeatConductionMaterial
        block = 2
        thermal_conductivity = 0.03
        specific_heat = 0.33
    []
    [helium]
        type = HeatConductionMaterial
        block = 1
        thermal_conductivity = 0.002556
        specific_heat = 5.188
    []
    [zirc]
        type = HeatConductionMaterial
        block = 0
        thermal_conductivity = 0.17
        specific_heat = 0.35
    []
    [uod]
        type = GenericConstantMaterial
        block = 2
        prop_names =  'density'
        prop_values = '10.98' 
    []
    [hed]
        type = GenericConstantMaterial
        block = 1
        prop_names =  'density'
        prop_values = '0.178e-3' 
    []
    [claddd]
        type = GenericConstantMaterial
        block = 0
        prop_names =  'density'
        prop_values = '6.5' 
    []
[]
[Postprocessors]
    [centerline_temperature]
        type = SideExtremeValue
        variable = temp
        boundary = left
    []
[]
   
  
[Problem]
    type = FEProblem
  
[]
  
[Executioner]
    type = Transient
    start_time = 0
    dt = 1
    end_time = 100
    solve_type = 'NEWTON'
    nl_rel_tol = 1e-10
    nl_abs_tol = 1e-10
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
[]
  
[Outputs]
    exodus = true
[]