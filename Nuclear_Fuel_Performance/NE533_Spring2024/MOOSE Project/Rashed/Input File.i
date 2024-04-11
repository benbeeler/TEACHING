[Mesh]
    [total]
        type = GeneratedMeshGenerator
        dim = 2
        xmin = 0 
        xmax = .605
        ymin = 0 
        ymax = 100.
        nx = 500
        ny = 10
    []
    [clad]
        type = SubdomainBoundingBoxGenerator
        input = gap
        bottom_left = '0.505 0 0'
        top_right = '0.605 100. 0'
        block_id = '0'
    []
    [gap]
        type = SubdomainBoundingBoxGenerator
        input = fuel
        bottom_left = '0.5 0 0'
        top_right = '0.505 100. 0'
        block_id = '1' 
    []
    [fuel]
        type = SubdomainBoundingBoxGenerator
        input = total
        bottom_left = '0 0 0'
        top_right = '0.5 100. 0'
        block_id = '2'
    []
    coord_type = RZ
    rz_coord_axis = Y
[]

[Functions]
    [q]
        type = ParsedFunction
        expression = 'LHR0*cos(A*(y/Z0-1))/(pi/(2^2))'
        symbol_names = 'LHR0 Z0 A'
        symbol_values = '350 50 1.208305'
    []
#    [temp_profile]
#        type = ParsedFunction
#        expression = 'Tin+((1/1.2)*(Z0*LHR0/mdot*cpw)*(sin(1.2)+sin(1.2*((y/Z0)-1))))'
#        symbol_names = 'Tin Z0 LHR0 mdot cpw'
#        symbol_values = '500 50 350 0.25 4200'
#    []
[]

[Variables]
    [T]
    []
[]

[Kernels]
    [heat]
        type = HeatSource
        block = 2
        variable = T 
        function = q 
    []
    [conduction]
        type = HeatConduction
        variable = T 
    []
[]

[BCs]
    [left]
        type = NeumannBC
        variable = T 
        boundary = left
        value = 0 
    []
 #   [right]
 #       type = DirichletBC
 #       variable = T 
 #       boundary = right
 #       value = 500
 #   []
    [right]
        type = FunctionDirichletBC
        variable = T
        function = ((1/1.2083)*((50*350)/(.3*4200))*(sin(1.2083)+sin(1.2083*((y/50)-1))))+500
        boundary = right
    []
[]

[Materials]
    [fuel]
        type = HeatConductionMaterial
        thermal_conductivity = 0.33
        block = 2
    []
    [gap]
        type = HeatConductionMaterial
        thermal_conductivity = 0.0026
        block = 1
    []
    [clad]
        type = HeatConductionMaterial
        thermal_conductivity = 0.17
        block = 0
    []
[]

#[Problem]
#    type = FEProblem
#    coord_type = RZ
#    rz_coord_axis = Y
#[]

[Preconditioning]
    [smp]
        type = SMP
        full = true
    []
[]

[Executioner]
    type = Steady   
[]


[VectorPostprocessors]
    [TLine0]
        type = LineValueSampler
        variable = T 
        start_point = '0 25 0'
        end_point = '0.605 25 0'
        num_points = 100 
        sort_by = x 
    []

    [TLine1]
        type = LineValueSampler
        variable = T 
        start_point = '0 50 0'
        end_point = '0.605 50 0'
        num_points = 100
        sort_by = x
    []

    [TLine2]
        type = LineValueSampler
        variable = T 
        start_point = '0 100 0'
        end_point = '0.605 100 0'
        num_points = 100 
        sort_by = x 
    [] 

    [TLine3]
        type = LineValueSampler
        variable = T 
        start_point = '0 0 0'
        end_point = '0 100 0'
        num_points = 100 
        sort_by = y
    [] 

    [TLine4]
        type = LineValueSampler
        variable = T 
        start_point = '0.605 0 0'
        end_point = '0.605 100 0'
        num_points = 100 
        sort_by = y
    [] 
[]

[Outputs]
   exodus = true
   [csv]
    type = CSV
    execute_on = 'final'
   []
[]

