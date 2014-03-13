Instructions: Performing Batch Analysis

1)	Copy all files from folder MatlabCode  to the Modelsim project file. Copy all files from Scripts folder to 
    Modelsim project file.
2)	In config.sv file make sure that `define METRICS_ENABLE and `define BATCH_ANALYSIS_ENABLE are N*O*T commented out.
3)	Open Modelsim, load the project and compile all files
4)	Type do batchAnalysis.do 
    This will run the simulation 10 times (15000ns each)
5)	Open Matlab and change set the project folder as the working folder
6)	Type batchAnalysis(10, PORTS), where 10 is the number of simulation runs, and PORTS is the number of PORTS as 
    defined in config.sv file

    
    
Instructions: Latency plot

1)	Comment out `define BATCH_ANALYSIS_ENABLE  O*N*L*Y from config.sv file. 
2)	Recompile all the files
3)	Type do metrics.do (this will run simulation 23 times till completion – this will take some time)
4)	Open Matlab
5)	Type latencyPlot(23, PORTS)
