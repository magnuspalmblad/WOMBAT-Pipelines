process MZDB2MGF {
    label 'process_low'
    label 'process_single_thread'
    conda (params.enable_conda ? "conda-forge::python-3.8.3" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "docker://wombatp/proline-pipeline:dev"
    } else {
        container "wombatp/proline-pipeline:dev"
    }

  
  publishDir "${params.outdir}/mgf", mode:'copy'


  input:
  path mzdbfile
  
  output:
  path "${mzdbfile.baseName}.mgf" , emit: mgfs
  
  script:
  """
  mzdb2mgf -i "${mzdbfile}" -o "${mzdbfile.baseName}.mgf" 
  """
}

