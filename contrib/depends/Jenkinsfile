pipeline {
    agent none
    
    parameters {
        string(
            name: 'LINUX_TARGETS',
            defaultValue: 'x86_64-linux-gnu,aarch64-linux-gnu,i686-linux-gnu',
            description: 'Comma-separated list of Linux targets to build'
        )
        string(
            name: 'ANDROID_TARGETS',
            defaultValue: 'x86_64-linux-android,armv7a-linux-androideabi,aarch64-linux-android',
            description: 'Comma-separated list of Android targets to build'
        )
        string(
            name: 'MINGW_TARGETS',
            defaultValue: 'x86_64-w64-mingw32,i686-w64-mingw32',
            description: 'Comma-separated list of MinGW targets to build'
        )
        string(
            name: 'DARWIN_TARGETS', 
            defaultValue: 'aarch64-apple-darwin,x86_64-apple-darwin,aarch64-apple-ios,aarch64-apple-iossimulator',
            description: 'Comma-separated list of Darwin targets to build'
        )
    }
    
    stages {
        stage('Check Changes') {
            agent any
            steps {
                script {
                    def changes = sh(
                        script: "git diff --name-only HEAD~1 HEAD | grep '^contrib/depends' || echo 'NO_CHANGES'",
                        returnStdout: true
                    ).trim()
                    
                    if (changes == 'NO_CHANGES') {
                        echo "No changes detected in contrib/depends directory. Skipping build."
                        currentBuild.result = 'NOT_BUILT'
                        return
                    } else {
                        echo "Changes detected in contrib/depends directory:"
                        echo changes
                    }
                }
            }
        }
        
        stage('Build Dependencies') {
            when {
                not { 
                    equals expected: 'NOT_BUILT', actual: currentBuild.result 
                }
            }
            parallel {
                stage('Linux Builds') {
                    agent {
                        dockerfile {
                            filename '.devcontainer/Dockerfile'
                            args '-v /opt/builds:/opt/builds'
                            label 'linux && amd64'
                        }
                    }
                    steps {
                        script {
                            def targets = params.LINUX_TARGETS.split(',').collect { it.trim() }
                            
                            checkout scm
                            
                            for (target in targets) {
                                echo "Building Linux dependencies for ${target}"
                                
                                dir('contrib/depends') {
                                    sh "rm -rf built/${target}/*"
                                    sh "make HOST=${target} DEPENDS_UNTRUSTED_FAST_BUILDS=yes"
                                }
                            }
                        }
                    }
                    post {
                        always {
                            script {
                                def targets = params.LINUX_TARGETS.split(',').collect { it.trim() }
                                for (target in targets) {
                                    // archiveArtifacts artifacts: "contrib/depends/built/${target}/*/*.tar.gz*", allowEmptyArchive: true
                                    sshPublisher(publishers: [sshPublisherDesc(configName: 'static.mrcyjanek.net', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'depends', remoteDirectorySDF: false, sourceFiles: "contrib/depends/built/${target}/*/*.tar.gz*")], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                }
                            }
                        }
                    }
                }

                stage('Android Builds') {
                    agent {
                        dockerfile {
                            filename '.devcontainer/Dockerfile'
                            args '-v /opt/builds:/opt/builds'
                            label 'linux && amd64'
                        }
                    }
                    steps {
                        script {
                            def targets = params.ANDROID_TARGETS.split(',').collect { it.trim() }
                            
                            checkout scm
                            
                            for (target in targets) {
                                echo "Building Android dependencies for ${target}"
                                
                                dir('contrib/depends') {
                                    sh "rm -rf built/${target}/*"
                                    sh "make HOST=${target} DEPENDS_UNTRUSTED_FAST_BUILDS=yes"
                                }
                            }
                        }
                    }
                    post {
                        always {
                            script {
                                def targets = params.ANDROID_TARGETS.split(',').collect { it.trim() }
                                for (target in targets) {
                                    // archiveArtifacts artifacts: "contrib/depends/built/${target}/*/*.tar.gz*", allowEmptyArchive: true
                                    sshPublisher(publishers: [sshPublisherDesc(configName: 'static.mrcyjanek.net', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'depends', remoteDirectorySDF: false, sourceFiles: "contrib/depends/built/${target}/*/*.tar.gz*")], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                }
                            }
                        }
                    }
                }

                stage('MinGW Builds') {
                    agent {
                        dockerfile {
                            filename '.devcontainer/Dockerfile'
                            args '-v /opt/builds:/opt/builds'
                            label 'linux && amd64'
                        }
                    }
                    steps {
                        script {
                            def targets = params.MINGW_TARGETS.split(',').collect { it.trim() }
                            
                            checkout scm
                            
                            for (target in targets) {
                                echo "Building MinGW dependencies for ${target}"
                                
                                dir('contrib/depends') {
                                    sh "rm -rf built/${target}/*"
                                    sh "make HOST=${target} DEPENDS_UNTRUSTED_FAST_BUILDS=yes"
                                }
                            }
                        }
                    }
                    post {
                        always {
                            script {
                                def targets = params.MINGW_TARGETS.split(',').collect { it.trim() }
                                for (target in targets) {
                                    // archiveArtifacts artifacts: "contrib/depends/built/${target}/*/*.tar.gz*", allowEmptyArchive: true
                                    sshPublisher(publishers: [sshPublisherDesc(configName: 'static.mrcyjanek.net', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'depends', remoteDirectorySDF: false, sourceFiles: "contrib/depends/built/${target}/*/*.tar.gz*")], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                }
                            }
                        }
                    }
                }
                
                stage('Darwin Builds') {
                    agent {
                        label 'darwin && arm64'
                    }
                    steps {
                        script {
                            def targets = params.DARWIN_TARGETS.split(',').collect { it.trim() }
                            
                            checkout scm
                            
                            for (target in targets) {
                                echo "Building dependencies for ${target}"
                                
                                dir('contrib/depends') {
                                    sh "rm -rf built/${target}/*"
                                    sh "make HOST=${target} DEPENDS_UNTRUSTED_FAST_BUILDS=yes"
                                }
                            }
                        }
                    }
                    post {
                        always {
                            script {
                                def targets = params.DARWIN_TARGETS.split(',').collect { it.trim() }
                                for (target in targets) {
                                    // archiveArtifacts artifacts: "contrib/depends/built/${target}/*/*.tar.gz*", allowEmptyArchive: true
                                    sshPublisher(publishers: [sshPublisherDesc(configName: 'static.mrcyjanek.net', transfers: [sshTransfer(cleanRemote: false, excludes: '', execCommand: '', execTimeout: 120000, flatten: false, makeEmptyDirs: false, noDefaultExcludes: false, patternSeparator: '[, ]+', remoteDirectory: 'depends', remoteDirectorySDF: false, sourceFiles: "contrib/depends/built/${target}/*/*.tar.gz*")], usePromotionTimestamp: false, useWorkspaceInPromotion: false, verbose: false)])
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    post {
        always {
            echo "Build completed."
        }
    }
} 