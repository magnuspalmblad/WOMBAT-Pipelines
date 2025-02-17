process CREATE_DECOY_DATABASE {
  label 'process_low'
  label 'process_single_thread'
    conda (params.enable_conda ? "bioconda::searchgui-4.0.41" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "docker://quay.io/biocontainers/searchgui:4.0.41--h779adbc_1"
    } else {
        container "quay.io/biocontainers/searchgui:4.0.41--h779adbc_1"
    }
  
  publishDir "${params.outdir}/decoy_database", mode:'copy'
  

  input:
  path fasta
  val run
  
  output:
  path "${fasta.baseName}_concatenated_target_decoy.fasta" , emit: fasta_with_decoy

  when:
  run

  
  script:
  """
  searchgui eu.isas.searchgui.cmd.FastaCLI -in ${fasta} -decoy
  """    
}    
