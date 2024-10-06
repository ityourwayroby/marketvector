import groovy.json.JsonSlurper
import groovy.json.JsonException

def pipelinesListFileName = 'pipelines_list.json'

try {
    // Read the pipelines list from JSON file
    def file = new File("${WORKSPACE}", pipelinesListFileName)
    
    if (!file.exists()) {
        throw new FileNotFoundException("JSON file '${pipelinesListFileName}' not found in workspace.")
    }

    def config = new JsonSlurper().parseText(file.text)

    // Check if the JSON has the required keys
    if (!config.containsKey('rbac-folders') || !(config['rbac-folders'] instanceof List)) {
        throw new IllegalArgumentException("Invalid JSON structure: 'rbac-folders' key is missing or not a list.")
    }

    // Loop through the folders
    config['rbac-folders'].each { folderName ->

        println "Creating RBAC folder: ${folderName}"
        folder(folderName) // Create the parent folder (e.g., devops, developers, etc.)

        // Create subfolders within each folder
        config.keySet().findAll { it.startsWith(folderName + "/") }.each { subfolderName ->
            println "Creating subfolder: ${subfolderName}"
            folder(subfolderName) // Create subfolders under parent

            // Loop through the projects in each subfolder and create pipelines
            config[subfolderName].each { project ->
                def pipelineName = project.name
                def repoUrl = project.repo
                def branch = project.branch
                def jenkinsfilePath = project.jenkinsfile
                def credentialsId = 'bitbucket_creds'

                // Validate project structure
                if (!pipelineName || !repoUrl || !branch || !jenkinsfilePath) {
                    throw new IllegalArgumentException("Project configuration missing required fields in folder '${subfolderName}'.")
                }

                // Create pipeline job inside the folder
                println "Creating pipeline job: ${subfolderName}/${pipelineName}"
                
                pipelineJob("${subfolderName}/${pipelineName}") {
                    definition {
                        cpsScm {
                            scm {
                                git {
                                    remote {
                                        url(repoUrl)
                                        credentials(credentialsId)
                                    }
                                    branches(branch)
                                    scriptPath(jenkinsfilePath)
                                }
                            }
                        }
                    }
                }
            }
        }
    }
} catch (JsonException e) {
    println "Error parsing JSON file: ${e.message}"
    currentBuild.result = 'FAILURE'
    throw e
} catch (FileNotFoundException e) {
    println "File error: ${e.message}"
    currentBuild.result = 'FAILURE'
    throw e
} catch (IllegalArgumentException e) {
    println "Configuration error: ${e.message}"
    currentBuild.result = 'FAILURE'
    throw e
} catch (Exception e) {
    println "Unexpected error: ${e.message}"
    currentBuild.result = 'FAILURE'
    throw e
}
