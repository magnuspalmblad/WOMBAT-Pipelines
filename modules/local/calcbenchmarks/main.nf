import groovy.json.JsonOutput

  process CALCBENCHMARKS {
    label 'process_low'
    label 'process_single_thread'
    publishDir "${params.outdir}", mode:'copy'
    conda (params.enable_conda ? "conda-forge::notyetavailable" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "docker://wombatp/maxquant-pipeline:dev"
    } else {
        container "wombatp/maxquant-pipeline:dev"
    }


    input:
        val foo 
        path exp_design_file
        path std_prot_file
        path std_pep_file
        path fasta_file
        val workflow
 
  output:
//   path "params.json",   emit: parameters
   path "benchmarks*.json",  emit:  benchmarks
   path "stand_pep_quant_merged${workflow}.csv"    , emit: std_peps
   path "stand_prot_quant_merged${workflow}.csv"    , emit: std_prots
  
  script:
  """
  echo '$foo' > params.json
  cp "${fasta_file}" database.fasta
  if [[ "${exp_design_file}" != "exp_design.txt" ]]
  then
    cp "${exp_design_file}" exp_design.txt
  fi
  Rscript $baseDir/bin/CalcBenchmarks.R
  mv benchmarks.json benchmarks_${workflow}.json
  cp stand_pep_quant_merged.csv stand_pep_quant_merged${workflow}.csv
  cp stand_prot_quant_merged.csv stand_prot_quant_merged${workflow}.csv
  """
}


