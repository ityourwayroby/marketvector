import groovy.json.JsonSlurper

def pipelinesListFileName = 'pipelines_list.json'

// Read the pipelines list from JSON file
def config = new JsonSlurper().parseText(new File("${WORKSPACE}", pipelinesListFileName).text)

// Loop through the folders
config['rbac-folders'].each { folderName ->
    folder(folderName) // Create a folder for each RBAC group

    // Loop through the projects in each folder and create pipelines
    config[folderName].each { project ->
        def pipelineName = project.name
        def repoUrl = project.repo
        def branch = project.branch
        def jenkinsfilePath = project.jenkinsfile
        def credentialsId = 'github_creds'

        // Create pipeline job inside the folder
        pipelineJob("${folderName}/${pipelineName}") {
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
