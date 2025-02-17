process EXP_DESIGN_PROLINE {
  label 'process_low'
  label 'process_single_thread'
    conda (params.enable_conda ? "bioconda::proline_todo" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "docker://wombatp/proline-pipeline:v0.17"
    } else {
        container "wombatp/proline-pipeline:v0.17"
    }
  
  publishDir "${params.outdir}/proline", mode:'copy'
  

  input:
  val mzdbs
  path exp_design
  
  output:
  path "quant_exp_design.txt" , emit: exp_design

  
  script:
if (exp_design.getName() == "none") {
    // no file provided
    exp_design_text = "mzdb_file\texp_condition"
    for( int i=0; i<mzdb.size(); i++ ) {
      exp_design_text += "\n./${mzdb[i].baseName}.mzDB\tMain"
    }
    """
    touch quant_exp_design.txt    
    echo "${exp_design_text}" >> quant_exp_design.txt
    """
  } else {
    """
    cp ${exp_design} quant_exp_design.txt
    sed -i 's/raw_file/mzdb_file/g' quant_exp_design.txt
    sed -i 's/.raw/.mzDB/g' quant_exp_design.txt
    sed -i 's/.mzML/.mzDB/g' quant_exp_design.txt
    sed -i 's/.mzml/.mzDB/g' quant_exp_design.txt
    sed -i '2,\$s|^|./|' quant_exp_design.txt
    """
  }
}    
