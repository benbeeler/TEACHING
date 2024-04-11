[Mesh]
    [rod]
      type = GeneratedMeshGenerator
      dim = 2
      nx = 125
      ny = 125
      xmin = 0
      xmax = 0.605
      ymin = 0
      ymax = 100
    []
    [fuelandgap]
        input = rod
        type = SubdomainBoundingBoxGenerator
        block_id = 1
        bottom_left = '0 0 0'
        top_right = '0.5050 100.0 0'
    []
    [fuel]
        input = fuelandgap
        type = SubdomainBoundingBoxGenerator
        block_id = 2
        bottom_left = '0 0 0'
        top_right = '0.5000 100.0 0'
    []
    [fuelboundary]
        type = SideSetsBetweenSubdomainsGenerator
        input = fuel
        #bottom_left = '0 0 0'
        #top_right = '0.5000 1.000 0'
        primary_block = 2
        paired_block = 1
        new_boundary = 'fuel_face'
    []
    [cladboundary]
        type = SideSetsBetweenSubdomainsGenerator
        input = fuelboundary
        #bottom_left = '0 0 0'
        #top_right = '0.5000 1.000 0'
        primary_block = 0
        paired_block = 1
        new_boundary = 'clad_face'
    []
    [final_mesh]
        type = BlockDeletionGenerator
        input = cladboundary
        block = 1
    []   
    coord_type = RZ
    
[]
  
[Variables]
    [temp]
      
    []
[]
  
[Functions]
    [lhr]
        type = ParsedFunction
        expression = (350*cos(1.2*((y/50)-1)))/(pi*(0.5)^2)  
    []
    [Tcool]
        type = ParsedFunction
        expression = 500+69.4444*(sin(1.2)+sin(1.2*((y/50)-1)))
    []
    
[]
[ThermalContact]
    [pellet_gap]
      type = GapHeatTransfer
      #gap_geometry_type = 'RZ'
      emissivity_primary = 0
      emissivity_secondary = 0
      variable = temp
      primary = 'fuel_face'
      secondary = 'clad_face'
      gap_conductivity = 0.002556
      quadrature = true
      #cylinder_axis_point_1 = '0 0 0'
      #cylinder_axis_point_2 = '0 0 5'
    []
  []
  
[Kernels]
    [diff]
      type = HeatConduction
      variable = temp
      block = '0 2'
    []
    [source]
      type = HeatSource
      variable = temp
      function = lhr
      block = 2
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
      type = FunctionDirichletBC
      variable = temp
      boundary = right
      function = Tcool
    []
[]
  
[Materials]
    [uotwo]
        type = HeatConductionMaterial
        block = 2
        temp = temp
        thermal_conductivity_temperature_function = '(1/(3.8+0.0217*t))'
        specific_heat = 0.33
    []
    #[helium]
        #type = HeatConductionMaterial
        #block = 1
        #temp = temp
        #min_T = 615
        #thermal_conductivity_temperature_function = 'if(t<600,0.0025,16e-6*(t^0.79))'
        #specific_heat = 5.188
    #[]
    [zirc]
        type = HeatConductionMaterial
        block = 0
        thermal_conductivity = 0.17
        specific_heat = 0.35
    []
[]

  
[Problem]
    type = FEProblem
  
[]
#[Preconditioning]
    #[smp]
      # this block is part of what is being tested, see "tests" file
      #type = SMP
      #full = true
    #[]
#[]
  
[Executioner]
    type = Steady
    solve_type = 'NEWTON'
    petsc_options_iname = '-pc_type -pc_hypre_type'
    petsc_options_value = 'hypre boomeramg'
    automatic_scaling = true

[]
  
[Outputs]
    exodus = true
[]
#if(t<323,0.102,1/(3.8+0.0217*t))