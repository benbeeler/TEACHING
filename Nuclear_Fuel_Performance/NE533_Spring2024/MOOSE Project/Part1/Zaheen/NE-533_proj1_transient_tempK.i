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
    #[kfunc]
        #type = PiecewiseLinear
        #x = '615 625 635 645 655 665 675 685 695 705 715 725 735 745 755 765 775 785 795 805 815 825 835'
        #y = '0.0025546 0.0025874 0.0026200 0.0026526 0.0026850 0.0027173 0.0027496 0.0027817 0.0028137 0.0028457 0.002877 0.0029092 0.0029409 0.0029725 0.0030039 0.0030353 0.0030666 0.0030978 0.003129 0.0031600 0.0031910 0.0032219 0.0032527'
    #[]
    
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
        temp = temp
        thermal_conductivity_temperature_function = '(1/(3.8+0.0217*t))'
        specific_heat = 0.33
    []
    [helium]
        type = HeatConductionMaterial
        block = 1
        temp = temp
        thermal_conductivity_temperature_function = 'if(t<600,0.0025,16e-6*(t^0.79))'
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