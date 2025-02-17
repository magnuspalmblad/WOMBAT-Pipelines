process PREPARE_SEARCHGUI {
  label 'process_low'
  label 'process_single_thread'
    conda (params.enable_conda ? "bioconda::searchgui-4.0.41" : null)
    if (workflow.containerEngine == 'singularity' && !params.singularity_pull_docker_container) {
        container "docker://quay.io/biocontainers/searchgui:4.0.41--h779adbc_1"
    } else {
        container "quay.io/biocontainers/searchgui:4.0.41--h779adbc_1"
    }
  publishDir "${params.outdir}/searchgui_params", mode:'copy'
  
  input:
  val parameters
  val ptm_mapping
  
  output:
  path "searchgui.par", emit: searchgui_param
  
  script:
  fragments = parameters.fragment_mass_tolerance.split(' ')
  frag_tol = fragments[0]
  frag_ppm = fragments[1] == "ppm" ? 1 : 0
  precursor = parameters.precursor_mass_tolerance.split(' ')
  prec_tol = precursor[0]
  prec_ppm = precursor[1] == "ppm" ? 1 : 0
  // mapping to searchgui enzyme names
  def enzyme_map = [
    "Trypsin": "Trypsin",
    "Trypsin/P": "Trypsin (no P rule)",
    "Chymotrypsin": "Chymotrypsin",
    "Chymotrypsin/P": "Chymotrypsin (no P rule)",
    "Lys-C": "Lys-C",
    "Lys-C/P": "Lys-C (no P rule)",
    "Lys-N": "Lys-N",
    "Arg-C": "Arg-C",
    "Arg_N": "Arg-N",
    "Arg-C/P": "Arg-C (no P rule)",
    "Asp-N": "Asp-N",
    "Asp-N_ambic": "Asp-N (ambic)",
    "Glu-C": "Glu-C",
    "Glu-C/P": "Glu-C/P",
    "CNBr": "CNBr",
    "LysargiNase": "LysargiNase",
    "PepsinA": "Pepsin A",
    "Thermolysin": "Thermolysin",
  ]
  def enzyme = enzyme_map[parameters["enzyme"]]
  // converting to searchgui format
  def ptm_mapping2 = ptm_mapping.sum()
  def var_mods = parameters["variable_mods"].replaceAll("Protein","protein")
  var_mods = var_mods.replaceAll("Peptide","peptide")
  var_mods = var_mods.split(",").collect { mod -> ptm_mapping2[mod] }.join(",")
  if(var_mods != "null") {
    var_mods = "-variable_mods \"" + var_mods + "\""
  } else {
    var_mods = ""
  }
  def fixed_mods = parameters["fixed_mods"].replaceAll("Protein","protein")
  fixed_mods = fixed_mods.replaceAll("Peptide","peptide")
  fixed_mods = fixed_mods.split(",").collect { mod -> ptm_mapping2[mod] }.join(",")
  if(fixed_mods != "null") {
    fixed_mods = "-fixed_mods \"" + fixed_mods + "\""
  } else {
    fixed_mods = ""
  }

  """
  mkdir tmp
  mkdir log
  touch /usr/local/share/searchgui-4.0.41-1/resources/conf/paths.txt
  searchgui eu.isas.searchgui.cmd.PathSettingsCLI -temp_folder ./tmp -log ./log
  searchgui eu.isas.searchgui.cmd.IdentificationParametersCLI -out searchgui \\
    -frag_tol ${frag_tol} -frag_ppm ${frag_ppm} -prec_tol ${prec_tol} -prec_ppm ${prec_ppm} -enzyme "${enzyme}" -mc ${parameters["allowed_miscleavages"]} \\
    -max_isotope ${parameters["isotope_error_range"]} \\
    ${fixed_mods} ${var_mods}\\
    -fi "${parameters["fions"]}" -ri "${parameters["rions"]}" -xtandem_quick_acetyl 0 -xtandem_quick_pyro 0 -peptide_fdr ${parameters["ident_fdr_peptide"]}\\
    -protein_fdr ${parameters["ident_fdr_protein"]} -psm_fdr ${parameters["ident_fdr_psm"]} \\
    -myrimatch_num_ptms ${parameters["max_mods"]} -ms_amanda_max_mod ${parameters["max_mods"]} -msgf_num_ptms ${parameters["max_mods"]} -meta_morpheus_max_mods_for_peptide\\
    ${parameters["max_mods"]} -directag_max_var_mods ${parameters["max_mods"]} -comet_num_ptms ${parameters["max_mods"]} \\#-tide_max_ptms ${parameters["max_mods"]}  \\
    -myrimatch_min_pep_length ${parameters["min_peptide_length"]} -myrimatch_max_pep_length ${parameters["max_peptide_length"]} -ms_amanda_min_pep_length ${parameters["min_peptide_length"]} \\
    -ms_amanda_max_pep_length ${parameters["max_peptide_length"]} -msgf_min_pep_length ${parameters["min_peptide_length"]} -msgf_max_pep_length ${parameters["max_peptide_length"]} \\
    -omssa_min_pep_length ${parameters["min_peptide_length"]} -omssa_max_pep_length ${parameters["max_peptide_length"]} -comet_min_pep_length ${parameters["min_peptide_length"]} \\
    -comet_max_pep_length ${parameters["max_peptide_length"]} -tide_min_pep_length ${parameters["min_peptide_length"]} -tide_max_pep_length ${parameters["max_peptide_length"]} \\
    -andromeda_min_pep_length ${parameters["min_peptide_length"]} -andromeda_max_pep_length ${parameters["max_peptide_length"]} -meta_morpheus_min_pep_length ${parameters["min_peptide_length"]} \\
    -meta_morpheus_max_pep_length ${parameters["max_peptide_length"]} -max_charge ${parameters.max_precursor_charge} -min_charge ${parameters.min_precursor_charge}
  """    
}
  
