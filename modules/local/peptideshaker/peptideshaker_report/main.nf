process PEPTIDESHAKER_REPORT {
  label 'process_medium'
  label 'process_single_thread'
conda (params.enable_conda ? "bioconda::peptideshaker-2.2.6" : null)
if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "docker://quay.io/biocontainers/peptide-shaker:2.2.6--hec16e2b_1"
} else {
        container "quay.io/biocontainers/peptide-shaker:2.2.6--hec16e2b_1"
}
  
publishDir "${params.outdir}/peptideshaker", mode:'copy'
 
  input:
  path pepshaker
  
  output:
  path "${pepshaker.baseName}.txt", emit: peptideshaker_tsv_file
  path "${pepshaker.baseName}_peptides.txt", emit: peptideshaker_peptide_file
  path "${pepshaker.baseName}_proteins.txt", emit: peptideshaker_protein_file
  path "${pepshaker.baseName}_filtered.txt", emit: peptideshaker_tsv_file_filtered
  
  script:
  """
  peptide-shaker eu.isas.peptideshaker.cmd.PathSettingsCLI  -temp_folder ./tmp -log ./log
  peptide-shaker eu.isas.peptideshaker.cmd.ReportCLI -in "./${pepshaker}" -out_reports "./" -reports "3,4,6,9"
        mv "wombat_Default_PSM_Report_with_non-validated_matches.txt" "${pepshaker.baseName}.txt"
        mv "wombat_Default_PSM_Report.txt" "${pepshaker.baseName}_filtered.txt"
        mv "wombat_Default_Peptide_Report.txt" "${pepshaker.baseName}_peptides.txt"
        mv "wombat_Default_Protein_Report.txt" "${pepshaker.baseName}_proteins.txt"

  """    

}    
