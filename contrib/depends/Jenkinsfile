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
                                    uploadIfChanged(target)
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
                                    uploadIfChanged(target)
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
                                    uploadIfChanged(target)
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
                                    uploadIfChanged(target)
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

def uploadIfChanged(target) {
    withCredentials([sshUserPrivateKey(credentialsId: 'static-mrcyjanek-net-ssh-key', keyFileVariable: 'SSH_KEY', usernameVariable: 'SSH_USER')]) {
        sh """
            set -e
            upload_with_checksum() {
                local file_path="\$1"
                local remote_path="\$2"
                local filename=\$(basename "\$file_path")
                
                if [ ! -f "\$file_path" ]; then
                    echo "File \$file_path does not exist, skipping..."
                    return 0
                fi
                
                local_checksum=\$(sha256sum "\$file_path" | cut -d' ' -f1)
                echo "Local checksum for \$filename: \$local_checksum"
                
                remote_checksum=\$(ssh -i "\$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "\$SSH_USER@static.mrcyjanek.net" "cd \$remote_path && sha256sum \$filename 2>/dev/null | cut -d' ' -f1 || echo 'FILE_NOT_FOUND'")
                
                echo "Remote checksum for \$filename: \$remote_checksum"
                
                if [ "\$local_checksum" != "\$remote_checksum" ]; then
                    echo "Checksums differ, uploading \$filename..."
                    
                    ssh -i "\$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "\$SSH_USER@static.mrcyjanek.net" "mkdir -p \$remote_path"
                    
                    scp -i "\$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "\$file_path" "\$SSH_USER@static.mrcyjanek.net:\$remote_path/\$filename"
                    
                    uploaded_checksum=\$(ssh -i "\$SSH_KEY" -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null "\$SSH_USER@static.mrcyjanek.net" "cd \$remote_path && sha256sum \$filename | cut -d' ' -f1")
                    
                    if [ "\$local_checksum" = "\$uploaded_checksum" ]; then
                        echo "Upload successful for \$filename"
                    else
                        echo "Upload verification failed for \$filename"
                        exit 1
                    fi
                else
                    echo "Checksums match, skipping upload for \$filename"
                fi
            }
            
            echo "Processing target: ${target}"
            
            for package_dir in contrib/depends/built/${target}/*/; do
                if [ -d "\$package_dir" ]; then
                    package=\$(basename "\$package_dir")
                    echo "Processing package: \$package: \$(ls -la "\$package_dir")"
                    
                    for file in "\$package_dir"/*.tar.gz*; do
                        remote_dir_base="/home/mrcyjanek/web/static.mrcyjanek.net/public_html/lfs/depends/contrib/depends/built/${target}/\$package"
                        echo "Uploading \$file to \$remote_dir_base"
                        upload_with_checksum "\$file" "\$remote_dir_base"
                    done
                fi
            done
            
            echo "Finished processing ${target}"
        """
    }
} 