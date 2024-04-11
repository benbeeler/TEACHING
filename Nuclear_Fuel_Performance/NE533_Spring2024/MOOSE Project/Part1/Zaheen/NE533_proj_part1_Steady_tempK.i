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
        top_right = '0.5050 1.000 0'
    []
    [fuel]
        input = fuelandgap
        type = SubdomainBoundingBoxGenerator
        block_id = 2
        bottom_left = '0 0 0'
        top_right = '0.5000 1.000 0'
    []
    coord_type = RZ
    
[]
  
[Variables]
    [temp]
      
    []
[]
  
[Functions]
    #[therm]
        #type = ParsedFunction
        #expression = 16e-6*(tem^0.79)
        #symbol_names = tem
        #symbol_values = temp

    #[]
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
      value = 445.6338407
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
        #min_T = 615
        thermal_conductivity_temperature_function = 'if(t<600,0.0025,16e-6*(t^0.79))'
        specific_heat = 5.188
    []
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